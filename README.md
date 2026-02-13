# Katulong Homebrew Formula

This directory contains the Homebrew formula for installing Katulong.

## For Users

### Installation

```bash
# Add the tap
brew tap dorky-robot/katulong

# Install katulong
brew install katulong
```

#### ⚠️ Known Issue: macOS 26.x Beta (Sequoia RC)

If you're running **macOS 26.x beta** and get this error:

```
Error: Your Xcode (16.2) is too outdated.
Please update to Xcode 26.0 (or delete it).
```

This is a **Homebrew bug** - Xcode 26.0 doesn't exist. Homebrew is confusing the macOS version with the Xcode requirement.

**Workaround - Automated Install Script:**

```bash
curl -fsSL https://raw.githubusercontent.com/dorky-robot/homebrew-katulong/master/install.sh | bash
```

Or **manual installation:**

```bash
# Clone the repository
git clone https://github.com/dorky-robot/katulong.git
cd katulong

# Install dependencies
npm install --production --omit=dev --ignore-scripts
chmod +x node_modules/node-pty/prebuilds/*/spawn-helper 2>/dev/null || true

# Create symlink
mkdir -p ~/.local/bin
ln -sf "$(pwd)/bin/katulong" ~/.local/bin/katulong

# Add to PATH (add this to your ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
katulong --version
```

This issue will be resolved when Homebrew updates to support macOS 26.x beta.

### Usage

```bash
# Start Katulong
katulong start

# Or use Homebrew services for auto-start on login
brew services start katulong

# Check status
katulong status

# View logs
katulong logs

# Stop Katulong
katulong stop
# or
brew services stop katulong
```

## For Maintainers

### Creating a Release

1. **Update version in package.json** (in main katulong repo)
   ```bash
   # Update version to 0.1.0
   npm version 0.1.0 --no-git-tag-version
   ```

2. **Create and push git tag** (in main katulong repo)
   ```bash
   git add package.json
   git commit -m "Release v0.1.0"
   git tag v0.1.0
   git push origin main --tags
   ```

3. **Compute SHA256 hash**
   ```bash
   # Download the tarball
   wget https://github.com/dorky-robot/katulong/archive/refs/tags/v0.1.0.tar.gz

   # Compute hash
   shasum -a 256 v0.1.0.tar.gz
   ```

4. **Update formula** (in homebrew-katulong repo)
   - Update `url` in Formula/katulong.rb with correct version
   - Update `sha256` with computed hash
   - Remove any old `bottle do ... end` block (will be regenerated)
   - Commit and push changes

5. **Build bottles automatically**

   Bottles are built automatically via GitHub Actions when you push to master/main:
   - Builds for macOS ARM (Sequoia, Sonoma) and Intel (Ventura)
   - Uploads bottles to GitHub Releases
   - Updates formula with bottle metadata

   Check the Actions tab to monitor progress: https://github.com/Dorky-Robot/homebrew-katulong/actions

6. **Test installation**
   ```bash
   # Uninstall old version
   brew uninstall katulong

   # Update tap and install with bottle
   brew update
   brew install dorky-robot/katulong/katulong

   # Verify it used a bottle (should NOT compile anything)
   katulong --version
   katulong start
   katulong status
   brew services start katulong
   brew services list | grep katulong
   ```

### Manual Bottle Building

If you need to build bottles manually:

```bash
# Build bottle for current platform
brew install --build-bottle dorky-robot/katulong/katulong
brew bottle --json dorky-robot/katulong/katulong

# This creates:
# - katulong--0.1.0.{platform}.bottle.tar.gz
# - katulong--0.1.0.{platform}.bottle.json

# Upload the .tar.gz to GitHub Releases
gh release upload v0.1.0 katulong--*.bottle.tar.gz

# Merge the bottle metadata into formula
brew bottle --merge --write katulong--*.bottle.json

# Commit and push the updated formula
git add Formula/katulong.rb
git commit -m "Add bottle for macOS {platform}"
git push
```

### Setting Up the Tap

For the first release, create the tap repository:

```bash
# Create a new repository: dorky-robot/homebrew-katulong
# Copy Formula/katulong.rb to the tap repository

cd ../homebrew-katulong
mkdir -p Formula
cp ../katulong/Formula/katulong.rb Formula/
git add Formula/katulong.rb
git commit -m "Add katulong formula"
git push origin main
```

## Formula Details

### Installation Paths

- **Binary:** `/usr/local/bin/katulong` (or `/opt/homebrew/bin/katulong` on Apple Silicon)
- **App files:** `/usr/local/opt/katulong/` (or `/opt/homebrew/opt/katulong/`)
- **Config/data:** `~/.config/katulong/`
- **Logs:** `~/.config/katulong/daemon.log` and `server.log`

### Service Integration

The formula includes a `service` block for `brew services` integration:

```bash
brew services start katulong   # Start and enable auto-start
brew services stop katulong    # Stop and disable auto-start
brew services restart katulong # Restart service
brew services list             # Show all services
```

The service runs with:
- **Keep alive:** Service restarts if it crashes
- **Log path:** `/usr/local/var/log/katulong.log` (or `/opt/homebrew/var/log/`)
- **Environment:** Sets `KATULONG_DATA_DIR` to `~/.config/katulong`

### Environment Variables

The wrapper script sets:
- `KATULONG_DATA_DIR=~/.config/katulong` - Config and data directory

Users can override by setting environment variables before running `katulong`:

```bash
export PORT=8080
export KATULONG_DATA_DIR=/custom/path
katulong start
```

## Troubleshooting

### Formula Audit

Before submitting to Homebrew core:

```bash
brew audit --strict --online katulong
brew test katulong
```

### Common Issues

**Issue:** `katulong` command not found after install

**Solution:** Ensure `/usr/local/bin` is in PATH:
```bash
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Issue:** Permission denied on `~/.config/katulong`

**Solution:** Fix directory permissions:
```bash
chmod 700 ~/.config/katulong
```

**Issue:** Service won't start

**Solution:** Check service logs:
```bash
tail -f /usr/local/var/log/katulong.log
# or
katulong logs
```
