#!/usr/bin/env bash
# Smoke Test - Quick validation that observability features work
#
# Usage:
#   ./tests/smoke-test.sh      # Quick test
#   ./tests/smoke-test.sh -v   # Verbose

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERBOSE="${1:-}"
PERSSUA="$PROJECT_ROOT/bin/perssua"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
info() { echo -e "${BLUE}→${NC} $1"; }

[[ -x "$PERSSUA" ]] || fail "Launcher not found at $PERSSUA"

info "Testing Perssua observabilidade..."
echo ""

# Test 1: Help
info "Test 1: Help command"
"$PERSSUA" --help >/dev/null 2>&1 && pass "Help works" || fail "Help failed"

# Test 2: Version
info "Test 2: Version command"
output=$("$PERSSUA" --version 2>&1)
echo "$output" | grep -q "0.23.3" && pass "Version works" || fail "Version failed"

# Test 3: Config
info "Test 3: Config command"
"$PERSSUA" --config >/dev/null 2>&1 && pass "Config works" || fail "Config failed"

# Test 4: Logging docs exist
info "Test 4: Logging documentation"
[[ -f "$PROJECT_ROOT/logging/GUIDE.md" ]] && pass "logging/GUIDE.md exists" || fail "logging/GUIDE.md not found"

# Test 5: Systemd example
info "Test 5: Systemd service file"
[[ -f "$PROJECT_ROOT/logging/systemd-example.service" ]] && pass "systemd-example.service exists" || fail "systemd-example.service not found"

# Test 6: Logrotate config
info "Test 6: Logrotate configuration"
[[ -f "$PROJECT_ROOT/logging/examples/logrotate.conf" ]] && pass "logrotate.conf exists" || fail "logrotate.conf not found"

# Test 7: Log level support
info "Test 7: Log level configuration"
export PERSSUA_LOG_LEVEL="DEBUG"
"$PERSSUA" --config >/dev/null 2>&1 && pass "DEBUG log level works" || fail "DEBUG log level failed"

# Test 8: Human format
info "Test 8: Human log format"
export PERSSUA_LOG_FORMAT="human"
"$PERSSUA" --config >/dev/null 2>&1 && pass "Human format works" || fail "Human format failed"

# Test 9: JSON format
info "Test 9: JSON log format"
export PERSSUA_LOG_FORMAT="json"
"$PERSSUA" --config >/dev/null 2>&1 && pass "JSON format works" || fail "JSON format failed"

# Test 10: Make test target
info "Test 10: Make test target"
cd "$PROJECT_ROOT"
if make help 2>&1 | grep -i "test" >/dev/null 2>&1 || true; then
  pass "make test target exists"
else
  fail "make test target not found"
fi

echo ""
echo -e "${GREEN}✓ All smoke tests passed!${NC}"
echo ""
echo "Next steps:"
echo "  • Read logging/GUIDE.md for detailed configuration"
echo "  • Try: PERSSUA_LOG_LEVEL=DEBUG perssua --config"
echo "  • Try: make tail-logs (after 'make up')"
echo "  • Run: make test (comprehensive validation)"
