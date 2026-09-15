#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STUDIO="${DEVECO_STUDIO_HOME:-/Applications/DevEco-Studio.app}"
BUILD_DIR="${AISKIN_BUILD_DIR:-$HOME/DevEcoStudioProjects/AIskin-HarmonyOS-Build}"
MODE="${1:-production}"
case "$MODE" in production|local|preview) ;; *) echo 'Usage: build-local.sh [production|local|preview]' >&2; exit 2 ;; esac
BUILD_MODE=release
if [ "$MODE" != production ]; then BUILD_MODE=debug; fi
export JAVA_HOME="$STUDIO/Contents/jbr/Contents/Home"
export DEVECO_SDK_HOME="$STUDIO/Contents/sdk"
python3 - "$ROOT" "$BUILD_DIR" <<'PY'
from pathlib import Path
import sys
source,build=map(lambda p:Path(p).resolve(),sys.argv[1:])
if not str(build).isascii() or source==build or source in build.parents:
    raise SystemExit('AISKIN_BUILD_DIR must be an isolated ASCII path outside the source checkout')
PY
mkdir -p "$BUILD_DIR"
# A disposable build copy avoids hvigor's restriction on Chinese project paths.
# Copy source afresh so local endpoints or temporary test prefills cannot survive.
rsync -a --exclude '.git' --exclude '.idea' --exclude '.hvigor' --exclude node_modules \
  --exclude oh_modules --exclude build --exclude doc --exclude scripts --exclude output \
  "$ROOT/" "$BUILD_DIR/"
# Remove obsolete application sources/resources only inside the build copy.
rsync -a --delete "$ROOT/entry/src/" "$BUILD_DIR/entry/src/"
rsync -a --delete "$ROOT/AppScope/" "$BUILD_DIR/AppScope/"
if [ "$MODE" != production ]; then
  python3 - "$BUILD_DIR/entry/src/main/ets/services/ApiConfig.ets" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]);p.write_text(p.read_text().replace('https://www.lunzo.site/api','http://127.0.0.1:5001/api'))
PY
fi
if [ "$MODE" = preview ]; then
  python3 - "$BUILD_DIR/entry/src/main/ets/services/ApiConfig.ets" <<'PYBUILD'
from pathlib import Path
import sys
p=Path(sys.argv[1]);p.write_text(p.read_text().replace('ENABLE_COMPONENT_PREVIEW: boolean = false','ENABLE_COMPONENT_PREVIEW: boolean = true'))
PYBUILD
fi
cd "$BUILD_DIR"
"$STUDIO/Contents/tools/ohpm/bin/ohpm" install
"$STUDIO/Contents/tools/hvigor/bin/hvigorw" --mode module -p product=default -p buildMode="$BUILD_MODE" assembleHap --no-daemon
