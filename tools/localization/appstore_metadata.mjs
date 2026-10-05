import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const source = new URL('../../AppStoreAssets/Metadata/localizations.json', import.meta.url);
export function metadataPlan(content) {
  const plan = [];
  for (const [locale, item] of Object.entries(content.localizations)) {
    if (typeof item.releaseReady !== 'boolean') throw new Error(`${locale}: releaseReady must be a boolean`);
    if (item.releaseReady !== true) continue;
    for (const [field, limit] of Object.entries({ name: 30, subtitle: 30, promotionalText: 170, description: 4000 })) {
      if (typeof item[field] !== 'string' || [...item[field]].length > limit) throw new Error(`${locale}: invalid ${field}`);
    }
    if (Buffer.byteLength(item.keywords) > 100) throw new Error(`${locale}: keywords exceed 100 bytes`);
    if (!item.description.includes(content.termsOfUseURL)) throw new Error(`${locale}: Terms of Use link missing`);
    if (!content.privacyPolicyURL.startsWith('https://')) throw new Error('HTTPS privacy policy required');
    plan.push({ locale,
      appInfo: { name: item.name, subtitle: item.subtitle, privacyPolicyUrl: content.privacyPolicyURL },
      version: { description: item.description, keywords: item.keywords, promotionalText: item.promotionalText },
    });
  }
  return plan;
}

async function run() {
  const content = JSON.parse(await fs.readFile(source, 'utf8'));
  const plan = metadataPlan(content);
  await fs.mkdir(new URL('./drafts/', import.meta.url), { recursive: true });
  await fs.writeFile(new URL('./drafts/metadata-plan.json', import.meta.url), JSON.stringify({ plan, pricesChanged: false }, null, 2));
  if (!process.argv.includes('--apply')) {
    console.log(`Prepared ${plan.length} reviewed listing locale(s). No App Store changes or price changes.`);
    return;
  }
  const versionID = process.env.ASC_VERSION_ID;
  const appInfoID = process.env.ASC_APP_INFO_ID;
  if (![versionID, appInfoID].every(v => /^[a-zA-Z0-9-]+$/.test(v ?? ''))) throw new Error('Explicit version and app-info IDs are required');
  const keyID = process.env.APP_STORE_CONNECT_API_KEY_ID;
  const issuer = process.env.APP_STORE_CONNECT_API_ISSUER_ID;
  const encodedKey = process.env.APP_STORE_CONNECT_API_KEY_BASE64;
  if (!keyID || !issuer || !encodedKey) throw new Error('Configure App Store Connect API Actions secrets');
  const privateKey = Buffer.from(encodedKey, 'base64').toString('utf8');
  function token() {
    const now = Math.floor(Date.now() / 1000);
    const data = [
      { alg: 'ES256', kid: keyID, typ: 'JWT' },
      { iss: issuer, iat: now, exp: now + 600, aud: 'appstoreconnect-v1' },
    ].map(v => Buffer.from(JSON.stringify(v)).toString('base64url')).join('.');
    const signature = crypto.sign('sha256', Buffer.from(data), { key: privateKey, dsaEncoding: 'ieee-p1363' });
    return `${data}.${signature.toString('base64url')}`;
  }
  async function api(path, method = 'GET', body) {
    // Deliberately cannot call pricing, purchase, review-submission, or release endpoints.
    if (!/^\/v1\/(appInfos|appInfoLocalizations|appStoreVersions|appStoreVersionLocalizations)\//.test(path)
        && !['/v1/appInfoLocalizations', '/v1/appStoreVersionLocalizations'].includes(path)) throw new Error('Endpoint outside metadata scope');
    const response = await fetch(`https://api.appstoreconnect.apple.com${path}`, {
      method, headers: { Authorization: `Bearer ${token()}`, 'Content-Type': 'application/json' },
      body: body ? JSON.stringify(body) : undefined, signal: AbortSignal.timeout(30000),
    });
    if (!response.ok) throw new Error(`App Store metadata request failed: HTTP ${response.status}`);
    return response.status === 204 ? null : response.json();
  }
  const version = (await api(`/v1/appStoreVersions/${versionID}?include=app`)).data;
  const info = (await api(`/v1/appInfos/${appInfoID}?include=app`)).data;
  for (const resource of [version, info]) {
    if (resource.relationships?.app?.data?.id !== '6767889535') throw new Error('Target is not PipeBoss AI');
  }
  const editable = ['PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED', 'METADATA_REJECTED'];
  if (!editable.includes(version.attributes.appStoreState)) throw new Error('Only an editable, unreleased app version can be updated');
  if (!editable.includes(info.attributes.appStoreState)) throw new Error('App info is not editable');
  const currentInfo = (await api(`/v1/appInfos/${appInfoID}/appInfoLocalizations?limit=200`)).data;
  const currentVersion = (await api(`/v1/appStoreVersions/${versionID}/appStoreVersionLocalizations?limit=200`)).data;
  async function upsert(type, parentType, parentID, existing, locale, attributes) {
    const current = existing.find(v => v.attributes.locale === locale);
    await api(current ? `/v1/${type}/${current.id}` : `/v1/${type}`, current ? 'PATCH' : 'POST', {
      data: { type, ...(current ? { id: current.id } : {}),
        attributes: { ...attributes, ...(!current ? { locale } : {}) },
        ...(!current ? { relationships: { [parentType]: { data: { type: `${parentType}s`, id: parentID } } } } : {}),
      },
    });
  }
  for (const entry of plan) {
    await upsert('appInfoLocalizations', 'appInfo', appInfoID, currentInfo, entry.locale, entry.appInfo);
    await upsert('appStoreVersionLocalizations', 'appStoreVersion', versionID, currentVersion, entry.locale, entry.version);
    console.log(`Updated reviewed locale: ${entry.locale}`);
  }
  console.log('Metadata updated. No prices changed; no version submitted or released.');
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  run().catch(error => { console.error(error.message); process.exitCode = 1; });
}
