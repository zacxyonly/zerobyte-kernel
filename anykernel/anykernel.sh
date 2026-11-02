### AnyKernel3 Ramdisk Mod Script
## ZeroByte Kernel for Realme P3 5G (dongfeng / RMX5079)

### AnyKernel setup
# global properties
properties() { '
kernel.string=ZeroByte Kernel for Realme P3 5G (dongfeng)
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=dongfeng
device.name2=RMX5079
device.name3=volcano
device.name4=SM6650
device.name5=
supported.versions=14 - 15
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
# boot shell variables
BLOCK=boot;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

ui_print " ";
ui_print "--> Installing ZeroByte Kernel...";
ui_print "--> Target: Realme P3 5G (dongfeng / RMX5079)";
ui_print "--> Architecture: ARM64 GKI 2.0 (Linux 6.1)";

# boot install
split_boot;

flash_boot;
## end boot install

ui_print " ";
ui_print "--> ZeroByte Kernel flashed successfully!";
ui_print "--> Reboot and enjoy!";
