#!/usr/bin/env bash
# Perssua Setup Script
# Installs perssua command to system PATH for global access
#
# Usage: ./bin/setup.sh [options]
# Options:
#   --user      Install for current user only (default)
#   --system    Install system-wide (requires sudo)
#   --uninstall Uninstall perssua command
#   --help      Show this message

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_SCRIPT="$SCRIPT_DIR/perssua"
INSTALL_MODE="${1:-user}"  # user | system | uninstall

# User install location
USER_BIN_DIR="$HOME/.local/bin"

# System install location (requires sudo)
SYSTEM_BIN_DIR="/usr/local/bin"

INSTALL_TARGET=""

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
  echo "ℹ️  $*"
}

log_success() {
  echo "✓ $*"
}

log_error() {
  echo "✗ Error: $*" >&2
}

die() {
  log_error "$1"
  exit "${2:-1}"
}

show_help() {
  cat << EOF
Perssua Setup Script
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script installs the 'perssua' command globally so you can type:
  perssua

...from any directory without prefixing the full path.

USAGE:
  ./bin/setup.sh [option]

OPTIONS:
  --user       Install for current user (~/.local/bin)
               Requires ~/.local/bin to be in PATH
               Default option

  --system     Install system-wide (/usr/local/bin)
               Requires sudo password
               Available to all users

  --uninstall  Remove perssua command
  --help       Show this help message

EXAMPLES:
  ./bin/setup.sh           # Install for user (default)
  ./bin/setup.sh --system  # Install system-wide
  ./bin/setup.sh --user    # Explicitly install for user

VERIFICATION:
  After installation, verify with:
    which perssua
    perssua --version

POST-INSTALLATION:
  If using --user install, ensure ~/.local/bin is in your PATH.

  Add to ~/.bashrc or ~/.zshrc if needed:
    export PATH="\$HOME/.local/bin:\$PATH"

  Then reload:
    source ~/.bashrc

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_user() {
  log_info "Installing perssua for current user ($USER)..."
  log_info "Target: $USER_BIN_DIR/perssua"

  # Create user bin directory if needed
  if [[ ! -d "$USER_BIN_DIR" ]]; then
    mkdir -p "$USER_BIN_DIR"
    log_info "Created $USER_BIN_DIR"
  fi

  # Check if in PATH
  if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
    log_error ""
    log_error "WARNING: $USER_BIN_DIR is not in your PATH!"
    log_error ""
    log_error "Add this to ~/.bashrc or ~/.zshrc:"
    log_error "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    log_error ""
    log_error "Then run: source ~/.bashrc"
    log_error ""
  fi

  # Create symlink or copy
  if [[ -e "$USER_BIN_DIR/perssua" ]]; then
    rm -f "$USER_BIN_DIR/perssua"
    log_info "Removed old installation"
  fi

  # Use symlink for development (easier to update)
  ln -s "$BIN_SCRIPT" "$USER_BIN_DIR/perssua"

  log_success "Installed perssua to $USER_BIN_DIR/perssua (symlink)"
  log_info ""
  log_info "Verify installation:"
  log_info "  which perssua"
  log_info "  perssua --version"
}

install_system() {
  log_info "Installing perssua system-wide..."
  log_info "Target: $SYSTEM_BIN_DIR/perssua (requires sudo)"

  if ! command -v sudo &> /dev/null; then
    die "sudo command not found. Cannot install system-wide." 1
  fi

  if [[ -e "$SYSTEM_BIN_DIR/perssua" ]]; then
    sudo rm -f "$SYSTEM_BIN_DIR/perssua"
    log_info "Removed old installation"
  fi

  # Use symlink for easier updates
  sudo ln -s "$BIN_SCRIPT" "$SYSTEM_BIN_DIR/perssua"

  log_success "Installed perssua to $SYSTEM_BIN_DIR/perssua (symlink)"
  log_info "Available to all users"
  log_info ""
  log_info "Verify installation:"
  log_info "  which perssua"
  log_info "  perssua --version"
}

uninstall() {
  local uninstalled=0

  # Check user install
  if [[ -L "$USER_BIN_DIR/perssua" ]]; then
    rm -f "$USER_BIN_DIR/perssua"
    log_success "Removed $USER_BIN_DIR/perssua"
    uninstalled=$((uninstalled + 1))
  fi

  # Check system install
  if [[ -L "$SYSTEM_BIN_DIR/perssua" ]]; then
    sudo rm -f "$SYSTEM_BIN_DIR/perssua"
    log_success "Removed $SYSTEM_BIN_DIR/perssua"
    uninstalled=$((uninstalled + 1))
  fi

  if [[ $uninstalled -eq 0 ]]; then
    log_info "No perssua installation found"
  else
    log_success "Uninstalled $uninstalled instance(s) of perssua"
  fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  case "$INSTALL_MODE" in
    --help|-h|help)
      show_help
      exit 0
      ;;
    --user|-u)
      install_user
      ;;
    --system|-s)
      install_system
      ;;
    --uninstall|-x)
      uninstall
      ;;
    *)
      log_error "Unknown option: $INSTALL_MODE"
      log_error "Use --help for usage information"
      exit 1
      ;;
  esac
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main "$@"
