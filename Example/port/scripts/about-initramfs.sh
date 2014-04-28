#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=about-initramfs
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{

cd ${SOURCES} 

}
build()
{
cat > /sbin/mkinitramfs << "EOF"
#!/bin/bash
# This file based in part on the mkinitrafms script for the LFS LiveCD
# written by Alexander E. Patrakov and Jeremy Huntwork.

copy()
{
  local file

  if [ "$2" == "lib" ]; then
    file=$(PATH=/lib:/usr/lib type -p $1)
  else
    file=$(type -p $1)
  fi

  if [ -n $file ] ; then
    cp $file $WDIR/$2
  else
    echo "Missing required file: $1 for directory $2"
    rm -rf $WDIR
    exit 1
  fi
}

if [ -z $1 ] ; then
  INITRAMFS_FILE=initrd.img-no-kmods
else
  KERNEL_VERSION=$1
  INITRAMFS_FILE=initrd.img-$KERNEL_VERSION
fi

if [ -n "$KERNEL_VERSION" ] && [ ! -d "/lib/modules/$1" ] ; then
  echo "No modules directory named $1"
  exit 1
fi

printf "Creating $INITRAMFS_FILE... "

binfiles="sh cat cp dd killall ls mkdir -pv mknod mount "
binfiles="$binfiles umount sed sleep ln rm uname"

sbinfiles="udevadm modprobe blkid switch_root"

#Optional files and locations
for f in mdadm udevd; do
  if [ -x /sbin/$f ] ; then sbinfiles="$sbinfiles $f"; fi
done

unsorted=$(mktemp /tmp/unsorted.XXXXXXXXXX)

DATADIR=/usr/share/mkinitramfs
INITIN=init.in

# Create a temporrary working directory
WDIR=$(mktemp -d /tmp/initrd-work.XXXXXXXXXX)

# Create base directory structure
mkdir -pv -p $WDIR/{bin,dev,lib/firmware,run,sbin,sys,proc}
mkdir -pv -p $WDIR/etc/{modprobe.d,udev/rules.d}
touch $WDIR/etc/modprobe.d/modprobe.conf
ln -svf lib $WDIR/lib64

# Create necessary device nodes
mknod -m 640 $WDIR/dev/console c 5 1
mknod -m 664 $WDIR/dev/null    c 1 3

# Install the udev configuration files
if [ -f /etc/udev/udev.conf ]; then
  cp /etc/udev/udev.conf $WDIR/etc/udev/udev.conf
fi

for file in $(find /etc/udev/rules.d/ -type f) ; do
  cp $file $WDIR/etc/udev/rules.d
done

# Install any firmware present
cp -a /lib/firmware $WDIR/lib

# Copy the RAID configureation file if present
if [ -f /etc/mdadm.conf ] ; then
  cp /etc/mdadm.conf $WDIR/etc
fi

# Install the init file
install -m0755 $DATADIR/$INITIN $WDIR/init

if [  -n "$KERNEL_VERSION" ] ; then
  if [ -x /bin/kmod ] ; then
    binfiles="$binfiles kmod"
  else
    binfiles="$binfiles lsmod"
    sbinfiles="$sbinfiles insmod"
  fi
fi

# Install basic binaries
for f in $binfiles ; do
  ldd /bin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
  copy $f bin
done

# Add lvm if present
if [ -x /sbin/lvm ] ; then sbinfiles="$sbinfiles lvm dmsetup"; fi

for f in $sbinfiles ; do
  ldd /sbin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
  copy $f sbin
done

# Add udevd libraries if not in /sbin
if [ -x /lib/udev/udevd ] ; then
  ldd /lib/udev/udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted
fi

# Add module symlinks if appropriate
if [ -n "$KERNEL_VERSION" ] && [ -x /bin/kmod ] ; then
  ln -svf kmod $WDIR/bin/lsmod
  ln -svf kmod $WDIR/bin/insmod
fi

# Add lvm symlinks if appropriate
# Also copy the lvm.conf file
if  [ -x /sbin/lvm ] ; then
  ln -svf lvm $WDIR/sbin/lvchange
  ln -svf lvm $WDIR/sbin/lvrename
  ln -svf lvm $WDIR/sbin/lvextend
  ln -svf lvm $WDIR/sbin/lvcreate
  ln -svf lvm $WDIR/sbin/lvdisplay
  ln -svf lvm $WDIR/sbin/lvscan

  ln -svf lvm $WDIR/sbin/pvchange
  ln -svf lvm $WDIR/sbin/pvck
  ln -svf lvm $WDIR/sbin/pvcreate
  ln -svf lvm $WDIR/sbin/pvdisplay
  ln -svf lvm $WDIR/sbin/pvscan

  ln -svf lvm $WDIR/sbin/vgchange
  ln -svf lvm $WDIR/sbin/vgcreate
  ln -svf lvm $WDIR/sbin/vgscan
  ln -svf lvm $WDIR/sbin/vgrename
  ln -svf lvm $WDIR/sbin/vgck
  # Conf file(s)
  cp -a /etc/lvm $WDIR/etc
fi

# Install libraries
sort $unsorted | uniq | while read library ; do
  if [ "$library" == "linux-vdso.so.1" ] ||
     [ "$library" == "linux-gate.so.1" ]; then
    continue
  fi

  copy $library lib
done

cp -a /lib/udev $WDIR/lib

# Install the kernel modules if requested
if [ -n "$KERNEL_VERSION" ]; then
  find /lib/modules/$KERNEL_VERSION/kernel/{crypto,fs,lib} /lib/modules/$KERNEL_VERSION/kernel/drivers/{block,ata,md,firewire} /lib/modules/$KERNEL_VERSION/kernel/drivers/{scsi,message,pcmcia,virtio} /lib/modules/$KERNEL_VERSION/kernel/drivers/usb/{host,storage} -type f 2> /dev/null | cpio --make-directories -p --quiet $WDIR

  cp /lib/modules/$KERNEL_VERSION/modules.{builtin,order} $WDIR/lib/modules/$KERNEL_VERSION

  depmod -b $WDIR $KERNEL_VERSION
fi

( cd $WDIR ; find . | cpio -o -H newc --quiet | gzip -9 ) > $INITRAMFS_FILE

# Remove the temporary directory and file
rm -rf $WDIR $unsorted
printf "done.\n"

EOF

chmod 0755 /sbin/mkinitramfs

mkdir -pv -p /usr/share/mkinitramfs 
cat > /usr/share/mkinitramfs/init.in << "EOF"
#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH

problem()
{
   printf "Encountered a problem!\n\nDropping you to a shell.\n\n"
   sh
}

no_device()
{
   printf "The device %s, which is supposed to contain the\n" $1
   printf "root file system, does not exist.\n"
   printf "Please fix this problem and exit this shell.\n\n"
}

no_mount()
{
   printf "Could not mount device %s\n" $1
   printf "Sleeping forever. Please reboot and fix the kernel command line.\n\n"
   printf "Maybe the device is formatted with an unsupported file system?\n\n"
   printf "Or maybe filesystem type autodetection went wrong, in which case\n"
   printf "you should add the rootfstype=... parameter to the kernel command line.\n\n"
   printf "Available partitions:\n"
}

do_mount_root()
{
   mkdir -pv /.root
   [ -n "$rootflags" ] && rootflags="$rootflags,"
   rootflags="$rootflags$ro"

   case "$root" in
      /dev/* ) device=$root ;;
      UUID=* ) eval $root; device="/dev/disk/by-uuid/$UUID"  ;;
      LABEL=*) eval $root; device="/dev/disk/by-label/$LABEL" ;;
      ""     ) echo "No root device specified." ; problem    ;;
   esac

   while [ ! -b "$device" ] ; do
       no_device $device
       problem
   done

   if ! mount -n -t "$rootfstype" -o "$rootflags" "$device" /.root ; then
       no_mount $device
       cat /proc/partitions
       while true ; do sleep 10000 ; done
   else
       echo "Successfully mounted device $root"
   fi
}

init=/sbin/init
root=
rootdelay=
rootfstype=auto
ro="ro"
rootflags=
device=

mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
mount -n -t tmpfs    tmpfs    /run

read -r cmdline < /proc/cmdline

for param in $cmdline ; do
  case $param in
    init=*      ) init=${param#init=}             ;;
    root=*      ) root=${param#root=}             ;;
    rootdelay=* ) rootdelay=${param#rootdelay=}   ;;
    rootfstype=*) rootfstype=${param#rootfstype=} ;;
    rootflags=* ) rootflags=${param#rootflags=}   ;;
    ro          ) ro="ro"                         ;;
    rw          ) ro="rw"                         ;;
  esac
done

# udevd location depends on version
if [ -x /sbin/udevd ]; then
  UDEV_PATH=/sbin
else
  UDEV_PATH=/lib/udev
fi

${UDEV_PATH}/udevd --daemon --resolve-names=never
udevadm trigger
udevadm settle

if [ -f /etc/mdadm.conf ] ; then mdadm -As                       ; fi
if [ -x /sbin/vgchange  ] ; then /sbin/vgchange -a y > /dev/null ; fi
if [ -n "$rootdelay"    ] ; then sleep "$rootdelay"              ; fi

do_mount_root

killall -w ${UDEV_PATH}/udevd

exec switch_root /.root "$init" "$@"

EOF

mkinitramfs [KERNEL VERSION]

# Generic initramfs and root fs identified by UUID
menuentry "LFS Dev (LFS-7.0-Feb14) initrd, Linux 3.0.4"
{
  linux  /vmlinuz-3.0.4-lfs-20120214 root=UUID=54b934a9-302d-415e-ac11-4988408eb0a8 ro
  initrd /initrd.img-no-kmods
}

# Generic initramfs and root fs on LVM partition
menuentry "LFS Dev (LFS-7.0-Feb18) initrd lvm, Linux 3.0.4"
{
  linux  /vmlinuz-3.0.4-lfs-20120218 root=/dev/mapper/myroot ro
  initrd /initrd.img-no-kmods
}

# Specific initramfs and root fs identified by LABEL
menuentry "LFS Dev (LFS-7.1-Feb20) initrd label, Linux 3.2.6"
{
  linux  /vmlinuz-3.2.6-lfs71-120220 root=LABEL=lfs71 ro
  initrd /initrd.img-3.2.6-lfs71-120220
}


}
download;unpack;build
