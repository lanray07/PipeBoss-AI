import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

const keyId = process.env.ASC_KEY_ID;
const issuerId = process.env.ASC_ISSUER_ID;
const keyPath = process.env.ASC_KEY_PATH;
const versionId = process.env.ASC_VERSION_ID;

if (!keyId || !issuerId || !keyPath || !versionId) {
  throw new Error('Set ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH, and ASC_VERSION_ID.');
}

const cwd = process.cwd();
const privateKey = await fs.readFile(keyPath, 'utf8');

const screenshotGroups = [
  {
    displayType: 'APP_IPHONE_65',
    directory: path.join(cwd, 'AppStoreAssets', 'Screenshots', 'iPhone65'),
    files: [
      '01-real-jobs.png',
      '02-diagnose-faults.png',
      '03-tool-inventory.png',
      '04-repair-decisions.png',
      '05-career-progress.png',
      '06-business-upgrades.png',
      '07-learning-cards.png',
      '08-pipeboss-pro.png'
    ]
  },
  {
    displayType: 'APP_IPAD_PRO_3GEN_129',
    directory: path.join(cwd, 'AppStoreAssets', 'Screenshots', 'iPad129'),
    files: [
      '01-ipad-dashboard.png',
      '02-ipad-diagnosis.png',
      '03-ipad-tools.png',
      '04-ipad-business.png'
    ]
  }
];

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

const localizations = await api(`/v1/appStoreVersions/${versionId}/appStoreVersionLocalizations?limit=20`);
const localization = localizations.data.find((item) => item.attributes.locale === 'en-GB') ?? localizations.data[0];
if (!localization) {
  throw new Error(`No localization found for version ${versionId}.`);
}

const setsResponse = await api(`/v1/appStoreVersionLocalizations/${localization.id}/appScreenshotSets?limit=50`);
const setsByType = new Map(setsResponse.data.map((item) => [item.attributes.screenshotDisplayType, item.id]));

const uploaded = [];
for (const group of screenshotGroups) {
  const setId = setsByType.get(group.displayType);
  if (!setId) {
    throw new Error(`No screenshot set found for ${group.displayType}.`);
  }

  const existingBefore = await listScreenshots(setId);
  const desiredIds = [];

  for (const fileName of group.files) {
    const existing = existingBefore.find((item) => item.fileName === fileName && item.state !== 'FAILED');
    if (existing) {
      desiredIds.push(existing.id);
      uploaded.push({ displayType: group.displayType, fileName, id: existing.id, status: 'existing' });
      continue;
    }

    const filePath = path.join(group.directory, fileName);
    const screenshotId = await uploadScreenshot(setId, filePath, fileName);
    desiredIds.push(screenshotId);
    uploaded.push({ displayType: group.displayType, fileName, id: screenshotId, status: 'uploaded' });
  }

  const existingAfter = await listScreenshots(setId);
  const remainingIds = existingAfter
    .filter((item) => !desiredIds.includes(item.id))
    .map((item) => item.id);
  await reorderScreenshots(setId, [...desiredIds, ...remainingIds]);
}

await new Promise((resolve) => setTimeout(resolve, 8000));

const states = {};
for (const group of screenshotGroups) {
  const setId = setsByType.get(group.displayType);
  states[group.displayType] = await listScreenshots(setId);
}

console.log(JSON.stringify({ versionId, localizationId: localization.id, uploaded, states }, null, 2));
