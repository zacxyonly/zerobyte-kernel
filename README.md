# ZeroByte Kernel ⚡
> **High-Efficiency, Lightweight & Battery-Oriented Custom Kernel**  
> *Targeted for Qualcomm Snapdragon 6 Gen 4 (SM6650) — Realme P3 5G / RMX5070*

[![Linux Kernel](https://img.shields.io/badge/Linux_Kernel-6.1_GKI-blue.svg?style=for-the-badge&logo=linux)](https://kernel.org/)
[![Android Version](https://img.shields.io/badge/Android-14%20%7C%2015-3DDC84.svg?style=for-the-badge&logo=android)](https://source.android.com/)
[![Target SoC](https://img.shields.io/badge/SoC-Snapdragon%206%20Gen%204%20(SM6650)-red.svg?style=for-the-badge&logo=qualcomm)](https://www.qualcomm.com/)
[![Compiler](https://img.shields.io/badge/Toolchain-AOSP%20Clang%20r487747c-informational.svg?style=for-the-badge)](https://android.googlesource.com/)
[![Base Release](https://img.shields.io/badge/Release-v1.0.0%20(Base)-brightgreen.svg?style=for-the-badge)](https://github.com/zacxyonly/zerobyte-kernel/releases)
[![License](https://img.shields.io/badge/License-GPL--2.0-yellow.svg?style=for-the-badge)](LICENSE)

---

## 📖 Overview

**ZeroByte Kernel** adalah custom kernel Android Generic Kernel Image (GKI 2.0) yang dirancang khusus dengan filosofi **efisiensi energi maksimal**, **suhu operasi lebih dingin**, dan **pengurangan overhead background**.

Kernel bawaan OEM umumnya memuat beragam driver debugging internal, tracing kernel, dan mekanisme benchmark boosting artifisial yang memboroskan siklus CPU serta kapasitas RAM. ZeroByte Kernel membersihkan komponen-komponen tersebut secara presisi untuk menghasilkan performa harian yang *smooth*, responsif, dan hemat daya baterai.

Versi **v1.0.0 (Base Initial Release)** ini menjadi pondasi dasar yang bersih, stabil, dan siap pakai untuk perangkat berbasis **Qualcomm SM6650 (Snapdragon 6 Gen 4)**.

---

## ✨ Fitur & Optimasi (v1.0.0 Base)

### 🔋 1. Power Management & Deep Sleep
* **Tickless Idle System (`CONFIG_NO_HZ_IDLE=y`)**: Mengizinkan inti CPU masuk ke status daya terendah (*C-states / low power modes*) saat layar mati tanpa terganggu interupsi berkala yang tidak penting.
* **Energy-Aware Scheduling (EAS) Focus**: Mengarahkan beban kerja background dan task ringan secara optimal ke kluster *Silver / Efficiency Cores (Cortex-A520)* sebelum melibatkan core performa tinggi.
* **Eliminasi Benchmark Booster Palsu**: Mematikan modul pendongkrak clock artifisial OEM yang sering memicu panas berlebih saat membuka aplikasi tertentu.

### 🧹 2. Overhead Stripping (Kernel Bloatware Removal)
* **Nonaktifkan Modul Debug Berat**: Menghapus beban `SLUB_DEBUG`, `DEBUG_INFO_DWARF4`, `DEBUG_INFO_BTF`, `PM_DEBUG`, `DYNAMIC_DEBUG_CORE`, `SCHEDSTATS`, dan `KUNIT_DEBUGFS`.
* **Penghematan RAM & CPU Cycles**: Mengurangi jejak memori *(memory footprint)* kernel hingga ratusan megabyte dan membebaskan instruksi CPU untuk aplikasi pengguna.

### 🚀 3. Memory & ZRAM Architecture (Default: LZ4 Zero-Overhead)
* **LZ4 Default Compression**: Menggunakan algoritma **LZ4** secara default (`CONFIG_ZRAM_DEF_COMP="lz4"`). Berbeda dengan ZSTD yang menuntut komputasi CPU lebih berat, LZ4 memiliki kecepatan dekompresi super instan (~3500+ MB/s) dengan beban komputasi mendekati nol (*near-zero CPU overhead*). Hal ini membuat suhu SoC tetap dingin saat multitasking padat serta menekan penggunaan daya baterai ke titik paling minimal. Modul ZSTD tetap tersedia di dalam kernel jika pengguna ingin mengaktifkannya via userspace.
* **Optimal Swap Latency**: Menghilangkan *micro-stutter* saat sistem Android melakukan kompresi dan dekompresi halaman memori di latar belakang.

### 🛡️ 4. Compiler Optimization & Binary Purity
* **Clang ThinLTO (`CONFIG_LTO_CLANG_THIN=y`)**: Mengaktifkan *Link-Time Optimization* untuk mengeliminasi dead-code lintas unit kompilasi, menghasilkan ukuran binary kernel yang lebih padat dan *cache-friendly*.
* **AOSP Clang Reference Toolchain**: Dibangun menggunakan Google AOSP Clang `r487747c` sesuai standar KMI resmi Android 14–6.1.

### 🌐 5. Networking & I/O
* **TCP BBR Congestion Control**: Diaktifkan secara default (`CONFIG_TCP_CONG_BBR=y`) untuk throughput jaringan yang lebih konsisten, latensi rendah, dan konsumsi daya modem yang lebih efisien saat transmisi data.

### ⚡ 6. Next-Gen Root Integration
* **Dukungan KernelSU-Next Bawaan**: Kompatibel dengan KernelSU-Next untuk kontrol root tingkat kernel tanpa memodifikasi partisi init/ramdisk secara invasif.

---

## 🧩 Catatan Teknis Kompatibilitas GKI 2.0 / KMI (Wi-Fi & Audio Protection)

Banyak custom kernel GKI mengalami masalah fatal seperti **Wi-Fi tidak bisa menyala**, **Bluetooth mati**, atau **Audio bisu** setelah instalasi. ZeroByte Kernel dirancang secara teliti untuk mencegah masalah ini melalui kepatuhan ketat pada arsitektur Android GKI 2.0:

### 1. Pemisahan Kernel & Vendor DLKM
* Pada Android 14 (GKI 2.0), driver perangkat keras vital seperti **Wi-Fi** (`qca_cld3_wlan.ko`), **Audio** (`snd-soc-*.ko`), **Touchscreen**, dan **Kamera** bukan merupakan bagian dari biner kernel `Image`, melainkan modul loadable (`.ko`) yang tersimpan di partisi `/vendor_dlkm` dan `/system_dlkm`.
* Skrip instalasi AnyKernel3 pada ZeroByte Kernel **hanya mengganti partisi `boot` (GKI `Image`)** dan **TIDAK mengubah modul vendor bawaan**, menjamin keutuhan driver pabrikan.

### 2. Kepatuhan KMI ABI (Kernel Module Interface)
* Modul vendor OEM memverifikasi hash CRC dari simbol-simbol kernel saat proses `modprobe`.
* **Mengapa Wi-Fi & Audio Tetap Berfungsi di ZeroByte Kernel?**
  * Konfigurasi internal yang menentukan ukuran struktur biner inti (seperti `struct task_struct` dan `struct sched_entity`) tetap **dipertahankan layout-nya 100% identik dengan GKI resmi**.
  * ZeroByte Kernel **TIDAK mematikan opsi yang merusak ukuran struct** (seperti `CONFIG_SCHEDSTATS` di tingkat kode), melainkan menyarankan penonaktifan beban pencatatannya di tingkat runtime userspace:
    ```bash
    # Matikan overhead pencatatan scheduler tanpa merusak ABI KMI (Zero Overhead):
    sysctl -w kernel.sched_schedstats=0
    ```
  * Pendekatan ini memastikan modul Wi-Fi dan Audio tidak mengalami penolakan *symbol version mismatch* saat dimuat oleh sistem.

### 3. Tips Troubleshooting bagi Penguji (Testers)
* **Wajib Firmware Basis yang Cocok**: Pastikan ROM yang Anda gunakan berbasis firmware resmi Realme UI 5.0 / 6.0 (Android 14) atau Custom ROM AOSP yang mematuhi standar GKI 6.1.
* **Jangan Wipe Vendor**: Saat instalasi via recovery, **JANGAN** lakukan wipe pada partisi `/vendor` atau `/vendor_dlkm`.
* **Diagnostik Log Modul**: Jika Anda menemukan kendala konektivitas, cek log kernel melalui Terminal / ADB:
  ```bash
  su -c "dmesg | grep -i -E 'wlan|audio|disagrees about version'"
  ```
  *(Jika tidak ada pesan "disagrees about version", artinya seluruh modul OEM sukses terhubung dengan kernel).*

---

## 📱 Spesifikasi Perangkat Target

| Parameter | Spesifikasi |
| :--- | :--- |
| **Model Perangkat** | Realme P3 5G / Realme 14 Series (RMX5070) |
| **Platform Chipset** | Qualcomm Snapdragon 6 Gen 4 (SM6650) |
| **Arsitektur CPU** | ARMv9-A (64-bit) |
| **Kernel Base** | Linux Common Kernel 6.1.y (GKI 2.0) |
| **Target OS** | Android 14 / Android 15 (Realme UI 5.0 / 6.0 & AOSP Custom ROM) |
| **Metode Packaging** | AnyKernel3 Flashable ZIP |

---

## 🛠️ Cara Kompilasi Otomatis (GitHub Actions)

Kernel ini dikonfigurasi penuh untuk proses build otomatis di cloud GitHub Actions tanpa perlu mengunduh toolchain puluhan gigabyte ke komputer lokal:

1. Buka tab **[Actions](https://github.com/zacxyonly/zerobyte-kernel/actions)** pada repositori ini.
2. Di sebelah kiri, pilih workflow:  
   **"Build Realme SM6650 (Snapdragon 6 Gen 4) Battery-Friendly Custom Kernel"**.
3. Klik tombol **Run workflow**:
   * Masukkan nama kernel (default: `ZeroByte-Kernel`).
   * Centang opsi **KernelSU-Next** (jika ingin root).
   * Centang opsi **Clang ThinLTO** (untuk optimasi efisiensi biner).
4. Klik tombol hijau **Run workflow**.
5. Tunggu proses kompilasi selesai (~15–20 menit).
6. Unduh file flashable `.zip` pada bagian **Artifacts** di halaman hasil build.

---

## 📥 Panduan Pemasangan (Flashing Guide)

### Persyaratan:
* Bootloader perangkat sudah dalam status **Unlocked**.
* Sudah terpasang Custom Recovery (**TWRP** / **OrangeFox**) ATAU perangkat sudah memiliki akses root (**KernelSU Manager**).
* **Cadangkan (Backup)** partisi `boot` bawaan sebelum melakukan instalasi.

### Langkah Flashing via Recovery:
1. Pindahkan file `ZeroByte-Kernel-*.zip` ke penyimpanan internal perangkat.
2. Matikan ponsel dan masuk ke mode Recovery (Tahan tombol **Power + Volume Bawah**).
3. Di menu Recovery, pilih **Install**.
4. Cari dan pilih file `ZeroByte-Kernel-*.zip`.
5. Geser slider **Swipe to Confirm Flash**.
6. Setelah selesai, pilih **Wipe Cache/Dalvik** (opsional), lalu pilih **Reboot System**.

---

## 🗺️ Roadmap Pengembangan Mendatang

- [x] **v1.0.0**: *Base release* — Pembersihan debug bloatware, aktivasi ThinLTO, ZRAM ZSTD, TCP BBR, dan integrasi KernelSU-Next.
- [ ] **v1.1.0**: Tweak parameter governor `schedutil` (penyesuaian up/down rate limit untuk daya tahan baterai ekstra).
- [ ] **v1.2.0**: Implementasi Boeffla Wakelock Blocker driver untuk menahan wakelock agresif Wi-Fi & Seluler saat layar mati.
- [ ] **v1.3.0**: Optimasi profil thermal untuk mengurangi throttling saat penggunaan beban sedang-berat.

---

## ⚠️ Disclaimer

```text
Segala bentuk modifikasi kernel dilakukan atas risiko Anda sendiri.
Pihak pengembang ZeroByte Kernel tidak bertanggung jawab atas kerusakan perangkat keras,
bootloop, kehilangan data, atau masalah lainnya.
Selalu lakukan backup partisi boot bawaan sebelum melakukan flashing.
```

---

## 🤝 Ucapan Terima Kasih & Kredit

* [Linux Kernel Organization](https://kernel.org/)
* [Google Android Open Source Project (AOSP)](https://source.android.com/)
* [Realme Kernel Open Source Team](https://github.com/realme-kernel-opensource)
* [osm0sis](https://github.com/osm0sis) untuk template installer AnyKernel3
* [KernelSU-Next Team](https://github.com/KernelSU-Next) untuk solusi root modern

---

<p align="center">
  <b>ZeroByte Kernel</b> • Developed with care for maximum battery longevity.
</p>
