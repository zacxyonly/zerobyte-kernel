---
name: 🐛 Bug Report
about: Create a report to help us improve ZeroByte Kernel
title: "[BUG]: "
labels: ["bug"]
assignees: "zacxyonly"
---

## 📱 Device & Environment
- **Device Model**: Realme P3 5G (`RMX5079`)
- **ROM / Firmware Version**: (e.g., Realme UI 5.0 RMX5079_14.0.0.xxx / Custom ROM)
- **Android Version**: (e.g., 14 / 15)
- **ZeroByte Kernel Version / Tag**: (e.g., v1.0.0-20261016)
- **Kernel Variant**: [ ] Original (Vanilla) | [ ] KernelSU-Next | [ ] APatch
- **Recovery Used for Flashing**: [ ] TWRP | [ ] OrangeFox | [ ] KernelSU Manager

## 📝 Bug Description
A clear and concise description of what the bug is.

## 🔄 Steps to Reproduce
1. Boot system with ZeroByte Kernel
2. Open application '...'
3. Trigger action '...'
4. See error

## 🎯 Expected Behavior
A clear and concise description of what you expected to happen.

## 📋 Kernel Logs (Crucial)
Please attach relevant logs (`dmesg`, `last_kmsg`, `pstore`, or `logcat`):
```bash
# To grab dmesg via ADB or Root Shell:
su -c "dmesg" > /sdcard/dmesg.txt
```
Paste or attach the output here.
