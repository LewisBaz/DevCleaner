## DevCleaner
### Overview
DevCleaner is a lightweight macOS utility that helps you free up disk space by removing automatically generated files created by Xcode — such as caches, device support files, archives, derived data, and other leftovers that tend to accumulate over time and take up gigabytes of storage.
### Features
- Derived Data — clean up cached data for autocomplete, intermediate build files, and more.
- Archives — review and delete unused build archives.
- Device Support — safely remove old device symbols.
- Simulator Previews & Data — remove old simulator previews and data.
### Compatibility
- Require macOS 15.x and higher.
### Installation
#### Option 1: Install from terminal (recommended)
1. Clone repository.
2. Run `chmod +x scripts/install.sh && ./scripts/install.sh`
   - If your Mac has no development certificate, the script automatically falls back to local ad-hoc signing.
3. Open app: `open /Applications/DevCleaner.app`
4. If macOS asks for confirmation, allow it in Settings > Privacy & Security.

#### Option 2: Install from ZIP
1. Download `DevCleaner-<version>.zip` from Releases.
2. Unpack archive (`double click` or `unzip DevCleaner-<version>.zip`).
3. Move `DevCleaner.app` to `/Applications`.
4. Open app: `open /Applications/DevCleaner.app`
5. If macOS asks for confirmation, allow it in Settings > Privacy & Security.

### Distribution
#### Build release artifact (ZIP)
1. Run `chmod +x scripts/package-release.sh`
2. Run `./scripts/package-release.sh`
3. Share `DevCleaner-<version>.zip` from `dist/`
4. Optional DMG: `CREATE_DMG=1 ./scripts/package-release.sh`

#### Optional: sign artifacts
Use your Developer ID certificate:
`SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/package-release.sh`

#### Publish flow (recommended)
1. Upload `DevCleaner-<version>.zip` from `dist/` to GitHub Releases.
2. Add SHA256 checksums shown by the script to release notes.
3. Instruct users to install by unzipping `DevCleaner.app` and moving it to `/Applications`.
### Usage
1. Launch DevCleaner.
2. Select DevCleaner at top bar.
3. Enable `Launch at Login` in the menu to keep the app available after reboot.
4. Delete what you prefer or clean all.
### Why DevCleaner?
Xcode generates large amounts of cached and temporary data that is rarely cleaned up automatically. Over time, this can consume tens or even hundreds of gigabytes of disk space. DevCleaner provides a simple, safe, and efficient way to regain that storage.
### Contributing
Contributions, ideas, and bug reports are welcome! Please open an Issue or submit a Pull Request.
### License
This project is licensed under the MIT License.
