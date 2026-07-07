# Complete Setup & Architecture Guide

See [TREE.md](TREE.md) for project structure overview.

---

## Quick Start (5 minutes)

### Prerequisites
```bash
# Install FUSE (required for AppImage)
sudo apt install fuse       # Ubuntu/Debian
sudo dnf install fuse       # Fedora
```

### Install Globally
```bash
cd /path/to/perssua-app
make install-user           # Install to ~/.local/bin/perssua
```

### Launch
```bash
perssua                     # Works from anywhere!
```

**First run:** ~8-15 seconds (extraction)  
**Subsequent runs:** ~2-3 seconds

---

## Installation Methods

### Option 1: Make (Recommended)
```bash
make install-user      # Install for current user
# or
make install-system    # Install system-wide (requires sudo)
```

### Option 2: Direct Script
```bash
./bin/setup.sh --user      # Current user only
./bin/setup.sh --system    # System-wide (requires sudo)
```

### Option 3: Direct Execution
```bash
./bin/perssua          # Run from project directory
```

### Option 4: No Installation
```bash
./bin/perssua          # Works without global install
```

---

## Common Commands

```bash
# Launch
make up                     # or: perssua

# Check status
make config                 # or: perssua --config

# Debug mode
make debug                  # or: PERSSUA_DEBUG=1 perssua

# Show version
make version                # or: perssua --version

# Show help
make help                   # or: perssua --help

# Install/uninstall
make install-user
make uninstall
```

---

## Environment Variables

### Configuration

```bash
# Override data directory (default: data/)
export PERSSUA_DATA_DIR="/tmp/perssua-test"
perssua

# Enable debug logging
export PERSSUA_DEBUG=1
perssua
```

### Persistent Setup

Add to `~/.bashrc` or `~/.zshrc`:
```bash
export PERSSUA_DATA_DIR="$HOME/.config/perssua"
export PERSSUA_DEBUG=0
```

Then reload:
```bash
source ~/.bashrc
```

---

## Architecture Details

### Execution Flow

```
User runs: perssua
    ↓
Shell resolves → ~/.local/bin/perssua (symlink)
    ↓
Symlink points to → /path/to/project/bin/perssua
    ↓
bin/perssua script:
    1. Parse arguments (--version, --help, --config, etc.)
    2. Validate prerequisites (FUSE installed?)
    3. Extract AppImage if needed
       - From: bin/Perssua-0.23.3-x86_64.AppImage
       - To: data/squashfs-root/
       - When: First run or if binary is newer
    4. Configure chrome-sandbox (one-time, needs sudo)
    5. Set environment (X11 mode for audio reliability)
    6. Launch: exec data/squashfs-root/AppRun
    ↓
Perssua Electron app runs
```

### Key Design Decisions

| Decision | Why |
|----------|-----|
| **Shell script launcher** | Minimal dependencies; no Python/Node.js bloat |
| **Idempotent extraction** | Safe to run repeatedly; detects if already done |
| **Single AppImage binary** | Self-contained; works on any Linux distro |
| **X11 enforcement** | Audio & screen-share work reliably (Wayland has bugs) |
| **Local data directory** | User control; no cloud dependency; easy backup |
| **Symlink installation** | Updates via git pull; no re-installation needed |

### Security Model

1. **AppImage Sandboxing** - Chromium sandbox prevents app interference
2. **Local Data** - Configuration stored locally, not in cloud
3. **Minimal Privileges** - Only sudo for Chrome sandbox (one-time)
4. **No Daemons** - App runs only when launched
5. **Debug Logs** - Optional, disabled by default

---

## Data Management

### Default Location
```
data/
├── config/          # User configuration
├── cache/           # Application cache
├── logs/            # Debug logs (when PERSSUA_DEBUG=1)
└── squashfs-root/   # Extracted AppImage (temporary)
```

### Backup Configuration
```bash
# Backup current settings
cp -r data data.backup

# Later, restore
cp -r data.backup/* data/
```

### Reset Configuration
```bash
# Remove all data (will recreate on next run with defaults)
rm -rf data/config data/cache data/logs

# Next run recreates with defaults
perssua
```

### Custom Data Directory
```bash
# One-time use
PERSSUA_DATA_DIR=/tmp/perssua-test perssua

# Permanent (add to ~/.bashrc)
export PERSSUA_DATA_DIR="$HOME/.config/perssua"
```

---

## Performance

### Startup Times

| Scenario | Time |
|----------|------|
| First run (extract + setup) | 8-15 seconds |
| Subsequent runs | 2-3 seconds |
| Extract alone (one-time) | 5-10 seconds |
| Sandbox setup (one-time) | ~100ms + sudo prompt |

### Memory Usage

| Component | Memory |
|-----------|--------|
| Launcher script | <1 MB |
| Extracted AppImage | ~600 MB |
| Running app | 150-300 MB |
| **Total** | 750-900 MB |

### Disk Space

| Component | Size |
|-----------|------|
| bin/perssua | 7.5 KB |
| bin/setup.sh | 5.7 KB |
| bin/AppImage | 193 MB |
| data/ (runtime) | ~600 MB (temporary) |
| **Total** | ~800 MB |

---

## Updates & Maintenance

### Update Application

```bash
cd /path/to/perssua-app
git pull                # Get latest version
perssua                 # Automatically uses new version
```

**No re-installation needed** - Symlink points to git checkout.

### View Debug Logs

```bash
# Enable debug mode
PERSSUA_DEBUG=1 perssua

# View logs
tail -f data/logs/
```

### Clean Extracted Files

```bash
make clean              # Remove squashfs-root/

# Or manually:
rm -rf data/squashfs-root/
```

### Uninstall

```bash
make uninstall          # Remove global command

# To remove project:
rm -rf /path/to/perssua-app
```

---

## Troubleshooting

### "command not found: perssua"

**Diagnosis:**
```bash
which perssua           # Check if command exists
ls -la ~/.local/bin/    # Check if symlink was created
echo $PATH              # Check if ~/.local/bin is in PATH
```

**Solution:**
1. Verify installation: `ls -la ~/.local/bin/perssua`
2. Reload shell: `exec bash` or `exec zsh`
3. Add to PATH if needed:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

### "FUSE not installed"

```bash
# Ubuntu/Debian
sudo apt install fuse

# Fedora
sudo dnf install fuse

# Verify
which fuse
```

### "Permission denied" on first run

First run asks for sudo to configure Chrome sandbox - this is normal:
```bash
perssua
# Enter password when prompted
```

The sandbox setup happens only once. Subsequent runs don't ask for password.

### "AppImage extraction failed"

**Checklist:**
```bash
# 1. Check FUSE
which fuse

# 2. Check disk space (need ~600 MB free)
df -h data/

# 3. Check file permissions
ls -l bin/Perssua-*.AppImage

# 4. Try manual extraction
cd bin/
./Perssua-0.23.3-x86_64.AppImage --appimage-extract
```

### Debug Mode

Enable detailed logging:
```bash
PERSSUA_DEBUG=1 perssua
tail -f data/logs/*
```

---

## Configuration Reference

### X11 vs Wayland

The launcher **forces X11 mode** by unsetting `XDG_SESSION_TYPE` and `WAYLAND_DISPLAY`. This is intentional:

**Why?** Wayland has bugs with:
- Audio capture via screen-share
- Display sharing reliability
- Chromium sandbox interaction

**Solution:** Use X11 (via XWayland on Wayland systems) - more reliable.

### Chrome Sandbox

The launcher configures `chrome-sandbox` as setuid-root, which:
- Enables Chromium sandbox isolation
- Improves security
- Needs sudo once (cached for future runs)

**Why setuid?** Chromium requires special privileges to sandbox processes safely.

---

## Advanced Usage

### Multiple Instances

Run separate instances with different configurations:

```bash
# Instance 1 (default)
perssua

# Instance 2 (separate config)
PERSSUA_DATA_DIR=/tmp/perssua-alt perssua

# Instance 3 (separate config)
PERSSUA_DATA_DIR=/tmp/perssua-other perssua
```

### System-Wide Installation

```bash
make install-system     # Requires sudo
# or
./bin/setup.sh --system
```

Available to all users on the system. Data is still user-specific (in `data/`).

### Custom Data Directory Script

Create `~/.local/bin/perssua-work`:
```bash
#!/bin/bash
PERSSUA_DATA_DIR="$HOME/.config/perssua-work" exec perssua "$@"
```

Then:
```bash
chmod +x ~/.local/bin/perssua-work
perssua-work             # Uses separate config
```

---

## Git Integration

### Clone and Use

```bash
git clone <repo> perssua-app
cd perssua-app
make install-user
perssua
```

### Automatic Updates

```bash
cd /path/to/perssua-app
git pull                # Pull latest
perssua                 # Automatically detects and uses new version
```

**Why it works:** Symlink points to git checkout, so updates are instant.

### Development Workflow

```bash
# Clone for development
git clone <repo> perssua-app
cd perssua-app

# Install development version (points to your checkout)
make install-user

# Make changes to bin/perssua or bin/setup.sh
vim bin/perssua

# Test immediately (symlink sees your changes)
perssua

# Commit when satisfied
git add bin/perssua
git commit -m "feat: improve launcher"
git push
```

---

## File Permissions Explained

### chmod +x (Make Executable)

```bash
chmod +x bin/perssua   # Make script executable
```

**Changes:** `rw-r--r--` → `rwxr-xr-x`

**Why?** Unix/Linux files are data by default. Execute permission explicitly allows running them.

**Verification:**
```bash
ls -l bin/perssua
# Output: -rwxr-xr-x  ← Note the "x" characters
```

This is normal practice for any shell script or binary.

---

## Project Structure Reference

See [TREE.md](TREE.md) for complete project structure.

Quick summary:
```
bin/             ← Executables
  ├── perssua
  ├── setup.sh
  └── AppImage
data/            ← Runtime (created on first run, .gitignored)
docs/            ← Documentation
  ├── TREE.md
  ├── GUIDE.md
  └── TROUBLESHOOT.md
README.md        ← Quick start
Makefile         ← Automation
```

---

## Next Steps

1. **Quick start:** See [README.md](../README.md)
2. **Troubleshooting:** See [TROUBLESHOOT.md](TROUBLESHOOT.md)
3. **Project structure:** See [TREE.md](TREE.md)

---

**Last Updated:** 2026-07-06  
**Version:** 0.23.3
