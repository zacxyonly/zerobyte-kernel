# ZeroByte Kernel for Realme P3 5G (dongfeng)

[![Device](https://img.shields.io/badge/Device-Realme_P3_5G_(dongfeng)-2563EB?style=for-the-badge&logo=android&logoColor=white)](https://github.com/zacxyonly/zerobyte-kernel)
[![SoC](https://img.shields.io/badge/SoC-Snapdragon_6_Gen_4-EA580C?style=for-the-badge&logo=qualcomm&logoColor=white)](https://www.qualcomm.com/)
[![Kernel](https://img.shields.io/badge/Kernel-Linux_6.1_GKI_2.0-16A34A?style=for-the-badge&logo=linux&logoColor=white)](https://kernel.org/)
[![Toolchain](https://img.shields.io/badge/Toolchain-AOSP_Clang_r487747c-6366F1?style=for-the-badge&logo=google&logoColor=white)](https://android.googlesource.com/)
[![License](https://img.shields.io/badge/License-GPL_2.0-DC2626?style=for-the-badge)](LICENSE)

High-efficiency, lightweight, and battery-oriented custom GKI 2.0 kernel specifically built for **Realme P3 5G** (`RMX5079`, codename: `dongfeng` / SM6650).

---

## 📱 Device Specifications

| Attribute | Specification |
|:---|:---|
| **Device** | Realme P3 5G |
| **Model** | `RMX5079` |
| **Codename** | `dongfeng` / `volcano` |
| **SoC** | Qualcomm Snapdragon 6 Gen 4 (SM6650, 4nm) |
| **Kernel Version** | Linux 6.1.y GKI 2.0 (`android14-6.1`) |
| **Toolchain** | Google AOSP Clang `r487747c` + ThinLTO |
| **Target OS** | Realme UI 5.0 / 6.0 (Android 14 / 15) & AOSP Custom ROMs |
| **Format** | AnyKernel3 Flashable ZIP |

---

## ⚡ Key Highlights

- **Power Efficiency**: Tickless idle (`CONFIG_NO_HZ_IDLE=y`) and tuned `schedutil` governor for optimal battery standby and deep sleep.
- **Zero-Overhead Memory**: Default **LZ4** ZRAM compression for rapid memory swapping with near-zero CPU overhead.
- **KMI Safe (Hardware Protection)**: 100% GKI 2.0 ABI compliance. Wi-Fi (`qca_cld3_wlan.ko`) and Audio (`snd-soc-*.ko`) OEM vendor modules load without CRC symbol mismatch.
- **Debloated Tracing**: Stripped heavy debugging routines (`SLUB_DEBUG`, `DEBUG_INFO_BTF`, `DYNAMIC_DEBUG_CORE`, `PM_DEBUG`) to minimize RAM footprint.
- **Network Performance**: TCP BBR congestion control enabled by default for lower packet latency and stable throughput.
- **ThinLTO**: Link-Time Optimization enabled for optimized binary size and cache utilization.

---

## 📦 Kernel Variants

Every build automatically generates two flashable variants available under [**Releases**](https://github.com/zacxyonly/zerobyte-kernel/releases):

| Variant | Purpose | Root Compatibility |
|:---|:---|:---|
| **`Original`** | Clean GKI kernel for everyday stability | Play Integrity & Banking ready (Supports Magisk / APatch separately) |
| **`KernelSU`** | Integrated kernel-level root solution | Native KernelSU-Next driver built-in (Install KernelSU Manager app) |

---

## 🚀 Installation Guide

> [!IMPORTANT]
> Always backup your stock `boot` partition in recovery before flashing any custom kernel!

### Flashing via Custom Recovery (TWRP / OrangeFox)
1. Download your preferred kernel variant (`Original` or `KernelSU`) from [Releases](https://github.com/zacxyonly/zerobyte-kernel/releases).
2. Boot into recovery (**TWRP** / **OrangeFox**).
3. Select **Install** and choose the downloaded `.zip` file.
4. Swipe to confirm flash.
5. Reboot System (*Wipe cache/dalvik is optional*).

*Alternatively, you can flash the `.zip` directly using KernelSU Manager or Franco Kernel Manager.*

---

## 🛠️ Automated CI/CD Build

Builds are powered by GitHub Actions:
1. Navigate to [**Actions**](https://github.com/zacxyonly/zerobyte-kernel/actions).
2. Select **Build ZeroByte Kernel for Realme P3 5G (RMX5079 / dongfeng)**.
3. Click **Run workflow** (ThinLTO enabled by default).
4. Flashable ZIP packages and SHA256 checksums will be published to [Releases](https://github.com/zacxyonly/zerobyte-kernel/releases).

---

## 🤝 Credits

- **[Google Android Open Source Project (AOSP)](https://source.android.com/)**
- **[Linux Kernel Organization](https://kernel.org/)**
- **[Realme Kernel Open Source Team](https://github.com/realme-kernel-opensource)**
- **[osm0sis](https://github.com/osm0sis)** for AnyKernel3
- **[KernelSU-Next](https://github.com/KernelSU-Next)**

---

<div align="center">
Maintained with ❤️ by <a href="https://github.com/zacxyonly"><b>@zacxyonly</b></a>
</div>
