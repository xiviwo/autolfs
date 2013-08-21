#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=cleaning
version=
chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login
