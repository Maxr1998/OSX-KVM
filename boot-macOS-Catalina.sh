#!/bin/bash

# qemu-img create -f qcow2 mac_hdd_ng.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

# This works for Catalina as well as Mojave. Tested with macOS 10.14.6 and macOS 10.15.

MY_OPTIONS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# OVMF=./firmware
OVMF="./"

qemu-system-x86_64 -enable-kvm -m 16384 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$MY_OPTIONS\
	  -machine q35 \
	  -smp 16,cores=8 \
	  -usb -device usb-kbd -device usb-mouse \
	  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	  -drive if=pflash,format=raw,readonly,file=$OVMF/OVMF_CODE.fd \
	  -drive if=pflash,format=raw,file=$OVMF/OVMF_VARS-1024x768.fd \
	  -smbios type=2 \
	  -device ich9-intel-hda -device hda-duplex \
	  -device ich9-ahci,id=sata \
	  -drive id=MacHDD,if=none,file=/home/max/mac_hdd.nobak.img,format=qcow2 \
	  -device ide-hd,bus=sata.4,drive=MacHDD \
	  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
	  -monitor stdio \
	  -vga vmware
