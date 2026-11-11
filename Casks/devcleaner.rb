cask "devcleaner" do
  version "1.0.0"
  sha256 "792264db88a177170155a6e4d18564d5e7534f24edbf35b1825fed8013df5dca"

  url "https://github.com/LewisBaz/DevCleaner/releases/download/v#{version}/DevCleaner-#{version}.zip"
  name "DevCleaner"
  desc "Menu bar utility for clearing Xcode caches, DerivedData, simulators and more"
  homepage "https://github.com/LewisBaz/DevCleaner"

  depends_on macos: ">= :sequoia"

  app "DevCleaner.app"

  caveats <<~EOS
    DevCleaner is signed with an ad-hoc signature (not notarized by Apple),
    so macOS Gatekeeper will block the first launch. Allow it once with:

      xattr -cr "#{appdir}/DevCleaner.app"

    or right-click the app in Finder and choose Open.
  EOS
end
