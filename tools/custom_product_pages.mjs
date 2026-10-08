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
  if (!/^\/v1\/(apps|appStoreVersions|appStoreVersionLocalizations|appCustomProductPages|appCustomProductPageVersions|appCustomProductPageLocalizations|appScreenshotSets|appScreenshots|appAssetLibraries|appAssetLibraryImages|appAssetLibraryPlacements|appAssetLibraryPlacementOrderingRequests)(\/|\?|$)/.test(url)) throw new Error('Endpoint outside product-page scope');
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

if (process.env.CPP_APPLY !== 'true') process.exit(0);
const captions=JSON.parse((await fs.readFile('tools/duo-captions.json','utf8')).replace(/^\uFEFF/,''));
const aliases={bn:'bn-BD',gu:'gu-IN',kn:'kn-IN',ml:'ml-IN',mr:'mr-IN',or:'or-IN',pa:'pa-IN',sl:'sl-SI',ta:'ta-IN',te:'te-IN',ur:'ur-PK'};
const captionMap=new Map(Object.entries(captions).map(([locale,copy])=>[aliases[locale]??locale,copy]));
const specs=[
 {name:'Apprentice Plumbing Training',lead:0,order:[1,2,4],keywords:['apprentice','trade','training','quiz'],en:'Practise plumbing with 10 beginner jobs. Build apprentice skills in fault diagnosis, tool selection and repair decisions. Educational simulation; app in English.'},
 {name:'Plumbing Fault Diagnosis',lead:1,order:[2,4,3],keywords:['plumbing','plumber','drain','DIY'],en:'Practise diagnosing leaks, blocked drains and water pressure faults. Choose a repair and learn from feedback. Educational simulation; app in English.'},
 {name:'Plumbing Tools and Heating',lead:2,order:[3,2,4],keywords:['tools','pipe','heating','boiler'],en:'Learn plumbing tool selection for pipe, drain and heating scenarios. Diagnose faults and build your virtual kit. Educational simulation; app in English.'}
];
const approved=versions.find(x=>x.attributes.appStoreState==='READY_FOR_SALE'||x.attributes.appStoreState==='READY_FOR_DISTRIBUTION');
const approvedLocales=approved?await list(`/v1/appStoreVersions/${approved.id}/appStoreVersionLocalizations?limit=200`):[];
const approvedKeywords=new Map(approvedLocales.map(x=>[x.attributes.locale,x.attributes.keywords.split(',').map(s=>s.trim())]));
const selection=process.env.CPP_LOCALES?.split(',');
const targets=sourceLocales.filter(x=>!selection||selection.includes(x.attributes.locale));
const report={createdAt:new Date().toISOString(),draftOnly:true,sourceVersionId:templateId,expectedLocaleCount:targets.length,machineTranslatedCaptions:true,appInterface:'English',pages:[],errors:[]};
const sourceCache=new Map();
const relation=(type,id)=>({data:{type,id}});
function promo(spec,locale){
 if(locale.startsWith('en-'))return spec.en;
 const c=captionMap.get(locale);if(!c)throw new Error(`Missing captions ${locale}`);
 for(const text of [`${c.shots[spec.lead].title}. ${c.shots[spec.lead].subtitle} ${c.footer}`,`${c.shots[spec.lead].subtitle} ${c.footer}`,`${c.shots[spec.lead].title}. ${c.footer}`])if([...text].length<=170)return text;
 throw new Error(`Cannot fit localized promo ${locale}`);
}
async function sourceAssets(loc){
 if(!sourceCache.has(loc.id))sourceCache.set(loc.id,(async()=>{
  const r=await api(`/v1/appStoreVersionLocalizations/${loc.id}/placements?include=image&sort=placementGroupPosition&limit=200`);
  const images=new Map((r.included??[]).map(x=>[x.id,x]));
  return r.data.map(p=>({...p,image:images.get(p.relationships.image?.data?.id)}));
 })());
 return sourceCache.get(loc.id);
}
for(const spec of specs){
 let page=pages.find(x=>x.attributes.name===spec.name);
 if(!page){page=(await api('/v1/appCustomProductPages','POST',{data:{type:'appCustomProductPages',attributes:{name:spec.name},relationships:{app:relation('apps',appId),appStoreVersionTemplate:relation('appStoreVersions',templateId)}}})).data;pages.push(page);}
 let vv=await list(`/v1/appCustomProductPages/${page.id}/appCustomProductPageVersions?limit=50`);
 let v=vv.find(x=>x.attributes.state==='PREPARE_FOR_SUBMISSION');
 if(!v){if(vv.length)throw new Error('Refusing to edit a submitted page');v=(await api('/v1/appCustomProductPageVersions','POST',{data:{type:'appCustomProductPageVersions',relationships:{appCustomProductPage:relation('appCustomProductPages',page.id)}}})).data;}
 const locs=await list(`/v1/appCustomProductPageVersions/${v.id}/appCustomProductPageLocalizations?limit=200`);
 const pageReport={name:spec.name,id:page.id,versionId:v.id,url:page.attributes.url,state:v.attributes.state,localizations:[]};report.pages.push(pageReport);
 for(const source of targets){
  const locale=source.attributes.locale;
  try{
   const text=promo(spec,locale);
   let loc=locs.find(x=>x.attributes.locale===locale);
   if(!loc){loc=(await api('/v1/appCustomProductPageLocalizations','POST',{data:{type:'appCustomProductPageLocalizations',attributes:{locale,promotionalText:text},relationships:{appCustomProductPageVersion:relation('appCustomProductPageVersions',v.id)}}})).data;locs.push(loc);}
   else if(loc.attributes.promotionalText!==text)await api(`/v1/appCustomProductPageLocalizations/${loc.id}`,'PATCH',{data:{type:'appCustomProductPageLocalizations',id:loc.id,attributes:{promotionalText:text}}});
   const sourceRows=await sourceAssets(source);
   const desired=sourceRows.filter(p=>p.attributes.placementType==='PRODUCT_PAGE_HEADER_ASSET'||(p.attributes.placementType==='APP_SCREENSHOT'&&spec.order.includes(Number(p.image?.attributes.fileName.slice(0,2)))));
   const groups=new Map();
   for(const row of desired){const key=row.attributes.placementGroup;if(!groups.has(key))groups.set(key,[]);groups.get(key).push(row);}
   const shotGroups=[...groups.values()].filter(rows=>rows[0].attributes.placementType==='APP_SCREENSHOT');
   if(shotGroups.length!==4||shotGroups.some(rows=>rows.length!==(rows[0].attributes.placementGroup==='IPHONE_DUO_PROFILE'?6:3)))throw new Error('Source localized screenshot coverage is incomplete');
   let current=(await api(`/v1/appCustomProductPageLocalizations/${loc.id}/placements?include=image&sort=placementGroupPosition&limit=200`)).data;
   // Delete only extra placements on this explicitly created draft; preserve every library image and default-page placement.
   for(const old of current){if(!desired.some(row=>row.relationships.image?.data?.id===old.relationships.image?.data?.id&&row.attributes.placementGroup===old.attributes.placementGroup))await api(`/v1/appAssetLibraryPlacements/${old.id}`,'DELETE');}
   current=current.filter(old=>desired.some(row=>row.relationships.image?.data?.id===old.relationships.image?.data?.id&&row.attributes.placementGroup===old.attributes.placementGroup));
   for(const [group,rows] of groups){
    rows.sort((a,b)=>spec.order.indexOf(Number(a.image.attributes.fileName.slice(0,2)))-spec.order.indexOf(Number(b.image.attributes.fileName.slice(0,2)))||a.image.attributes.fileName.localeCompare(b.image.attributes.fileName));
    const ordered=[];
    for(const row of rows){
     let placement=current.find(x=>x.relationships.image?.data?.id===row.relationships.image.data.id&&x.attributes.placementGroup===group);
     if(!placement){placement=(await api('/v1/appAssetLibraryPlacements','POST',{data:{type:'appAssetLibraryPlacements',attributes:{placementType:row.attributes.placementType,placementGroup:group},relationships:{image:row.relationships.image,appCustomProductPageLocalization:relation('appCustomProductPageLocalizations',loc.id)}}})).data;current.push(placement);}
     ordered.push({type:'appAssetLibraryPlacements',id:placement.id});
    }
    if(rows[0].attributes.placementType==='APP_SCREENSHOT')await api('/v1/appAssetLibraryPlacementOrderingRequests','POST',{data:{type:'appAssetLibraryPlacementOrderingRequests',attributes:{placementGroup:group},relationships:{orderedPlacements:{data:ordered},appCustomProductPageLocalization:relation('appCustomProductPageLocalizations',loc.id)}}});
   }
   const eligible=approvedKeywords.get(locale)??[];
   const keywords=spec.keywords.filter(k=>eligible.some(x=>x.toLowerCase()===k.toLowerCase()));
   if(keywords.length)await api(`/v1/appCustomProductPageLocalizations/${loc.id}/relationships/searchKeywords`,'POST',{data:keywords.map(id=>({type:'appKeywords',id}))});
   const verified=await api(`/v1/appCustomProductPageLocalizations/${loc.id}/placements?include=image&sort=placementGroupPosition&limit=200`);
   for(const [group,rows] of groups){
    const actual=verified.data.filter(x=>x.attributes.placementGroup===group);
    if(actual.length!==rows.length||actual.some((x,i)=>x.relationships.image?.data?.id!==rows[i].relationships.image.data.id||x.attributes.stateDetails))throw new Error(`Placement verification failed ${group}`);
   }
   pageReport.localizations.push({locale,id:loc.id,promotionalText:text,keywords,keywordStatus:keywords.length?'assigned':'no-matching-keywords-in-approved-localization',screenshotCount:desired.filter(x=>x.attributes.placementType==='APP_SCREENSHOT').length,headerCount:desired.filter(x=>x.attributes.placementType==='PRODUCT_PAGE_HEADER_ASSET').length,verified:true});
   console.log(`${spec.name}: ${locale} verified`);
  }catch(e){report.errors.push({page:spec.name,locale,error:e.message});console.error(`${spec.name} ${locale}: ${e.message}`);}
  await fs.writeFile(`${out}/report.json`,JSON.stringify(report,null,2));
 }
}
console.log(JSON.stringify({pages:report.pages.length,verifiedLocales:report.pages.reduce((n,p)=>n+p.localizations.length,0),errors:report.errors.length,draftOnly:true}));
if(report.errors.length)process.exitCode=1;
