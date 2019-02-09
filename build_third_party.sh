#!/bin/bash

VERSION_VHCI_HCD=1.15
VERSION_LIBUSB_VHCI=0.7
cd third_party
#git clone https://git.code.sf.net/p/usb-vhci/vhci_hcd
wget https://sourceforge.net/projects/usb-vhci/files/linux%20kernel%20module/vhci-hcd-$VERSION_VHCI_HCD.tar.gz
if $?!=0 then echo "Can\`t get vhci-hcd kernel module. Check Internet connection"
tar -xzf vhci-hcd-$VERSION_VHCI_HCD.tar.gz
cd vhci-hcd-$VERSION_VHCI_HCD
sed -i "/#define DEBUG/d" usb-vhci-hcd.c
sed -i "/#define DEBUG/d" usb-vhci-iocifc.c
make
if $?!=0 then echo "ERR:Can\`t compile vhci-hcd module"
make install
if $?!=0 then echo "You are sudo?"
cd ..
wget https://sourceforge.net/projects/usb-vhci/files/native%20libraries/libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz
if $?!=0 then echo "Check Internet connection"
tar -xzf libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz
#git clone https://git.code.sf.net/p/usb-vhci/libusb_vhci
cd libusb_vhci-$VERSION_LIBUSB_VHCI
./configure
make
if $?!=0 then echo "ERR:Can\`t compile libusb-vhci"
make install
if $?!=0 then echo "You are sudo?"
echo "Done. Add line to /etc/modules and PATH=/usr/local/lib"
