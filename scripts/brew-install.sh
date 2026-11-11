#!/usr/bin/env bash

set -euo pipefail

TAP="LewisBaz/devcleaner"
TAP_URL="https://github.com/LewisBaz/DevCleaner"
CASK="dev-cleaner"
APP_PATH="/Applications/DevCleaner.app"

if ! command -v brew &>/dev/null; then
  echo "Homebrew is not installed. Install it from https://brew.sh first." >&2
  exit 1
fi

echo "Tapping $TAP..."
brew tap "$TAP" "$TAP_URL"

install_cask() {
  brew install --cask "$CASK"
}

echo "Installing $CASK..."
if ! install_cask; then
  echo "Install failed — checking whether the tap needs to be trusted..."
  if brew trust --cask "$TAP/$CASK" 2>/dev/null; then
    echo "Trusted. Retrying install..."
    install_cask
  else
    echo "Install failed for a reason other than tap trust. See the output above." >&2
    exit 1
  fi
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Homebrew reports $CASK as installed, but $APP_PATH is missing"
  echo "(this happens if the app was previously removed by hand instead of"
  echo "via 'brew uninstall'). Repairing with a forced reinstall..."
  brew reinstall --cask "$CASK"
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Still missing $APP_PATH after reinstall — something else is wrong." >&2
  echo "Try: brew uninstall --cask $CASK --force && brew install --cask $CASK" >&2
  exit 1
fi

echo "Clearing Gatekeeper quarantine flag (app is ad-hoc signed, not notarized)..."
xattr -cr "$APP_PATH"

echo "Launching DevCleaner..."
open "$APP_PATH"

echo "Done. DevCleaner is installed at $APP_PATH."
