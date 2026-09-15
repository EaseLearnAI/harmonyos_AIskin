"""Fault-injection checks for release guards; fixtures are not device/AGC evidence."""
import importlib.util
import json
import shutil
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('appgallery', ROOT / 'scripts/check-appgallery.py')
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)


class AppGalleryRegression(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temp.name)
        files = list((ROOT / 'entry/src/main/ets').rglob('*.ets'))
        files += list(ROOT.glob('*/src/main/module.json5'))
        for base in ('AppScope/resources', 'entry/src/main/resources'):
            for file in (ROOT / base).rglob('*'):
                if file.is_file() and file.name in ('string.json', 'color.json', 'layered_image.json', 'foreground.png', 'background.png'):
                    files.append(file)
        for file in files:
            target = cls.root / file.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(file, target)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def mutate(self, relative, before, after):
        path = self.root / relative
        original = path.read_text()
        self.assertIn(before, original)
        path.write_text(original.replace(before, after))
        self.addCleanup(path.write_text, original)

    def test_current_source(self):
        self.assertEqual(review.source_checks(self.root), [])

    def test_broad_album_permission_is_rejected(self):
        self.mutate('entry/src/main/module.json5', 'ohos.permission.INTERNET', 'ohos.permission.READ_IMAGEVIDEO')
        self.assertTrue(any('permission allowlist' in e for e in review.source_checks(self.root)))

    def test_ai_label_removed_from_daily_summary_is_rejected(self):
        self.mutate('entry/src/main/ets/components/home/DailyRoutine.ets', "AIContentNotice({ scene: '每日护肤方案' })", '')
        self.assertTrue(any('DailyRoutine' in e for e in review.source_checks(self.root)))

    def test_truncated_report_is_rejected(self):
        self.mutate('entry/src/main/ets/design/AISkinReportComponents.ets', 'Text(this.text)', 'Text(this.text).maxLines(3)')
        self.assertTrue(any('truncate' in e for e in review.source_checks(self.root)))

    def test_original_low_contrast_palette_is_rejected(self):
        self.mutate('entry/src/main/resources/base/element/color.json', '#5B3E73', '#6B4D86')
        self.assertTrue(any('contrast' in e for e in review.source_checks(self.root)))

    def test_wrong_icon_dimensions_are_rejected(self):
        path = self.root / 'AppScope/resources/base/media/foreground.png'
        original = path.read_bytes()
        self.addCleanup(path.write_bytes, original)
        data = bytearray(original)
        data[16:24] = review.struct.pack('>II', 216, 216)
        path.write_bytes(data)
        self.assertTrue(any('1024' in e for e in review.source_checks(self.root)))

    def test_display_name_regression_is_rejected(self):
        self.mutate('AppScope/resources/base/element/string.json', '析肤AI', 'Old name')
        self.assertTrue(any('display name' in e for e in review.source_checks(self.root)))

    def test_dark_resource_gap_is_rejected(self):
        self.mutate('entry/src/main/resources/dark/element/color.json', 'start_window_background', 'old_start_color')
        self.assertTrue(any('same semantic' in e for e in review.source_checks(self.root)))

    def package(self, client_id='test-fixture-id', permission='ohos.permission.INTERNET', debug=False):
        path = self.root / 'fixture.hap'
        with zipfile.ZipFile(path, 'w') as package:
            package.writestr('module.json', json.dumps({'app': {'bundleName': 'com.example.aiskin3', 'debug': debug, 'buildMode': 'release'},
                'module': {'metadata': [{'name': 'client_id', 'value': client_id}], 'requestPermissions': [{'name': permission}]}}))
            for name in ('foreground', 'background'):
                package.write(self.root / f'AppScope/resources/base/media/{name}.png', f'resources/base/media/{name}.png')
            package.writestr('ets/modules.abc', b'fixture only: https://www.lunzo.site/api')
        return path

    def test_hap_is_inspected_independently_of_clean_source(self):
        for kwargs, message in (({'client_id': ''}, 'Client ID'), ({'permission': 'ohos.permission.READ_IMAGEVIDEO'}, 'permissions'), ({'debug': True}, 'release build')):
            with self.subTest(kwargs=kwargs):
                self.assertTrue(any(message in e for e in review.hap_checks(self.package(**kwargs))))

    def test_materials_cannot_be_closed_by_booleans_alone(self):
        hap = self.package()
        path = self.root / 'evidence.json'
        path.write_text(json.dumps({'hap_sha256': review.digest(hap), 'ai_file_export': False,
            'checks': {name: {'status': 'passed', 'reviewed_by': 'fixture', 'reviewed_at': '2026-09-16'} for name in review.EVIDENCE}}))
        self.assertEqual(len(review.evidence_checks(path, hap)), len(review.EVIDENCE))

    def test_changed_package_and_evidence_are_rejected(self):
        hap = self.package()
        proof = self.root / 'fixture-proof.txt'
        proof.write_text('test fixture, not real evidence')
        path = self.root / 'evidence.json'
        data = {'hap_sha256': review.digest(hap), 'source_sha256': review.source_fingerprint(self.root), 'ai_file_export': False,
            'checks': {name: {'status': 'passed', 'reviewed_by': 'fixture', 'reviewed_at': '2026-09-16',
                'files': [{'path': proof.name, 'sha256': review.digest(proof)}]} for name in review.EVIDENCE}}
        path.write_text(json.dumps(data))
        self.assertEqual(review.evidence_checks(path, hap), [])
        self.assertEqual(review.evidence_checks(path, hap, self.root), [])
        self.mutate('AppScope/resources/base/element/string.json', '析肤AI', 'changed')
        self.assertTrue(any('source changed' in e for e in review.evidence_checks(path, hap, self.root)))
        proof.write_text('changed')
        self.assertEqual(len(review.evidence_checks(path, hap)), len(review.EVIDENCE))
        hap.write_bytes(b'different artifact')
        self.assertTrue(any('different HAP' in e for e in review.evidence_checks(path, hap)))


if __name__ == '__main__':
    unittest.main()
