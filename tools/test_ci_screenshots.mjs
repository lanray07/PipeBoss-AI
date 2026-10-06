import { createHash } from 'node:crypto';
import test from 'node:test';
import assert from 'node:assert/strict';
import { encodeScreenshot, parseScreenshots } from './read-ci-screenshots.mjs';

const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aAvsAAAAASUVORK5CYII=', 'base64');
const hash = createHash('sha256').update(png).digest('hex');
const block = name => `PIPEBOSS_SCREENSHOT_BEGIN ${name} ${hash}\n${png.toString('base64')}\nPIPEBOSS_SCREENSHOT_END`;
const sample = ['iPhone', 'iPad'].flatMap(kind => ['dashboard', 'diagnosis', 'result', 'skills', 'tools', 'learning'].map(screen => block(`${kind}/${screen}.png`))).join('\n');

test('restores all twelve raw log images', () => {
  const result = parseScreenshots(sample);
  assert.equal(result.size, 12);
  assert.deepEqual(result.get('iPad/result.png'), png);
});
test('exports bounded PNGs and restores the exported set', () => {
  const names = [...parseScreenshots(sample).keys()];
  const encoded = names.map(name => encodeScreenshot(name, png)).join('\n');
  assert.deepEqual(parseScreenshots(encoded).get('iPhone/dashboard.png'), png);
});
test('export refuses unknown paths and non-PNG content', () => {
  assert.throws(() => encodeScreenshot('../outside.png', png), /expected/);
  assert.throws(() => encodeScreenshot('iPhone/dashboard.png', Buffer.from('private data')), /expected/);
});
test('accepts GitHub job, step and timestamp prefixes', () => {
  const prefixed = sample.split('\n').map(line => `Build\tCapture\t2026-10-06T03:00:00Z ${line}`).join('\r\n');
  assert.equal(parseScreenshots(prefixed).size, 12);
});
test('accepts payloads wrapped at 76 characters', () => {
  const wrapped = sample.replaceAll(png.toString('base64'), png.toString('base64').match(/.{1,76}/g).join('\n'));
  assert.equal(parseScreenshots(wrapped).size, 12);
});
test('rejects a path outside the known screenshot set', () => {
  assert.throws(() => parseScreenshots(sample.replace('iPhone/dashboard.png', '../outside.png')), /Unexpected/);
});
test('rejects duplicate blocks', () => {
  assert.throws(() => parseScreenshots(`${sample}\n${block('iPhone/dashboard.png')}`), /duplicate/);
});
test('rejects an incomplete capture set', () => {
  assert.throws(() => parseScreenshots(block('iPhone/dashboard.png')), /all 12/);
});
test('rejects a truncated payload', () => {
  assert.throws(() => parseScreenshots(sample.replace('PIPEBOSS_SCREENSHOT_END', '')), /encoding|nested/);
});
test('rejects a checksum mismatch', () => {
  assert.throws(() => parseScreenshots(sample.replace(hash, '0'.repeat(64))), /checksum/);
});
test('rejects malformed base64', () => {
  assert.throws(() => parseScreenshots(sample.replace(png.toString('base64'), '***')), /encoding/);
});
test('rejects non-PNG data even with its matching checksum', () => {
  const bytes = Buffer.from('not an image');
  const modified = sample.replace(hash, createHash('sha256').update(bytes).digest('hex')).replace(png.toString('base64'), bytes.toString('base64'));
  assert.throws(() => parseScreenshots(modified), /Invalid PNG/);
});
