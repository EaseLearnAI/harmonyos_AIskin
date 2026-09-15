'use strict';

const assert = require('node:assert/strict');
const { test: runTest } = require('node:test');
const test = (name, body) => runTest(name, { timeout: 5000 }, body);
const { extractBusinessService, deferred } = require('./business-component.cjs');

const instantiateStore = extractBusinessService(
  'entry/src/main/ets/services/AuthSessionStore.ets', 'AuthSessionStore', ['initialize', 'read', 'save', 'update', 'clear']
);

function secureFixture() {
  const f = {
    assets: new Map(), durablePreferences: new Map(), preferenceCache: new Map(),
    savedAttributes: [], preferenceWrites: [], failAdd: false, failRemove: false,
    failQuery: false, failFlush: false, failUnblockFlush: false
  };
  const Tag = {
    ALIAS: 'alias', SECRET: 'secret', RETURN_TYPE: 'returnType', RETURN_LIMIT: 'returnLimit',
    ACCESSIBILITY: 'accessibility', SYNC_TYPE: 'syncType', CONFLICT_RESOLUTION: 'conflictResolution'
  };
  const key = attributes => Buffer.from(attributes.get(Tag.ALIAS)).toString('utf8');
  const clone = attributes => new Map([...attributes].map(([tag, value]) => [tag, value instanceof Uint8Array ? value.slice() : value]));
  f.context = {
    Uint8Array,
    asset: {
      Tag, ReturnType: { ALL: 1 }, Accessibility: { DEVICE_FIRST_UNLOCKED: 1 },
      SyncType: { NEVER: 0 }, ConflictResolution: { OVERWRITE: 1 }, ErrorCode: { NOT_FOUND: 404 },
      addSync: attributes => {
        if (f.failAdd) throw { code: 403 };
        f.savedAttributes.push(clone(attributes));
        f.assets.set(key(attributes), clone(attributes));
      },
      querySync: attributes => {
        if (f.failQuery) throw { code: 403 };
        const found = f.assets.get(key(attributes));
        if (!found) throw { code: 404 };
        return [clone(found)];
      },
      removeSync: attributes => {
        if (f.failRemove) throw { code: 403 };
        if (!f.assets.delete(key(attributes))) throw { code: 404 };
      }
    },
    preferences: { getPreferencesSync: () => ({
      putSync: (name, value) => { f.preferenceWrites.push([name, value]); f.preferenceCache.set(name, value); },
      getSync: (name, fallback) => f.preferenceCache.has(name) ? f.preferenceCache.get(name) : fallback,
      flushSync: () => {
        if (f.failFlush || (f.failUnblockFlush && [...f.preferenceCache.values()].some(value => value === false))) throw { code: 500 };
        f.durablePreferences = new Map(f.preferenceCache);
      }
    }) },
    util: {
      TextEncoder: class { encodeInto(value) { return new TextEncoder().encode(value); } },
      TextDecoder: class { decodeWithStream(value) { return new TextDecoder().decode(value); } }
    },
    ApiConfig: { getBaseUrl: () => 'https://fixture.example/api' }
  };
  f.newStore = () => { const store = instantiateStore(f.context); store.initialize({}); return store; };
  f.coldStore = () => { f.preferenceCache = new Map(f.durablePreferences); return f.newStore(); };
  f.store = f.newStore();
  f.user = { id: 'fixture-user', name: 'User', age: 28, avatar: 'not-a-persisted-photo', token: 'duplicate-token-field' };
  f.token = 'fixture-token';
  return f;
}

test('secure session: one asset restores across instances without putting credentials in preferences', () => {
  const f = secureFixture();
  f.store.save(f.user, f.token);
  const restored = f.coldStore().read();
  assert.equal(restored.token, f.token);
  assert.equal(restored.user.id, f.user.id);
  assert.equal(restored.user.age, 28);
  assert.equal(restored.user.avatar, undefined);
  assert.equal(restored.user.token, undefined);
  assert.equal(f.assets.size, 1);
  assert.ok(f.preferenceWrites.every(([, value]) => typeof value === 'boolean'));
  const attributes = f.savedAttributes[0];
  assert.equal(attributes.get('accessibility'), f.context.asset.Accessibility.DEVICE_FIRST_UNLOCKED);
  assert.equal(attributes.get('syncType'), f.context.asset.SyncType.NEVER);
  assert.equal(attributes.has('isPersistent'), false);
});

test('secure session: a different API environment cannot restore the saved credential', () => {
  const f = secureFixture();
  f.store.save(f.user, f.token);
  f.context.ApiConfig.getBaseUrl = () => 'https://other-fixture.example/api';
  assert.equal(f.newStore().read(), null);
});

test('secure session: signed-out barrier survives removal failure and cold restart', () => {
  const f = secureFixture();
  f.store.save(f.user, f.token);
  f.failRemove = true;
  f.store.clear();
  assert.equal(f.assets.size, 1);
  assert.equal(f.coldStore().read(), null);
});

test('secure session: secure deletion handles preference failure, but both durable failures throw', () => {
  const f = secureFixture();
  f.store.save(f.user, f.token);
  f.failFlush = true;
  f.store.clear();
  assert.equal(f.assets.size, 0);
  assert.equal(f.coldStore().read(), null);
  f.failFlush = false;
  f.store.save(f.user, f.token);
  f.failFlush = true;
  f.failRemove = true;
  assert.throws(() => f.store.clear(), /安全退出未完成/);
});

test('secure session: failed asset write cannot expose a recoverable new login', () => {
  const f = secureFixture();
  f.failAdd = true;
  assert.throws(() => f.store.save(f.user, f.token));
  assert.equal(f.store.read(), null);
  assert.equal(f.coldStore().read(), null);
});

test('secure session: failed unblock flush cannot expose a failed login in memory or after restart', () => {
  const f = secureFixture();
  f.failUnblockFlush = true;
  assert.throws(() => f.store.save(f.user, f.token));
  assert.equal(f.store.read(), null);
  assert.equal(f.coldStore().read(), null);
});

test('secure session: a denied asset read is an error, not an empty session', () => {
  const f = secureFixture();
  f.store.save(f.user, f.token);
  f.failQuery = true;
  assert.throws(() => f.store.read(), /读取失败/);
});

const instantiateAuth = extractBusinessService(
  'entry/src/main/ets/services/AuthService.ets', 'AuthService',
  ['restoreSession', 'fetchCurrentUser', 'login', 'register', 'logout', 'setUser', 'getToken', 'getCurrentUser', 'isAuthenticated']
);

function authFixture(saved = true) {
  const f = secureFixture();
  if (saved) f.store.save(f.user, f.token);
  f.store = f.coldStore();
  f.memory = new Map();
  f.sentTokens = [];
  f.me = async () => ({ success: true, data: { ...f.user, name: 'Verified profile' } });
  f.login = async () => ({ success: true, data: { token: f.token, user: f.user } });
  f.auth = instantiateAuth({
    AuthSessionStore: { getInstance: () => f.store },
    AuthApiService: { getInstance: () => ({
      getCurrentUser: token => { f.sentTokens.push(token); return f.me(token); },
      login: credentials => f.login(credentials),
      register: user => f.login(user)
    }) },
    AppStorage: {
      get: name => f.memory.get(name),
      setOrCreate: (name, value) => f.memory.set(name, value),
      delete: name => f.memory.delete(name)
    },
    console: { error() {} }
  });
  return f;
}

test('auth restore: cold session is checked with the saved token and refreshed from the server', async () => {
  const f = authFixture();
  assert.equal(f.auth.isAuthenticated(), false);
  const response = await f.auth.restoreSession();
  assert.equal(response.success, true);
  assert.equal(f.auth.isAuthenticated(), true);
  assert.deepEqual(f.sentTokens, [f.token]);
  assert.equal(f.auth.getCurrentUser().name, 'Verified profile');
  assert.equal(f.coldStore().read().user.name, 'Verified profile');
});

test('auth restore: offline and server failures retain the secure session even when a message contains 401', async () => {
  for (const mode of ['offline', 'exception', 'server error']) {
    const f = authFixture();
    f.me = async () => {
      if (mode === 'exception') throw new Error('offline');
      return { success: false, statusCode: mode === 'server error' ? 500 : 0, message: 'connection error, trace 401' };
    };
    const response = await f.auth.restoreSession();
    assert.equal(response.success, false);
    assert.notEqual(response.retryRequired, true);
    assert.equal(f.auth.isAuthenticated(), true);
    assert.equal(f.auth.getToken(), f.token);
    assert.equal(f.auth.getCurrentUser().name, f.user.name);
    assert.equal(f.coldStore().read().token, f.token);
  }
});

test('auth restore: actual HTTP 401 clears memory and prevents cold restoration', async () => {
  const f = authFixture();
  f.me = async () => ({ success: false, statusCode: 401, message: 'expired credential' });
  const response = await f.auth.restoreSession();
  assert.equal(response.success, false);
  assert.equal(f.auth.isAuthenticated(), false);
  assert.equal(f.auth.getToken(), null);
  assert.equal(f.memory.get('aiskinAuthenticated'), false);
  assert.equal(f.coldStore().read(), null);
});

test('auth restore: unreadable secure storage requires retry without publishing a login', async () => {
  const f = authFixture();
  f.failQuery = true;
  const response = await f.auth.restoreSession();
  assert.equal(response.success, false);
  assert.equal(response.retryRequired, true);
  assert.equal(f.auth.isAuthenticated(), false);
  assert.equal(f.sentTokens.length, 0);
});

test('auth restore: logout invalidates a pending profile response and a later login using the same token', async () => {
  for (const loginAgain of [false, true]) {
    const f = authFixture();
    await f.auth.restoreSession();
    const profile = deferred();
    f.me = () => profile.promise;
    const pending = f.auth.fetchCurrentUser();
    f.auth.logout();
    if (loginAgain) f.auth.setUser({ id: 'new-session-user', name: 'New session' }, f.token);
    profile.resolve({ success: true, data: { id: f.user.id, name: 'Late old profile' } });
    const response = await pending;
    assert.equal(response.success, false);
    assert.equal(f.auth.isAuthenticated(), loginAgain);
    if (loginAgain) {
      assert.equal(f.auth.getCurrentUser().id, 'new-session-user');
      assert.equal(f.coldStore().read().user.id, 'new-session-user');
    } else {
      assert.equal(f.auth.getToken(), null);
      assert.equal(f.coldStore().read(), null);
    }
  }
});

test('auth restore: logout invalidates pending login and registration responses', async () => {
  for (const method of ['login', 'register']) {
    const f = authFixture(false);
    const credentials = deferred();
    f.login = () => credentials.promise;
    const pending = f.auth[method]({ phone: 'fixture-phone', password: 'fixture-password' });
    f.auth.logout();
    credentials.resolve({ success: true, data: { token: f.token, user: f.user } });
    const response = await pending;
    assert.equal(response.success, false);
    assert.equal(f.auth.isAuthenticated(), false);
    assert.equal(f.coldStore().read(), null);
  }
});

test('auth restore: failed secure save cannot report login or registration success', async () => {
  for (const method of ['login', 'register']) {
    const f = authFixture(false);
    f.failAdd = true;
    const response = await f.auth[method]({ phone: 'fixture-phone', password: 'fixture-password' });
    assert.equal(response.success, false);
    assert.match(response.message, /安全保存/);
    assert.equal(f.auth.isAuthenticated(), false);
    assert.equal(f.auth.getToken(), null);
    assert.equal(f.coldStore().read(), null);
  }
});

test('auth restore: when both logout barriers fail the service reports failure and retains the visible session', async () => {
  const f = authFixture();
  await f.auth.restoreSession();
  f.failFlush = true;
  f.failRemove = true;
  assert.throws(() => f.auth.logout(), /安全退出未完成/);
  assert.equal(f.auth.isAuthenticated(), true);
  assert.equal(f.auth.getToken(), f.token);
  assert.equal(f.memory.get('aiskinAuthenticated'), true);
});

test('auth restore: a profile-cache update failure does not revoke a valid verified credential', async () => {
  const f = authFixture();
  f.failAdd = true;
  const response = await f.auth.restoreSession();
  assert.equal(response.success, true);
  assert.equal(f.auth.isAuthenticated(), true);
  assert.equal(f.auth.getCurrentUser().name, 'Verified profile');
  assert.equal(f.coldStore().read().token, f.token);
});

test('secure session: long optional profile fields fall back to an asset secret within 1024 bytes', () => {
  const f = secureFixture();
  f.store.save({ ...f.user, name: '可选昵称'.repeat(500) }, f.token);
  const secret = f.savedAttributes[0].get('secret');
  assert.ok(secret.byteLength <= 1024);
  const stored = JSON.parse(new TextDecoder().decode(secret));
  assert.deepEqual(stored.user, { id: f.user.id });
  assert.equal(stored.token, f.token);
  assert.equal(f.coldStore().read().user.id, f.user.id);
});

test('auth restore: malformed and null stored payloads are cleared and return to signed-out state', async () => {
  const payloads = ['null', '{broken-json', '{}', '{"version":1,"token":"","user":{"id":"x"}}',
    '{"version":1,"token":"fixture-token","user":null}', 'non-byte-secret'];
  for (const payload of payloads) {
    const f = authFixture();
    const attributes = [...f.assets.values()][0];
    attributes.set('secret', payload === 'non-byte-secret' ? payload : new TextEncoder().encode(payload));
    const response = await f.auth.restoreSession();
    assert.equal(response.success, true);
    assert.notEqual(response.retryRequired, true);
    assert.equal(f.auth.isAuthenticated(), false);
    assert.equal(f.auth.getToken(), null);
    assert.equal(f.sentTokens.length, 0);
    assert.equal(f.coldStore().read(), null);
  }
});

test('auth restore: rejected session stays revoked on offline retry after both cleanup barriers fail', async () => {
  const f = authFixture();
  f.failFlush = true;
  f.failRemove = true;
  f.me = async () => ({ success: false, statusCode: 401, message: 'expired credential' });
  const first = await f.auth.restoreSession();
  assert.equal(first.retryRequired, true);
  assert.equal(f.auth.isAuthenticated(), false);
  assert.equal(f.auth.getToken(), null);
  f.me = async () => { throw new Error('offline'); };
  const offlineRetry = await f.auth.restoreSession();
  assert.equal(offlineRetry.retryRequired, true);
  assert.equal(f.auth.isAuthenticated(), false);
  assert.equal(f.auth.getToken(), null);
  assert.equal(f.sentTokens.length, 1, 'rejected credentials must not be reused for an offline profile request');
  f.failFlush = false;
  f.failRemove = false;
  const cleanupRetry = await f.auth.restoreSession();
  assert.equal(cleanupRetry.success, true);
  assert.equal(f.auth.isAuthenticated(), false);
  assert.equal(f.coldStore().read(), null);
});
