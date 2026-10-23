'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
const inlineScriptPattern = /<script>([\s\S]*?)<\/script>/i;
assert.equal('<SCRIPT>synthetic</SCRIPT>'.match(inlineScriptPattern)?.[1], 'synthetic', 'HTML tags must be matched case-insensitively');
const match = html.match(inlineScriptPattern);
assert.ok(match, 'Expected production inline app script');
const startup = /\(async\(\)=>\{const authReturn=consumeAuthReturn\(\);[^\n]*\}\)\(\);/;
assert.match(match[1], startup, 'Tests must replace only the live startup statement');

function makeHarness(hash = '', storageFailure = '') {
  const elements = new Map();
  const requests = [];
  const historyCalls = [];
  const session = new Map();
  function el(id) {
    if (!elements.has(id)) {
      elements.set(id, {
        value: '', textContent: '', className: '', disabled: false,
        selectedOptions: [{ text: 'Fixed Speed' }],
        classList: { add() {}, remove() {}, toggle() {} },
        addEventListener() {}, querySelector() { return { textContent: '' }; },
        replaceChildren() {}, select() {}, remove() {}, click() {}
      });
    }
    return elements.get(id);
  }
  const storage = {
    getItem(key) { if (storageFailure === 'read') throw new Error('Storage unavailable'); return session.get(key) || null; },
    setItem(key, value) { if (storageFailure === 'write' || (storageFailure === 'refresh-write' && key === 'RANDA_REFRESH_TOKEN_V1')) throw new Error('Storage unavailable'); session.set(key, value); },
    removeItem(key) { session.delete(key); }
  };
  const location = { hash, protocol: 'http:', pathname: '/Randa/', search: '', href: 'https://example.test/Randa/' };
  const context = {
    document: {
      getElementById: el,
      createElement() { return el('temporary'); },
      body: { appendChild() {} },
      execCommand() { return false; }
    },
    window: { addEventListener() {} },
    navigator: {},
    history: { replaceState(...args) { historyCalls.push(args); } },
    location,
    sessionStorage: storage,
    localStorage: { getItem() { return null; }, setItem() {}, removeItem() {} },
    URLSearchParams, URL, Blob,
    setTimeout() { return 1; }, clearTimeout() {},
    fetch: async (url, options = {}) => {
      requests.push({ url, options });
      return { ok: true, status: 200, json: async () => ({}) };
    }
  };
  const exposure = 'globalThis.__randaAuthTest={consumeAuthReturn,signUp,resendConfirmation,getPaid:()=>isPro,getTokens:()=>[accessToken,refreshToken]};';
  vm.runInNewContext(match[1].replace(startup, exposure), context, { timeout: 1500 });
  assert.ok(context.__randaAuthTest, 'Test hook must be installed');
  return { app: context.__randaAuthTest, elements, requests, historyCalls, session, location };
}

test('expired Supabase confirmation is recognised and sensitive hash is removed', () => {
  const h = makeHarness('#error=access_denied&error_code=otp_expired&error_description=expired');
  assert.equal(h.app.consumeAuthReturn(), 'expired');
  assert.equal(h.historyCalls.length, 1);
  assert.equal(h.historyCalls[0][2], '/Randa/');
  assert.equal(h.session.size, 0);
  assert.equal(h.app.getPaid(), false);
});

test('valid confirmation strips URL credentials and never grants paid access by itself', () => {
  const h = makeHarness('#access_token=synthetic-access&refresh_token=synthetic-refresh&type=signup');
  assert.equal(h.app.consumeAuthReturn(), 'confirmed');
  assert.equal(h.historyCalls.length, 1);
  assert.equal(h.historyCalls[0][2], '/Randa/');
  assert.equal(h.session.get('RANDA_AUTH_TOKEN_V1'), 'synthetic-access');
  assert.equal(h.session.get('RANDA_REFRESH_TOKEN_V1'), 'synthetic-refresh');
  assert.equal(h.app.getPaid(), false);
});

test('partial confirmation tokens fail closed and scrub callback fragment', () => {
  const h = makeHarness('#access_token=synthetic-access');
  assert.equal(h.app.consumeAuthReturn(), 'failed');
  assert.equal(h.historyCalls.length, 1);
  assert.equal(h.session.size, 0);
  assert.equal(h.app.getPaid(), false);
});

test('unrelated application hash is left unchanged', () => {
  const h = makeHarness('#settings');
  assert.equal(h.app.consumeAuthReturn(), '');
  assert.equal(h.historyCalls.length, 0);
  assert.equal(h.session.size, 0);
});

for (const hash of ['#refresh_token=synthetic-refresh', '#error_code=otp_expired', '#error_description=invalid', '#token_type=bearer&expires_in=3600&type=signup']) {
  test('incomplete auth fragment is scrubbed without unlocking: ' + hash.split('=')[0], () => {
    const h = makeHarness(hash);
    assert.equal(h.app.consumeAuthReturn(), hash.includes('otp_expired') ? 'expired' : 'failed');
    assert.equal(h.historyCalls[0][2], '/Randa/');
    assert.equal(h.session.size, 0);
    assert.equal(h.app.getPaid(), false);
  });
}

test('blocked storage reads cannot prevent callback cleanup', () => {
  let h;
  assert.doesNotThrow(() => { h = makeHarness('#error=access_denied&error_code=otp_expired', 'read'); });
  assert.equal(h.app.consumeAuthReturn(), 'expired');
  assert.equal(h.historyCalls[0][2], '/Randa/');
  assert.equal(h.app.getPaid(), false);
});

for (const failure of ['write', 'refresh-write']) {
  test('failed token storage clears partial session and memory: ' + failure, () => {
    const h = makeHarness('#access_token=synthetic-access&refresh_token=synthetic-refresh', failure);
    assert.equal(h.app.consumeAuthReturn(), 'failed');
    assert.equal(h.historyCalls[0][2], '/Randa/');
    assert.equal(h.session.size, 0);
    assert.deepEqual(Array.from(h.app.getTokens()), ['', '']);
    assert.equal(h.app.getPaid(), false);
  });
}

test('sign-up sends the exact official RANDA redirect rather than localhost', async () => {
  const h = makeHarness();
  h.elements.set('email', { value: 'synthetic-test-user@example.com' });
  h.elements.set('password', { value: 'synthetic-password-for-test' });
  await h.app.signUp();
  assert.equal(h.requests.length, 1);
  const request = h.requests[0];
  const url = new URL(request.url);
  assert.equal(url.pathname, '/auth/v1/signup');
  assert.equal(url.searchParams.get('redirect_to'), 'https://pmnow6851-cyber.github.io/Randa/');
  assert.equal(request.options.method, 'POST');
  assert.equal(h.app.getPaid(), false);
});

test('resend validates email and does not fire for invalid input', async () => {
  const h = makeHarness();
  h.elements.set('email', { value: 'invalid' });
  await h.app.resendConfirmation();
  assert.equal(h.requests.length, 0);
});

test('resend requests a signup email against only the official redirect', async () => {
  const h = makeHarness();
  h.elements.set('email', { value: 'synthetic-test-user@example.com' });
  await h.app.resendConfirmation();
  assert.equal(h.requests.length, 1);
  const r = h.requests[0];
  const url = new URL(r.url);
  assert.equal(url.pathname, '/auth/v1/resend');
  assert.equal(url.searchParams.get('redirect_to'), 'https://pmnow6851-cyber.github.io/Randa/');
  assert.equal(r.options.method, 'POST');
  assert.equal(JSON.parse(r.options.body).type, 'signup');
  assert.equal(h.app.getPaid(), false);
});

