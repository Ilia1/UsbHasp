#!/bin/bash

VERSION_VHCI_HCD=1.15
VERSION_LIBUSB_VHCI=0.7
a=0
if [ -e third_party ] 
	then cd third_party
	else mkdir third_party
		cd third_party
	fi
if [ -e vhci-hcd-$VERSION_VHCI_HCD ]
        then cd vhci-hcd-$VERSION_VHCI_HCD
	else if [ -e vhci-hcd-$VERSION_VHCI_HCD.tar.gz ]
	        then tar -xzf vhci-hcd-$VERSION_VHCI_HCD.tar.gz
			cd vhci-hcd-$VERSION_VHCI_HCD
		else wget https://sourceforge.net/projects/usb-vhci/files/linux%20kernel%20module/vhci-hcd-$VERSION_VHCI_HCD.tar.gz
tar -xzf vhci-hcd-$VERSION_VHCI_HCD.tar.gz
cd vhci-hcd-$VERSION_VHCI_HCD
fi fi 
sed -i "/#define DEBUG/d" usb-vhci-hcd.c
sed -i "/#define DEBUG/d" usb-vhci-iocifc.c
make
make install
if [ "$?" -ne "$a" ] 
then 
	echo -e "\033[31mYou are sudo?" 
else echo "OK"
fi
cd ..
if [ -e libusb_vhci-$VERSION_LIBUSB_VHCI ]
        then cd libusb_vhci-$VERSION_LIBUSB_VHCI
	else if [ -e libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz ]
	        then tar -xzf libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz
			cd libusb_vhci-$VERSION_LIBUSB_VHCI
		else wget https://sourceforge.net/projects/usb-vhci/files/native%20libraries/libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz
tar -xzf libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz
cd libusb_vhci-$VERSION_LIBUSB_VHCI
fi fi 
./configure
make
make install
if [ "$?" -ne "$a" ] 
then 
	echo -e "\033[31mYou are sudo?" 
else echo "OK"
fi
echo "Done. Add line to /etc/modules and PATH=/usr/local/lib"
