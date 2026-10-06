import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

const keyId = process.env.ASC_KEY_ID;
const issuerId = process.env.ASC_ISSUER_ID;
const keyPath = process.env.ASC_KEY_PATH;

if (!keyId || !issuerId || !keyPath) {
  throw new Error('Set ASC_KEY_ID, ASC_ISSUER_ID, and ASC_KEY_PATH.');
}

const cwd = process.cwd();
const keyText = await fs.readFile(keyPath, 'utf8');
const privateKey = keyText.includes('BEGIN PRIVATE KEY') ? keyText : Buffer.from(keyText.trim(), 'base64').toString('utf8');

function b64url(input) {
  return Buffer.from(input)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

function makeToken() {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'ES256', kid: keyId, typ: 'JWT' };
  const payload = { iss: issuerId, iat: now, exp: now + 1200, aud: 'appstoreconnect-v1' };
  const data = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(payload))}`;
  const signature = crypto
    .createSign('SHA256')
    .update(data)
    .end()
    .sign({ key: privateKey, dsaEncoding: 'ieee-p1363' });
  return `${data}.${b64url(signature)}`;
}

async function api(pathname, options = {}) {
  const res = await fetch(`https://api.appstoreconnect.apple.com${pathname}`, {
    ...options,
    headers: {
      Authorization: `Bearer ${makeToken()}`,
      'Content-Type': 'application/json',
      ...(options.headers ?? {})
    }
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`${options.method ?? 'GET'} ${pathname} failed: ${res.status} ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

async function uploadScreenshot(setId, filePath, fileName) {
  const bytes = await fs.readFile(filePath);
  const reservation = await api('/v1/appScreenshots', {
    method: 'POST',
    body: JSON.stringify({
      data: {
        type: 'appScreenshots',
        attributes: {
          fileSize: bytes.length,
          fileName
        },
        relationships: {
          appScreenshotSet: {
            data: {
              type: 'appScreenshotSets',
              id: setId
            }
          }
        }
      }
    })
  });

  const screenshotId = reservation.data.id;
  const uploadOperations = reservation.data.attributes.uploadOperations ?? [];
  for (const operation of uploadOperations) {
    const chunk = bytes.subarray(operation.offset, operation.offset + operation.length);
    const headers = {};
    for (const header of operation.requestHeaders ?? []) {
      headers[header.name] = header.value;
    }
    const uploadRes = await fetch(operation.url, {
      method: operation.method,
      headers,
      body: chunk
    });
    if (!uploadRes.ok) {
      const uploadText = await uploadRes.text();
      throw new Error(`Upload failed for ${fileName}: ${uploadRes.status} ${uploadText}`);
    }
  }

  const checksum = crypto.createHash('md5').update(bytes).digest('hex');
  await api(`/v1/appScreenshots/${screenshotId}`, {
    method: 'PATCH',
    body: JSON.stringify({
      data: {
        type: 'appScreenshots',
        id: screenshotId,
        attributes: {
          uploaded: true,
          sourceFileChecksum: checksum
        }
      }
    })
  });

  return screenshotId;
}

async function listScreenshots(setId) {
  const response = await api(`/v1/appScreenshotSets/${setId}/appScreenshots?limit=50`);
  return response.data.map((item) => ({
    id: item.id,
    fileName: item.attributes.fileName,
    state: item.attributes.assetDeliveryState?.state ?? 'UNKNOWN'
  }));
}

async function reorderScreenshots(setId, screenshotIds) {
  await api(`/v1/appScreenshotSets/${setId}/relationships/appScreenshots`, {
    method: 'PATCH',
    body: JSON.stringify({
      data: screenshotIds.map((id) => ({ type: 'appScreenshots', id }))
    })
  });
}

const apply = process.argv.includes('--apply');
const assetRoot = path.join(cwd,'AppStoreAssets','Screenshots','Optimized-1.0.2');
const manifest = JSON.parse((await fs.readFile(path.join(assetRoot,'manifest.json'),'utf8')).replace(/^\uFEFF/,''));
const aliases={bn:'bn-BD',gu:'gu-IN',kn:'kn-IN',ml:'ml-IN',mr:'mr-IN',or:'or-IN',pa:'pa-IN',sl:'sl-SI',ta:'ta-IN',te:'te-IN',ur:'ur-PK'};
const targets = new Map();
for (const item of manifest) {
  const locale=aliases[item.locale]??item.locale;
  if(process.env.SCREENSHOT_LOCALES&&!process.env.SCREENSHOT_LOCALES.split(',').includes(locale))continue;
  const key=`${locale}/${item.displayType}`;
  if(!targets.has(key))targets.set(key,{locale,displayType:item.displayType,files:[]});
  targets.get(key).files.push(item);
  const bytes=await fs.readFile(item.path);
  if(bytes.subarray(1,4).toString()!=='PNG'||bytes.readUInt32BE(16)!==item.width||bytes.readUInt32BE(20)!==item.height||bytes[25]!==2)throw new Error(`Invalid RGB dimensions: ${item.path}`);
  if(crypto.createHash('sha256').update(bytes).digest('hex')!==item.sha256)throw new Error(`Manifest checksum mismatch: ${item.path}`);
}
const versions=await api('/v1/apps/6767889535/appStoreVersions?filter[versionString]=1.0.2&limit=20');
const selected=versions.data.find(x=>x.attributes.platform==='IOS');
if(!selected||selected.attributes.appStoreState!=='PREPARE_FOR_SUBMISSION')throw new Error('Expected editable 1.0.2 draft');
const locs=(await api(`/v1/appStoreVersions/${selected.id}/appStoreVersionLocalizations?limit=200`)).data;
const localeMap=new Map(locs.map(x=>[x.attributes.locale,x.id]));
const backupDir=path.join(assetRoot,'remote-backups');
await fs.mkdir(backupDir,{recursive:true});
const report=[];
const reportPath=path.join(assetRoot,apply?'upload-report.json':'verification.json');
const queue=[...targets.values()];
async function deleteAsset(asset) {await api(`/v1/appScreenshots/${asset.id}`,{method:'DELETE'});}
async function waitForAssets(setId,ids) {
  for(let attempt=0;attempt<30;attempt++) {
    const shots=await listScreenshots(setId);
    const selected=shots.filter(x=>ids.includes(x.id));
    if(selected.some(x=>x.state==='FAILED'))throw new Error('Apple screenshot processing failed');
    if(selected.length===ids.length&&selected.every(x=>x.state==='COMPLETE'))return;
    await new Promise(resolve=>setTimeout(resolve,3000));
  }
  throw new Error('Apple processing still pending; safe to rerun');
}
async function handle(target) {
  const localizationId=localeMap.get(target.locale);
  if(!localizationId)throw new Error(`Missing existing locale ${target.locale}`);
  const sets=(await api(`/v1/appStoreVersionLocalizations/${localizationId}/appScreenshotSets?limit=50`)).data;
  let set=sets.find(x=>x.attributes.screenshotDisplayType===target.displayType);
  if(!set&&apply)set=(await api('/v1/appScreenshotSets',{method:'POST',body:JSON.stringify({data:{type:'appScreenshotSets',attributes:{screenshotDisplayType:target.displayType},relationships:{appStoreVersionLocalization:{data:{type:'appStoreVersionLocalizations',id:localizationId}}}}})})).data;
  if(!set)return {...target,files:undefined,count:0,status:'missing'};
  let existing=await listScreenshots(set.id);
  const desired=new Set(target.files.map(x=>x.fileName));
  if(apply) {
    const backupPath=path.join(backupDir,`${target.locale}-${target.displayType}.json`);
    try {await fs.writeFile(backupPath,JSON.stringify({capturedAt:new Date().toISOString(),versionId:selected.id,setId:set.id,originalAssets:existing},null,2),{flag:'wx'});}catch(e){if(e.code!=='EEXIST')throw e;}
    // Keep old assets until at least one new native composition has processed.
    for(const failed of existing.filter(x=>desired.has(x.fileName)&&x.state==='FAILED'))await deleteAsset(failed);
    existing=existing.filter(x=>!(desired.has(x.fileName)&&x.state==='FAILED'));
    if(existing.some(x=>!desired.has(x.fileName))&&!existing.some(x=>desired.has(x.fileName)&&x.state==='COMPLETE')) {
      let anchor=existing.find(x=>desired.has(x.fileName));
      if(!anchor) {
        if(existing.length===10) {
          const old=existing.findLast(x=>!desired.has(x.fileName));
          if(!old)throw new Error('No replaceable legacy slot');
          await deleteAsset(old); existing=existing.filter(x=>x.id!==old.id);
        }
        const file=target.files[0];
        anchor={id:await uploadScreenshot(set.id,file.path,file.fileName),fileName:file.fileName};
      }
      await waitForAssets(set.id,[anchor.id]);
      existing=await listScreenshots(set.id);
    }
    for(const old of existing.filter(x=>!desired.has(x.fileName)))await deleteAsset(old);
    existing=await listScreenshots(set.id);
    const missing=target.files.filter(x=>!existing.some(a=>a.fileName===x.fileName));
    for(let i=0;i<missing.length;i+=2) {
      await Promise.all(missing.slice(i,i+2).map(async file=>({id:await uploadScreenshot(set.id,file.path,file.fileName)})));
    }
    existing=await listScreenshots(set.id);
    const ordered=target.files.map(file=>{
      const matches=existing.filter(x=>x.fileName===file.fileName);
      if(matches.length!==1)throw new Error(`Unexpected duplicate/missing optimized asset ${file.fileName}`);
      return matches[0].id;
    });
    await reorderScreenshots(set.id,ordered);
    existing=await listScreenshots(set.id);
  }
  const orderedCorrect=existing.length===target.files.length&&existing.every((shot,i)=>shot.fileName===target.files[i].fileName);
  return {locale:target.locale,displayType:target.displayType,setId:set.id,count:existing.length,expected:target.files.length,status:orderedCorrect&&existing.every(x=>x.state==='COMPLETE')?'complete':'processing',screenshots:existing};
}
async function worker(){while(queue.length){const target=queue.shift();try{const entry=await handle(target);report.push(entry);console.log(`${entry.locale} ${entry.displayType}: ${entry.count}/${entry.expected} ${entry.status}`);}catch(e){report.push({locale:target.locale,displayType:target.displayType,status:'error',error:e.message});console.error(`${target.locale} ${target.displayType}: ${e.message}`);}}}
const workerCount = apply ? 3 : 8;
await Promise.all(Array.from({length:workerCount},()=>worker()));
const summary={versionId:selected.id,checkedAt:new Date().toISOString(),readOnly:!apply,totalSets:report.length,completeSets:report.filter(x=>x.status==='complete').length,errors:report.filter(x=>x.status==='error').length,sets:report};
await fs.writeFile(reportPath,JSON.stringify(summary,null,2));
console.log(JSON.stringify({totalSets:summary.totalSets,completeSets:summary.completeSets,errors:summary.errors,reportPath}));
if(summary.errors)process.exitCode=1;
