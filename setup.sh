#!/usr/bin/env bash
# ILMS project setup / release helper.
#
# Order: gather every answer first (build number, version bump, whether to
# build, apk/aab, flavor), print a summary, confirm once, THEN run
# everything — clean, pub get, pod install, version bump, build — with no
# further prompts in between.
set -euo pipefail

cd "$(dirname "$0")"

PUBSPEC="pubspec.yaml"

command -v flutter >/dev/null 2>&1 || {
  echo "flutter is not on PATH." >&2
  exit 1
}

version_line() { grep -m1 '^version:' "$PUBSPEC"; }
current_version() { version_line | sed -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$/\1/'; }
current_build() { version_line | sed -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$/\2/'; }

# Mirrors the per-flavor app_name in android/app/flavorizr.gradle.kts and
# F.title in lib/flavors.dart — keep these three in sync if the app name
# ever changes.
app_name_for_flavor() {
  case "$1" in
  dev) echo "ILMS Dev" ;;
  stg) echo "ILMS Stg" ;;
  prod) echo "ILMS" ;;
  esac
}

CUR_VERSION="$(current_version)"
CUR_BUILD="$(current_build)"

echo "=== ILMS Setup ==="
echo "Current pubspec version: $CUR_VERSION+$CUR_BUILD"
echo

# ---------------------------------------------------------------------------
# 1) Gather every answer up front — nothing runs yet.
# ---------------------------------------------------------------------------

read -rp "New build number [blank = keep $CUR_BUILD]: " NEW_BUILD
if [[ -z "$NEW_BUILD" ]]; then
  NEW_BUILD="$CUR_BUILD"
elif ! [[ "$NEW_BUILD" =~ ^[0-9]+$ ]]; then
  echo "Build number must be a positive integer." >&2
  exit 1
fi

echo
echo "Version: type 'patch' to auto-bump the patch number,"
echo "or type a full version (e.g. 1.2.0) for a minor/major bump."
read -rp "New version [blank = keep $CUR_VERSION]: " VERSION_INPUT
if [[ -z "$VERSION_INPUT" ]]; then
  NEW_VERSION="$CUR_VERSION"
elif [[ "$VERSION_INPUT" == "patch" ]]; then
  IFS='.' read -r MAJOR MINOR PATCH <<<"$CUR_VERSION"
  NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
elif [[ "$VERSION_INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  NEW_VERSION="$VERSION_INPUT"
else
  echo "Invalid version — use 'patch' or X.Y.Z (e.g. 1.2.0)." >&2
  exit 1
fi

echo
read -rp "Build the app now? [y/N]: " DO_BUILD
DO_BUILD="${DO_BUILD:-n}"

BUILD_FORMAT=""
FLAVOR="dev"
if [[ "$DO_BUILD" =~ ^[Yy] ]]; then
  read -rp "Build format - apk or aab? [apk]: " BUILD_FORMAT
  BUILD_FORMAT="${BUILD_FORMAT:-apk}"
  if [[ "$BUILD_FORMAT" != "apk" && "$BUILD_FORMAT" != "aab" ]]; then
    echo "Invalid build format — must be 'apk' or 'aab'." >&2
    exit 1
  fi

  read -rp "Flavor - dev, stg, or prod? [dev]: " FLAVOR
  FLAVOR="${FLAVOR:-dev}"
  if [[ "$FLAVOR" != "dev" && "$FLAVOR" != "stg" && "$FLAVOR" != "prod" ]]; then
    echo "Invalid flavor — must be dev, stg, or prod." >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# 2) Summary + single confirmation before anything actually runs.
# ---------------------------------------------------------------------------

echo
echo "=== Summary ==="
echo "Version:  $CUR_VERSION+$CUR_BUILD -> $NEW_VERSION+$NEW_BUILD"
if [[ "$DO_BUILD" =~ ^[Yy] ]]; then
  echo "Build:    $BUILD_FORMAT ($FLAVOR, release)"
  echo "Output:   ./$BUILD_FORMAT/$(app_name_for_flavor "$FLAVOR")($NEW_VERSION($NEW_BUILD))-$(date +%Y-%m-%d).$BUILD_FORMAT"
else
  echo "Build:    skipped"
fi
echo

read -rp "Proceed? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-y}"
if ! [[ "$CONFIRM" =~ ^[Yy] ]]; then
  echo "Cancelled — nothing was changed."
  exit 0
fi

# ---------------------------------------------------------------------------
# 3) Run everything, no more prompts.
# ---------------------------------------------------------------------------

echo
echo ">> flutter clean"
flutter clean

echo ">> flutter pub get"
flutter pub get

if [[ "$(uname)" == "Darwin" && -f ios/Podfile ]]; then
  echo ">> pod install"
  # Non-fatal: an Android-only build shouldn't die because CocoaPods (or the
  # Podfile) isn't set up on this machine.
  if ! (cd ios && pod install); then
    echo "!! pod install failed — continuing (this only matters for iOS builds)." >&2
  fi
else
  echo ">> Skipping pod install (not macOS, or no ios/Podfile)"
fi

if [[ "$NEW_VERSION+$NEW_BUILD" != "$CUR_VERSION+$CUR_BUILD" ]]; then
  echo ">> Updating pubspec.yaml -> version: $NEW_VERSION+$NEW_BUILD"
  sed -i.bak -E "s/^version:.*/version: $NEW_VERSION+$NEW_BUILD/" "$PUBSPEC"
  rm -f "$PUBSPEC.bak"
else
  echo ">> Version unchanged ($CUR_VERSION+$CUR_BUILD)"
fi

if [[ "$DO_BUILD" =~ ^[Yy] ]]; then
  case "$BUILD_FORMAT" in
  apk) TARGET="apk" ;;
  aab) TARGET="appbundle" ;;
  esac

  echo ">> flutter build $TARGET --flavor $FLAVOR --release --dart-define=APP_FLAVOR=$FLAVOR"
  flutter build "$TARGET" --flavor "$FLAVOR" --release --dart-define=APP_FLAVOR="$FLAVOR"

  # ---- Copy + rename the build output ----
  APP_NAME="$(app_name_for_flavor "$FLAVOR")"
  OUT_NAME="${APP_NAME}(${NEW_VERSION}(${NEW_BUILD}))-$(date +%Y-%m-%d)"

  if [[ "$BUILD_FORMAT" == "apk" ]]; then
    SRC="build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
    DEST_DIR="apk"
  else
    SRC="build/app/outputs/bundle/${FLAVOR}Release/app-${FLAVOR}-release.aab"
    DEST_DIR="aab"
  fi

  if [[ ! -f "$SRC" ]]; then
    # Fall back to a search in case this Flutter/AGP version names the
    # output differently than the convention above.
    SRC="$(find build/app/outputs -iname "*.${BUILD_FORMAT}" -print -quit)"
  fi

  if [[ -z "${SRC:-}" || ! -f "$SRC" ]]; then
    echo "!! Could not find the built .$BUILD_FORMAT under build/app/outputs — skipping copy." >&2
  else
    mkdir -p "$DEST_DIR"
    DEST="$DEST_DIR/${OUT_NAME}.${BUILD_FORMAT}"
    cp "$SRC" "$DEST"
    echo ">> Copied build to $DEST"
  fi
fi

echo
echo "Done."
