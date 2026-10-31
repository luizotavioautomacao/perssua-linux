# Troubleshooting & FAQ

See [TREE.md](TREE.md) for project structure and [GUIDE.md](GUIDE.md) for setup details.

---

## Common Issues

### "command not found: perssua"

**Problem:** Typed `perssua` but command not found.

**Solution:**

1. **Verify installation:**
   ```bash
   which perssua                    # Should return: ~/.local/bin/perssua
   ls -la ~/.local/bin/perssua      # Symlink should exist
   ```

2. **Reload shell:**
   ```bash
   exec bash                        # Or: exec zsh
   ```

3. **Check PATH:**
   ```bash
   echo $PATH | grep ".local/bin"   # Should show ~/.local/bin
   ```

4. **If not in PATH, add it:**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$HOME/.local/bin:$PATH"
   
   # Then reload
   source ~/.bashrc
   ```

5. **Reinstall if needed:**
   ```bash
   cd /path/to/perssua-app
   make install-user
   ```

---

### "FUSE not installed"

**Error:** `FUSE not installed. Install with: sudo apt install fuse`

**Solution:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install fuse

# Fedora/RHEL
sudo dnf install fuse

# Verify installation
which fuse
```

After installation, try again:
```bash
perssua
```

---

### "Permission denied" on first run

**Problem:** Script asks for sudo and won't continue without it.

**Context:** This is **normal and expected**. First run needs sudo to configure the Chrome sandbox.

**Solution:**

```bash
perssua
# When prompted, enter your password
# Sandbox setup happens ONCE; subsequent runs don't ask
```

This is a one-time setup cost for security.

---

### "AppImage extraction failed"

**Problem:** Extraction hangs or fails.

**Diagnosis:**

```bash
# 1. Verify FUSE is working
which fuse
ls /dev/fuse

# 2. Check disk space (need ~600 MB)
df -h /path/to/perssua-app/data/

# 3. Check AppImage file
ls -lh bin/Perssua-*.AppImage
file bin/Perssua-*.AppImage

# 4. Check permissions
ls -l bin/perssua
# Should show: -rwxr-xr-x  (executable)
```

**Solutions:**

a) **Free up disk space:**
   ```bash
   # Clean up old extracted files
   make clean
   rm -rf data/squashfs-root/
   
   # Try again
   perssua
   ```

b) **Re-extract manually:**
   ```bash
   cd bin/
   ./Perssua-0.27.5-x86_64.AppImage --appimage-extract
   # If this works, the issue was with launcher detection
   ```

c) **Check logs:**
   ```bash
   PERSSUA_DEBUG=1 perssua
   tail -f data/logs/*
   ```

---

### "XDG_SESSION_TYPE" or Wayland errors

**Problem:** Audio capture or screen-share not working.

**Context:** The launcher forces X11 mode because Wayland has reliability issues.

**Solution:** Already handled automatically by the launcher. If you still have issues:

```bash
# Verify X11 is being used
echo $XDG_SESSION_TYPE          # Should be empty (unset)
echo $WAYLAND_DISPLAY            # Should be empty (unset)

# Enable debug to see environment
PERSSUA_DEBUG=1 perssua
```

---

### Audio capture not working

**Problem:** No sound being captured.

**Checklist:**

1. **System audio working?**
   ```bash
   # Test with default player
   speaker-test -c 2 -l 5
   ```

2. **Pulseaudio/Pipewire running?**
   ```bash
   # Check Pulseaudio
   pactl info
   
   # Or check Pipewire
   pw-cli info core
   ```

3. **Perssua running in X11 mode?**
   ```bash
   # Verify launcher output
   PERSSUA_DEBUG=1 perssua
   # Look for: "Configuring display server (X11 mode...)"
   ```

4. **Try alternative data directory:**
   ```bash
   PERSSUA_DATA_DIR=/tmp/perssua-audio perssua
   # If this works, old config might be corrupted
   ```

5. **Check logs:**
   ```bash
   PERSSUA_DEBUG=1 perssua 2>&1 | tee debug.log
   tail -f data/logs/*
   ```

**Audio Setup Guide:**

See original docs (CONFIG.md, AUDIO_SETUP.md) for detailed audio configuration. Key points:
- X11 mode is required (enforced by launcher)
- Chrome sandbox may need special permissions
- Pulseaudio/Pipewire must be running

---

### Screen sharing not working

**Problem:** Display capture fails or doesn't ask for permission.

**Context:** Same root cause as audio - Wayland reliability issues.

**Solution:**

1. **Verify X11 mode:**
   ```bash
   PERSSUA_DEBUG=1 perssua
   # Should show: "Configuring display server (X11 mode...)"
   ```

2. **Check display server:**
   ```bash
   echo $DISPLAY                  # Should be set (e.g., :0)
   echo $XDG_SESSION_TYPE         # Should be empty (unset)
   ```

3. **Try manual test:**
   ```bash
   # This script uses X11 directly
   PERSSUA_DEBUG=1 perssua
   ```

---

### "Chrome sandbox" permission errors

**Problem:** Error about chrome-sandbox permissions during first run.

**Context:** Launcher tries to set sandbox permissions. If this fails, it's usually a permissions issue.

**Solution:**

```bash
# Check current state
ls -l data/squashfs-root/chrome-sandbox
# Should show: -rwsr-xr-x  (note the 's')

# If missing or wrong, reconfigure:
sudo chown root:root data/squashfs-root/chrome-sandbox
sudo chmod 4755 data/squashfs-root/chrome-sandbox

# Try again
perssua
```

---

### High memory usage

**Problem:** Perssua uses a lot of memory.

**Context:** Electron apps are typically 150-300 MB.

**Normal behavior:**

```
Launcher script:        <1 MB
Extracted AppImage:     ~600 MB (temporary, shared filesystem)
Running Perssua app:    150-300 MB
Total:                  ~750-900 MB (normal)
```

**If unusually high:**

1. Check what's open:
   ```bash
   ps aux | grep perssua
   ```

2. Check disk I/O:
   ```bash
   iostat -x 1
   ```

3. Try clean restart:
   ```bash
   # Kill running instance
   killall perssua
   
   # Clean up
   make clean
   
   # Start fresh
   perssua
   ```

---

### Slow startup (>3 seconds)

**Problem:** Perssua takes longer than expected to launch.

**Context:**

- First run: 8-15 seconds (extraction)
- Subsequent runs: 2-3 seconds (normal)

**If slow on subsequent runs:**

1. **Check disk I/O:**
   ```bash
   time perssua --version
   # Isolates launcher startup from app startup
   ```

2. **Check system load:**
   ```bash
   uptime
   free -h
   ```

3. **Check if extraction is running:**
   ```bash
   PERSSUA_DEBUG=1 perssua
   # Look for: "AppImage already extracted"
   ```

4. **Try clean extraction:**
   ```bash
   make clean
   perssua  # Should extract and run fresh
   ```

---

### Symlink not working after git update

**Problem:** Symlink points to old or missing path.

**Context:** If you moved the project directory, symlinks become invalid.

**Solution:**

```bash
# Check symlink
ls -la ~/.local/bin/perssua

# Should point to: /path/to/perssua-app/bin/perssua

# If broken, reinstall
cd /path/to/perssua-app
make install-user
```

---

### Old data causing issues

**Problem:** Something changed but old configuration breaks things.

**Solution:**

1. **Backup current data:**
   ```bash
   cp -r data data.backup
   ```

2. **Reset to defaults:**
   ```bash
   rm -rf data/config data/cache data/logs
   ```

3. **Try running:**
   ```bash
   perssua
   ```

4. **If that doesn't fix it, nuke everything:**
   ```bash
   rm -rf data
   perssua  # Creates fresh data/ directory
   ```

---

## FAQ

### Q: Does first run really need sudo?

**A:** Yes. Only for Chrome sandbox setup (one-time). Subsequent runs don't ask.

### Q: Can I use a custom data directory permanently?

**A:** Yes. Add to your shell profile (`~/.bashrc` or `~/.zshrc`):
```bash
export PERSSUA_DATA_DIR="$HOME/.config/perssua"
```

### Q: How do I completely uninstall?

**A:**
```bash
make uninstall              # Remove global command
rm -rf /path/to/perssua-app  # Remove project
rm -rf data/                # Remove all data
```

### Q: Will git updates break my installation?

**A:** No. Symlink points to git checkout, so updates are automatic.

### Q: Can I run multiple instances?

**A:** Yes, with different data directories:
```bash
PERSSUA_DATA_DIR=/tmp/perssua-1 perssua &
PERSSUA_DATA_DIR=/tmp/perssua-2 perssua &
```

### Q: What if I move the project directory?

**A:** Reinstall the symlink:
```bash
cd /new/path/to/perssua-app
make install-user
```

### Q: How do I debug issues?

**A:**
```bash
# Enable debug mode
PERSSUA_DEBUG=1 perssua

# View logs
tail -f data/logs/*

# Check configuration
perssua --config
```

### Q: Is Perssua safe?

**A:** Yes:
- Runs in Chromium sandbox
- No cloud dependencies
- Configuration stored locally
- Optional debug logging
- No persistent daemons

### Q: What about privacy?

**A:** By default:
- No telemetry
- No cloud sync
- No tracking
- Data stays local

### Q: Can I use it offline?

**A:** Yes. Perssua doesn't require internet connection.

### Q: How often should I update?

**A:** Periodically pull latest:
```bash
cd /path/to/perssua-app
git pull
```

No manual steps needed - updates are automatic.

---

## Diagnostic Commands

Use these to troubleshoot:

```bash
# Check configuration status
perssua --config

# Show version
perssua --version

# Show help
perssua --help

# Enable debug logging
PERSSUA_DEBUG=1 perssua

# Test extraction directly
cd bin/
./Perssua-0.27.5-x86_64.AppImage --appimage-extract

# Check Makefile targets
make help

# Validate setup
make validate

# Check installed symlink
which perssua
ls -la ~/.local/bin/perssua
ls -la /usr/local/bin/perssua

# Check data directory
ls -la data/
du -sh data/

# View debug logs
tail -20 data/logs/*
```

---

## Getting Help

1. **Check the docs:**
   - [TREE.md](TREE.md) - Project structure
   - [GUIDE.md](GUIDE.md) - Setup & configuration
   - This file - Troubleshooting

2. **Run diagnostics:**
   ```bash
   perssua --config
   PERSSUA_DEBUG=1 perssua
   ```

3. **Review logs:**
   ```bash
   tail -f data/logs/*
   ```

4. **Try the suggestions above**

---

**Last Updated:** 2026-07-06  
**Version:** 0.27.5
