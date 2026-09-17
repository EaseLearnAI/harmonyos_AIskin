'use strict';

const assert = require('node:assert/strict');
const { test: runTest } = require('node:test');
const test = (name, body) => runTest(name, { timeout: 5000 }, body);
const { extractBusinessService, deferred } = require('./business-component.cjs');

const instantiatePicker = extractBusinessService(
  'entry/src/main/ets/services/ImagePickerService.ets', 'ImagePickerService', ['takePhoto']
);

function fixture() {
  const f = { events: [], files: new Map(), handles: new Set(), logs: [], picks: 0 };
  f.captureResult = { resultCode: 0, resultUri: 'private-fixture-result-uri' };
  f.create = path => { f.files.set(path, ''); };
  f.unlink = path => { f.files.delete(path); };
  f.uri = path => `private-fixture-uri:${path}`;
  f.pick = async () => f.captureResult;
  const recordLog = (...values) => f.logs.push(values.join(' '));
  f.service = instantiatePicker({
    fs: {
      OpenMode: { CREATE: 0o100 },
      createRandomAccessFileSync: path => {
        f.events.push(['create', path]);
        f.create(path);
        const handle = { close: () => {
          f.events.push(['close', path]);
          assert.ok(f.handles.delete(handle), 'the created handle must be closed exactly once');
        } };
        f.handles.add(handle);
        return handle;
      },
      unlinkSync: path => { f.events.push(['unlink', path]); f.unlink(path); }
    },
    fileUri: { getUriFromPath: path => { f.events.push(['uri', path]); return f.uri(path); } },
    camera: { CameraPosition: { CAMERA_POSITION_FRONT: 1, CAMERA_POSITION_BACK: 0 } },
    cameraPicker: {
      PickerMediaType: { PHOTO: 1 },
      pick: async (context, types, profile) => {
        f.picks++;
        assert.equal(f.handles.size, 0, 'destination handle must already be closed when the camera starts');
        const path = f.events.find(event => event[0] === 'create')[1];
        assert.equal(profile.saveUri, `private-fixture-uri:${path}`);
        assert.equal(f.files.has(path), true, 'destination must still exist when capture starts');
        f.events.push(['pick', path]);
        return f.pick(context, types, profile);
      }
    },
    console: { log: recordLog, warn: recordLog, error: recordLog }
  });
  f.context = { cacheDir: '/fixture-cache' };
  return f;
}

test('camera cache: successful capture closes the handle and preserves the upload file', async () => {
  const f = fixture();
  f.pick = async () => {
    const path = f.events.find(event => event[0] === 'create')[1];
    f.files.set(path, 'fixture-image-bytes');
    return f.captureResult;
  };
  const result = await f.service.takePhoto(f.context);
  assert.equal(result.success, true);
  assert.equal(result.uri, f.captureResult.resultUri);
  assert.equal(f.files.get(result.filePath), 'fixture-image-bytes');
  assert.equal(f.handles.size, 0);
  assert.deepEqual(f.events.map(event => event[0]), ['create', 'close', 'uri', 'pick']);
});

test('camera cache: pending camera work retains the file until cancellation settles', async () => {
  const f = fixture();
  const pendingCapture = deferred();
  f.pick = () => pendingCapture.promise;
  const pending = f.service.takePhoto(f.context);
  assert.equal(f.handles.size, 0);
  assert.equal(f.files.size, 1);
  assert.equal(f.events.some(event => event[0] === 'unlink'), false);
  pendingCapture.resolve({ resultCode: -1, resultUri: '' });
  const result = await pending;
  assert.equal(result.success, false);
  assert.equal(f.files.size, 0);
  assert.equal(f.events.filter(event => event[0] === 'unlink').length, 1);
  assert.ok(f.logs.some(line => line.includes('resultCode=-1')));
});

test('camera cache: rejected camera launch cleans the capture and logs only its numeric code', async () => {
  const f = fixture();
  f.pick = async () => { throw { code: 2097152, message: 'private-photo-path-and-token' }; };
  const result = await f.service.takePhoto(f.context);
  assert.equal(result.success, false);
  assert.equal(f.handles.size, 0);
  assert.equal(f.files.size, 0);
  assert.ok(f.logs.some(line => line.includes('errorCode=2097152')));
  assert.equal(f.logs.some(line => /private-|fixture-cache/.test(line)), false);
});

test('camera cache: missing result URI is a failed capture and does not keep an empty cache file', async () => {
  const f = fixture();
  f.captureResult = { resultCode: 0, resultUri: '' };
  const result = await f.service.takePhoto(f.context);
  assert.equal(result.success, false);
  assert.equal(f.files.size, 0);
  assert.equal(f.handles.size, 0);
});

test('camera cache: URI conversion failure closes and cleans the already-created destination', async () => {
  const f = fixture();
  f.uri = () => { throw { code: 13900020 }; };
  const result = await f.service.takePhoto(f.context);
  assert.equal(result.success, false);
  assert.equal(f.picks, 0);
  assert.equal(f.handles.size, 0);
  assert.equal(f.files.size, 0);
  assert.deepEqual(f.events.map(event => event[0]), ['create', 'close', 'uri', 'unlink']);
});

test('camera cache: creation failure does not delete an unowned path or open the camera', async () => {
  const f = fixture();
  f.create = path => { f.files.set(path, 'pre-existing-file'); throw { code: 13900002 }; };
  const result = await f.service.takePhoto(f.context);
  assert.equal(result.success, false);
  assert.equal(f.picks, 0);
  assert.equal(f.handles.size, 0);
  assert.deepEqual([...f.files.values()], ['pre-existing-file']);
  assert.equal(f.events.some(event => event[0] === 'unlink'), false);
});

test('camera cache: cleanup failure keeps the original failure and reports a safe diagnostic', async () => {
  const f = fixture();
  f.pick = async () => { throw { code: 2097152, message: 'private-token' }; };
  f.unlink = () => { throw { code: 13900002, message: 'private-path' }; };
  const result = await f.service.takePhoto(f.context);
  assert.equal(result.success, false);
  assert.equal(result.message, '拍照失败，请重试');
  assert.ok(f.logs.some(line => line.includes('errorCode=2097152')));
  assert.ok(f.logs.some(line => line.includes('errorCode=13900002')));
  assert.equal(f.logs.some(line => /private-|fixture-cache/.test(line)), false);
});

test('camera cache: absent context creates no file and makes no camera request', async () => {
  const f = fixture();
  const result = await f.service.takePhoto(undefined);
  assert.equal(result.success, false);
  assert.equal(f.events.length, 0);
  assert.equal(f.picks, 0);
});

for (const [front, expected] of [[undefined, 1], [false, 0]]) {
  test(`camera selection: ${front === false ? 'product uses rear' : 'skin defaults to front'}`, async () => {
    const f = fixture();
    f.pick = async (_context, _types, profile) => {
      assert.equal(profile.cameraPosition, expected);
      return f.captureResult;
    };
    assert.equal((await f.service.takePhoto(f.context, front)).success, true);
  });
}
