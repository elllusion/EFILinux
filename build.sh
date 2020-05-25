#!/bin/bash

set -e

# RootFS variables
ROOTFS="rootfs-corepure64"
CACHEPATH="$ROOTFS/var/cache/"
SHELLHISTORY="$ROOTFS/root/.ash_history"
DEVCONSOLE="$ROOTFS/dev/console"
MODULESPATH="$ROOTFS/lib/modules/"
DEVURANDOM="$ROOTFS/dev/urandom"

# Kernel variables
KERNELVERSION="5.4.3-tinycore64"
KERNELPATH="linux-5.4.3"
export INSTALL_MOD_PATH="../$ROOTFS/"

# Build threads equall CPU cores
THREADS=$(getconf _NPROCESSORS_ONLN)

echo "      ____________  "
echo "    /|------------| "
echo "   /_|  .---.     | "
echo "  |    /     \    | "
echo "  |    \.6-6./    | "
echo "  |    /\`\_/\`\    | "
echo "  |   //  _  \\\   | "
echo "  |  | \     / |  | "
echo "  | /\`\_\`>  <_/\`\ | "
echo "  | \__/'---'\__/ | "
echo "  |_______________| "
echo "                    "
echo "   EFILinux.efi "

##########################
# Checking root filesystem
##########################

echo "----------------------------------------------------"
echo -e "Checking root filesystem\n"

# Clearing cache 
if [ "$(ls -A $CACHEPATH)" ]; then 
    echo -e "Apk cache folder is not empty: $CACHEPATH \nRemoving cache...\n"
    rm $CACHEPATH*
fi

# Remove shell history
if [ -f $SHELLHISTORY ]; then
    echo -e "Shell history found: $SHELLHISTORY \nRemoving history file...\n"
    rm $SHELLHISTORY
fi

# Clearing kernel modules folder 
if [ "$(ls -A $MODULESPATH)" ]; then 
    echo -e "Kernel modules folder is not empty: $MODULESPATH \nRemoving modules...\n"
    rm -r $MODULESPATH*
fi

# Removing dev bindings
if [ -e $DEVURANDOM ]; then
    echo -e "/dev/ bindings found: $DEVURANDOM. Unmounting...\n"
    umount $DEVURANDOM || echo -e "Not mounted. \n"
    rm $DEVURANDOM
fi


# Check if console character file exist
if [ ! -e $DEVCONSOLE ]; then
    echo -e "ERROR: Console device does not exist: $DEVCONSOLE \nPlease create device file:  mknod -m 600 $DEVCONSOLE c 5 1"
    exit 1
else
    if [ -d $DEVCONSOLE ]; then # Check that console device is not a folder 
        echo -e  "ERROR: Console device is a folder: $DEVCONSOLE \nPlease create device file:  mknod -m 600 $DEVCONSOLE c 5 1"
        exit 1
    fi

    if [ -f $DEVCONSOLE ]; then # Check that console device is not a regular file
        echo -e "ERROR: Console device is a regular: $DEVCONSOLE \nPlease create device file:  mknod -m 600 $DEVCONSOLE c 5 1"
    fi
fi

# Print version from /etc/issue
echo -n "Version in banner: " 
grep -Eo "v[0-9\.]+" $ROOTFS/etc/issue

# Print rootfs uncompressed size
echo -e "Uncompressed root filesystem size WITHOUT kernel modules: $(du -sh $ROOTFS | cut -f1)\n"


##########################
# Bulding kernel modules
##########################

echo "----------------------------------------------------"
echo -e "Building kernel mobules using $THREADS threads...\n"
cd $KERNELPATH 
make modules -j$THREADS

# Copying kernel modules in root filesystem
echo "----------------------------------------------------"
echo -e "Copying kernel modules in root filesystem\n"
make modules_install

echo -e "Uncompressed root filesystem size WITH kernel modules: $(du -sh ../$ROOTFS | cut -f1)\n"


# Creating modules.dep
echo "----------------------------------------------------"
echo -e "Copying modules.dep\n"
if  [ -f System.map ]; then
depmod -b ../$ROOTFS -F System.map $KERNELVERSION
fi

##########################
# Bulding kernel
##########################

echo "----------------------------------------------------"
echo -e "Building kernel with initrams using $THREADS threads...\n"
make -j$THREADS


##########################
# Get builded file
##########################

cp arch/x86/boot/bzImage ../EFILinux.efi
cd ..

echo "----------------------------------------------------"
echo -e "\nBuilded successfully: $(pwd)/EFILinux.efi\n"
echo -e "File size: $(du -sh EFILinux.efi | cut -f1)\n"

test -e EFILinux.img || (dd if=/dev/zero of=EFILinux.img bs=512 count=93750 2>/dev/null && \
    /sbin/sgdisk -Z EFILinux.img >/dev/null && \
    /sbin/sgdisk -N 1 EFILinux.img >/dev/null && \
    /sbin/sgdisk -t 1:ef00 EFILinux.img >/dev/null && \
    /sbin/sgdisk -c 1:"EFI" EFILinux.img >/dev/null && \
    /sbin/sgdisk -v EFILinux.img >/dev/null && \
    /sbin/sgdisk -p EFILinux.img && \
    mformat -i EFILinux.img@@1M -v EFI -F -h 32 -t 44 -n 64 -c 1 && \
    mmd -i EFILinux.img@@1M EFI && \
    mmd -i EFILinux.img@@1M EFI/Boot \
)
mcopy -o -i EFILinux.img@@1M EFILinux.efi ::EFI/Boot/BOOTX64.efi
mcopy -o -i EFILinux.img@@1M startup.nsh ::startup.nsh
touch EFILinux.img

echo "----------------------------------------------------"
echo -e "\nBuilded successfully: $(pwd)/EFILinux.img\n"
echo -e "File size: $(du -sh EFILinux.img | cut -f1)\n"