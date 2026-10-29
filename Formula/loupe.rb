class Loupe < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent with coordinated sessions"
  homepage "https://github.com/bkavuri-hwlr1/loupe"
  version "0.1.0a3"

  bottle do
    root_url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a8b7a67f422544067803a57601a37c7d565b3726bdbc9d3cdccc7c5b62f7e47e"
    sha256 cellar: :any_skip_relocation, sequoia:       "c3339b28b27602311c17375e7a3688fa535a20f72b6cb5c0c87f6080a710b4ab"
  end

  depends_on "git"
  depends_on macos: :sequoia
  depends_on "python@3.14"

  on_macos do
    on_arm do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a3/loupe-0.1.0a3-macos-arm64.tar.gz"
      sha256 "eb9cb28c3e59c258cf99b720f8a88cb637c0d9276ddac4b2faba34f1c1f13f0f"
    end
    on_intel do
      url "https://github.com/bkavuri-hwlr1/homebrew-tap/releases/download/v0.1.0a3/loupe-0.1.0a3-macos-x86_64.tar.gz"
      sha256 "7e76f865b77f1541933c0b300ea182a42bbea97deef5cb6965162b5e8861938f"
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
