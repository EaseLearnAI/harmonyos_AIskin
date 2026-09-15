#!/usr/bin/env python3
"""Audit frontend structure against the checked-out iOS DesignSystem.

This is source-level reuse and asset/token verification, not visual acceptance.
Exit 1 means structural findings, missing references, or unreviewed parity failures.
--strict-parity also fails for explicitly retained accessibility deviations.
No dependencies, server, compiler, browser, or device are required.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
FRONTEND = REPO / "entry/src/main/ets"
SHARED_CALLS = (
    "AISkinButton", "AISkinField", "AISkinIconButton", "AISkinHeader", "AppHeader",
    "AISkinTabBar", "BottomNavigation", "AISkinTabs", "AISkinTag", "AISkinStateView",
    "AISkinCard", "CardStyle", "TextStyle", "Modal", "DocumentModal", "DeleteConfirmModal",
    "AISkinProfilePanel", "AISkinProfileIdentity", "AISkinSettingsRow", "AISkinSettingsGroup",
)
VISUAL_MODIFIERS = re.compile(r"\.(fontSize|fontWeight|borderRadius|shadow|linearGradient|radialGradient)\s*\(")
NATIVE_CONTROLS = re.compile(r"(?<![\w.])(Button|TextInput|TextArea|Tabs|TabContent)\s*\(")
BARE_BUILDER_SLOT = re.compile(r"\b(content|footer|header|anchor)\s*:\s*this\.(\w+)\s*(?=[,}])")
HEX_LITERAL = re.compile(r"(['\"])#[0-9a-fA-F]{3,8}\1")
# These exact values retain the previous Huawei contrast remediation. They are
# explicitly reported, not counted as an iOS color match. Supporting review evidence
# belongs in the release review matrix; new values or changed iOS references do not
# inherit this exception. --strict-parity rejects all four differences.
ACCESSIBILITY_DEVIATIONS = {
    "aiskin_secondary": ("#544A5C", "#FF706878"),
    "aiskin_danger": ("#B3261E", "#FFD42E33"),
    "aiskin_warning": ("#8A4B00", "#FFF0962E"),
    "aiskin_success": ("#2E7D32", "#FF339E6B"),
}

ASSETS = {
    "onboarding_skin.png": "OnboardingSkin.imageset/artwork.png",
    "onboarding_conflict.png": "OnboardingConflict.imageset/artwork.png",
    "onboarding_ingredient.png": "OnboardingIngredient.imageset/artwork.png",
    "product_capture.png": "PrototypeProductCapture.imageset/product-capture@3x.png",
}


def mask_comments(text: str) -> str:
    """Preserve offsets and quoted URL strings while masking JS/Swift comments."""
    chars = list(text)
    index = 0
    quote = ""
    while index < len(chars):
        if quote:
            if chars[index] == "\\":
                index += 2
                continue
            if chars[index] == quote:
                quote = ""
            index += 1
            continue
        if chars[index] in "'\"`":
            quote = chars[index]
            index += 1
            continue
        if text[index:index + 2] == "//":
            end = text.find("\n", index)
            end = len(chars) if end == -1 else end
            chars[index:end] = " " * (end - index)
            index = end
        elif text[index:index + 2] == "/*":
            end = text.find("*/", index + 2)
            end = len(chars) if end == -1 else end + 2
            for position in range(index, end):
                if chars[position] != "\n":
                    chars[position] = " "
            index = end
        else:
            index += 1
    return "".join(chars)


def mask_strings(text: str) -> str:
    return re.sub(r"(['\"`])(?:\\.|(?!\1)[\s\S])*?\1", lambda match: re.sub(r"[^\n]", " ", match.group()), text)


def location(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def enclosing_call_name(code: str, position: int) -> str:
    """Find the recipient call, with strings/comments already masked."""
    stack = []
    for match in re.finditer(r"[(){}\[\]]", code[:position]):
        character = match.group()
        if character in "({[":
            name = re.search(r"([\w$]+)\s*$", code[:match.start()]) if character == "(" else None
            stack.append((character, name.group(1) if name else ""))
        elif stack and {')': '(', '}': '{', ']': '['}[character] == stack[-1][0]:
            stack.pop()
    return next((name for character, name in reversed(stack) if character == "(" and name), "")


def builder_contracts(paths: list[Path]) -> dict[str, set[str]]:
    # Native ListItemGroup declares header/footer as CustomBuilder. Custom slots
    # are discovered from actual @BuilderParam declarations, including design/.
    contracts = {"ListItemGroup": {"header", "footer"}}
    for path in paths:
        code = mask_strings(mask_comments(path.read_text()))
        for component in re.finditer(r"\bstruct\s+(\w+)\s*\{", code):
            depth, end = 1, component.end()
            while end < len(code) and depth:
                depth += (code[end] == "{") - (code[end] == "}")
                end += 1
            slots = set(re.findall(r"@BuilderParam\s+(\w+)\s*:", code[component.end():end - 1]))
            if slots:
                contracts[component.group(1)] = slots
    return contracts


def bare_builder_findings(path: Path, original: str, code: str, contracts: dict[str, set[str]]) -> list[dict]:
    findings = []
    local_builders = set(re.findall(r"@(?:Local)?Builder\s+(?:(?:private|public|protected)\s+)?(\w+)\s*\(", code))
    scalar_members = set(re.findall(r"\b(\w+)\??\s*:\s*(?:string|Resource|ResourceStr|ResourceColor)\b", code))
    for match in BARE_BUILDER_SLOT.finditer(code):
        slot, member = match.groups()
        recipient = enclosing_call_name(code, match.start())
        # DocumentModal.content is text. A ternary, this.content string/resource,
        # ordinary data payload, and an already-invoked/bound function are not
        # equivalent to passing a component-local @Builder method as a callback.
        if recipient == "DocumentModal" and slot == "content":
            continue
        if member in scalar_members and member not in local_builders:
            continue
        if slot not in contracts.get(recipient, set()) and member not in local_builders:
            continue
        line = location(code, match.start())
        findings.append({"path": str(path.relative_to(REPO)), "line": line,
                         "rule": "bare_builder_callback", "recipient": recipient, "slot": slot, "member": member,
                         "expression": original.splitlines()[line - 1].strip(),
                         "reason": "A bare builder can execute with the receiving component as this; use a lexical wrapper: () => { this." + member + "() }"})
    return findings


def scan_business_sources() -> tuple[list[dict], dict, int]:
    findings = []
    coverage = {name: defaultdict(list) for name in SHARED_CALLS}
    paths = sorted(path for directory in ("pages", "components") for path in (FRONTEND / directory).rglob("*.ets"))
    all_frontend_paths = sorted(FRONTEND.rglob("*.ets"))
    contracts = builder_contracts(all_frontend_paths)
    for path in paths:
        original = path.read_text()
        comments_masked = mask_comments(original)
        code = mask_strings(comments_masked)
        relative = str(path.relative_to(REPO))
        findings.extend(bare_builder_findings(path, original, code, contracts))
        for pattern, rule in ((VISUAL_MODIFIERS, "visual_modifier_outside_design"), (NATIVE_CONTROLS, "native_control_outside_design"), (HEX_LITERAL, "literal_hex_outside_design")):
            source = comments_masked if pattern is HEX_LITERAL else code
            for match in pattern.finditer(source):
                line = location(source, match.start())
                findings.append({"path": relative, "line": line, "rule": rule, "expression": original.splitlines()[line - 1].strip()})
        for name in SHARED_CALLS:
            for match in re.finditer(r"\b" + name + r"\s*\(", code):
                coverage[name][relative].append(location(code, match.start()))
    # The binding contract also applies inside DesignSystem components/services,
    # where native style modifiers themselves are intentionally not audited.
    for path in sorted(set(all_frontend_paths) - set(paths)):
        original = path.read_text()
        findings.extend(bare_builder_findings(path, original, mask_strings(mask_comments(original)), contracts))
    stats = {}
    for name, files in coverage.items():
        stats[name] = {"calls": sum(map(len, files.values())), "files": len(files), "sites": dict(files)}
    return findings, stats, len(paths)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify_assets(ios: Path) -> list[dict]:
    results = []
    for harmony_name, ios_name in ASSETS.items():
        harmony = REPO / "entry/src/main/resources/base/media" / harmony_name
        reference = ios / "AIskin/Assets.xcassets" / ios_name
        result = {"asset": harmony_name, "reference": str(reference)}
        if not harmony.is_file() or not reference.is_file():
            result.update(status="not_verified", reason="missing HarmonyOS or iOS asset")
        else:
            actual, expected = sha256(harmony), sha256(reference)
            result.update(status="match" if actual == expected else "mismatch", harmony_sha256=actual, ios_sha256=expected)
        results.append(result)
    return results


def token_declarations(directory: Path, suffix: str) -> dict[str, str]:
    declarations = {}
    if not directory.is_dir():
        return declarations
    for path in sorted(directory.glob("*" + suffix)):
        text = mask_comments(path.read_text())
        for owner in re.finditer(r"\b(?:enum|class)\s+(\w+)\s*\{", text):
            depth, end = 1, owner.end()
            while end < len(text) and depth:
                depth += (text[end] == "{") - (text[end] == "}")
                end += 1
            body = text[owner.end():end - 1]
            pattern = r"static\s+(?:readonly|let)\s+(\w+)\s*(?::[^=\n]+)?\s*=\s*([^\n]+)"
            for declaration in re.finditer(pattern, body):
                declarations[owner.group(1) + "." + declaration.group(1)] = declaration.group(2).strip().rstrip(";")
    return declarations


def numeric_value(tokens: dict[str, str], key: str, seen: frozenset = frozenset()) -> float | None:
    if key in seen or key not in tokens:
        return None
    expression = tokens[key]
    direct = re.fullmatch(r"[-+]?\d+(?:\.\d+)?", expression)
    if direct:
        return float(expression)
    font = re.match(r"Font\.system\(size:\s*(\d+(?:\.\d+)?)", expression)
    if font:
        return float(font.group(1))
    if re.fullmatch(r"[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)?", expression):
        reference = expression if "." in expression else key.rsplit(".", 1)[0] + "." + expression
        return numeric_value(tokens, reference, seen | {key})
    return None


def verify_tokens(ios: Path) -> list[dict]:
    actual = token_declarations(FRONTEND / "design/Foundation", ".ets")
    expected = token_declarations(ios / "AIskin/DesignSystem/Foundation", ".swift")
    mapping = {}
    for owner, names in {
        "AISkinRadius": "medium card actionCard featureCard routineCard control",
        "AISkinSpacing": "xxxSmall xxSmall xSmall small medium large xLarge xxLarge xxxLarge screenEdge sectionGap cardPadding homeCardPadding routineRowPadding",
        "AISkinLayout": "headerHeight hairline actionTileHeight actionIconDiameter routineRowHeight routineCheckDiameter productThumbnailCabinet productThumbnailDetail captureGuideDiameter captureGuideInnerDiameter tabIndicatorWidth tabIndicatorHeight",
    }.items():
        mapping.update({f"{owner}.{name}": f"{owner}.{name}" for name in names.split()})
    mapping.update({f"AISkinLayout.{harmony}": f"AISkinLayout.{swift}" for harmony, swift in {
        "tap": "minimumTapHeight", "fieldHeight": "fieldMinimumHeight", "processingRing": "processingRingDiameter",
        "processingPanelWidth": "processingPanelMaxWidth", "progressStroke": "progressRingStroke",
        "productCardMinimumHeight": "cabinetCardMinimumHeight", "regularUnderlineHeight": "regularUnderlineTabHeight",
        "emphasisLine": "emphasisLineWidth", "tagHeight": "compactTagHeight", "regularTagHeight": "regularTagHeight",
    }.items()})
    for name in "goalGridGap noteHeight cycleFieldWidth".split():
        mapping[f"AISkinPlanInputTokens.{name}"] = f"AISkinAccountPlanTokens.{name}"
    for name in "profileCoverHeight avatarSize avatarOverlap avatarRadius avatarBorder profilePanelRadius profileSectionGap settingsHeight settingsIconWidth".split():
        mapping[f"AISkinAccountTokens.{name}"] = f"AISkinAccountPlanTokens.{name}"
    mapping.update({f"AISkinAccountTokens.{harmony}": f"AISkinAccountPlanTokens.{swift}" for harmony, swift in {
        "profileNameSize": "profileName", "avatarIconSize": "avatarIcon", "settingsTitleSize": "rowTitle", "sectionLabelSize": "sectionLabel",
    }.items()})
    results = []
    for harmony, swift in mapping.items():
        value, reference = numeric_value(actual, harmony), numeric_value(expected, swift)
        status = "not_verified" if value is None or reference is None else "match" if value == reference else "mismatch"
        results.append({"token": harmony, "ios_token": swift, "harmony": value, "ios": reference, "status": status})
    return results


def color_value(tokens: dict[str, str], key: str, seen: frozenset = frozenset()) -> tuple[int, int, int, int] | None:
    if key in seen or key not in tokens:
        return None
    expression = tokens[key]
    opacity = re.search(r"\.opacity\(([0-9.]+)\)", expression)
    alpha = float(opacity.group(1)) if opacity else 1.0
    base = expression[:opacity.start()] if opacity else expression
    components = re.fullmatch(r"Color\(red:\s*([0-9.]+),\s*green:\s*([0-9.]+),\s*blue:\s*([0-9.]+)\)", base)
    if components:
        return (round(alpha * 255), *(round(float(value) * 255) for value in components.groups()))
    if base == "Color.white":
        return (round(alpha * 255), 255, 255, 255)
    if re.fullmatch(r"\w+", base):
        reference = color_value(tokens, "AISkinColor." + base, seen | {key})
        if reference:
            return (round(reference[0] * alpha), *reference[1:])
    return None


def verify_colors(ios: Path) -> list[dict]:
    expected = token_declarations(ios / "AIskin/DesignSystem/Foundation", ".swift")
    palette_file = REPO / "entry/src/main/resources/base/element/color.json"
    actual = {item["name"]: item["value"] for item in json.loads(palette_file.read_text()).get("color", [])}
    mapping = {
        "top": "screenBaseTop", "middle": "screenBaseMiddle", "bottom": "screenBaseBottom",
        "glowLeft": "screenGlowTopLeading", "glowRight": "screenGlowTopTrailing", "glowMiddle": "screenGlowMiddleLower",
        "accent": "accent", "primary": "primaryAction", "text": "textPrimary", "secondary": "textSecondary",
        "surface": "surface", "featureSurface": "featureSurface", "routineSurface": "routineSurface",
        "elevated": "surfaceElevated", "muted": "surfaceMuted", "selected": "surfaceSelected",
        "border": "border", "divider": "divider", "scrim": "scrim", "danger": "destructive",
        "warning": "warning", "success": "success",
    }
    checks = []
    for harmony, swift in mapping.items():
        value = actual.get("aiskin_" + harmony, "")
        reference = color_value(expected, "AISkinColor." + swift)
        digits = value.removeprefix("#")
        if len(digits) == 6:
            digits = "FF" + digits
        channels = tuple(int(digits[index:index + 2], 16) for index in range(0, 8, 2)) if re.fullmatch(r"[0-9A-Fa-f]{8}", digits) else None
        # Swift's three-decimal RGB literals and 8-bit resources can differ by one quantization step.
        status = "not_verified" if channels is None or reference is None else "match" if max(abs(a-b) for a,b in zip(channels, reference)) <= 1 else "difference"
        color_name = "aiskin_" + harmony
        quantized = "#" + "".join(f"{channel:02X}" for channel in reference) if reference else None
        if status == "difference" and ACCESSIBILITY_DEVIATIONS.get(color_name) == (value.upper(), quantized):
            status = "accessibility_deviation"
        checks.append({"color": color_name, "ios_token": "AISkinColor." + swift, "harmony": value,
                       "ios_quantized_argb": quantized, "status": status,
                       "note": "Retained Huawei contrast remediation; an intentional parity deviation, not an iOS color match." if status == "accessibility_deviation" else ""})
    return checks


def revision(path: Path) -> str:
    try:
        result = subprocess.run(["git", "-C", str(path), "rev-parse", "HEAD"], capture_output=True, text=True, timeout=3)
        return result.stdout.strip() if result.returncode == 0 else "unavailable"
    except (OSError, subprocess.TimeoutExpired):
        return "unavailable"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ios-root", type=Path, default=REPO.parents[1] / "ios_aiskin")
    parser.add_argument("--strict-parity", action="store_true", help="Exit 1 for every reference deviation, including the retained Huawei accessibility palette")
    parser.add_argument("--json", action="store_true", help="Print all findings, parity checks, and call sites as JSON")
    args = parser.parse_args()
    findings, coverage, files = scan_business_sources()
    assets = verify_assets(args.ios_root)
    tokens = verify_tokens(args.ios_root)
    colors = verify_colors(args.ios_root)
    accessibility_deviations = sum(item["status"] == "accessibility_deviation" for item in colors)
    failed_parity = sum(item["status"] not in ("match", "accessibility_deviation") for item in assets + tokens + colors)
    report = {
        "scope": "source structure and reference parity only; not rendered visual acceptance",
        "ios_revision": revision(args.ios_root), "scanned_files": files,
        "builder_contract_scanned_files": len(list(FRONTEND.rglob("*.ets"))),
        "findings": findings, "assets": assets, "tokens": tokens, "light_palette": colors, "shared_call_sites": coverage,
        "summary": {"structural_pass": not findings, "findings": len(findings), "unreviewed_parity_failures_or_unverified": failed_parity,
                    "accessibility_deviations": accessibility_deviations, "strict_parity_pass": not failed_parity and not accessibility_deviations},
    }
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(f"Source structure audit: {files} frontend business files; iOS {report['ios_revision']}")
        print(f"Builder callback contracts: all {report['builder_contract_scanned_files']} frontend .ets files (including design/).")
        print("This report does not verify screenshots, interaction, or device appearance.")
        print(f"\nFindings ({len(findings)}):")
        for item in findings:
            print(f"  {item['path']}:{item['line']} [{item['rule']}] {item['expression']}")
        if not findings:
            print("  No occurrences of the explicitly scanned private modifiers, native controls, or bare builder callbacks.")
        print("\nReference asset byte hashes:")
        for item in assets:
            print(f"  {item['status']}: {item['asset']} {item.get('harmony_sha256', item.get('reason'))}")
        print(f"\nReference tokens: {sum(item['status'] == 'match' for item in tokens)}/{len(tokens)} matched")
        for item in tokens:
            if item["status"] != "match":
                print(f"  {item['status']}: {item['token']}={item['harmony']} vs {item['ios_token']}={item['ios']}")
        print(f"\nReference light palette: {sum(item['status'] == 'match' for item in colors)}/{len(colors)} matched (8-bit quantization tolerance: 1)")
        for item in colors:
            if item["status"] != "match":
                print(f"  {item['status']}: {item['color']}={item['harmony']} vs {item['ios_token']}={item['ios_quantized_argb']}")
        print("  Four exact contrast-remediation colors are retained accessibility warnings; all other differences fail. Use --strict-parity to reject every deviation.")
        print("\nShared call sites (facades included; zero direct page calls can be intentional):")
        for name, item in coverage.items():
            print(f"  {name}: {item['calls']} calls across {item['files']} files")
        print(f"\nStructural findings: {len(findings)}; unreviewed parity failures/unverified: {failed_parity}; retained accessibility deviations: {accessibility_deviations}")
    return 1 if findings or failed_parity or (args.strict_parity and accessibility_deviations) else 0


if __name__ == "__main__":
    raise SystemExit(main())
