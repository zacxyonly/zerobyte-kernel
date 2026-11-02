#!/usr/bin/env bash
# ==============================================================================
# ZeroByte Kernel Configuration Applier
# Applies battery-friendly tuning fragment and localversion to gki_defconfig
# ==============================================================================
set -euo pipefail

KERNEL_DIR="${1:-.}"
DEFCONFIG="${2:-arch/arm64/configs/gki_defconfig}"
ENABLE_LTO="${3:-true}"
KERNEL_NAME="${4:-ZeroByte-Kernel}"

CONFIG_TOOL="${KERNEL_DIR}/scripts/config"
TARGET_FILE="${KERNEL_DIR}/${DEFCONFIG}"

if [[ ! -f "$CONFIG_TOOL" ]]; then
    echo "[-] Error: scripts/config not found at $CONFIG_TOOL"
    exit 1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
    echo "[-] Error: Target defconfig not found at $TARGET_FILE"
    exit 1
fi

echo "[*] Applying ZeroByte Kernel configuration to ${TARGET_FILE}..."

# 1. Stripping Debugging & Tracing Overhead
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable DEBUG_INFO_DWARF4
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable DEBUG_INFO_BTF
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable PM_DEBUG
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable PM_ADVANCED_DEBUG
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable DYNAMIC_DEBUG_CORE
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable KUNIT_DEBUGFS
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable DEBUG_MEMORY_INIT
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable SLUB_DEBUG
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable CMA_DEBUGFS
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable ANDROID_DEBUG_SYMBOLS
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable ANDROID_DEBUG_KINFO

# 2. Power Management & Deep Sleep
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable NO_HZ_IDLE
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable CPU_IDLE_GOV_MENU
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable CPU_FREQ_GOV_SCHEDUTIL

# 3. Memory & ZRAM (Default LZ4 Zero-Overhead)
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable CRYPTO_LZ4
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable CRYPTO_ZSTD
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --set-str ZRAM_DEF_COMP "lz4"

# 4. Networking (TCP BBR)
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable TCP_CONG_BBR
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --set-str DEFAULT_TCP_CONG "bbr"

# 5. Link-Time Optimization (ThinLTO)
if [[ "${ENABLE_LTO}" == "true" ]]; then
    "${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable LTO_CLANG_THIN
    "${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable LTO_NONE
else
    "${CONFIG_TOOL}" --file "${TARGET_FILE}" --disable LTO_CLANG_THIN
    "${CONFIG_TOOL}" --file "${TARGET_FILE}" --enable LTO_NONE
fi

# 6. Set Local Version
"${CONFIG_TOOL}" --file "${TARGET_FILE}" --set-str LOCALVERSION "-${KERNEL_NAME}"

echo "[+] Successfully configured ${TARGET_FILE} for ZeroByte Kernel (-${KERNEL_NAME})."
