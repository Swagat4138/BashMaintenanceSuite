#!/usr/bin/env bash
# Utility functions shared by all maintenance scripts
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Returns current timestamp
timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

# General logging functions
log() {
  local level="${1:-INFO}"; shift || true
  local message="$*"
  local ts
  ts="$(timestamp)"
  echo "[$ts] [$level] $message"
}

log_to_file() {
  local file="$1"; shift
  local ts
  ts="$(timestamp)"
  printf "[%s] %s\n" "$ts" "$*" >> "$file"
}

# Check for root privileges
require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    log ERROR "This action requires root. Re-run with sudo."
    exit 1
  fi
}

# Load environment variables
load_env() {
  local env_file="$SCRIPT_DIR/.env"
  if [[ -f "$env_file" ]]; then
    source "$env_file"
  else
    log WARN "No .env file found. Using defaults from .env.example where possible."
    source "$SCRIPT_DIR/.env.example"
  fi
}

# Detect system package manager
detect_pkg_manager() {
    local forced="${PACKAGE_MANAGER:-}"
    if [[ -n "$forced" ]]; then
    echo "$forced"
    return
    fi
    if command -v apt >/dev/null 2>&1; then echo "apt" && return; fi
    if command -v dnf >/dev/null 2>&1; then echo "dnf" && return; fi
    if command -v pacman >/dev/null 2>&1; then echo "pacman" && return; fi
    echo ""
}

# Send email alert if configured
send_alert() {
    local subject="$1"; shift
    local body="$*"
    local recipient="${NOTIFY_EMAIL:-}"
    local log_file="$LOG_DIR/alerts_$(date +%Y-%m-%d).log"
    log_to_file "$log_file" "$subject :: $body"
    if [[ -n "$recipient" ]] && command -v mail >/dev/null 2>&1; then
    printf "%s\n" "$body" | mail -s "$subject" "$recipient" || true
    fi
}
