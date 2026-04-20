#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/DevCleaner.xcodeproj"
SCHEME="DevCleaner"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.build/DerivedData}"
BUILD_OUTPUT_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION"
APP_NAME="DevCleaner.app"
SOURCE_APP_PATH="$BUILD_OUTPUT_PATH/$APP_NAME"
TARGET_APP_PATH="/Applications/$APP_NAME"

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

if [[ ! -d "$SOURCE_APP_PATH" ]]; then
  echo "Build succeeded but app bundle was not found at $SOURCE_APP_PATH"
  echo "See build logs at /tmp/devcleaner-build.log"
  exit 1
fi

echo "Cleaning extended attributes..."
xattr -cr "$SOURCE_APP_PATH"

echo "Applying local ad-hoc signature..."
if ! codesign --force --deep --sign - "$SOURCE_APP_PATH"; then
  echo "Ad-hoc signing failed."
  echo "Inspect build logs at /tmp/devcleaner-build.log"
  exit 1
fi

echo "Installing to $TARGET_APP_PATH..."
rm -rf "$TARGET_APP_PATH"
ditto "$SOURCE_APP_PATH" "$TARGET_APP_PATH"

echo "Installed successfully."
echo "Run with: open \"$TARGET_APP_PATH\""
