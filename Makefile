.PHONY: help up install install-user install-system configure-sandbox uninstall config debug debug-json version validate test test-full test-verbose test-no-cleanup lint tail-logs

# Default target
.DEFAULT_GOAL := help

# Project paths
SHELL := /bin/bash
PROJECT_ROOT := $(shell pwd)
BIN_DIR := $(PROJECT_ROOT)/bin
PERSSUA := $(BIN_DIR)/perssua
VERSION := 0.27.5
APPIMAGE := $(BIN_DIR)/Perssua-$(VERSION)-x86_64.AppImage

# Color output
BOLD := $(shell printf '\033[1m')
BLUE := $(shell printf '\033[34m')
GREEN := $(shell printf '\033[32m')
YELLOW := $(shell printf '\033[33m')
RESET := $(shell printf '\033[0m')

# ============================================================================
# TARGETS
# ============================================================================

help:
	@echo "$(BOLD)Perssua - AI-powered Audio Capture Tool$(RESET)"
	@echo ""
	@echo "$(BOLD)Usage:$(RESET)"
	@echo "  make $(GREEN)up$(RESET)                   Launch Perssua application"
	@echo "  make $(GREEN)install-user$(RESET)        Install 'perssua' command for current user"
	@echo "  make $(GREEN)install-system$(RESET)      Install 'perssua' command system-wide (needs sudo)"
	@echo "  make $(GREEN)configure-sandbox$(RESET)   Configure Chrome sandbox (one-time setup)"
	@echo "  make $(GREEN)uninstall$(RESET)           Remove 'perssua' command"
	@echo "  make $(GREEN)config$(RESET)              Show configuration status"
	@echo "  make $(GREEN)debug$(RESET)               Launch with debug logging enabled"
	@echo "  make $(GREEN)debug-json$(RESET)          Launch with debug logging (JSON format)"
	@echo "  make $(GREEN)version$(RESET)             Show version information"
	@echo "  make $(GREEN)help$(RESET)                Show this help message"
	@echo ""
	@echo "$(BOLD)Development:$(RESET)"
	@echo "  make $(GREEN)validate$(RESET)           Validate prerequisites and configuration"
	@echo "  make $(GREEN)test$(RESET)               Run test suite (observability validation)"
	@echo "  make $(GREEN)tail-logs$(RESET)          Monitor logs in real-time"
	@echo "  make $(GREEN)clean$(RESET)              Remove extracted files and cache"
	@echo ""
	@echo "$(BOLD)Logging & Observability:$(RESET)"
	@echo "  PERSSUA_LOG_LEVEL=DEBUG make up         Launch with debug logs"
	@echo "  PERSSUA_LOG_FORMAT=json make up         Launch with JSON output"
	@echo "  make tail-logs                          Monitor logs (tail -f data/logs/perssua.log)"
	@echo ""
	@echo "$(BOLD)Documentation:$(RESET)"
	@echo "  $(YELLOW)README.md$(RESET)                 Project overview"
	@echo "  $(YELLOW)logging/GUIDE.md$(RESET)          Logging & observability guide"
	@echo "  $(YELLOW)docs/GUIDE.md$(RESET)             Complete setup & architecture guide"
	@echo "  $(YELLOW)docs/TROUBLESHOOT.md$(RESET)      Troubleshooting & FAQ"

# ============================================================================
# MAIN TARGETS
# ============================================================================

up:
	@echo "$(BLUE)[Perssua] Launching...$(RESET)"
	@$(PERSSUA)

debug:
	@echo "$(BLUE)[Perssua] Launching with debug enabled...$(RESET)"
	@PERSSUA_DEBUG=1 $(PERSSUA)

debug-json:
	@echo "$(BLUE)[Perssua] Launching with debug logging (JSON format)...$(RESET)"
	@PERSSUA_LOG_LEVEL=DEBUG PERSSUA_LOG_FORMAT=json $(PERSSUA)

version:
	@$(PERSSUA) --version

config:
	@$(PERSSUA) --config

# ============================================================================
# INSTALLATION TARGETS
# ============================================================================

install-deps:
	@echo "$(BLUE)[Setup] Installing system dependencies (FUSE3)...$(RESET)"
	@if command -v apt &>/dev/null; then \
		echo "$(BLUE)[Setup] Detected: Ubuntu/Debian$(RESET)"; \
		sudo apt update && sudo apt install -y fuse3; \
	elif command -v dnf &>/dev/null; then \
		echo "$(BLUE)[Setup] Detected: Fedora/RHEL$(RESET)"; \
		sudo dnf install -y fuse3; \
	elif command -v zypper &>/dev/null; then \
		echo "$(BLUE)[Setup] Detected: openSUSE$(RESET)"; \
		sudo zypper install -y fuse3; \
	elif command -v pacman &>/dev/null; then \
		echo "$(BLUE)[Setup] Detected: Arch Linux$(RESET)"; \
		sudo pacman -S --noconfirm fuse3; \
	else \
		echo "$(YELLOW)[Setup] Could not detect package manager$(RESET)"; \
		echo "$(YELLOW)Please install FUSE3 manually: sudo apt install fuse3 (or equivalent)$(RESET)"; \
	fi
	@if which fusermount3 >/dev/null 2>&1; then \
		echo "$(GREEN)✓ FUSE3 installed$(RESET)"; \
	fi

configure-sandbox:
	@echo "$(BLUE)[Setup] Configuring Chrome sandbox (one-time, needs sudo)...$(RESET)"
	@SANDBOX_PATH="$(PROJECT_ROOT)/data/squashfs-root/chrome-sandbox"; \
	if [[ -f "$$SANDBOX_PATH" ]]; then \
		sudo chown root:root "$$SANDBOX_PATH" && \
		sudo chmod 4755 "$$SANDBOX_PATH" && \
		echo "$(GREEN)✓ Sandbox configured$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ AppImage not extracted yet. Run 'make up' first.$(RESET)"; \
	fi

install-user:
	@echo "$(BLUE)[Setup] Installing for current user...$(RESET)"
	@$(BIN_DIR)/setup.sh --user

install-system:
	@echo "$(BLUE)[Setup] Installing system-wide (requires sudo)...$(RESET)"
	@$(BIN_DIR)/setup.sh --system

install: install-deps install-user
	@echo "$(GREEN)✓ Installation complete!$(RESET)"
	@echo "$(BLUE)Next: perssua --config$(RESET)"

uninstall:
	@echo "$(YELLOW)[Setup] Uninstalling perssua command...$(RESET)"
	@$(BIN_DIR)/setup.sh --uninstall

# ============================================================================
# VALIDATION & MAINTENANCE
# ============================================================================

validate:
	@echo "$(BLUE)[Check] Validating prerequisites...$(RESET)"
	@which fusermount3 >/dev/null 2>&1 && echo "$(GREEN)✓ FUSE3 installed$(RESET)" || echo "$(YELLOW)✗ FUSE3 not found$(RESET)"
	@[[ -f "$(PERSSUA)" ]] && echo "$(GREEN)✓ Launcher found$(RESET)" || echo "$(YELLOW)✗ Launcher not found$(RESET)"
	@[[ -f "$(APPIMAGE)" ]] && echo "$(GREEN)✓ AppImage found$(RESET)" || echo "$(YELLOW)✗ AppImage not found$(RESET)"
	@which perssua >/dev/null 2>&1 && echo "$(GREEN)✓ perssua command available$(RESET)" || echo "$(YELLOW)✗ perssua not in PATH$(RESET)"

clean:
	@echo "$(YELLOW)[Clean] Removing extracted files and cache...$(RESET)"
	@rm -rf $(PROJECT_ROOT)/data/squashfs-root
	@echo "$(GREEN)✓ Cleaned extracted files$(RESET)"
	@echo "$(BLUE)Note: Configuration and cache preserved. To reset everything:$(RESET)"
	@echo "  rm -rf $(PROJECT_ROOT)/data"

# ============================================================================
# DEVELOPMENT & TESTING
# ============================================================================

test:
	@echo "$(BLUE)[Test] Running observability smoke tests...$(RESET)"
	@bash tests/smoke-test.sh

test-full:
	@echo "$(BLUE)[Test] Running comprehensive validation suite...$(RESET)"
	@bash tests/validate.sh

test-verbose:
	@echo "$(BLUE)[Test] Running observability validation suite (verbose)...$(RESET)"
	@bash tests/validate.sh --verbose

test-no-cleanup:
	@echo "$(BLUE)[Test] Running observability validation suite (keep artifacts)...$(RESET)"
	@bash tests/validate.sh --no-cleanup

lint:
	@echo "$(BLUE)[Lint] Checking shell scripts...$(RESET)"
	@if command -v shellcheck &>/dev/null; then \
		shellcheck $(BIN_DIR)/perssua $(BIN_DIR)/setup.sh && echo "$(GREEN)✓ No issues found$(RESET)"; \
	else \
		echo "$(YELLOW)shellcheck not installed. Install with: sudo apt install shellcheck$(RESET)"; \
	fi

# ============================================================================
# LOGGING & OBSERVABILITY
# ============================================================================

tail-logs:
	@if [[ -f "$(PROJECT_ROOT)/data/logs/perssua.log" ]]; then \
		echo "$(BLUE)[Logs] Monitoring logs in real-time (Ctrl+C to exit)...$(RESET)"; \
		tail -f "$(PROJECT_ROOT)/data/logs/perssua.log"; \
	else \
		echo "$(YELLOW)[Logs] No log file found. Run 'make up' first.$(RESET)"; \
	fi

.PHONY: up debug version config install-user install-system install uninstall validate test test-verbose test-no-cleanup clean lint tail-logs help
