cask "dev-cleaner" do
  version "1.0.0"
  sha256 "be6fc58a6e7847478cfc302fdf4a76d922c700468d78f86aecf488ccd53b2382"

  url "https://github.com/LewisBaz/DevCleaner/releases/download/v#{version}/DevCleaner-#{version}.zip"
  name "DevCleaner"
  desc "Menu bar utility for clearing Xcode caches, DerivedData, simulators and more"
  homepage "https://github.com/LewisBaz/DevCleaner"

  depends_on macos: :sequoia

  app "DevCleaner.app"

  postflight do
    system_command "/usr/bin/xattr",
                    args: ["-cr", "#{appdir}/DevCleaner.app"],
                    sudo: false
  end
end
