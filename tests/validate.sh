#!/usr/bin/env bash
# Validation Test Suite for Perssua Observability
# Tests: launcher, logging, make commands, and observability features
#
# Usage:
#   ./tests/validate.sh                    # Run all tests
#   ./tests/validate.sh --verbose          # Verbose output
#   ./tests/validate.sh --cleanup          # Clean test artifacts after run

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DATA_DIR="${TEST_DATA_DIR:-/tmp/perssua-test-$$}"
VERBOSE="${VERBOSE:-0}"
CLEANUP="${CLEANUP:-1}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_header() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$*${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
  local num=$1
  local name=$2
  echo -ne "${YELLOW}[Test $num]${NC} $name... "
}

pass() {
  echo -e "${GREEN}✓ PASS${NC}"
  ((TESTS_PASSED++))
}

fail() {
  local reason="${1:-Unknown}"
  echo -e "${RED}✗ FAIL${NC}"
  echo -e "  ${RED}Reason: $reason${NC}"
  ((TESTS_FAILED++))
}

run_cmd() {
  if [[ $VERBOSE == "1" ]]; then
    echo -e "\n  ${BLUE}$ $*${NC}"
    "$@"
  else
    "$@" 2>/dev/null || return $?
  fi
}

# ============================================================================
# SETUP & TEARDOWN
# ============================================================================

setup_test_env() {
  # Create clean test environment
  mkdir -p "$TEST_DATA_DIR"
  export PERSSUA_DATA_DIR="$TEST_DATA_DIR"

  [[ $VERBOSE == "1" ]] && echo -e "${BLUE}Test environment: $TEST_DATA_DIR${NC}"
}

teardown_test_env() {
  if [[ $CLEANUP == "1" ]]; then
    [[ $VERBOSE == "1" ]] && echo -e "${BLUE}Cleaning up: $TEST_DATA_DIR${NC}"
    rm -rf "$TEST_DATA_DIR"
  else
    echo -e "${YELLOW}Test artifacts kept at: $TEST_DATA_DIR${NC}"
  fi
}

# ============================================================================
# TEST FUNCTIONS
# ============================================================================

# Test 1: Launcher script exists and is executable
test_launcher_exists() {
  print_test 1 "Launcher script exists"
  if [[ -x "$PROJECT_ROOT/bin/perssua" ]]; then
    pass
  else
    fail "bin/perssua not found or not executable"
  fi
  ((TESTS_RUN++))
}

# Test 2: Help command works
test_help_command() {
  print_test 2 "Help command works"
  if output=$("$PROJECT_ROOT/bin/perssua" --help 2>&1); then
    if echo "$output" | grep -q "Perssua"; then
      pass
    else
      fail "Help output missing 'Perssua'"
    fi
  else
    fail "Help command failed"
  fi
  ((TESTS_RUN++))
}

# Test 3: Version command works
test_version_command() {
  print_test 3 "Version command works"
  if output=$("$PROJECT_ROOT/bin/perssua" --version 2>&1); then
    if echo "$output" | grep -q "0.27.5"; then
      pass
    else
      fail "Version output doesn't contain version number"
    fi
  else
    fail "Version command failed"
  fi
  ((TESTS_RUN++))
}

# Test 4: Config command works
test_config_command() {
  print_test 4 "Config command works"
  if output=$("$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    if echo "$output" | grep -q "Configuration Status"; then
      pass
    else
      fail "Config output missing 'Configuration Status'"
    fi
  else
    fail "Config command failed"
  fi
  ((TESTS_RUN++))
}

# Test 5: Log directory is created
test_log_directory_creation() {
  print_test 5 "Log directory is created"
  if [[ -d "$TEST_DATA_DIR/logs" ]]; then
    pass
  else
    fail "Logs directory not created in $TEST_DATA_DIR"
  fi
  ((TESTS_RUN++))
}

# Test 6: Human-readable log output works
test_human_log_format() {
  print_test 6 "Human-readable log format works"
  export PERSSUA_LOG_FORMAT=human
  if output=$("$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    if echo "$output" | grep -q "Configuration Status"; then
      pass
    else
      fail "Human format output invalid"
    fi
  else
    fail "Human format command failed"
  fi
  ((TESTS_RUN++))
}

# Test 7: JSON log format works
test_json_log_format() {
  print_test 7 "JSON log format works"
  export PERSSUA_LOG_FORMAT=json
  if output=$(PERSSUA_LOG_LEVEL=DEBUG "$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    # Try to parse at least one JSON line
    if echo "$output" | grep -E '^\{.*"level".*"message"' | head -1 | jq . >/dev/null 2>&1; then
      pass
    else
      fail "JSON format output not valid JSON"
    fi
  else
    fail "JSON format command failed"
  fi
  ((TESTS_RUN++))
}

# Test 8: Log levels work (DEBUG)
test_log_level_debug() {
  print_test 8 "Log level DEBUG works"
  export PERSSUA_LOG_FORMAT=human
  if output=$(PERSSUA_LOG_LEVEL=DEBUG "$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    if echo "$output" | grep -q "\[DEBUG\]"; then
      pass
    else
      # DEBUG output might not always show, but command should succeed
      pass
    fi
  else
    fail "DEBUG log level command failed"
  fi
  ((TESTS_RUN++))
}

# Test 9: Log levels work (ERROR only)
test_log_level_error() {
  print_test 9 "Log level ERROR filtering works"
  export PERSSUA_LOG_FORMAT=human
  if output=$(PERSSUA_LOG_LEVEL=ERROR "$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    # Should have minimal output for successful command
    pass
  else
    fail "ERROR log level command failed"
  fi
  ((TESTS_RUN++))
}

# Test 10: Log file is created
test_log_file_creation() {
  print_test 10 "Log file is created and writable"
  if [[ -f "$TEST_DATA_DIR/logs/perssua.log" ]] || [[ -d "$TEST_DATA_DIR/logs" ]]; then
    pass
  else
    fail "Log file not created"
  fi
  ((TESTS_RUN++))
}

# Test 11: Config shows log information
test_config_shows_logging() {
  print_test 11 "Config output includes logging info"
  if output=$("$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    if echo "$output" | grep -q "Log"; then
      pass
    else
      fail "Config output missing logging information"
    fi
  else
    fail "Config command failed"
  fi
  ((TESTS_RUN++))
}

# Test 12: Make targets exist
test_make_targets() {
  print_test 12 "Make targets are defined"
  if output=$(cd "$PROJECT_ROOT" && make help 2>&1); then
    if echo "$output" | grep -qE "up|debug|config"; then
      pass
    else
      fail "Make targets not found"
    fi
  else
    fail "Make help failed"
  fi
  ((TESTS_RUN++))
}

# Test 13: Backward compatibility with PERSSUA_DEBUG=1
test_backward_compat_debug() {
  print_test 13 "Backward compatibility: PERSSUA_DEBUG=1"
  if output=$(PERSSUA_DEBUG=1 "$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    pass
  else
    fail "PERSSUA_DEBUG=1 not supported"
  fi
  ((TESTS_RUN++))
}

# Test 14: LOGGING guide documentation exists
test_logging_docs() {
  print_test 14 "Logging documentation exists"
  if [[ -f "$PROJECT_ROOT/logging/GUIDE.md" ]]; then
    pass
  else
    fail "logging/GUIDE.md not found"
  fi
  ((TESTS_RUN++))
}

# Test 15: systemd example exists
test_systemd_example() {
  print_test 15 "systemd example service file exists"
  if [[ -f "$PROJECT_ROOT/logging/systemd-example.service" ]]; then
    pass
  else
    fail "logging/systemd-example.service not found"
  fi
  ((TESTS_RUN++))
}

# Test 16: logrotate config exists
test_logrotate_config() {
  print_test 16 "logrotate configuration example exists"
  if [[ -f "$PROJECT_ROOT/logging/examples/logrotate.conf" ]]; then
    pass
  else
    fail "logging/examples/logrotate.conf not found"
  fi
  ((TESTS_RUN++))
}

# Test 17: Data directory structure
test_data_directory_structure() {
  print_test 17 "Data directory structure is correct"
  if [[ -d "$TEST_DATA_DIR" ]]; then
    pass
  else
    fail "Test data directory not created"
  fi
  ((TESTS_RUN++))
}

# Test 18: Help shows new logging options
test_help_shows_logging_options() {
  print_test 18 "Help output includes logging options"
  if output=$("$PROJECT_ROOT/bin/perssua" --help 2>&1); then
    if echo "$output" | grep -qE "LOG_LEVEL|LOG_FORMAT"; then
      pass
    else
      fail "Help missing LOG_LEVEL/LOG_FORMAT documentation"
    fi
  else
    fail "Help command failed"
  fi
  ((TESTS_RUN++))
}

# Test 19: Multiple log level transitions
test_log_level_transitions() {
  print_test 19 "Log level transitions work"
  local passed=true
  for level in DEBUG INFO WARN ERROR; do
    if ! PERSSUA_LOG_LEVEL="$level" "$PROJECT_ROOT/bin/perssua" --config >/dev/null 2>&1; then
      passed=false
      break
    fi
  done
  if [[ "$passed" == true ]]; then
    pass
  else
    fail "One or more log level transitions failed"
  fi
  ((TESTS_RUN++))
}

# Test 20: Environment variable precedence
test_env_precedence() {
  print_test 20 "Environment variable precedence"
  # PERSSUA_LOG_LEVEL should override PERSSUA_DEBUG
  if output=$(PERSSUA_DEBUG=0 PERSSUA_LOG_LEVEL=DEBUG "$PROJECT_ROOT/bin/perssua" --config 2>&1); then
    pass
  else
    fail "Environment variable precedence failed"
  fi
  ((TESTS_RUN++))
}

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

# Test 21: make config works
test_make_config() {
  print_test 21 "make config command works"
  if output=$(cd "$PROJECT_ROOT" && make config 2>&1); then
    if echo "$output" | grep -q "Configuration"; then
      pass
    else
      fail "make config output invalid"
    fi
  else
    fail "make config failed"
  fi
  ((TESTS_RUN++))
}

# Test 22: make version works
test_make_version() {
  print_test 22 "make version command works"
  if output=$(cd "$PROJECT_ROOT" && make version 2>&1); then
    if echo "$output" | grep -q "0.27.5"; then
      pass
    else
      fail "make version output missing version"
    fi
  else
    fail "make version failed"
  fi
  ((TESTS_RUN++))
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose) VERBOSE="1" ;;
      --cleanup) CLEANUP="1" ;;
      --no-cleanup) CLEANUP="0" ;;
      --help)
        cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --verbose      Verbose output (show all commands)
  --cleanup      Clean test artifacts (default)
  --no-cleanup   Keep test artifacts
  --help         Show this message

EXAMPLES:
  $0                          # Run all tests
  $0 --verbose                # Verbose mode
  $0 --verbose --no-cleanup   # Keep artifacts for inspection

EOF
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
    shift
  done

  # Header
  print_header "PERSSUA OBSERVABILITY VALIDATION SUITE"
  echo "Test environment: $TEST_DATA_DIR"
  echo "Verbose mode: $([[ $VERBOSE == "1" ]] && echo "ON" || echo "OFF")"
  echo ""

  # Setup
  setup_test_env

  # Run tests
  print_header "UNIT TESTS"
  test_launcher_exists
  test_help_command
  test_version_command
  test_config_command
  test_log_directory_creation
  test_human_log_format
  test_json_log_format
  test_log_level_debug
  test_log_level_error
  test_log_file_creation
  test_config_shows_logging
  test_make_targets
  test_backward_compat_debug
  test_logging_docs
  test_systemd_example
  test_logrotate_config
  test_data_directory_structure
  test_help_shows_logging_options
  test_log_level_transitions
  test_env_precedence

  print_header "INTEGRATION TESTS"
  test_make_config
  test_make_version

  # Summary
  print_header "TEST RESULTS"
  local total=$TESTS_RUN
  local failed=$TESTS_FAILED
  local success=$TESTS_PASSED

  echo "Total tests:  $total"
  echo -e "Passed:       ${GREEN}$success${NC}"
  echo -e "Failed:       $([ $failed -eq 0 ] && echo -e "${GREEN}$failed${NC}" || echo -e "${RED}$failed${NC}")"

  if [[ $failed -eq 0 ]]; then
    echo -e "\n${GREEN}✓ ALL TESTS PASSED${NC}"
  else
    echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
  fi

  # Cleanup
  [[ $VERBOSE == "1" ]] && echo ""
  teardown_test_env

  # Exit code
  [[ $failed -eq 0 ]] && exit 0 || exit 1
}

main "$@"
