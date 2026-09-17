'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { extractBusinessComponent, deferred, nextTurn } = require('./business-component.cjs');
const product = extractBusinessComponent('entry/src/main/ets/components/product/ProductUploadModal.ets', 'ProductUploadModal', ['aboutToAppear', 'handleSelectImage', 'handleClose']);
const skin = extractBusinessComponent('entry/src/main/ets/pages/SkinStatusView.ets', 'SkinStatusView', ['analyze']);
function productFixture(result) {
  const f = { calls: [], uploads: [], closed: 0 };
  f.view = product({
    ProductApiService: { getInstance: () => ({}) },
    IngredientAnalysisApiService: { getInstance: () => ({}) },
    ImagePickerService: { getInstance: () => ({
      takePhoto: async (_context, front) => { f.calls.push(['camera', front]); return result; },
      selectFromGallery: async () => { f.calls.push(['gallery']); return result; }
    }) },
    console: { log() {}, error() {} }
  });
  f.view.getUIContext = () => ({ getHostContext: () => ({ cacheDir: '/fixture' }) });
  f.view.onClose = () => f.closed++;
  f.view.submitProduct = () => f.uploads.push(f.view.selectedImagePath);
  return f;
}
test('product camera entry opens rear camera immediately and submits the confirmed photo', async () => {
  const f = productFixture({ success: true, filePath: '/fixture/photo.jpg' });
  f.view.initialSource = 'camera';
  f.view.aboutToAppear();
  assert.deepEqual(f.calls, [['camera', false]]);
  await nextTurn();
  assert.deepEqual(f.uploads, ['/fixture/photo.jpg']);
});
test('product camera cancellation closes the direct entry without uploading', async () => {
  const f = productFixture({ success: false, message: '未拍摄照片' });
  f.view.initialSource = 'camera';
  f.view.aboutToAppear();
  await nextTurn();
  assert.equal(f.closed, 1);
  assert.deepEqual(f.uploads, []);
});
test('product picker failure presents a retryable error without uploading', async () => {
  const f = productFixture({ success: false, message: '拍照失败，请重试' });
  await f.view.handleSelectImage('camera');
  assert.equal(f.view.modalError, true);
  assert.equal(f.view.modalErrorMessage, '拍照失败，请重试');
  assert.deepEqual(f.uploads, []);
});
test('product picker ignores duplicate taps and results after leaving the page', async () => {
  const gate = deferred();
  const f = productFixture(gate.promise);
  const pending = f.view.handleSelectImage('camera');
  await f.view.handleSelectImage('camera');
  assert.equal(f.calls.length, 1);
  f.view.handleClose();
  gate.resolve({ success: true, filePath: '/fixture/photo.jpg' });
  await pending;
  assert.deepEqual(f.uploads, []);
});
test('product album entry opens the gallery directly', async () => {
  const f = productFixture({ success: true, filePath: '/fixture/album.jpg' });
  f.view.initialSource = 'library';
  f.view.aboutToAppear();
  await nextTurn();
  assert.deepEqual(f.calls, [['gallery']]);
  assert.deepEqual(f.uploads, ['/fixture/album.jpg']);
});
test('skin capture starts directly, prevents duplicate launches and silently handles cancel', async () => {
  const gate = deferred();
  let captures = 0;
  const view = skin({ Scroller: class {}, SkinAnalysisService: { getInstance: () => ({
    analyzeFromCamera: () => { captures++; return gate.promise; }
  }) } });
  view.getUIContext = () => ({ getHostContext: () => ({}) });
  const pending = view.analyze('camera');
  assert.equal(captures, 1);
  await view.analyze('camera');
  assert.equal(captures, 1);
  gate.resolve({ success: false, message: '未拍摄照片' });
  await pending;
  assert.equal(view.error, '');
  assert.equal(view.capturing, false);
});
