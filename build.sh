#!/usr/bin/env bash
# ==============================================================================
# ZeroByte Kernel Standalone Builder
# Target: Realme P3 5G (RMX5079 / dongfeng / SM6650)
# ==============================================================================
set -euo pipefail

# --- Color Constants ---
C_RESET="\033[0m"
C_RED="\033[1;31m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_BLUE="\033[1;34m"
C_CYAN="\033[1;36m"

log_info()    { echo -e "${C_BLUE}[*]${C_RESET} $*"; }
log_success() { echo -e "${C_GREEN}[+]${C_RESET} $*"; }
log_warn()    { echo -e "${C_YELLOW}[!]${C_RESET} $*"; }
log_error()   { echo -e "${C_RED}[-]${C_RESET} $*"; }

# --- Directories & Defaults ---
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${ROOT_DIR}/workspace_root"
TOOLCHAIN_DIR="${ROOT_DIR}/toolchain/clang-aosp"
OUT_DIR="${ROOT_DIR}/out"

KERNEL_NAME="ZeroByte-Kernel"
BRANCH="realme/sm6650_16_b_16.0_p3_5g"
VARIANT="original"
ENABLE_LTO=true
JOBS="$(nproc --all)"
BUILD_DATE="$(date +'%Y%m%d_%H%M%S')"

CLANG_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android14-release/clang-r487747c.tar.gz"
TREE_MODULES_URL="https://github.com/realme-kernel-opensource/android_kernel_modules_and_devicetree_realme_sm6650.git"
TREE_COMMON_URL="https://github.com/realme-kernel-opensource/android_kernel_common_realme_sm6650.git"

# --- Usage Guide ---
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

ZeroByte Kernel Automated Build Script for Realme P3 5G (dongfeng / RMX5079)

Options:
  -v, --variant <type>    Build variant: original (default), ksu, or all
  -n, --name <name>       Kernel name string (default: ZeroByte-Kernel)
  --lto / --no-lto        Enable or disable Clang ThinLTO (default: enabled)
  -j, --jobs <n>          Number of parallel compilation jobs (default: all cores)
  -c, --clean             Clean build output directories and exit
  -h, --help              Show this help message and exit

Examples:
  ./build.sh --variant ksu
  ./build.sh --variant original --no-lto
  ./build.sh --variant all
EOF
    exit 0
}

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--variant)
            VARIANT="${2:-}"
            shift 2
            ;;
        -n|--name)
            KERNEL_NAME="${2:-}"
            shift 2
            ;;
        --lto)
            ENABLE_LTO=true
            shift
            ;;
        --no-lto)
            ENABLE_LTO=false
            shift
            ;;
        -j|--jobs)
            JOBS="${2:-}"
            shift 2
            ;;
        -c|--clean)
            log_info "Cleaning build output directories..."
            rm -rf "${OUT_DIR}" "${WORKSPACE_DIR}/kernel_platform/common/out_"*
            log_success "Clean completed."
            exit 0
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# --- Dependency Checker ---
check_deps() {
    local missing=()
    for bin in git curl tar make bc bison flex zip python3; do
        if ! command -v "$bin" >/dev/null 2>&1; then
            missing+=("$bin")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required build tools: ${missing[*]}"
        log_info "On Ubuntu/Debian, run: sudo apt install -y build-essential bc bison flex git zip curl python3 libssl-dev libelf-dev"
        exit 1
    fi
}

# --- Toolchain Setup ---
setup_toolchain() {
    if [[ -x "${TOOLCHAIN_DIR}/bin/clang" ]]; then
        log_info "AOSP Clang toolchain already present: $(${TOOLCHAIN_DIR}/bin/clang --version | head -n1)"
        return
    fi

    log_info "Downloading AOSP Clang Reference Toolchain (r487747c)..."
    mkdir -p "${TOOLCHAIN_DIR}"
    curl -sSL "${CLANG_URL}" | tar -xz -C "${TOOLCHAIN_DIR}"
    log_success "AOSP Clang downloaded successfully."
}

# --- Source Trees Setup ---
setup_sources() {
    if [[ ! -d "${WORKSPACE_DIR}/kernel_platform/common/.git" ]]; then
        log_info "Cloning Realme SM6650 Vendor Tree..."
        git clone -b "${BRANCH}" --depth 1 "${TREE_MODULES_URL}" "${WORKSPACE_DIR}"

        log_info "Cloning Realme SM6650 Common Kernel Tree..."
        git clone -b "${BRANCH}" --depth 1 "${TREE_COMMON_URL}" "${WORKSPACE_DIR}/kernel_platform/common"
        log_success "Kernel sources ready."
    else
        log_info "Kernel sources already present in ${WORKSPACE_DIR}."
    fi
}

# --- Compile Single Variant ---
compile_variant() {
    local var_name="$1"
    local common_dir="${WORKSPACE_DIR}/kernel_platform/common"
    local out_sub="out_${var_name}"
    local img_path="${common_dir}/${out_sub}/arch/arm64/boot/Image"

    log_info "=========================================================="
    log_info "Starting build for variant: ${C_CYAN}${var_name}${C_RESET}"
    log_info "=========================================================="

    cd "${common_dir}"

    # Reset any git working tree changes in common kernel
    git checkout -f arch/arm64/configs/gki_defconfig >/dev/null 2>&1 || true

    # Integrate Root Drivers
    if [[ "${var_name}" == "ksu" ]]; then
        log_info "Integrating KernelSU-Next..."
        curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next
    fi

    # Apply configuration fragment
    "${ROOT_DIR}/configs/apply_config.sh" "${common_dir}" "arch/arm64/configs/gki_defconfig" "${ENABLE_LTO}" "${KERNEL_NAME}"

    # Setup Cross-Compilation Environment
    export PATH="${TOOLCHAIN_DIR}/bin:$PATH"
    export ARCH=arm64
    export SUBARCH=arm64
    export CC=clang
    export LD=ld.lld
    export LLVM=1
    export LLVM_IAS=1
    export CLANG_TRIPLE=aarch64-linux-gnu-
    export CROSS_COMPILE=aarch64-linux-gnu-

    log_info "Generating defconfig..."
    make -j"${JOBS}" O="${out_sub}" gki_defconfig

    log_info "Compiling Kernel Image (Parallel jobs: ${JOBS})..."
    local start_time=$(date +%s)
    make -j"${JOBS}" O="${out_sub}" Image
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ ! -f "${img_path}" ]]; then
        log_error "Compilation failed: Image not found at ${img_path}"
        exit 1
    fi
    log_success "Image compiled successfully in $((duration / 60))m $((duration % 60))s."

    # Package via AnyKernel3
    package_zip "${var_name}" "${img_path}"
}

# --- Package Flashable ZIP ---
package_zip() {
    local var_name="$1"
    local img_path="$2"
    local pkg_dir="${WORKSPACE_DIR}/anykernel_${var_name}"
    local zip_title=""

    case "${var_name}" in
        original) zip_title="${KERNEL_NAME}_Original_SM6650_${BUILD_DATE}.zip" ;;
        ksu)      zip_title="${KERNEL_NAME}_KernelSU_SM6650_${BUILD_DATE}.zip" ;;
        apatch)   zip_title="${KERNEL_NAME}_APatch_SM6650_${BUILD_DATE}.zip" ;;
        *)        zip_title="${KERNEL_NAME}_${var_name}_SM6650_${BUILD_DATE}.zip" ;;
    esac

    log_info "Packaging AnyKernel3 flashable ZIP..."
    rm -rf "${pkg_dir}"
    mkdir -p "${pkg_dir}" "${OUT_DIR}"
    cp -r "${ROOT_DIR}/anykernel/"* "${pkg_dir}/"
    cp -f "${img_path}" "${pkg_dir}/Image"

    cd "${pkg_dir}"
    zip -r9 "${OUT_DIR}/${zip_title}" * -x .git README.md *placeholder >/dev/null 2>&1
    cd "${ROOT_DIR}"
    rm -rf "${pkg_dir}"

    local zip_file="${OUT_DIR}/${zip_title}"
    local sha256=$(sha256sum "${zip_file}" | awk '{print $1}')
    local size=$(ls -lh "${zip_file}" | awk '{print $5}')

    log_success "Build complete: ${C_GREEN}${zip_file}${C_RESET} (${size})"
    log_info "SHA256: ${C_CYAN}${sha256}${C_RESET}"
}

# --- Main Entry Point ---
main() {
    echo -e "${C_CYAN}"
    echo "  ______              ____        _        "
    echo " |__  /___ _ __ ___  | __ ) _   _| |_ ___  "
    echo "   / // _ \ '__/ _ \ |  _ \| | | | __/ _ \ "
    echo "  / /|  __/ | | (_) || |_) | |_| | ||  __/ "
    echo " /____\___|_|  \___/ |____/ \__, |\__\___| "
    echo "                            |___/          "
    echo "           Realme P3 5G (dongfeng)"
    echo -e "${C_RESET}"

    check_deps
    setup_toolchain
    setup_sources

    mkdir -p "${OUT_DIR}"

    case "${VARIANT}" in
        original|vanilla)
            compile_variant "original"
            ;;
        ksu|kernelsu)
            compile_variant "ksu"
            ;;
        all)
            compile_variant "original"
            compile_variant "ksu"
            ;;
        *)
            log_error "Unknown variant: ${VARIANT}. Choose from: original, ksu, all."
            exit 1
            ;;
    esac

    echo ""
    log_success "All requested builds finished successfully!"
    log_info "Output directory: ${OUT_DIR}"
}

main
