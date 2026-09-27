const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const source = fs.readFileSync(path.join(__dirname, '..', 'service-worker.js'), 'utf8');

function harness({ offline = false } = {}) {
  const handlers = {};
  const writes = [];
  const removed = [];
  const response = { ok: true, body: 'app shell', clone() { return this; } };
  const cache = {
    addAll: async () => {},
    put: async (key, value) => { writes.push({ key, body: value.body }); },
  };
  const caches = {
    open: async () => cache,
    keys: async () => ['stale-home-cache', 'randa-aim-sync-v6-paid-20260927-navigation'],
    delete: async (name) => { removed.push(name); },
    match: async () => response,
  };
  const self = {
    registration: { scope: 'https://example.test/Randa/' },
    location: { origin: 'https://example.test' },
    clients: { claim: async () => {} },
    skipWaiting: async () => {},
    addEventListener: (type, fn) => { handlers[type] = fn; },
  };
  vm.runInNewContext(source, {
    self,
    caches,
    URL,
    fetch: async () => {
      if (offline) throw new Error('offline');
      return response;
    },
  });
  return {
    writes,
    removed,
    async navigate(url) {
      const waiting = [];
      let reply;
      handlers.fetch({
        request: { method: 'GET', mode: 'navigate', url },
        respondWith: (promise) => { reply = promise; },
        waitUntil: (promise) => { waiting.push(promise); },
      });
      if (reply) await reply;
      await Promise.all(waiting);
      return Boolean(reply);
    },
    async activate() {
      let work;
      handlers.activate({ waitUntil: (promise) => { work = promise; } });
      await work;
    },
  };
}

test('only the app home page can refresh the offline home entry', async () => {
  const app = harness();
  for (const route of ['support.html', 'unlock/', 'delete-account.html', 'updates/']) {
    assert.equal(await app.navigate(`https://example.test/Randa/${route}`), false);
  }
  assert.deepEqual(app.writes, []);
  assert.equal(await app.navigate('https://example.test/Randa/'), true);
  assert.deepEqual(app.writes, [{ key: './index.html', body: 'app shell' }]);
});

test('offline home uses the app shell and activation discards old caches', async () => {
  const app = harness({ offline: true });
  assert.equal(await app.navigate('https://example.test/Randa/index.html'), true);
  assert.deepEqual(app.writes, []);
  await app.activate();
  assert.deepEqual(app.removed, ['stale-home-cache']);
});
