# Project Structure & File Usage

Complete directory tree with descriptions of each file and where it's used.

```
perssua-linux/
├── bin/                                    # Executables & binaries
│   ├── perssua                             # Main launcher script
│   ├── setup.sh                            # Installation helper script
│   └── Perssua-0.23.3-x86_64.AppImage     # Application binary
│
├── data/                                   # Runtime state (.gitignored)
│   ├── config/                             # User configuration (created on first run)
│   ├── cache/                              # Application cache
│   ├── logs/                               # Structured logs (human-readable + JSON)
│   └── squashfs-root/                      # Extracted AppImage filesystem
│
├── docs/                                   # User documentation
│   ├── TREE.md                             # This file
│   ├── GUIDE.md                            # Setup & architecture
│   └── TROUBLESHOOT.md                     # Troubleshooting & FAQ
│
├── logging/                                # Observability & logging
│   ├── README.md                           # Logging overview
│   ├── GUIDE.md                            # Complete logging guide
│   ├── IMPLEMENTATION.md                   # Implementation details
│   ├── systemd-example.service             # Systemd service example
│   └── examples/
│       └── logrotate.conf                  # Log rotation configuration
│
├── tests/                                  # Test suite
│   ├── smoke-test.sh                       # Quick observability tests
│   └── validate.sh                         # Comprehensive validation
│
├── .gitignore                              # Git exclusions
├── Makefile                                # Build automation
├── README.md                               # Quick start guide
└── LICENSE                                 # Legal terms
```

## Detailed File Reference

### `bin/perssua` - Main Launcher Script
- **Type:** Bash script (POSIX-compliant)
- **Size:** ~7.5 KB, ~250 lines
- **Purpose:** Main entry point that users execute
- **Used By:** 
  - Users: `perssua` command
  - Makefile: `make up`, `make debug`, `make debug-json`, `make config`, `make version`
  - setup.sh: invoked when symlink is executed
  - Tests: `tests/smoke-test.sh`, `tests/validate.sh`
- **Key Responsibilities:**
  - Extracts AppImage to `data/squashfs-root/` (idempotent)
  - Validates prerequisites (FUSE, AppImage, permissions)
  - Configures Chrome sandbox (one-time sudo)
  - Manages structured logging (DEBUG, INFO, WARN, ERROR)
  - Supports multiple log formats (human-readable, JSON)
  - Environment variables:
    - `PERSSUA_DEBUG=1` — Enable debug logging
    - `PERSSUA_LOG_LEVEL` — Set log level (DEBUG|INFO|WARN|ERROR)
    - `PERSSUA_LOG_FORMAT` — Set format (human|json)
    - `PERSSUA_DATA_DIR` — Override data directory
  - Command-line flags:
    - `--help` — Show usage
    - `--version` — Show version (0.23.3)
    - `--config` — Show configuration status

### `bin/setup.sh` - Installation Helper
- **Type:** Bash script
- **Size:** ~5.7 KB, ~200 lines
- **Purpose:** Install/uninstall `perssua` command globally
- **Used By:**
  - Makefile: `make install-user`, `make install-system`, `make uninstall`
  - Users: direct execution via `./bin/setup.sh`
- **Features:**
  - Creates symlinks (not copies) — updates automatic with `git pull`
  - User-level installation: `~/.local/bin/perssua`
  - System-wide installation: `/usr/local/bin/perssua` (requires sudo)
  - Uninstall support: `--uninstall` removes symlinks
  - Idempotent: safe to run multiple times
  - Dependency checking (verifies FUSE availability)

### `bin/Perssua-0.23.3-x86_64.AppImage` - Application Binary
- **Type:** Self-contained AppImage (Linux universal format)
- **Size:** ~193 MB
- **Purpose:** Immutable, pre-built application runtime
- **Used By:**
  - bin/perssua: Extracts and launches via AppRun
- **Contents:**
  - Electron application framework
  - Chromium browser engine
  - System libraries
  - All dependencies bundled
- **Notes:**
  - Version locked (0.23.3)
  - Read-only (immutable)
  - Extracted to `data/squashfs-root/` on first run
  - Requires FUSE for mounting

### `data/` - Runtime State Directory
- **Type:** .gitignored (not versioned)
- **Purpose:** Stores runtime data, configuration, cache, logs
- **Created:** On first run
- **Customizable:** Via `PERSSUA_DATA_DIR` environment variable
- **Contents:**
  - `config/` — User configuration (created on first launch)
  - `cache/` — Application cache and temporary data
  - `logs/perssua.log` — Structured activity log
  - `squashfs-root/` — Extracted AppImage filesystem (temporary, recreated on updates)
- **Permissions:** User-owned, isolated per user

### `.gitignore` - Version Control Exclusions
- **Type:** Git configuration
- **Size:** ~280 bytes
- **Purpose:** Prevents committing runtime artifacts
- **Excludes:**
  - Runtime: `.plan/`, `data/`, `*.log`
  - Build artifacts: `build/`, `dist/`, `*.egg-info/`
  - Environment: `.env`, `.env.local`
  - IDE files: `.vscode/`, `.idea/`, `*.pyc`
  - OS files: `.DS_Store`, `Thumbs.db`

### `Makefile` - Build Automation
- **Type:** GNU Make automation
- **Size:** ~1 KB
- **Purpose:** Provides convenient commands for common tasks
- **Used By:** Developers and CI/CD systems
- **Targets:** 20+ commands organized in sections
- **Main Commands:**
  - **Usage:** `make up`, `make install-user`, `make install-system`, `make uninstall`
  - **Debug:** `make debug`, `make debug-json`
  - **Config:** `make config`, `make version`
  - **Deps:** `make install-deps`, `make install` (full setup)
  - **Testing:** `make test`, `make test-full`, `make test-verbose`
  - **Maintenance:** `make validate`, `make clean`, `make lint`, `make tail-logs`
- **Features:**
  - Color-coded output
  - OS auto-detection for dependency installation
  - Checks for dependencies before running
  - Helpful documentation in `make help`

### `README.md` - Quick Start Guide
- **Type:** Markdown documentation
- **Purpose:** First thing users read
- **Used By:** New users, GitHub repository page
- **Contains:**
  - Project overview (what it is)
  - Quick start (5 minutes, 2 commands)
  - System requirements
  - Common commands
  - Project structure overview
  - Documentation index
  - Performance metrics
  - Troubleshooting quick reference

### `docs/` Directory - User Documentation
- **Purpose:** Consolidated user-facing guides
- **Used By:** Users needing detailed help
- **Files:**
  - **TREE.md** — This file (complete file reference)
  - **GUIDE.md** — Setup & architecture guide
  - **TROUBLESHOOT.md** — Common issues & solutions

### `docs/GUIDE.md` - Complete Setup & Architecture
- **Type:** Markdown documentation
- **Purpose:** Comprehensive guide for setup and understanding architecture
- **Used By:** Users needing detailed setup instructions or developers
- **Covers:**
  - Prerequisites and dependencies
  - Installation methods (Make, direct script, direct execution)
  - Configuration options
  - Architecture overview
  - Build automation details

### `docs/TROUBLESHOOT.md` - Troubleshooting & FAQ
- **Type:** Markdown documentation
- **Purpose:** Solve common problems
- **Used By:** Users encountering issues
- **Covers:**
  - Common errors and solutions
  - Diagnostic commands
  - Log analysis
  - Performance issues
  - Integration with system tools

### `logging/` Directory - Observability & Logging
- **Purpose:** Professional logging and observability setup
- **Used By:** DevOps, system administrators, troubleshooting
- **Files:**
  - **README.md** — Quick overview of logging features
  - **GUIDE.md** — Complete logging guide with all features
  - **IMPLEMENTATION.md** — Implementation details and architecture
  - **systemd-example.service** — Example systemd service file
  - **examples/logrotate.conf** — Example log rotation configuration

### `logging/README.md` - Logging Overview
- **Type:** Markdown documentation
- **Size:** ~1 KB
- **Purpose:** Quick reference for logging
- **Used By:** Users wanting to enable logging
- **Covers:**
  - Quick start for viewing logs in real-time
  - Debug modes
  - JSON format for parsing
  - Integration with Make

### `logging/GUIDE.md` - Complete Logging Guide
- **Type:** Markdown documentation
- **Purpose:** Comprehensive logging reference
- **Used By:** Developers, system administrators, DevOps
- **Covers:**
  - Log levels (DEBUG, INFO, WARN, ERROR)
  - Log formats (human-readable, JSON)
  - Environment variables
  - File-based logging
  - Real-time monitoring
  - Structured logging principles
  - Integration with Linux tools

### `logging/IMPLEMENTATION.md` - Implementation Details
- **Type:** Markdown documentation  
- **Purpose:** Technical details about logging implementation
- **Used By:** Developers modifying logging or integrating with monitoring
- **Covers:**
  - What was implemented
  - How logging works internally
  - Compatibility with legacy PERSSUA_DEBUG=1
  - Log file location and rotation
  - JSON schema for structured logs

### `logging/systemd-example.service` - Systemd Service Example
- **Type:** Systemd unit file (.service)
- **Size:** ~40 lines
- **Purpose:** Example for running Perssua as a systemd service
- **Used By:** System administrators wanting service integration
- **Features:**
  - User service definition
  - Environment variable configuration
  - Security hardening (PrivateTmp, ProtectSystem, etc.)
  - Automatic restart on failure
  - Resource limits (memory, CPU)
  - Journalctl integration
  - Usage: Copy to `~/.config/systemd/user/perssua.service` then enable with `systemctl --user enable perssua`

### `logging/examples/logrotate.conf` - Log Rotation Configuration
- **Type:** Logrotate configuration
- **Size:** ~40 lines
- **Purpose:** Automatic log file rotation and cleanup
- **Used By:** System administrators for production deployments
- **Features:**
  - Rotation trigger: 10 MB file size
  - Keep 5 rotated files
  - Compress old logs
  - Automatic cleanup after 30 days
  - Copy-truncate (safe for running processes)
  - Date extension with YYYYMMDD format
  - Usage: Copy to `/etc/logrotate.d/perssua` and configure path

### `tests/` Directory - Test Suite
- **Purpose:** Automated testing of functionality
- **Used By:** Developers validating changes, CI/CD pipelines
- **Commands:**
  - `make test` — Run quick smoke tests
  - `make test-full` — Run comprehensive validation
  - `make test-verbose` — Run with verbose output
  - `make test-no-cleanup` — Keep test artifacts

### `tests/smoke-test.sh` - Quick Observability Tests
- **Type:** Bash test script
- **Size:** ~80 lines
- **Purpose:** Quick validation that basic features work
- **Used By:** `make test` and CI/CD
- **Tests:**
  - Help command (`--help`)
  - Version display (`--version`)
  - Configuration display (`--config`)
  - Documentation existence (logging guides)
  - Systemd service file presence
- **Execution:** Less than 1 second

### `tests/validate.sh` - Comprehensive Validation Suite
- **Type:** Bash test script
- **Size:** ~300+ lines
- **Purpose:** Complete system validation
- **Used By:** `make test-full` and detailed validation
- **Tests:**
  - Launcher functionality
  - Logging features
  - Make command targets
  - Observability features
  - Configuration management
  - Error handling
- **Options:**
  - `--verbose` — Show detailed output
  - `--no-cleanup` — Keep test artifacts for inspection
- **Reports:** Test count, pass/fail statistics, timing

## Quick Reference Table

| Want to... | Command | Notes |
|---|---|---|
| Launch Perssua | `make up` or `perssua` | — |
| Install globally | `make install` or `make install-user` | Full setup or user-only |
| Check status | `make config` | Shows all prerequisites |
| Enable debug | `PERSSUA_LOG_LEVEL=DEBUG perssua` | Or `PERSSUA_DEBUG=1` (legacy) |
| View JSON logs | `PERSSUA_LOG_FORMAT=json perssua` | Pipe to `jq` for parsing |
| Monitor logs live | `make tail-logs` | Real-time log viewing |
| Run tests | `make test` or `make test-full` | Quick or comprehensive |
| Check for issues | `make validate` | Validates prerequisites |
| Update | `git pull` | Symlink auto-updates |
| Uninstall | `make uninstall` | Removes symlinks only |
| Clean artifacts | `make clean` | Removes extracted files |
| See all commands | `make help` | Full help output |

## Dependency & Usage Map

### What Calls What?

```
User Commands
├─ perssua → bin/perssua (launcher)
│  ├─ Uses: bin/Perssua-0.23.3-x86_64.AppImage
│  ├─ Creates: data/squashfs-root/ (extraction)
│  ├─ Writes: data/logs/perssua.log
│  └─ References: data/config/ (user config)
│
└─ make <target> → Makefile
   ├─ make install → bin/setup.sh --user
   ├─ make install-deps → apt|dnf|zypper|pacman
   ├─ make up → bin/perssua
   ├─ make debug → bin/perssua (with PERSSUA_DEBUG=1)
   ├─ make config → bin/perssua --config
   ├─ make test → tests/smoke-test.sh
   ├─ make test-full → tests/validate.sh
   └─ make tail-logs → tail -f data/logs/perssua.log

Tests
├─ tests/smoke-test.sh
│  ├─ Tests: bin/perssua (--help, --version, --config)
│  └─ Verifies: logging/GUIDE.md, logging/systemd-example.service
│
└─ tests/validate.sh
   ├─ Tests: bin/perssua, Makefile targets
   └─ Validates: logging features, observability

CI/CD Integration
├─ .gitignore → Prevents committing data/, .plan/, *.log
└─ Makefile → Multiple targets for automation
```

### File Dependencies

**Executable Chain:**
```
User runs: perssua
    ↓
Invokes: bin/perssua (launcher)
    ↓
Reads: bin/Perssua-0.23.3-x86_64.AppImage
    ↓
Extracts to: data/squashfs-root/AppRun
    ↓
Launches: Electron app (Perssua UI)
```

**Installation Chain:**
```
User runs: make install
    ↓
Makefile calls: bin/setup.sh --user
    ↓
Creates symlink: ~/.local/bin/perssua → bin/perssua
    ↓
User can now: perssua (from anywhere)
```

**Logging Chain:**
```
bin/perssua runs
    ↓
Writes to: data/logs/perssua.log (structured format)
    ├─ Human-readable (default) or JSON format
    ├─ Configurable via PERSSUA_LOG_FORMAT
    └─ Configurable via PERSSUA_LOG_LEVEL
    ↓
Users can view: tail -f data/logs/perssua.log
           or: make tail-logs
           or: journalctl (if systemd service)
```

## File Statistics

| Component | Type | Size | Status |
|-----------|------|------|--------|
| **bin/perssua** | Script | 7.5 KB | Active - core executable |
| **bin/setup.sh** | Script | 5.7 KB | Active - installation |
| **bin/AppImage** | Binary | 193 MB | Immutable - application |
| **Makefile** | Config | 1 KB | Active - automation |
| **docs/** | Documentation | ~50 KB | Active - user guides |
| **logging/** | Documentation | ~30 KB | Active - observability |
| **tests/** | Scripts | ~8 KB | Active - validation |
| **.gitignore** | Config | 280 B | Active - version control |
| **README.md** | Documentation | ~10 KB | Active - quick start |
| **data/** | Runtime | Variable | .gitignored - user data |
| **Total (versioned)** | — | **~200 MB** | AppImage is majority |

## Execution Flow

When a user runs `perssua`:

```
1. Shell executes perssua (symlink or direct)
2. bin/perssua script starts
3. Validate prerequisites (FUSE installed, permissions OK)
4. Check if AppImage extracted (if not, extract to data/squashfs-root/)
5. Configure Chrome sandbox (one-time, may ask for sudo)
6. Set X11 environment variables
7. Log startup event (data/logs/perssua.log)
8. Execute: data/squashfs-root/AppRun (the actual Electron app)
9. Perssua UI launches
```

## System Requirements

### Required
- **Linux kernel** (Ubuntu, Debian, Fedora, Arch, openSUSE, etc.)
- **FUSE** (File System in Userspace) - for AppImage mounting
- **Bash** - for launcher script execution
- **Standard utils** - coreutils, grep, sed, awk

### Install FUSE

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

### Optional (for advanced features)
- **Systemd** — for service integration (see logging/systemd-example.service)
- **Logrotate** — for automatic log rotation (see logging/examples/logrotate.conf)
- **Shellcheck** — for script linting (run with `make lint`)

## How to Use This Guide

1. **Getting started?** → Read [README.md](../README.md) first
2. **Installing?** → Use `make install` (handles everything)
3. **Troubleshooting?** → Check [docs/TROUBLESHOOT.md](TROUBLESHOOT.md)
4. **Enabling logging?** → See [logging/GUIDE.md](../logging/GUIDE.md)
5. **Advanced setup?** → Read [docs/GUIDE.md](GUIDE.md)
6. **Understanding files?** → You're reading it! (This file)

## File Checklist - Are They All Used?

✅ **bin/perssua** — YES, primary executable  
✅ **bin/setup.sh** — YES, installation script  
✅ **bin/AppImage** — YES, application binary  
✅ **Makefile** — YES, build automation  
✅ **README.md** — YES, quick start  
✅ **.gitignore** — YES, version control  
✅ **docs/GUIDE.md** — YES, detailed guide  
✅ **docs/TROUBLESHOOT.md** — YES, troubleshooting  
✅ **docs/TREE.md** — YES, this file  
✅ **logging/README.md** — YES, logging overview  
✅ **logging/GUIDE.md** — YES, detailed logging  
✅ **logging/IMPLEMENTATION.md** — YES, technical details  
✅ **logging/systemd-example.service** — YES, service example  
✅ **logging/examples/logrotate.conf** — YES, rotation example  
✅ **tests/smoke-test.sh** — YES, quick tests  
✅ **tests/validate.sh** — YES, comprehensive tests  

**All files are actively used!** ✓

---

**Last Updated:** 2026-07-07  
**Version:** 0.23.3  
**Status:** Production Ready
