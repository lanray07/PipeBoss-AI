import fs from 'node:fs/promises';
import crypto from 'node:crypto';

const appId = '6767889535';
const templateId = 'fe8bb46d-7337-47c4-8fb1-d224ddce21f1';
const out = 'AppStoreAssets/CustomProductPages';
await fs.mkdir(out, { recursive: true });
const privateKey = Buffer.from(process.env.APP_STORE_CONNECT_API_KEY_BASE64 ?? '', 'base64').toString();
if (!privateKey.includes('PRIVATE KEY')) throw new Error('Existing Apple API secret is required');
function token() {
  const now = Math.floor(Date.now()/1000);
  const data = [{alg:'ES256',kid:process.env.APP_STORE_CONNECT_API_KEY_ID,typ:'JWT'},
    {iss:process.env.APP_STORE_CONNECT_API_ISSUER_ID,iat:now,exp:now+1200,aud:'appstoreconnect-v1'}]
    .map(x=>Buffer.from(JSON.stringify(x)).toString('base64url')).join('.');
  return `${data}.${crypto.sign('sha256',Buffer.from(data),{key:privateKey,dsaEncoding:'ieee-p1363'}).toString('base64url')}`;
}
async function api(url, method='GET', body) {
  if (!/^\/v1\/(apps|appStoreVersions|appStoreVersionLocalizations|appCustomProductPages|appCustomProductPageVersions|appCustomProductPageLocalizations|appScreenshotSets|appScreenshots|appAssetLibraries|appAssetLibraryImages|appAssetLibraryPlacements)(\/|\?|$)/.test(url)) throw new Error('Endpoint outside product-page scope');
  if (/reviewSubmissions|appStoreVersionSubmissions|pricing|appStoreVersionReleaseRequests/i.test(url)) throw new Error('Publication is outside this workflow');
  const res=await fetch(`https://api.appstoreconnect.apple.com${url}`,{method,headers:{Authorization:`Bearer ${token()}`,'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined});
  const text=await res.text();
  if(!res.ok){let errors;try{errors=JSON.parse(text).errors?.map(({status,code,title,detail})=>({status,code,title,detail}));}catch{} throw new Error(`${method} ${url}: ${res.status} ${JSON.stringify(errors)}`);}
  return text?JSON.parse(text):null;
}
async function list(url) {
  const rows=[];
  do {const r=await api(url);rows.push(...r.data);url=r.links?.next?.replace('https://api.appstoreconnect.apple.com','');} while(url);
  return rows;
}
const pages=await list(`/v1/apps/${appId}/appCustomProductPages?limit=200`);
const versions=await list(`/v1/apps/${appId}/appStoreVersions?limit=20`);
const draft=versions.find(x=>x.id===templateId);
if(draft?.attributes.appStoreState!=='PREPARE_FOR_SUBMISSION')throw new Error('Expected editable 1.0.2 template');
const sourceLocales=await list(`/v1/appStoreVersions/${templateId}/appStoreVersionLocalizations?limit=200`);
const inventory={pages:[],sourceLocaleCount:sourceLocales.length,sourceVersionId:templateId};
for(const page of pages){
 const vv=await list(`/v1/appCustomProductPages/${page.id}/appCustomProductPageVersions?limit=50`);
 const entry={id:page.id,...page.attributes,versions:[]};
 for(const v of vv){
  const locs=await list(`/v1/appCustomProductPageVersions/${v.id}/appCustomProductPageLocalizations?limit=200`);
  const ve={id:v.id,...v.attributes,localizations:[]};
  for(const loc of locs){
   const keywords=await api(`/v1/appCustomProductPageLocalizations/${loc.id}/searchKeywords`);
   const sets=await list(`/v1/appCustomProductPageLocalizations/${loc.id}/appScreenshotSets?limit=50`);
   ve.localizations.push({id:loc.id,...loc.attributes,keywords:keywords.data,sets:sets.map(x=>({id:x.id,...x.attributes}))});
  }
  entry.versions.push(ve);
 }
 inventory.pages.push(entry);
}
const first=sourceLocales.find(x=>x.attributes.locale==='en-GB');
try {const placements=await api(`/v1/appStoreVersionLocalizations/${first.id}/placements?include=image&limit=200`);inventory.sourcePlacements=placements;} catch(e){inventory.sourcePlacementsError=e.message;}
await fs.writeFile(`${out}/inventory.json`,JSON.stringify(inventory,null,2));
console.log(JSON.stringify({pageCount:pages.length,sourceLocaleCount:sourceLocales.length,pages:inventory.pages.map(x=>({id:x.id,name:x.name,versions:x.versions.map(v=>({id:v.id,state:v.state,locales:v.localizations.length,keywords:v.localizations[0]?.keywords,sets:v.localizations[0]?.sets}))})),placementCount:inventory.sourcePlacements?.data?.length,placementError:inventory.sourcePlacementsError}));
