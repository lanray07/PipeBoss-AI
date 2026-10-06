import { createHash } from 'node:crypto';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { pathToFileURL } from 'node:url';

const screens = ['dashboard', 'diagnosis', 'result', 'skills', 'tools', 'learning'];
const expected = new Set(['iPhone', 'iPad'].flatMap(kind => screens.map(screen => `${kind}/${screen}.png`)));
const signature = Buffer.from('89504e470d0a1a0a', 'hex');
const maxEncodedSize = Math.ceil(8 * 1024 * 1024 / 3) * 4;

export function encodeScreenshot(name, bytes) {
  if (!expected.has(name) || bytes.length > 8 * 1024 * 1024 || !bytes.subarray(0, 8).equals(signature)) {
    throw new Error('Only the expected bounded PNG screenshots may be exported');
  }
  const hash = createHash('sha256').update(bytes).digest('hex');
  const encoded = bytes.toString('base64').match(/.{1,76}/g).join('\n');
  return `PIPEBOSS_SCREENSHOT_BEGIN ${name} ${hash}\n${encoded}\nPIPEBOSS_SCREENSHOT_END`;
}

export function parseScreenshots(log) {
  if (Buffer.byteLength(log) > 128 * 1024 * 1024) throw new Error('CI log exceeds the readback limit');
  const results = new Map();
  let active;
  for (const line of log.split(/\r?\n/)) {
    if (line.includes('PIPEBOSS_SCREENSHOT_BEGIN')) {
      const match = line.match(/PIPEBOSS_SCREENSHOT_BEGIN (\S+) ([a-f0-9]{64})$/);
      if (active || !match || !expected.has(match[1]) || results.has(match[1])) {
        throw new Error('Unexpected, duplicate or nested screenshot marker');
      }
      active = { name: match[1], hash: match[2], chunks: [], size: 0 };
    } else if (line.endsWith('PIPEBOSS_SCREENSHOT_END')) {
      if (!active) throw new Error('Screenshot ended without a start marker');
      const encoded = active.chunks.join('');
      const bytes = Buffer.from(encoded, 'base64');
      if (!encoded || bytes.toString('base64') !== encoded || !bytes.subarray(0, 8).equals(signature)) {
        throw new Error(`Invalid PNG payload: ${active.name}`);
      }
      if (createHash('sha256').update(bytes).digest('hex') !== active.hash) {
        throw new Error(`Screenshot checksum mismatch: ${active.name}`);
      }
      results.set(active.name, bytes);
      active = undefined;
    } else if (active) {
      const match = line.match(/(?:^|\s)([A-Za-z0-9+/]+={0,2})$/);
      if (!match) throw new Error(`Invalid screenshot encoding: ${active.name}`);
      active.size += match[1].length;
      if (active.size > maxEncodedSize) throw new Error('Screenshot exceeds the readback limit');
      active.chunks.push(match[1]);
    }
  }
  if (active || results.size !== expected.size) throw new Error('CI log must contain all 12 complete screenshots');
  return results;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const [, , modeOrLog, directory] = process.argv;
  if (!modeOrLog || !directory) throw new Error('Usage: node tools/read-ci-screenshots.mjs <job-log|--export> <directory>');
  if (modeOrLog === '--export') {
    for (const name of expected) {
      console.log(encodeScreenshot(name, await readFile(resolve(directory, name))));
    }
  } else {
    const results = parseScreenshots(await readFile(modeOrLog, 'utf8'));
    for (const [name, bytes] of results) {
      const target = resolve(directory, name);
      await mkdir(dirname(target), { recursive: true });
      await writeFile(target, bytes);
    }
    console.log(`Restored ${results.size} checksum-verified native screenshots.`);
  }
}
