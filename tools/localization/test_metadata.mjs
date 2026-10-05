import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { metadataPlan } from './appstore_metadata.mjs';
const content = JSON.parse(await fs.readFile(new URL('../../AppStoreAssets/Metadata/localizations.json', import.meta.url), 'utf8'));
test('only explicitly reviewed metadata is included', () => {
  assert.deepEqual(metadataPlan(content).map(v => v.locale), ['en-GB']);
});
test('metadata plan never includes price schedules', () => {
  for (const item of metadataPlan(content)) {
    assert.deepEqual(Object.keys(item).sort(), ['appInfo', 'locale', 'version']);
    assert.deepEqual(Object.keys(item.version).sort(), ['description', 'keywords', 'promotionalText']);
  }
});
test('invalid reviewed metadata fails before any API operation', () => {
  const invalid = structuredClone(content);
  invalid.localizations['en-GB'].name = 'x'.repeat(31);
  assert.throws(() => metadataPlan(invalid), /invalid name/);
});
test('string and missing review flags cannot bypass the publication gate', () => {
  const invalid = structuredClone(content);
  invalid.localizations['es-ES'].releaseReady = 'false';
  assert.throws(() => metadataPlan(invalid), /releaseReady must be a boolean/);
  delete invalid.localizations['es-ES'].releaseReady;
  assert.throws(() => metadataPlan(invalid), /releaseReady must be a boolean/);
});
