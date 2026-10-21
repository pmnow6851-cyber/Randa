'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
const script = html.match(/<script>([\s\S]*?)<\/script>/);
assert.ok(script, 'The production app must contain its inline script');
const boot = '(async()=>{renderAccess();await checkHealth();await restoreSession();await handleReturn()})();';
assert.ok(script[1].includes(boot), 'The harness must replace only the live startup call');

function harness() {
  const calls = { fetch: [], writes: [], downloads: [], fallbacks: 0 };
  const flags = { status: 'active', offline: false, clipboardError: false, clipboardDeferred: null, serverWait: null, fallbackResult: false };
  const elements = new Map();
  function element() {
    return {
      value: '',
      textContent: '',
      className: '',
      disabled: false,
      selectedOptions: [{ text: 'Fixed Speed' }],
      classList: { add() {}, remove() {}, toggle() {} },
      addEventListener() {},
      querySelector() { return { textContent: '' }; },
      replaceChildren() {},
      select() {},
      remove() {},
      click() { calls.downloads.push(true); },
    };
  }
  const document = {
    getElementById(id) {
      if (!elements.has(id)) elements.set(id, element());
      return elements.get(id);
    },
    createElement() { return element(); },
    body: { appendChild() {} },
    execCommand(cmd) {
      assert.equal(cmd, 'copy');
      calls.fallbacks++;
      return flags.fallbackResult;
    },
  };
  const storage = { getItem() { return null; }, setItem() {}, removeItem() {} };
  const context = {
    document,
    navigator: {
      clipboard: {
        async writeText(value) {
          calls.writes.push(value);
          if (flags.clipboardDeferred) await flags.clipboardDeferred;
          if (flags.clipboardError) throw new Error('Clipboard denied');
        },
      },
    },
    sessionStorage: storage,
    localStorage: storage,
    location: { protocol: 'http:', search: '', pathname: '/Randa/', href: 'https://example.test/Randa/' },
    window: { addEventListener() {} },
    setTimeout() { return 1; },
    clearTimeout() {},
    URLSearchParams,
    Blob,
    URL: { createObjectURL() { return 'blob:synthetic'; }, revokeObjectURL() {} },
    fetch: async (url, options = {}) => {
      calls.fetch.push({ url, options });
      if (flags.serverWait) await flags.serverWait;
      if (flags.offline) throw new Error('Network offline');
      return { status: 200, ok: true, json: async () => [{ tier: 'pro', status: flags.status }] };
    },
  };
  const exposure = [
    'globalThis.__randaTest = {',
    ' setPaid(userId = "user-a") { currentUser = { id: userId }; accessToken = "synthetic-token"; isPro = true; lastResult = { sync_score: 90, engine_version: "test-only", multiplayer: [{scope:"Standard",camera:11,firing:12,gyroscope:13}] }; },',
    ' setUnpaid() { isPro = false; lastResult = null; },',
    ' switchUser() { sessionSequence++; calcSequence++; currentUser = {id:"user-b"}; accessToken = "synthetic-new-token"; isPro = true; lastResult = {sync_score:91,multiplayer:[{scope:"Standard",camera:21,firing:22,gyroscope:23}]}; },',
    ' beginCalculation() { calcSequence++; lastResult = null; },',
    ' getState() { return { isPro, hasResult: !!lastResult, calcSequence }; },',
    ' copyConfig, exportJson, queueCalculation',
    '};',
  ].join('\n');
  vm.runInNewContext(script[1].replace(boot, exposure), context, { timeout: 1500 });
  return { app: context.__randaTest, calls, flags, elements };
}

test('unpaid users cannot copy or export and do not query an entitlement', async () => {
  const h = harness();
  await h.app.copyConfig();
  await h.app.exportJson();
  assert.equal(h.calls.fetch.length, 0);
  assert.equal(h.calls.writes.length, 0);
  assert.equal(h.calls.downloads.length, 0);
});

test('paid copy succeeds only after a fresh non-cached entitlement read', async () => {
  const h = harness();
  h.app.setPaid();
  await h.app.copyConfig();
  assert.equal(h.calls.fetch.length, 1);
  assert.equal(h.calls.fetch[0].options.cache, 'no-store');
  assert.equal(h.calls.writes.length, 1);
  assert.match(h.calls.writes[0], /RANDA.MKCOOL AIM SYNC CONFIG/);
  assert.equal(h.elements.get('snack').textContent, 'Complete paid config copied');
});

test('revoked entitlement relocks and destroys retained paid results', async () => {
  const h = harness();
  h.app.setPaid();
  h.flags.status = 'revoked';
  await h.app.copyConfig();
  assert.equal(h.calls.writes.length, 0);
  assert.equal(h.app.getState().isPro, false);
  assert.equal(h.app.getState().hasResult, false);
  assert.equal(h.elements.get('copyBtn').disabled, true);
  assert.equal(h.elements.get('exportBtn').disabled, true);
});

test('failed network verification blocks copy and export', async () => {
  const h = harness();
  h.app.setPaid();
  h.flags.offline = true;
  await h.app.copyConfig();
  await h.app.exportJson();
  assert.equal(h.calls.writes.length, 0);
  assert.equal(h.calls.downloads.length, 0);
  assert.equal(h.app.getState().isPro, false);
});

test('clipboard failure cannot claim success unless the fallback explicitly succeeds', async () => {
  const h = harness();
  h.app.setPaid();
  h.flags.clipboardError = true;
  await h.app.copyConfig();
  assert.equal(h.calls.fallbacks, 1);
  assert.match(h.elements.get('notice').textContent, /Copy failed/);
  assert.notEqual(h.elements.get('snack')?.textContent, 'Complete paid config copied');
});

test('clipboard rejection after an account switch never copies the previous users result', async () => {
  const h = harness();
  h.app.setPaid();
  let rejectClipboard;
  h.flags.clipboardDeferred = new Promise((resolve, reject) => { rejectClipboard = reject; });
  const pending = h.app.copyConfig();
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(h.calls.writes.length, 1);
  h.app.switchUser();
  rejectClipboard(new Error('Copy rejected after account change'));
  await pending;
  assert.equal(h.calls.fallbacks, 0);
  assert.notEqual(h.elements.get('snack')?.textContent, 'Complete paid config copied');
});

test('a recalculation during an entitlement read blocks an obsolete result', async () => {
  const h = harness();
  h.app.setPaid();
  let releaseServer;
  h.flags.serverWait = new Promise(resolve => { releaseServer = resolve; });
  const pending = h.app.copyConfig();
  h.app.beginCalculation();
  releaseServer();
  await pending;
  assert.equal(h.calls.writes.length, 0);
  assert.equal(h.app.getState().hasResult, false);
});

test('export uses a fresh entitlement read and produces no file after revocation', async () => {
  const h = harness();
  h.app.setPaid();
  await h.app.exportJson();
  assert.equal(h.calls.downloads.length, 1);
  assert.equal(h.calls.fetch.length, 1);
  h.flags.status = 'revoked';
  await h.app.exportJson();
  assert.equal(h.calls.downloads.length, 1);
});

test('editing an input immediately clears obsolete results during the debounce window', async () => {
  const h = harness();
  h.app.setPaid();
  h.elements.get('base').value = '190';
  h.app.queueCalculation();
  assert.equal(h.app.getState().hasResult, false);
  assert.equal(h.elements.get('copyBtn').disabled, true);
  assert.equal(h.elements.get('exportBtn').disabled, true);
  await h.app.copyConfig();
  await h.app.exportJson();
  assert.equal(h.calls.fetch.length, 0);
  assert.equal(h.calls.writes.length, 0);
  assert.equal(h.calls.downloads.length, 0);
});

test('editing inputs while copy entitlement is pending blocks the old result', async () => {
  const h = harness();
  h.app.setPaid();
  let releaseServer;
  h.flags.serverWait = new Promise(resolve => { releaseServer = resolve; });
  const pending = h.app.copyConfig();
  h.app.queueCalculation();
  releaseServer();
  await pending;
  assert.equal(h.calls.writes.length, 0);
  assert.equal(h.app.getState().hasResult, false);
});
