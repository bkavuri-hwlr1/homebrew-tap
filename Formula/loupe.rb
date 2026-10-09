class Loupe < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent with coordinated sessions"
  homepage "https://github.com/bkavuri-hwlr1/loupe"
  version "0.1.0a1"

  bottle do
    root_url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4d6f96a2bb3db2fd42bfb8fe05ada6d46eeaffdb3f317c6cee8d9ce1a43aec4e"
    sha256 cellar: :any_skip_relocation, sequoia:       "2b509da98c2e95195244eb67bfd303ec65a9fb8637747f77af1852d2fe1ce95e"
  end

  depends_on "git"
  depends_on macos: :sequoia
  depends_on "python@3.14"

  on_macos do
    on_arm do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a1/loupe-0.1.0a1-macos-arm64.tar.gz"
      sha256 "553a1c4b9fca6acfa85dbda48efb0977ea701944e38682c8ee91bd3d2410de06"
    end
    on_intel do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a1/loupe-0.1.0a1-macos-x86_64.tar.gz"
      sha256 "1b2789c1391ab9c071b44dec023c95dd25e76c74c9f7642bd4a0ca69389f975b"
    end
  end

  # The prebuilt Python extensions already use relocatable @rpath IDs. Their
  # Mach-O headers do not reserve space for Homebrew's longer absolute IDs.
  preserve_rpath

  def install
    # The archive contains the exact, hash-verified runtime wheels from uv.lock.
    # Never resolve or download dependencies during installation.
    ENV["PIP_NO_INDEX"] = "1"
    venv = virtualenv_create(libexec, "python3.14", system_site_packages: false)
    venv.pip_install Dir[buildpath/"wheels/*.whl"], build_isolation: false
    %w[loupe louped llm-coord llm-coordd].each do |command|
      bin.install_symlink libexec/"bin"/command
    end
    pkgshare.install "manifest.json", "smoke_test.py"
  end

  def caveats
    <<~EOS
      Start Loupe with: loupe
      Connect an account with /login inside the app.

      Before upgrading or uninstalling, finish active tasks, exit Loupe,
      and stop each profile's daemon: loupe --profile NAME daemon stop
      Your next task starts the updated daemon. User data is preserved.
    EOS
  end

  test do
    # brew test puts Homebrew's internal shims first on PATH, and their git
    # runs only inside brew. Find the real git first, as a user's shell does.
    ENV.prepend_path "PATH", formula_opt_bin("git")
    system libexec/"bin/python", pkgshare/"smoke_test.py", bin, version.to_s
  end
end
