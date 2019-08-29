#!/bin/bash

VERSION_VHCI_HCD=1.15
VERSION_LIBUSB_VHCI=0.7
ID=$(cat /etc/os-release | grep ^ID=  | cut -f2 -d =)
VERSION_ID=$(cat /etc/os-release | grep ^VERSION\_ID=  | cut -f2 -d = | tr -d \")
ID_LIKE=$(cat /etc/os-release | grep ID_LIKE | cut -f2 -d = |cut -f1 -d " " | tr -d \")
VER_HASPD=7.90
if [ $ID_LIKE = debian ]
then apt-get install linux-source wget make linux-headers-generic gcc libjansson4 libjansson-dev libelf-dev
	apt-mark hold linux-source linux-headers-generic linux-image-generic
elif [ $ID_LIKE = rhel ]
then yum install -y make gcc-c++ wget jansson jansson-devel kernel-headers kernel-devel epel-release centos-release-scl
	echo "exclude=kernel kernel-devel kernel-headers" >> /etc/yum.conf
	yum install devtoolset-7-gcc*
else echo "Unknown Linux distr. Install manual wget, make, gcc, jansson-dev, git, kernel headers and source and compile manual"
	echo "Continue?"
	read -n 1
fi

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
		else wget "https://sourceforge.net/projects/usb-vhci/files/linux kernel module/vhci-hcd-$VERSION_VHCI_HCD.tar.gz"
tar -xzf vhci-hcd-$VERSION_VHCI_HCD.tar.gz
cd vhci-hcd-$VERSION_VHCI_HCD
fi fi 
sed -i "/#define DEBUG/d" usb-vhci-hcd.c
sed -i "s/#define DEBUG/#include <linux\/uaccess.h>/" usb-vhci-iocifc.c
make
make install
if [ "$?" -ne 0 ] 
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
		else wget "https://sourceforge.net/projects/usb-vhci/files/native libraries/libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz"
tar -xzf libusb_vhci-$VERSION_LIBUSB_VHCI.tar.gz
cd libusb_vhci-$VERSION_LIBUSB_VHCI
fi fi 
./configure
make
make install
if [ "$?" -ne 0 ] 
then 
	echo -e "\033[31mYou are sudo?" 
else echo "OK"
fi
touch /etc/modules-load.d/usb-vhci.conf
echo usb-vhci-hcd > /etc/modules-load.d/usb-vhci.conf
echo usb-vhci-iocifc >> /etc/modules-load.d/usb-vhci.conf

echo "Installing haspd from Etersoft"
if [ $ID = debian ]
then wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/Debian/$VERSION_ID/haspd-modules_$VER_HASPD-eter2debian_amd64.deb
	wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/Debian/$VERSION_ID/haspd_$VER_HASPD-eter2debian_amd64.deb
	dpkg -i haspd_$VER_HASPD-eter1debian_amd64.deb
	dpkg -i haspd-modules_$VER_HASPD-eter1debian_amd64.deb
elif [ $ID_LIKE = rhel ]
then wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/RHEL/$VERSION_ID/haspd-$VER_HASPD-eter2centos.x86_64.rpm
	wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/RHEL/$VERSION_ID/haspd-modules-$VER_HASPD-eter2centos.x86_64.rpm
	yum install -y haspd-$VER_HASPD-eter1centos.x86_64.rpm
	yum install -y haspd-modules-$VER_HASPD-eter1centos.x86_64.rpm
elif [ $ID = ubuntu ]
then wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/Ubuntu/$VERSION_ID/haspd-modules_$VER_HASPD-eter2ubuntu_amd64.deb || wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/Ubuntu/18.04/haspd-modules_$VER_HASPD-eter1ubuntu_amd64.deb
	wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/Ubuntu/$VERSION_ID/haspd_$VER_HASPD-eter2ubuntu_amd64.deb || wget http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/Ubuntu/18.04/haspd_$VER_HASPD-eter1ubuntu_amd64.deb
	dpkg -i haspd_$VER_HASPD-eter1ubuntu_amd64.deb
	dpkg -i haspd-modules_$VER_HASPD-eter1ubuntu_amd64.deb
else echo "Unknown distr, visit http://download.etersoft.ru/pub/Etersoft/HASP/last/x86_64/ and manual install"
fi
cd ../..
if [ $ID_LIKE = rhel ]
then scl enable devtoolset-7 "make all"
else make all
fi
echo "export PATH=\$PATH:$PWD/dist/Release/GNU-Linux " >> ~/.bash_profile
echo "export LD_LIBRARY_PATH=/usr/local/lib" >> ~/.bash_profile
echo "Done. Reboot and run usbhasp -d hasp.json"
