# ZeroByte Kernel ⚡
> **High-Efficiency & Battery-Oriented Custom GKI Kernel for Realme P3 5G (RMX5079 / dongfeng)**

[![Target Device](https://img.shields.io/badge/Device-Realme%20P3%205G%20(dongfeng)-007acc.svg?style=flat-square)](https://github.com/zacxyonly/zerobyte-kernel)
[![Linux Kernel](https://img.shields.io/badge/Kernel-Linux%206.1%20GKI%202.0-blue.svg?style=flat-square&logo=linux)](https://kernel.org/)
[![SoC](https://img.shields.io/badge/SoC-Snapdragon%206%20Gen%204%20(SM6650)-red.svg?style=flat-square&logo=qualcomm)](https://www.qualcomm.com/)
[![Toolchain](https://img.shields.io/badge/Compiler-AOSP%20Clang%20r487747c%20+%20ThinLTO-informational.svg?style=flat-square)](https://android.googlesource.com/)
[![Android Version](https://img.shields.io/badge/Android-14%20%7C%2015-3DDC84.svg?style=flat-square&logo=android)](https://source.android.com/)
[![License](https://img.shields.io/badge/License-GPL--2.0-yellow.svg?style=flat-square)](LICENSE)

---

## 📖 Overview

**ZeroByte Kernel** adalah custom kernel Android Generic Kernel Image (GKI 2.0) yang dioptimalkan khusus untuk **Realme P3 5G (`RMX5079`, codename: `dongfeng`)**. Berfokus pada efisiensi daya maksimal, suhu operasional yang dingin, pemangkasan beban debug latar belakang (*overhead stripping*), serta kepatuhan penuh terhadap ABI KMI resmi Google demi integritas perangkat keras (Wi-Fi, Bluetooth, dan Audio).

Setiap build secara otomatis menghasilkan **2 varian siap pakai**: **Original (Vanilla / Non-Root)** dan **KernelSU-Next**.

---

## 📱 Spesifikasi Perangkat Target

| Parameter | Keterangan |
| :--- | :--- |
| **Perangkat** | Realme P3 5G |
| **Model / Codename** | `RMX5079` / `dongfeng` |
| **Chipset** | Qualcomm Snapdragon 6 Gen 4 (`SM6650`, 4nm) |
| **Arsitektur CPU** | 64-bit ARMv9-A (Octa-core) |
| **Basis Kernel** | Linux Common Kernel 6.1.y (GKI 2.0) |
| **Kompatibilitas OS** | Realme UI 5.0 / 6.0 (Android 14 / 15) & AOSP Custom ROM / GSI |
| **Metode Distribusi** | AnyKernel3 Flashable ZIP |

---

## ⚡ Fitur & Optimasi Utama

* **🔋 Manajemen Daya & Deep Sleep Optimal**:
  * Mengaktifkan tickless idle system (`CONFIG_NO_HZ_IDLE=y`) untuk konsumsi daya minimal saat mode siaga (*sleep*).
  * Optimasi penjadwalan CPU via governor `schedutil` yang responsif tanpa boros daya.
* **🚀 Arsitektur Memori LZ4 (Zero-Overhead)**:
  * Mengonfigurasi algoritma **LZ4** sebagai kompresor default ZRAM (`CONFIG_ZRAM_DEF_COMP="lz4"`). Menawarkan kecepatan dekompresi instan (~3500+ MB/s) dengan beban CPU mendekati nol, menjaga SoC tetap dingin saat multitasking.
* **🛡️ KMI & OEM Hardware Protection**:
  * Menjaga tata letak struct ABI kernel tetap 100% identik dengan standar GKI resmi. Modul driver DLKM bawaan pabrik seperti **Wi-Fi** (`qca_cld3_wlan.ko`) dan **Audio** (`snd-soc-*.ko`) dijamin bebas dari kendala *symbol CRC version mismatch*.
* **🧹 Stripped Debugging Overhead**:
  * Mematikan pustaka debug dan tracing berat yang memboroskan RAM dan CPU (`SLUB_DEBUG`, `DEBUG_INFO_BTF`, `DYNAMIC_DEBUG_CORE`, `PM_DEBUG`, `KUNIT_DEBUGFS`).
* **🌐 Latensi Jaringan Rendah**:
  * Mengaktifkan algoritma TCP BBR (`CONFIG_TCP_CONG_BBR=y`) secara bawaan untuk koneksi internet seluler dan Wi-Fi yang lebih stabil dan hemat energi.
* **⚙️ Kompilasi Modern**:
  * Dibangun menggunakan toolchain referensi Google **AOSP Clang `r487747c`** dengan **ThinLTO** (*Link-Time Optimization*) untuk eksekusi biner yang ringkas dan cepat.

---

## 📦 Pilihan Varian Rilis

| Varian | Target Pengguna | Fitur Utama |
| :--- | :--- | :--- |
| **Original (Vanilla)** | Pengguna harian / Perbankan | Kernel bersih murni tanpa modul root. 100% aman untuk Play Integrity dan perbankan (BCA, Livin Mandiri, BRImo, DANA). Kompatibel jika ingin memakai Magisk / APatch terpisah. |
| **KernelSU-Next** | Pengguna Power User / Modifikasi | Terintegrasi langsung dengan driver **KernelSU-Next** di tingkat kernel. Tidak merusak partisi init/ramdisk, cukup instal app KernelSU Manager setelah flashing. |

---

## 📥 Panduan Instalasi (Flashing)

### Persyaratan:
1. Bootloader perangkat sudah terbuka (**Unlocked Bootloader**).
2. Terpasang Custom Recovery (**TWRP** / **OrangeFox**) atau aplikasi manajemen root (**KernelSU Manager**).
3. Buat cadangan (*backup*) partisi `boot` bawaan terlebih dahulu sebagai langkah antisipasi.

### Langkah Flashing via Recovery:
1. Unduh varian file zip kernel pilihan Anda dari tab [Releases](https://github.com/zacxyonly/zerobyte-kernel/releases).
2. Salin file `.zip` ke penyimpanan internal ponsel.
3. Masuk ke Custom Recovery (TWRP / OrangeFox).
4. Pilih menu **Install**, cari dan pilih file `.zip` kernel.
5. Konfirmasi flash (*Swipe to confirm flash*).
6. Selesai! Pilih **Reboot System** (*Wipe cache/dalvik bersifat opsional*).

---

## 🛠️ Build Otomatis via GitHub Actions

Repositori ini telah dilengkapi pipeline CI/CD GitHub Actions:
1. Buka tab **[Actions](https://github.com/zacxyonly/zerobyte-kernel/actions)** pada repositori.
2. Pilih workflow **"Build ZeroByte Kernel for Realme P3 5G (RMX5079 / dongfeng)"**.
3. Klik tombol **Run workflow** (atur nama kernel & ThinLTO sesuai keinginan).
4. Tunggu runner menyelesaikan kompilasi; kedua varian kernel akan otomatis terunggah ke tab **Releases** lengkap dengan hash SHA256.

---

## ⚠️ Disclaimer

```text
Modifikasi kernel dilakukan atas kesadaran dan risiko pribadi.
Pengembang tidak bertanggung jawab atas potensi bootloop, kehilangan data, atau kerusakan perangkat.
Selalu pastikan Anda memiliki cadangan (backup) partisi boot sebelum melakukan instalasi.
```

---

## 🤝 Ucapan Terima Kasih & Kredit

* [Google Android Open Source Project (AOSP)](https://source.android.com/)
* [Linux Kernel Organization](https://kernel.org/)
* [Realme Kernel Open Source Team](https://github.com/realme-kernel-opensource)
* [osm0sis](https://github.com/osm0sis) untuk AnyKernel3
* [KernelSU-Next Team](https://github.com/KernelSU-Next)

---

<p align="center">
  <b>ZeroByte Kernel</b> • High Efficiency & Battery Longevity for Realme P3 5G (RMX5079)
</p>
