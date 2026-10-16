# Custom Kernel Builder untuk Realme SM6650 (Snapdragon 6 Gen 4 / Realme P3 5G / RMX5070)
*Berbasis Android 14 / Linux 6.1 Generic Kernel Image (GKI 2.0)*

Proyek ini dirancang untuk mengompilasi custom kernel yang **ringan, dingin, dan hemat baterai** secara otomatis menggunakan cloud **GitHub Actions**.

---

## ⚡ Fitur Optimasi "Ringan & Hemat Baterai"

1. **Pembersihan Bloat & Overhead Debugging**:
   - Menonaktifkan modul debug berat bawaan: `SLUB_DEBUG`, `DEBUG_INFO_BTF`, `DYNAMIC_DEBUG_CORE`, `PM_DEBUG`, dan tracing overhead.
   - Hasil: Pengurangan beban siklus CPU di latar belakang, penggunaan RAM kernel lebih sedikit, dan suhu perangkat saat standby jauh lebih dingin.
2. **Deep Sleep & Tickless Idle**:
   - `CONFIG_NO_HZ_IDLE=y` aktif agar CPU dapat masuk ke level tidur terdalam (*C-states / low power modes*) tanpa interupsi berkala saat layar mati.
3. **Memory & ZRAM (Kompresi ZSTD / LZ4)**:
   - Kompresi ZRAM diubah ke **ZSTD**, menghemat RAM dengan beban CPU yang sangat minim dibanding LZO standar.
4. **Link-Time Optimization (ThinLTO)**:
   - Kode kernel dioptimalkan secara global oleh compiler Clang untuk membuang fungsi-fungsi tak terpakai (*dead-code elimination*) dan mempercepat jalur eksekusi instruksi CPU.
5. **Jaringan Cepat TCP BBR**:
   - Menghasilkan latency jaringan yang lebih stabil dan hemat daya saat streaming atau unduh data.
6. **KernelSU-Next Terintegrasi**:
   - Root aman tanpa membebani init/ramdisk seperti modul root jadul.

---

## 🚀 Cara Menjalankan Kompilasi di GitHub Actions

1. **Buat Repository Baru di Akun GitHub Anda**:
   - Beri nama bebas (contoh: `realme-sm6650-kernel`).
   - Buat sebagai repository **Public** (agar kuota GitHub Actions gratis tanpa batas).

2. **Upload Folder Ini ke Repository GitHub**:
   Jalankan perintah berikut di terminal:
   ```bash
   git init
   git add .
   git commit -m "feat: setup battery-friendly kernel builder"
   git branch -M main
   git remote add origin https://github.com/USERNAME-ANDA/NAMA-REPO-ANDA.git
   git push -u origin main
   ```

3. **Jalankan Build**:
   - Buka tab **Actions** di repositori GitHub Anda.
   - Pilih workflow **"Build Realme SM6650 Battery-Friendly Custom Kernel"** di panel sebelah kiri.
   - Klik tombol **"Run workflow"**.
   - (Opsional) Sesuaikan nama kernel atau centang KernelSU.
   - Klik tombol hijau **Run workflow**.

4. **Unduh Hasil Zip**:
   - Tunggu proses kompilasi selesai (sekitar 15–25 menit).
   - Setelah selesai (tanda centang hijau), klik build tersebut.
   - Scroll ke bagian bawah (**Artifacts**) dan unduh file `.zip` kernel flashable!

---

## 📲 Cara Flashing ke Perangkat

1. **Backup**: Selalu backup partisi `boot` bawaan Anda via TWRP/OrangeFox atau simpan file `boot.img` stock firmware.
2. **Flashing**:
   - Masuk ke Custom Recovery (TWRP / OrangeFox).
   - Pilih file `.zip` hasil download AnyKernel3 tadi, lalu geser untuk Flash (*Swipe to Confirm Flash*).
   - Alternatif: Flash langsung via aplikasi **KernelSU Manager** jika perangkat sudah dalam keadaan root.
3. **Reboot System**.
