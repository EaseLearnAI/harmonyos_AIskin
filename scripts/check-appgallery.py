#!/usr/bin/env python3
"""Review regression checks. Source/package checks are NOT Huawei approval or device acceptance."""
import argparse
import hashlib
import math
import json
import os
import re
import struct
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path
from importlib.util import spec_from_file_location, module_from_spec

ROOT = Path(__file__).resolve().parents[1]
spec = spec_from_file_location('design_check', ROOT / 'scripts/check-design-system.py')
design = module_from_spec(spec)
spec.loader.exec_module(design)


def read_json(path):
    # Project manifests use comments/trailing commas, but quoted property names.
    text = design.mask_comments(Path(path).read_text())
    masked = design.mask_strings(text)
    for match in reversed(list(re.finditer(r',\s*(?=[}\]])', masked))):
        text = text[:match.start()] + ' ' + text[match.start() + 1:]
    return json.loads(text)


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def source_fingerprint(root):
    paths = [p for folder in ('AppScope', 'entry/src/main') for p in (root / folder).rglob('*') if p.is_file()]
    paths += [root / name for name in ('build-profile.json5', 'entry/build-profile.json5',
        'oh-package.json5', 'oh-package-lock.json5', 'hvigorfile.ts', 'entry/hvigorfile.ts') if (root / name).is_file()]
    result = hashlib.sha256()
    for path in sorted(paths):
        result.update(path.relative_to(root).as_posix().encode() + b'\0' + bytes.fromhex(digest(path)))
    return result.hexdigest()


def png_size(data):
    if data[:8] != b'\x89PNG\r\n\x1a\n' or data[12:16] != b'IHDR':
        raise ValueError('not a PNG with IHDR')
    return struct.unpack('>II', data[16:24])


def rgba(value):
    value = value.lstrip('#')
    if len(value) == 6:
        value = 'FF' + value
    return tuple(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4, 6))


def blend(color, background):
    alpha, *channels = rgba(color)
    return tuple(alpha * front + (1 - alpha) * back for front, back in zip(channels, background))


def contrast(a, b):
    def luminance(color):
        return sum(weight * (v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4)
                   for weight, v in zip((.2126, .7152, .0722), color))
    low, high = sorted((luminance(a), luminance(b)))
    return (high + .05) / (low + .05)


def palette_checks(root):
    results = []
    palettes = {mode: {v['name']: v['value'] for v in read_json(
        root / f'entry/src/main/resources/{mode}/element/color.json')['color']} for mode in ('base', 'dark')}
    if palettes['base'].keys() != palettes['dark'].keys():
        results.append('dark palette must define exactly the same semantic resources as base')
    for mode, palette in palettes.items():
        c = lambda name: palette['aiskin_' + name]
        backgrounds = []
        # Sample the actual AISkinBackground gradient geometry at phone and foldable
        # aspect ratios. Do not stack every glow at maximum: their centers differ.
        # This is a token calculation, not rendered device pixel acceptance.
        for aspect in (2856 / 1320, 1.1):
            for row in range(41):
                y = row / 40
                a, b, t = ('top', 'middle', y / .58) if y <= .58 else ('middle', 'bottom', (y - .58) / .42)
                base = tuple(v * (1 - t) + w * t for v, w in zip(rgba(c(a))[1:], rgba(c(b))[1:]))
                for column in range(21):
                    x, background = column / 20, base
                    for glow, cx, cy, fade in (('glowMiddle', .65, .54, .42),
                                               ('glowRight', .91, .13, .34), ('glowLeft', .14, .09, .32)):
                        radius = math.hypot(max(cx, 1 - cx), aspect * max(cy, 1 - cy)) * fade
                        fraction = max(0, 1 - math.hypot(x - cx, aspect * (y - cy)) / radius)
                        alpha, *channels = rgba(c(glow))
                        alpha *= fraction
                        background = tuple(alpha * v + (1 - alpha) * w for v, w in zip(channels, background))
                    backgrounds.append(background)
        surfaces = backgrounds + [blend(c(surface), b) for b in backgrounds for surface in
            ('surface', 'elevated', 'muted', 'selected', 'featureSurface', 'routineSurface', 'dialog')]
        for text in ('text', 'secondary', 'accent'):
            minimum = min(contrast(blend(c(text), bg), bg) for bg in surfaces)
            if minimum < 4.5:
                results.append(f'{mode} {text} contrast {minimum:.2f}:1 < 4.5:1')
        for text, surface in (('white', 'primary'), ('danger', 'dangerSurface'),
                              ('warning', 'warningSurface'), ('success', 'successSurface')):
            bg = rgba(c(surface))[1:]
            minimum = contrast(blend(c(text), bg), bg)
            if minimum < 4.5:
                results.append(f'{mode} {text}/{surface} contrast {minimum:.2f}:1 < 4.5:1')
    return results


def source_checks(root):
    errors = []
    ets = root / 'entry/src/main/ets'
    for path in root.glob('*/src/main/module.json5'):
        permissions = {p['name'] for p in read_json(path)['module'].get('requestPermissions', [])}
        if permissions != {'ohos.permission.INTERNET'}:
            errors.append(f'{path.relative_to(root)}: review permission allowlist changed: {sorted(permissions)}')
    picker = design.mask_comments((ets / 'services/ImagePickerService.ets').read_text())
    if 'new picker.PhotoViewPicker()' not in picker:
        errors.append('PhotoViewPicker selection path missing')
    for directory in ('AppScope/resources', 'entry/src/main/resources'):
        media = root / directory / 'base/media'
        layers = read_json(media / 'layered_image.json')['layered-image']
        for layer in ('foreground', 'background'):
            name = layers[layer].removeprefix('$media:')
            if png_size((media / (name + '.png')).read_bytes()) != (1024, 1024):
                errors.append(f'{directory}: {layer} must be 1024 x 1024')
    for relative, key in (('AppScope/resources/base/element/string.json', 'app_name'),
                          ('entry/src/main/resources/base/element/string.json', 'EntryAbility_label')):
        strings = {v['name']: v['value'] for v in read_json(root / relative)['string']}
        if strings.get(key) != '析肤AI':
            errors.append(f'{relative}: display name must be 析肤AI')
    docs = (ets / 'utils/DocumentContent.ets').read_text()
    if '# 析肤AI 使用条款' not in docs or '# 析肤AI 隐私政策' not in docs:
        errors.append('legal document titles must match 析肤AI')
    # These are explicit source contracts, not simulated ArkUI rendering.
    notices = {
        'pages/ConflictView.ets': ('AISkinReportScore({', 1),
        'pages/IngredientView.ets': ('AnalysisOverview({', 1),
        'pages/ConflictHistoryView.ets': ('ForEach(this.records', 1),
        'pages/SkinStatusView.ets': ('AISkinSkinPhotoMap({', 2),
        'components/home/DailyRoutine.ets': ('ForEach(', 1),
        'components/product/ProductList.ets': ('ForEach(this.getFilteredProducts()', 1),
        'design/AISkinPlanContent.ets': ("this.period('早间护理'", 1),
    }
    for relative, (content, minimum) in notices.items():
        source = design.mask_comments((ets / relative).read_text())
        first = source.find('AIContentNotice({')
        if source.count('AIContentNotice({') < minimum or first < 0 or source.find(content) < first:
            errors.append(f'{relative}: AI notice must precede results, including summaries')
    notice = design.mask_comments((ets / 'design/AISkinAIGeneratedNotice.ets').read_text())
    if "title: 'AI生成'" not in notice or '本内容由 AI 生成，仅供参考。' not in notice:
        errors.append('shared explicit AI label missing')
    report = design.mask_comments((ets / 'design/AISkinReportComponents.ets').read_text())
    if re.search(r'\.(maxLines|textOverflow)\s*\(', report):
        errors.append('shared report text must not truncate results')
    conflict = design.mask_comments((ets / 'pages/ConflictView.ets').read_text())
    if 'Scroll()' not in conflict or re.search(r'\.(slice|substring|maxLines|textOverflow)\s*\(', conflict):
        errors.append('conflict report must scroll and preserve all result entries')
    for path in ets.rglob('*.ets'):
        source = design.mask_strings(design.mask_comments(path.read_text()))
        if re.search(r'DocumentViewPicker|ShareController|\.saveAs\(', source):
            errors.append(f'{path.relative_to(root)}: permission/export behavior requires renewed review')
    config = design.mask_comments((ets / 'services/ApiConfig.ets').read_text())
    if 'ENABLE_COMPONENT_PREVIEW: boolean = false' not in config or 'https://www.lunzo.site/api' not in config:
        errors.append('formal source must disable previews and use the production API')
    errors.extend(palette_checks(root))
    return errors


def hap_checks(path, require_huawei=True):
    errors = []
    with zipfile.ZipFile(path) as package:
        manifest = json.loads(package.read('module.json'))
        app, module = manifest['app'], manifest['module']
        if app.get('bundleName') != 'com.example.aiskin3' or app.get('debug') is not False or app.get('buildMode') != 'release':
            errors.append('HAP must be the release build of com.example.aiskin3')
        permissions = {p['name'] for p in module.get('requestPermissions', [])}
        if permissions != {'ohos.permission.INTERNET'}:
            errors.append('HAP contains unexpected permissions')
        ids = [v.get('value', '') for v in module.get('metadata', []) if v['name'] == 'client_id']
        if (require_huawei or ids) and (len(ids) != 1 or not isinstance(ids[0], str) or not ids[0].strip()):
            errors.append('HAP Huawei Client ID is missing; native login cannot work')
        for layer in ('foreground', 'background'):
            # Source assets must remain 1024. Restool's ScaleImage deliberately
            # produces 512x512 packaged icons (compression_parser.cpp:403).
            # Confirmed in this SDK's real HAP and upstream commit 9203d8530e4c.
            if png_size(package.read(f'resources/base/media/{layer}.png')) not in ((512, 512), (1024, 1024)):
                errors.append(f'HAP {layer} icon has an unexpected compiled size')
        bytecode = package.read('ets/modules.abc')
        if b'http://127.0.0.1:5001/api' in bytecode or b'https://www.lunzo.site/api' not in bytecode:
            errors.append('HAP API endpoint is not the production endpoint')
    return errors


EVIDENCE = ('safety_report', 'safety_platform_pass', 'ai_labels', 'ai_declaration',
            'product_flow', 'skin_flow', 'mate60_full_report', 'pura80_contrast',
            'matex5_dark_mode', 'production_login', 'release_signature')


def evidence_checks(path, hap, root=None):
    data = read_json(path)
    errors = []
    if data.get('hap_sha256') != digest(hap):
        errors.append('evidence belongs to a different HAP (SHA-256 mismatch)')
    if root is not None and data.get('source_sha256') != source_fingerprint(root):
        errors.append('source changed since release evidence was recorded')
    if data.get('ai_file_export') is not False:
        errors.append('AI file export scope must be reviewed; implicit-label evidence is not covered by this no-export release')
    for name in EVIDENCE:
        item = data.get('checks', {}).get(name, {})
        if item.get('status') != 'passed' or not item.get('reviewed_by') or not item.get('reviewed_at'):
            errors.append(f'{name}: human review is missing')
            continue
        files = item.get('files')
        if not isinstance(files, list) or not files:
            errors.append(f'{name}: evidence files are missing')
            continue
        for record in files:
            file = Path(path).resolve().parent / record.get('path', '')
            if not file.is_file() or not file.stat().st_size or record.get('sha256') != digest(file):
                errors.append(f'{name}: evidence file missing, empty, or changed')
    return errors


def signature_checks(hap):
    studio = Path(os.environ.get('DEVECO_STUDIO_HOME', '/Applications/DevEco-Studio.app'))
    java = studio / 'Contents/jbr/Contents/Home/bin/java'
    signer = studio / 'Contents/sdk/default/openharmony/toolchains/lib/hap-sign-tool.jar'
    if not java.is_file() or not signer.is_file():
        return ['official DevEco HAP signature verifier unavailable; release signature not verified']
    # Keep extracted signing profile/certificate private, and remove after verification.
    with tempfile.TemporaryDirectory(prefix='aiskin-signature-') as directory:
        result = subprocess.run([str(java), '-jar', str(signer), 'verify-app', '-inFile', str(hap.resolve()),
            '-outCertChain', str(Path(directory) / 'chain.cer'), '-outProfile', str(Path(directory) / 'profile.p7b')],
            capture_output=True, timeout=60)
        if result.returncode:
            return ['official HAP signature verification failed; unsigned or invalid package']
    return []


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT)
    parser.add_argument('--hap', type=Path)
    parser.add_argument('--evidence', type=Path)
    parser.add_argument('--release', action='store_true', help='Require HAP and human-reviewed evidence manifest')
    parser.add_argument('--fingerprint', action='store_true', help='Print source SHA-256 for the evidence manifest')
    args = parser.parse_args()
    if args.fingerprint:
        print(source_fingerprint(args.root))
        return 0
    try:
        errors = source_checks(args.root)
        if args.hap:
            errors.extend(hap_checks(args.hap, require_huawei=(args.root / 'entry/src/main/ets/services/HuaweiLoginStore.ets').exists()))
            if args.release:
                errors.extend(signature_checks(args.hap))
        if args.release and (not args.hap or not args.evidence):
            errors.append('release requires --hap and --evidence; code/build success does not close review blockers')
        if args.evidence:
            if not args.hap:
                errors.append('--evidence requires --hap')
            else:
                errors.extend(evidence_checks(args.evidence, args.hap, args.root))
    except (OSError, ValueError, KeyError, TypeError, struct.error, zipfile.BadZipFile, subprocess.TimeoutExpired) as error:
        errors = [f'incomplete or invalid review input: {error}']
    for error in errors:
        print(f'BLOCKED: {error}')
    print(f'AppGallery checks: {len(errors)} blocking findings. '
          'Source/package/evidence integrity only; not legal validity, device acceptance, or Huawei approval.')
    return int(bool(errors))


if __name__ == '__main__':
    sys.exit(main())
