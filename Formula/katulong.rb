class Katulong < Formula
  desc "Self-hosted web terminal with tmux sessions and WebAuthn security"
  homepage "https://github.com/Dorky-Robot/katulong"
  url "https://github.com/Dorky-Robot/katulong/archive/refs/tags/v0.41.4.tar.gz"
  sha256 "4195bc3ee56d3dd6e652c217d75b8b39992d1e5ccced9ce1d084b8ca81cedd39"
  license "MIT"

  depends_on "node"

  depends_on "tmux"

  def install
    system "npm", "install", "--omit=dev"
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/katulong"
  end

  def post_install
    # After brew upgrade the old server process may still be running (holding
    # the port) even though its Cellar path was removed.  Stop it first, then
    # start the new version.  The update command also handles this, so
    # post_install is a belt-and-suspenders safety net.
    katulong = bin/"katulong"
    if (Pathname.new(Dir.home) / "Library/LaunchAgents/com.dorkyrobot.katulong.plist").exist?
      system katulong, "service", "restart"
    else
      system katulong, "stop"
      system katulong, "start"
    end
  end

  def caveats
    <<~EOS
      To auto-start katulong on login:
        katulong service install

      To restart after upgrading (if not using the service):
        katulong start

      If the service is installed, brew upgrade restarts it automatically.
    EOS
  end

  test do
    assert_match "katulong", shell_output("#{bin}/katulong --help")
  end
end
