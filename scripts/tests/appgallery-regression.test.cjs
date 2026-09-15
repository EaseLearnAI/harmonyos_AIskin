'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const path = require('node:path');
test('AppGallery guards reject review regressions (11 Python fault-injection cases)', () => {
  const result = spawnSync('python3', [path.join(__dirname, 'test_appgallery.py'), '-v'], { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
});
