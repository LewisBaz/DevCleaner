#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/DevCleaner.xcodeproj"
SCHEME="DevCleaner"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.build/DerivedData}"
BUILD_OUTPUT_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION"
APP_NAME="DevCleaner.app"
APP_PATH="$BUILD_OUTPUT_PATH/$APP_NAME"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
VERSION="${VERSION:-$(date +%Y.%m.%d)}"
ARCHIVE_NAME="DevCleaner-$VERSION"
ZIP_PATH="$DIST_DIR/$ARCHIVE_NAME.zip"
SIGN_IDENTITY="${SIGN_IDENTITY:-}"
CREATE_DMG="${CREATE_DMG:-0}"
DMG_PATH="$DIST_DIR/$ARCHIVE_NAME.dmg"
DMG_VOLUME_NAME="DevCleaner"

mkdir -p "$DIST_DIR"

echo "Building $APP_NAME ($CONFIGURATION)..."
if ! xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build \
  >/tmp/devcleaner-build.log; then
  echo "Default build failed (likely code signing). Retrying with local ad-hoc signing..."
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    build \
    >>/tmp/devcleaner-build.log
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Build succeeded but app bundle was not found at $APP_PATH"
  echo "See build logs at /tmp/devcleaner-build.log"
  exit 1
fi

echo "Cleaning extended attributes..."
xattr -cr "$APP_PATH"

if [[ -n "$SIGN_IDENTITY" ]]; then
  echo "Signing app with identity: $SIGN_IDENTITY"
  codesign --force --deep --timestamp --options runtime --sign "$SIGN_IDENTITY" "$APP_PATH"
else
  echo "Applying local ad-hoc signature..."
  codesign --force --deep --sign - "$APP_PATH"
fi

echo "Preparing release artifacts in $DIST_DIR..."
rm -f "$ZIP_PATH"
if [[ "$CREATE_DMG" == "1" ]]; then
  rm -f "$DMG_PATH"
fi

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

if [[ "$CREATE_DMG" == "1" ]]; then
  TMP_DMG_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DMG_DIR"' EXIT

  ditto "$APP_PATH" "$TMP_DMG_DIR/$APP_NAME"
  ln -s /Applications "$TMP_DMG_DIR/Applications"

  hdiutil create \
    -volname "$DMG_VOLUME_NAME" \
    -srcfolder "$TMP_DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH" \
    >/tmp/devcleaner-dmg.log

  if [[ -n "$SIGN_IDENTITY" ]]; then
    echo "Signing dmg with identity: $SIGN_IDENTITY"
    codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG_PATH"
  fi
fi

echo "Done."
echo "ZIP: $ZIP_PATH"
echo "Checksums:"
if [[ "$CREATE_DMG" == "1" ]]; then
  echo "DMG: $DMG_PATH"
  shasum -a 256 "$ZIP_PATH" "$DMG_PATH"
else
  shasum -a 256 "$ZIP_PATH"
fi
