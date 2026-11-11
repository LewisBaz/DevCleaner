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
#### Option 1: Homebrew (recommended)
```bash
git clone https://github.com/LewisBaz/DevCleaner.git
cd DevCleaner
chmod +x scripts/brew-install.sh
./scripts/brew-install.sh
```
This taps the cask, installs it, and self-heals the common "Homebrew thinks it's installed but the app is missing" state (e.g. after you removed the app by hand instead of via `brew uninstall`) automatically. Read the script before running it, as with any install script.

If you'd rather run the steps yourself:
```bash
brew tap LewisBaz/devcleaner https://github.com/LewisBaz/DevCleaner
brew install --cask dev-cleaner
open /Applications/DevCleaner.app
```
> Notes:
> - The cask token is `dev-cleaner` (hyphenated), not `devcleaner` — that name is already taken in Homebrew's official cask repository by an unrelated app.
> - If install fails with `Refusing to load cask ... from untrusted tap` (some Homebrew versions require explicit trust for third-party taps), run `brew trust --cask lewisbaz/devcleaner/dev-cleaner` and retry.
> - DevCleaner is signed with an ad-hoc signature, not notarized by Apple, so the first launch will be blocked by Gatekeeper. Allow it once with `xattr -cr /Applications/DevCleaner.app`, or right-click the app in Finder and choose Open.
> - If you removed the app manually and `brew install`/`brew upgrade` now seems to do nothing, run `brew reinstall --cask dev-cleaner` (or just re-run the script above).

To update later: `brew upgrade --cask dev-cleaner`. To remove: `brew uninstall --cask dev-cleaner`.

#### Option 2: Install from terminal
1. Clone repository.
2. Open repository `cd DevCleaner`
3. Run `chmod +x scripts/install.sh && ./scripts/install.sh`
   - If your Mac has no development certificate, the script automatically falls back to local ad-hoc signing.
4. Open app: `open /Applications/DevCleaner.app`
5. If macOS asks for confirmation, allow it in Settings > Privacy & Security.
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
