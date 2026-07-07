# Perssua - AI-Powered Audio Capture Tool

Professional Linux application for real-time audio capture and AI-powered interaction.

**Status:** ✅ Production Ready | **Version:** 0.23.3 | **Build Date:** 2026-07-06

---

## What Is This?

A professionally packaged, single-command Linux application:

- **Single binary:** 193 MB AppImage (self-contained, all dependencies included)
- **Zero-config:** Run `perssua` and it auto-initializes (first run: 8-15s, subsequent: 2-3s)
- **Global command:** After `make install`, works from anywhere
- **Secure:** Runs in Chromium sandbox, stores data locally
- **Production-ready:** Professional scripts, comprehensive docs, full error handling

---

## Quick Start (2 commands, 5 minutes)

### 1. Full Setup (Install dependencies + command)
```bash
git clone git@github.com:luizotavioautomacao/perssua-linux.git
make install           # One command does it all!
```

This automatically:
- ✓ Installs FUSE (auto-detects your OS: Ubuntu, Fedora, Arch, openSUSE)
- ✓ Creates symlink: `~/.local/bin/perssua`
- ✓ Makes `perssua` available globally

### 2. Launch
```bash
perssua                     # Works from anywhere!
```

**First run:** Extracts AppImage (~8-15s) + configures sandbox (asks for sudo once)  
**Subsequent runs:** Fast launch (~2-3s)

---

## System Requirements & Dependencies

### Required
- **Linux kernel** (Ubuntu, Debian, Fedora, Arch, or similar)
- **FUSE** (File System in Userspace) - for AppImage mounting

### Install Dependencies

**Automatic (Recommended):**
```bash
make install-deps      # Auto-detects your OS and installs FUSE
```

Supports: Ubuntu/Debian (apt), Fedora/RHEL (dnf), openSUSE (zypper), Arch (pacman)

**Or use the all-in-one command:**
```bash
make install           # Installs deps + sets up command
```

**Manual Installation (if preferred):**
```bash
# Ubuntu/Debian
sudo apt install fuse

# Fedora/RHEL
sudo dnf install fuse

# Arch Linux
sudo pacman -S fuse

# openSUSE
sudo zypper install fuse
```

**Verify Installation:**
```bash
which fuse             # Should show: /usr/bin/fuse
make config            # Shows all dependency status
```

### Optional
- **Systemd** (for service integration, see `logging/systemd-example.service`)
- **Logrotate** (for log rotation, see `logging/examples/logrotate.conf`)
- **Shellcheck** (for script linting, `make lint`)

---

## Common Commands

### Using Makefile (Recommended)
```bash
make install         # Full setup: install deps + command (RECOMMENDED!)
make install-deps    # Install FUSE (auto-detects your OS)
make install-user    # Install command for current user (~/.local/bin/)
make install-system  # Install command system-wide (requires sudo)
make up              # Launch Perssua application
make config          # Show system status & configuration
make debug           # Launch with debug logging (human-readable)
make debug-json      # Launch with JSON logging (for parsing)
make uninstall       # Remove global command
make help            # Show all available make targets
```

### What Does Each Command Do?

**`make install`** (RECOMMENDED - One command setup!)
- Installs FUSE (auto-detects Ubuntu, Fedora, Arch, openSUSE)
- Creates symlink: `~/.local/bin/perssua → bin/perssua`
- After this, `perssua` works from anywhere
- One-time setup, everything is handled

**`make install-deps`**
- Installs FUSE with OS auto-detection
- Uses: apt (Ubuntu), dnf (Fedora), zypper (openSUSE), pacman (Arch)
- Fallback: shows manual installation instructions if OS not detected

**`make install-user`**
- Creates symlink: `~/.local/bin/perssua → bin/perssua`
- Current user only
- Requires: FUSE already installed (use `make install` instead for full setup)

**`make install-system`**
- Creates symlink: `/usr/local/bin/perssua → bin/perssua`
- Available to all users
- Requires sudo
- Requires: FUSE already installed

**`make config`**
- Diagnostic command showing:
  - AppImage status (found/not found)
  - FUSE availability (installed/not installed)
  - Extraction state (extracted/not extracted)
  - Log configuration (level, format, file location)
  - System info (OS, architecture)
  - Suggests next steps if something is missing

**`make up`**
- Launches Perssua application
- Equivalent to: `perssua`

**`make debug`**
- Launches with detailed logging (human-readable)
- Equivalent to: `PERSSUA_LOG_LEVEL=DEBUG perssua`
- Shows timestamps, log levels, modules

**`make debug-json`**
- Launches with JSON logging (for machine parsing)
- Equivalent to: `PERSSUA_LOG_FORMAT=json perssua`
- Output: `{"timestamp":"...", "level":"...", "message":"..."}`
- Useful for: parsing, metrics, log aggregation

### Direct Commands
```bash
perssua              # Launch
perssua --version    # Show version
perssua --config     # Show configuration
PERSSUA_DEBUG=1 perssua  # Enable debug logging
```

---

## Project Structure

```
perssua-app/
├── bin/                          # Executables
│   ├── perssua                   # Main launcher (250+ lines, professionl)
│   ├── setup.sh                  # Installation helper
│   └── Perssua-0.23.3-x86_64.AppImage  # Application binary (193 MB)
│
├── data/                         # Runtime state (.gitignored)
│   ├── config/                   # User configuration (created on first run)
│   ├── cache/                    # Application cache
│   ├── logs/                     # Debug logs
│   └── squashfs-root/            # Extracted AppImage (temporary)
│
├── docs/                         # Consolidated documentation
│   ├── TREE.md                   # Project structure overview
│   ├── GUIDE.md                  # Complete setup & architecture
│   └── TROUBLESHOOT.md           # Troubleshooting & FAQ
│
├── logging/                      # Logging & observability
│   ├── GUIDE.md                  # Comprehensive logging guide
│   ├── README.md                 # Logging overview
│   ├── systemd-example.service   # Systemd service example
│   └── examples/
│       └── logrotate.conf        # Log rotation configuration (example)
│
├── tests/                        # Test suite
│   └── validate.sh               # Observability validation tests
│
├── .plan/                        # Execution plan
│   └── PERSSUA_MIGRATION_2026-07-06.md  # What was implemented
│
├── Makefile                      # Build automation (15+ targets)
├── README.md                     # This file (quick start)
├── LICENSE                       # Legal terms
└── .gitignore                    # Version control config
```

---

## Documentation

| File | Purpose | Time |
|------|---------|------|
| **README.md** | This file - quick start | 5 min |
| **docs/TREE.md** | Project structure & overview | 10 min |
| **docs/GUIDE.md** | Complete setup, config, architecture | 20 min |
| **docs/TROUBLESHOOT.md** | Issues, FAQ, diagnostics | 15 min |
| **logging/GUIDE.md** | Logging & observability | 10 min |
| **.plan/PERSSUA_MIGRATION_2026-07-06.md** | Implementation plan | 10 min |

**Starting out?** Read in this order:
1. This file (README.md)
2. [docs/TREE.md](docs/TREE.md)
3. [docs/GUIDE.md](docs/GUIDE.md) if needed
4. [docs/TROUBLESHOOT.md](docs/TROUBLESHOOT.md) if stuck

---

## What Was Built

### Professional Setup
- ✅ Moved Perssua from `/home/luizotavio/Downloads/Perssua`
- ✅ Simplified directory structure
- ✅ Created comprehensive build automation

### Intelligent Installation
- ✅ `make install` - One command: install deps + setup command
- ✅ `make install-deps` - OS auto-detection (Ubuntu, Fedora, Arch, openSUSE)
- ✅ Automatic FUSE installation
- ✅ Fallback to manual instructions if needed

### Professional Scripts
- ✅ **bin/perssua** (250+ lines)
  - Idempotent extraction
  - Structured logging (DEBUG, INFO, WARN, ERROR)
  - JSON output support
  - Comprehensive error handling

- ✅ **bin/setup.sh** (200+ lines)
  - User/system installation
  - Uninstall support
  - Symlink-based (git-pull-friendly)

### Build Automation
- ✅ **Makefile** with 15+ targets
- ✅ OS auto-detection and dependency installation
- ✅ Color-coded output
- ✅ Validation targets

### Logging & Observability
- ✅ Structured logging with timestamps (ISO 8601)
- ✅ Multiple log levels and formats
- ✅ Persistent logs in `data/logs/perssua.log`
- ✅ Logrotate and Systemd examples

### Documentation
- ✅ Consolidated to 4 focused docs
- ✅ ~50 KB total (minimal)
- ✅ Complete setup guides

---

## Troubleshooting

### Quick Diagnostics
```bash
# Check configuration and dependencies
make config

# Auto-install missing dependencies
make install-deps

# Enable debug mode
make debug
make debug-json

# View logs
tail -f data/logs/perssua.log
make tail-logs

# See all targets
make help
```

### Common Issues

**"command not found: perssua"**
```bash
which perssua          # Check if installed
exec bash              # Reload shell
make config            # Check status
```

**"FUSE not installed"**
```bash
make install-deps      # Auto-install for your OS
```

**"Permission denied" on first run**
- Normal! First run needs sudo for Chrome sandbox (one-time only)
- Subsequent runs don't ask

**See [docs/TROUBLESHOOT.md](docs/TROUBLESHOOT.md) for more help**

---

## Git Integration

### Clone and Use
```bash
git clone <repo> perssua-app
cd perssua-app
make install          # Full setup in one command!
perssua               # Launch
```

### Updates
```bash
cd /path/to/perssua-app
git pull              # Get latest
perssua               # Automatically uses new version
```

No re-installation needed - Symlink points to git checkout.

---

## Performance

| Metric | Value |
|--------|-------|
| **First run** | 8-15 seconds (extraction + setup) |
| **Subsequent runs** | 2-3 seconds |
| **Memory usage** | ~750-900 MB |
| **Disk usage** | ~400 MB |

---

## Next Steps

1. **Quick start:** `make install`
2. **Launch:** `perssua`
3. **Check status:** `make config`
4. **Read docs:** `less docs/TREE.md`
5. **See help:** `make help`

---

**Version:** 0.23.3 | **Status:** ✅ Production Ready  
**Installation:** `make install` (one command!)  
**Global Command:** ✅ WORKING (`perssua`)
