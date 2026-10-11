class Loupe < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent with coordinated sessions"
  homepage "https://github.com/bkavuri-hwlr1/loupe"
  version "0.1.0a2"

  bottle do
    root_url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b809e15062369643030ed5fc044501f04b074dd8130419fd3864ee911ea49246"
    sha256 cellar: :any_skip_relocation, sequoia:       "282b252d71201559cee2cd82666de0981dfbe4c32690a054bf61cb5ffb631219"
  end

  depends_on "git"
  depends_on macos: :sequoia
  depends_on "python@3.14"

  on_macos do
    on_arm do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a2/loupe-0.1.0a2-macos-arm64.tar.gz"
      sha256 "a25fc37710b97c7bd2a9714b1ce6abc9c03aa5e64446f61d220ea4e21712bf7c"
    end
    on_intel do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a2/loupe-0.1.0a2-macos-x86_64.tar.gz"
      sha256 "1c7bda9aaaaf381198b66b779a0491120f93823ca318b44b648953e82523b246"
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
