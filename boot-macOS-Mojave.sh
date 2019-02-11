#!/bin/bash

# qemu-img create -f qcow2 mac_hdd.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)
#
# The "media=cdrom" part is needed to make Clover recognize the bootable ISO
# image.

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

MY_OPTIONS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

VFIO="-vga qxl -device vfio-pci,host=0c:00.0,multifunction=on -device vfio-pci,host=0c:00.1"
USB="-device usb-host,vendorid=0x046d,productid=0xc52b -device usb-host,vendorid=0xfeed,productid=0x6060"

OPTS=""
#OPTS="$OPTS $VFIO"
#OPTS="$OPTS $USB"

qemu-system-x86_64 -enable-kvm -m 6144 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$MY_OPTIONS\
	  -machine pc-q35-2.11 \
	  -smp cpus=8,cores=4,threads=2,sockets=1 \
	  $OPTS \
	  -usb -device usb-kbd -device usb-tablet \
	  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	  -drive if=pflash,format=raw,readonly,file=OVMF_CODE.fd \
	  -drive if=pflash,format=raw,file=OVMF_VARS-1024x768.fd \
	  -smbios type=2 \
	  -device ich9-intel-hda -device hda-duplex \
	  -device ide-drive,bus=ide.1,drive=MacHDD \
	  -drive id=MacHDD,if=none,file=/home/max/mac_hdd.nobak.img,format=qcow2 \
	  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
	  -monitor stdio
