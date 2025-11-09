# 🛠 Bash Maintenance Suite

**Bash Maintenance Suite**  

A powerful Bash toolkit to automate Linux system maintenance tasks:

- 🔹 **Automated Backups** – Configurable sources & retention (`KEEP_DAYS`)  
- 🔹 **System Updates & Cleanup** – Supports `apt`, `dnf`, `pacman`  
- 🔹 **Log Monitoring** – Keyword alerts (`ALERT_KEYWORDS`), cron/systemd friendly  
- 🔹 **Interactive Menu** – Run tasks on demand  

> Tested on Ubuntu/Debian, Fedora/RHEL, and Arch-based systems. Requires **Bash 4+**.

---

## 🚀 Quick Start

```bash
git clone <repo_url> BashMaintenanceSuite
cd BashMaintenanceSuite
cp .env.example .env
# Edit .env to configure paths, log keywords, retention, and email notifications
chmod +x *.sh
./menu.sh
```
## 📜 Included Scripts

| Script | Description |
|--------|-------------|
| 🗄️ `backup.sh` | Archives specified directories into timestamped `.tar.gz` files and prunes old backups based on `KEEP_DAYS`. |
| 🔄 `update_cleanup.sh` | Performs safe system updates and cleans caches/logs. Auto-detects your package manager or uses `PACKAGE_MANAGER` from `.env`. |
| 📝 `log_monitor.sh` | Scans logs for keywords defined in `ALERT_KEYWORDS` within the last `LOG_WINDOW_MINUTES` minutes. Generates alerts and exits with a non-zero status if matches are found. |
| 🎛️ `menu.sh` | Interactive menu to run suite tasks easily without remembering commands. |
| ⚙️ `install.sh` | Optional installer for setting up cron jobs or a systemd timer for log monitoring, and making scripts executable. |
| 🛠️ `utils.sh` | Helper functions shared across scripts (environment loading, logging, sudo checks, package manager detection, alerting). |
