class Loupe < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent with coordinated sessions"
  homepage "https://github.com/bkavuri-hwlr1/loupe"
  version "0.1.0a4"

  bottle do
    root_url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d9982c81900d7f4fc861b3abbbfd142b93824c44754f0d12167db57ec289dee2"
    sha256 cellar: :any_skip_relocation, sequoia:       "920f280f2c6eff6c9c0183f83947146682a455a06d26494fdfb935b83b02339b"
  end

  depends_on "git"
  depends_on macos: :sequoia
  depends_on "python@3.14"

  on_macos do
    on_arm do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a4/loupe-0.1.0a4-macos-arm64.tar.gz"
      sha256 "0fbeee4adfd0543dfde8a40077eecade6a97d067c661fa1c12d64cfe782a986b"
    end
    on_intel do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a4/loupe-0.1.0a4-macos-x86_64.tar.gz"
      sha256 "0de7afd7a9c75bea0db537c6044a22c63a6d624ac5d2f55af4be2e3e29248cc8"
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
    # brew test's macOS sandbox blocks the Unix socket the background service
    # listens on. The tap's publish workflow runs the full smoke test outside it.
    ENV["LOUPE_SMOKE_NO_SERVICE"] = "1"
    system libexec/"bin/python", pkgshare/"smoke_test.py", bin, version.to_s
  end
end
