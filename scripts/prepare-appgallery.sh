#!/bin/bash
# Single local release entry point. Materials/signature/production verification
# remain required after compilation; this script never uploads or submits a build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
python3 scripts/check-appgallery.py
if [ -n "${AISKIN_IOS_ROOT:-}" ]; then
  python3 scripts/check-design-system.py --ios-root "$AISKIN_IOS_ROOT"
else
  python3 scripts/check-design-system.py
fi
node --test scripts/tests/*.test.cjs
git diff --check
./scripts/build-local.sh production
BUILD_DIR="${AISKIN_BUILD_DIR:-$HOME/DevEcoStudioProjects/AIskin-HarmonyOS-Build}"
HAP="${AISKIN_REVIEW_HAP:-$BUILD_DIR/entry/build/default/outputs/default/entry-default-unsigned.hap}"
if [ -z "${AISKIN_REVIEW_EVIDENCE:-}" ]; then
  python3 scripts/check-appgallery.py --release --hap "$HAP"
else
  python3 scripts/check-appgallery.py --release --hap "$HAP" --evidence "$AISKIN_REVIEW_EVIDENCE"
fi
