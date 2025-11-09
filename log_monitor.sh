#!/usr/bin/env bash
# Scan logs for keywords and trigger alerts
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

main() {
  load_env
  local ts outlog tmpfile found=0
  ts="$(timestamp)"
  outlog="$LOG_DIR/log_monitor_${ts}.log"

  if [[ -z "${ALERT_KEYWORDS:-}" ]]; then
    log WARN "ALERT_KEYWORDS not defined; skipping scan." | tee -a "$outlog"
    exit 0
  fi

  tmpfile="$(mktemp)"
  trap 'rm -f "$tmpfile"' EXIT

  # Prepare logs to scan
  if [[ -n "${SCAN_LOGS:-}" ]]; then
    IFS=',' read -r -a log_files <<< "$SCAN_LOGS"
    for f in "${log_files[@]}"; do
      f="$(echo "$f" | xargs)"
      [[ -f "$f" ]] && tail -n 2000 "$f" >> "$tmpfile" 2>/dev/null || true
    done
  else
    # Use journalctl fallback
    if command -v journalctl >/dev/null 2>&1; then
      journalctl --since "$LOG_WINDOW_MINUTES minutes ago" --no-pager >> "$tmpfile" 2>/dev/null || true
    elif [[ -f /var/log/syslog ]]; then
      tail -n 2000 /var/log/syslog >> "$tmpfile" 2>/dev/null || true
    fi
  fi

  IFS=',' read -r -a keywords <<< "$ALERT_KEYWORDS"

  for kw in "${keywords[@]}"; do
    kw="$(echo "$kw" | xargs)"
    [[ -z "$kw" ]] && continue
    if grep -i -E -- "$kw" "$tmpfile" >/dev/null 2>&1; then
      cnt="$(grep -i -E -- "$kw" "$tmpfile" | wc -l || echo 0)"
      log WARN "Keyword '$kw' detected x$cnt times" | tee -a "$outlog"
      send_alert "Log alert: $kw detected" "Found $cnt occurrences in last $LOG_WINDOW_MINUTES minutes"
      found=1
    fi
  done

  if [[ "$found" -eq 1 ]]; then
    log WARN "One or more alerts generated." | tee -a "$outlog"
    exit 2
  else
    log INFO "No alerts found." | tee -a "$outlog"
    exit 0
  fi
}

main "$@"
