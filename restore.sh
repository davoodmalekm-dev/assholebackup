#!/usr/bin/env bash
# ================================================================
# Hermes Restore Script — بازیابی از بکاپ GitHub روی یه سرور جدید
# ================================================================
set -euo pipefail

# ⚠️ BEFORE RUNNING: توکن گیت‌هاب رو اینجا بذار:
# GITHUB_TOKEN="ghp_..."
# یا از env بگیره:
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_URL="https://github.com/davoodmalekm-dev/assholebackup.git"
HERMES_HOME="${HOME}/.hermes"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔄 Hermes Restore Tool"
echo "  بازیابی بکاپ روی سرور جدید"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "❌ توکن گیت‌هاب تنظیم نشده!"
    echo "   export GITHUB_TOKEN=\"ghp_...\""
    echo "   یا توکن رو توی اسکریپت بذار"
    exit 1
fi

if ! command -v hermes &>/dev/null; then
    echo "❌ Hermes Agent نصب نیست!"
    echo "   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
    exit 1
fi

HERMES_PATH=$(command -v hermes)
echo "✅ Hermes: ${HERMES_PATH}"

echo ""
echo "[1/4] Downloading backup from GitHub..."
WORK_DIR="/tmp/hermes-restore"
rm -rf "${WORK_DIR}"
git clone --depth 1 "https://${GITHUB_TOKEN}@github.com/davoodmalekm-dev/assholebackup.git" "${WORK_DIR}" 2>&1 || exit 1

echo ""
echo "[2/4] Finding latest backup..."
LATEST_ARCHIVE=$(ls -t "${WORK_DIR}"/hermes-full-backup-*.tar.gz 2>/dev/null | head -1)
if [ -z "${LATEST_ARCHIVE}" ]; then
    echo "❌ No backup archive found!"
    exit 1
fi
echo "   Found: $(basename "${LATEST_ARCHIVE}") ($(du -sh "${LATEST_ARCHIVE}" | cut -f1))"

echo ""
echo "[3/4] Extracting..."
EXTRACT_DIR="/tmp/hermes-restored"
rm -rf "${EXTRACT_DIR}"
mkdir -p "${EXTRACT_DIR}"
tar -xzf "${LATEST_ARCHIVE}" -C "${EXTRACT_DIR}"

echo ""
echo "[4/4] Restoring..."

BACKUP_TIME=$(date +%Y%m%d_%H%M%S)
if [ -d "${HERMES_HOME}" ]; then
    echo "   Backing up existing → ${HERMES_HOME}.bak.${BACKUP_TIME}"
    mv "${HERMES_HOME}" "${HERMES_HOME}.bak.${BACKUP_TIME}"
fi

cp -a "${EXTRACT_DIR}/hermes" "${HERMES_HOME}"
chmod +x "${HERMES_HOME}/scripts/"*.sh 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Restore complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔄 Restart gateway:"
echo "   ${HERMES_PATH} gateway restart"
echo ""
echo "📋 Check cron jobs (inside Hermes):"
echo "   cronjob list"
echo ""

rm -rf "${WORK_DIR}" "${EXTRACT_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 Hermes is ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
