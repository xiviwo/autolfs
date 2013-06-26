#!/bin/bash
BLFS_Boot_Scripts_C2(){
: 
} 


export Host_System_Requirements_C0_download=""

export Host_System_Requirements_C0_packname=""


export C0_Preface="Foreword_C0 Audience_C0 LFS_Target_Architectures_C0 LFS_and_Standards_C0 Rationale_for_Packages_in_the_Book_C0 Prerequisites_C0 Host_System_Requirements_C0 Typography_C0 Structure_C0 Errata_C0 "


export C1_Introduction="How_to_Build_an_LFS_System_C1 What_s_new_since_the_last_release_C1 Changelog_C1 Resources_C1 Help_C1 "



Mounting_the_New_Partition_C2(){

export LFS=/mnt/lfs
mkdir -pv $LFS
mount -v -t ext4 /dev/<xxx> $LFS

mkdir -pv $LFS
mount -v -t ext4 /dev/<xxx> $LFS
mount -v -t ext4 /dev/<yyy> $LFS/usr

/sbin/swapon -v /dev/mapper/loop0p2

}

export C2_PreparingaNewPartition="Introduction_C2 Creating_a_New_Partition_C2 Creating_a_File_System_on_the_Partition_C2 Mounting_the_New_Partition_C2 "


Introduction_C3(){

mkdir -pv $LFS/sources
chmod -v a+wt $LFS/sources
wget -i wget-list -P $LFS/sources
pushd $LFS/sources
md5sum -c md5sums
popd
}

export C3_PackagesandPatches="Introduction_C3 All_Packages_C3 Needed_Patches_C3 "



Creating_the_LFS_tools_Directory_C4(){

mkdir -pv $LFS/tools
ln -sv $LFS/tools /
}

Adding_the_LFS_User_C4(){

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo 'lfs:ping' | chpasswd
chown -Rv lfs $LFS/tools
chown -Rv lfs $LFS/sources
}

Setting_Up_the_Environment_C4(){

cat > ~/.bash_profile << "EOF"
source ~/.bashrc
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF

source ~/.bash_profile
}


export C4_FinalPreparations="About_LFS_C4 Creating_the_LFS_tools_Directory_C4 Adding_the_LFS_User_C4 Setting_Up_the_Environment_C4 About_SBUs_C4 About_the_Test_Suites_C4 "



Binutils_2_23_2_Pass_1_C5(){

sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -pv ../binutils-build
cd ../binutils-build
../binutils-2.23.2/configure   \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror
make
case $(uname -m) in
  x86_64) mkdir -pv /tools/lib && ln -sv lib /tools/lib64 ;;
esac
make install
}

GCC_4_8_1_Pass_1_C5(){

tar -Jxf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -Jxf ../gmp-5.1.2.tar.xz
mv -v gmp-5.1.2 gmp
tar -zxf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure
mkdir -pv ../gcc-build
cd ../gcc-build
../gcc-4.8.1/configure                               \
    --target=$LFS_TGT                                \
    --prefix=/tools                                  \
    --with-sysroot=$LFS                              \
    --with-newlib                                    \
    --without-headers                                \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --disable-nls                                    \
    --disable-shared                                 \
    --disable-multilib                               \
    --disable-decimal-float                          \
    --disable-threads                                \
    --disable-libatomic                              \
    --disable-libgomp                                \
    --disable-libitm                                 \
    --disable-libmudflap                             \
    --disable-libquadmath                            \
    --disable-libsanitizer                           \
    --disable-libssp                                 \
    --disable-libstdc++-v3                           \
    --enable-languages=c,c++                         \
    --with-mpfr-include=$(pwd)/../gcc-4.8.1/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs
make
make install
ln -sv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`
}

Linux_3_9_6_API_Headers_C5(){

make mrproper
make headers_check
make INSTALL_HDR_PATH=dest headers_install

cp -rv dest/include/* /tools/include
}

Glibc_2_17_C5(){

if [ ! -r /usr/include/rpc/types.h ]; then
  su -c 'mkdir -p /usr/include/rpc'
  su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
fi
mkdir -pv ../glibc-build
cd ../glibc-build
../glibc-2.17/configure                             \
      --prefix=/tools                               \
      --host=$LFS_TGT                               \
      --build=$(../glibc-2.17/scripts/config.guess) \
      --disable-profile                             \
      --enable-kernel=2.6.25                        \
      --with-headers=/tools/include                 \
      libc_cv_forced_unwind=yes                     \
      libc_cv_ctors_header=yes                      \
      libc_cv_c_cleanup=yes
make
make install
}

Libstdc_4_8_1_C5(){
mkdir -pv Libstdc++
cd Libstdc++
mkdir -pv ../gcc-build
cd ../gcc-build
rm -rf *
../gcc-4.8.1/libstdc++-v3/configure \
    --host=$LFS_TGT                      \
    --prefix=/tools                      \
    --disable-multilib                   \
    --disable-shared                     \
    --disable-nls                        \
    --disable-libstdcxx-threads          \
    --disable-libstdcxx-pch              \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/4.8.1
make
make install
}

Binutils_2_23_2_Pass_2_C5(){

sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -pv ../binutils-build
cd ../binutils-build
CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../binutils-2.23.2/configure   \
    --prefix=/tools            \
    --disable-nls              \
    --with-lib-path=/tools/lib \
    --with-sysroot
make
make install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin
}

GCC_4_8_1_Pass_2_C5(){

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h
cp -v gcc/Makefile.in{,.tmp}
sed 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in.tmp \
  > gcc/Makefile.in
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
  -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
tar -Jxf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -Jxf ../gmp-5.1.2.tar.xz
mv -v gmp-5.1.2 gmp
tar -zxf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc
mkdir -pv ../gcc-build
cd ../gcc-build

CC=$LFS_TGT-gcc                                      \
CXX=$LFS_TGT-g++                                     \
AR=$LFS_TGT-ar                                       \
RANLIB=$LFS_TGT-ranlib                               \
../gcc-4.8.1/configure                               \
    --prefix=/tools                                  \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --enable-clocale=gnu                             \
    --enable-shared                                  \
    --enable-threads=posix                           \
    --enable-__cxa_atexit                            \
    --enable-languages=c,c++                         \
    --disable-libstdcxx-pch                          \
    --disable-multilib                               \
    --disable-bootstrap                              \
    --disable-libgomp                                \
    --with-mpfr-include=$(pwd)/../gcc-4.8.1/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs
make
make install
ln -sv gcc /tools/bin/cc
}

Tcl_8_6_0_C5(){

sed -i s/500/5000/ generic/regc_nfa.c
cd unix
./configure --prefix=/tools
make
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh
}

Expect_5_45_C5(){

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools --with-tcl=/tools/lib \
  --with-tclinclude=/tools/include
make
make SCRIPTS="" install
}

DejaGNU_1_5_1_C5(){

./configure --prefix=/tools
make install
}

Check_0_9_10_C5(){

./configure --prefix=/tools
make
make install
}

Ncurses_5_9_C5(){

./configure --prefix=/tools --with-shared \
    --without-debug --without-ada --enable-overwrite
make
make install
}

Bash_4_2_C5(){

patch -Np1 -i ../bash-4.2-fixes-12.patch
./configure --prefix=/tools --without-bash-malloc
make
make install
ln -sv bash /tools/bin/sh
}

Bzip2_1_0_6_C5(){

make
make PREFIX=/tools install
}

Coreutils_8_21_C5(){

./configure --prefix=/tools --enable-install-program=hostname
make
make install
}

Diffutils_3_3_C5(){

./configure --prefix=/tools
make
make install
}

File_5_14_C5(){

./configure --prefix=/tools
make
make install
}

Findutils_4_4_2_C5(){

./configure --prefix=/tools
make
make install
}

Gawk_4_1_0_C5(){

./configure --prefix=/tools
make
make install
}

Gettext_0_18_2_1_C5(){

cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared
make -C gnulib-lib
make -C src msgfmt
cp -v src/msgfmt /tools/bin
}

Grep_2_14_C5(){

./configure --prefix=/tools
make
make install
}

Gzip_1_6_C5(){

./configure --prefix=/tools
make
make install
}

M4_1_4_16_C5(){

sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/tools
make
make install
}

Make_3_82_C5(){

./configure --prefix=/tools
make
make install
}

Patch_2_7_1_C5(){

./configure --prefix=/tools
make
make install
}

Perl_5_18_0_C5(){

patch -Np1 -i ../perl-5.18.0-libc-1.patch
sh Configure -des -Dprefix=/tools
make
cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.18.0
cp -Rv lib/* /tools/lib/perl5/5.18.0
}

Sed_4_2_2_C5(){

./configure --prefix=/tools
make
make install
}

Tar_1_26_C5(){

sed -i -e '/gets is a/d' gnu/stdio.in.h
./configure --prefix=/tools
make
make install
}

Texinfo_5_1_C5(){

./configure --prefix=/tools
make
make install
}

Xz_5_0_4_C5(){

./configure --prefix=/tools
make
make install
}

Stripping_C5(){

strip --strip-debug /tools/lib/*
strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
}

Changing_Ownership_C5(){

chown -R root:root $LFS/tools
}

export C5_ConstructingaTemporarySystem="Introduction_C5 Toolchain_Technical_Notes_C5 General_Compilation_Instructions_C5 Binutils_2_23_2_Pass_1_C5 GCC_4_8_1_Pass_1_C5 Linux_3_9_6_API_Headers_C5 Glibc_2_17_C5 Libstdc_4_8_1_C5 Binutils_2_23_2_Pass_2_C5 GCC_4_8_1_Pass_2_C5 Tcl_8_6_0_C5 Expect_5_45_C5 DejaGNU_1_5_1_C5 Check_0_9_10_C5 Ncurses_5_9_C5 Bash_4_2_C5 Bzip2_1_0_6_C5 Coreutils_8_21_C5 Diffutils_3_3_C5 File_5_14_C5 Findutils_4_4_2_C5 Gawk_4_1_0_C5 Gettext_0_18_2_1_C5 Grep_2_14_C5 Gzip_1_6_C5 M4_1_4_16_C5 Make_3_82_C5 Patch_2_7_1_C5 Perl_5_18_0_C5 Sed_4_2_2_C5 Tar_1_26_C5 Texinfo_5_1_C5 Xz_5_0_4_C5 Stripping_C5 Changing_Ownership_C5 "


Preparing_Virtual_Kernel_File_Systems_C6(){

mkdir -pv $LFS/{dev,proc,sys}
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
if [ -h $LFS/dev/shm ]; then
  link=$(readlink $LFS/dev/shm)
  mkdir -p $LFS/$link
  mount -vt tmpfs shm $LFS/$link
  unset link
else
  mount -vt tmpfs shm $LFS/dev/shm
fi
}



Creating_Directories_C6(){

mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib,mnt,opt,run}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
mkdir -pv  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
for dir in /usr /usr/local; do
  ln -sv share/{man,doc,info} $dir
done
case $(uname -m) in
 x86_64) ln -sv lib /lib64 && ln -sv lib /usr/lib64 ;;
esac
mkdir -pv /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
}

Creating_Essential_Files_and_Symlinks_C6(){

ln -sv /tools/bin/{bash,cat,echo,pwd,stty} /bin
ln -sv /tools/bin/perl /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib
sed 's/tools/usr/' /tools/lib/libstdc++.la > /usr/lib/libstdc++.la
ln -sv bash /bin/sh
ln -sv /proc/self/mounts /etc/mtab
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
mail:x:34:
nogroup:x:99:
EOF

touch /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
}

Linux_3_9_6_API_Headers_C6(){

make mrproper
make headers_check
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete

cp -rv dest/include/* /usr/include
}

Man_pages_3_51_C6(){

make install
}

Glibc_2_17_C6(){

mkdir -pv ../glibc-build
cd ../glibc-build
../glibc-2.17/configure    \
    --prefix=/usr          \
    --disable-profile      \
    --enable-kernel=2.6.25 \
    --libexecdir=/usr/lib/glibc
make
touch /etc/ld.so.conf
make install
cp -v ../glibc-2.17/sunrpc/rpc/*.h /usr/include/rpc
cp -v ../glibc-2.17/sunrpc/rpcsvc/*.h /usr/include/rpcsvc
cp -v ../glibc-2.17/nis/rpcsvc/*.h /usr/include/rpcsvc
mkdir -pv /usr/lib/locale
make localedata/install-locales
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../tzdata2013c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew solar87 solar88 solar89 \
          systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
cp -v --remove-destination /usr/share/zoneinfo/Asia/Shanghai \
    /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

}

Adjusting_the_Toolchain_C6(){

mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld
gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs
}

Zlib_1_2_8_C6(){

./configure --prefix=/usr
make
make install
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/libz.so.1.2.8 /usr/lib/libz.so
}

File_5_14_C6(){

./configure --prefix=/usr
make
make install
}

Binutils_2_23_2_C6(){

rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in
sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -pv ../binutils-build
cd ../binutils-build
../binutils-2.23.2/configure --prefix=/usr --enable-shared
make tooldir=/usr
make tooldir=/usr install
cp -v ../binutils-2.23.2/include/libiberty.h /usr/include
}

GMP_5_1_2_C6(){


ABI=64 
./configure --prefix=/usr --enable-cxx
make
make install
mkdir -pv /usr/share/doc/gmp-5.1.2
cp    -v doc/{isa_abi_headache,configuration} doc/*.html \
         /usr/share/doc/gmp-5.1.2
}

MPFR_3_1_2_C6(){

./configure  --prefix=/usr        \
             --enable-thread-safe \
             --docdir=/usr/share/doc/mpfr-3.1.2
make
make install
make html

make install-html
}

MPC_1_0_1_C6(){

./configure --prefix=/usr
make
make install
}

GCC_4_8_1_C6(){

case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in 
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}
mkdir -pv ../gcc-build
cd ../gcc-build
../gcc-4.8.1/configure --prefix=/usr               \
                       --libexecdir=/usr/lib       \
                       --enable-shared             \
                       --enable-threads=posix      \
                       --enable-__cxa_atexit       \
                       --enable-clocale=gnu        \
                       --enable-languages=c,c++    \
                       --disable-multilib          \
                       --disable-bootstrap         \
                       --disable-install-libiberty \
                       --with-system-zlib
make
make install
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
}

Sed_4_2_2_C6(){

./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2
make
make html
make install
make -C doc install-html
}

Bzip2_1_0_6_C6(){

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat
}

Pkg_config_0_28_C6(){

./configure --prefix=/usr         \
            --with-internal-glib  \
            --disable-host-tool   \
            --docdir=/usr/share/doc/pkg-config-0.28
make
make install
}

Ncurses_5_9_C6(){

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --enable-pc-files       \
            --enable-widec
make
make install
mv -v /usr/lib/libncursesw.so.5* /lib
ln -sfv ../../lib/libncursesw.so.5 /usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv lib${lib}w.a      /usr/lib/lib${lib}.a
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncurses++w.a /usr/lib/libncurses++.a
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
ln -sfv libncursesw.a      /usr/lib/libcursesw.a
ln -sfv libncurses.a       /usr/lib/libcurses.a
mkdir -pv       /usr/share/doc/ncurses-5.9
cp -v -R doc/* /usr/share/doc/ncurses-5.9
make distclean
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding
make sources libs
cp -av lib/lib*.so.5* /usr/lib
}

Shadow_4_1_5_1_C6(){

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' \
    etc/login.defs
./configure --sysconfdir=/etc --with-libpam=no
make
make install
mv -v /usr/bin/passwd /bin
pwconv
grpconv
sed -i 's/yes/no/' /etc/default/useradd
echo 'root:ping' | chpasswd
}

Util_linux_2_23_1_C6(){

sed -i -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
     $(grep -rl '/etc/adjtime' .)

mkdir -pv /var/lib/hwclock
./configure --disable-su --disable-sulogin --disable-login
make
make install
}

Psmisc_22_20_C6(){

./configure --prefix=/usr
make
make install
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin
}

Procps_ng_3_3_8_C6(){

./configure --prefix=/usr                           \
            --exec-prefix=                          \
            --libdir=/usr/lib                       \
            --docdir=/usr/share/doc/procps-ng-3.3.8 \
            --disable-static                        \
            --disable-skill                         \
            --disable-kill
make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp

make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/libprocps.so.1.1.2 /usr/lib/libprocps.so
}

E2fsprogs_1_42_7_C6(){

mkdir -pv build
cd build
../configure --prefix=/usr         \
             --with-root-prefix="" \
             --enable-elf-shlibs   \
             --disable-libblkid    \
             --disable-libuuid     \
             --disable-uuidd       \
             --disable-fsck
make
make install
make install-libs
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
}

Coreutils_8_21_C6(){

patch -Np1 -i ../coreutils-8.21-i18n-1.patch
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr         \
            --libexecdir=/usr/lib \
            --enable-no-install-program=kill,uptime
make
make install
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname,test,[} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
mv -v /usr/bin/{head,sleep,nice} /bin
}

Iana_Etc_2_30_C6(){

make
make install
}

M4_1_4_16_C6(){

sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/usr
make
sed -i -e '41s/ENOENT/& || errno == EINVAL/' tests/test-readlink.h
make install
}

Bison_2_7_1_C6(){

./configure --prefix=/usr
echo '#define YYENABLE_NLS 1' >> lib/config.h
make
make install
}

Grep_2_14_C6(){

./configure --prefix=/usr --bindir=/bin
make
make install
}

Readline_6_2_C6(){

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
patch -Np1 -i ../readline-6.2-fixes-1.patch
./configure --prefix=/usr --libdir=/lib
make SHLIB_LIBS=-lncurses
make install
mv -v /lib/lib{readline,history}.a /usr/lib
rm -v /lib/lib{readline,history}.so
ln -sfv ../../lib/libreadline.so.6 /usr/lib/libreadline.so
ln -sfv ../../lib/libhistory.so.6 /usr/lib/libhistory.so
mkdir   -v       /usr/share/doc/readline-6.2
install -v -m644 doc/*.{ps,pdf,html,dvi} \
                 /usr/share/doc/readline-6.2
}

Bash_4_2_C6(){

patch -Np1 -i ../bash-4.2-fixes-12.patch
./configure --prefix=/usr                     \
            --bindir=/bin                     \
            --htmldir=/usr/share/doc/bash-4.2 \
            --without-bash-malloc             \
            --with-installed-readline
make
make install
}

Bc_1_06_95_C6(){

./configure --prefix=/usr --with-readline
make
echo "quit" | ./bc/bc -l Test/checklib.b
make install
}

Libtool_2_4_2_C6(){

./configure --prefix=/usr
make
make install
}

GDBM_1_10_C6(){

./configure --prefix=/usr --enable-libgdbm-compat
make
make install
}

Inetutils_1_9_1_C6(){

sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/usr  \
    --libexecdir=/usr/sbin \
    --localstatedir=/var   \
    --disable-ifconfig     \
    --disable-logger       \
    --disable-syslogd      \
    --disable-whois        \
    --disable-servers
make
make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
}

Perl_5_18_0_C6(){

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|"           \
       -e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" \
       -e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|"         \
    cpan/Compress-Raw-Zlib/config.in
sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib
make
make install
}

Autoconf_2_69_C6(){

./configure --prefix=/usr
make
make install
}

Automake_1_13_4_C6(){

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.13.4
make
make install
}

Diffutils_3_3_C6(){

./configure --prefix=/usr
make
make install
}

Gawk_4_1_0_C6(){

./configure --prefix=/usr --libexecdir=/usr/lib
make
make install
mkdir -pv /usr/share/doc/gawk-4.1.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.0
}

Findutils_4_4_2_C6(){

./configure --prefix=/usr                   \
            --libexecdir=/usr/lib/findutils \
            --localstatedir=/var/lib/locate
make
make install
mv -v /usr/bin/find /bin
sed -i 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb
}

Flex_2_5_37_C6(){

patch -Np1 -i ../flex-2.5.37-bison-2.6.1-1.patch
./configure --prefix=/usr             \
            --docdir=/usr/share/doc/flex-2.5.37
make
make install
ln -sv libfl.a /usr/lib/libl.a
cat > /usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex

exec /usr/bin/flex -l "$@"

# End /usr/bin/lex
EOF
chmod -v 755 /usr/bin/lex

}

Gettext_0_18_2_1_C6(){

./configure --prefix=/usr \
            --docdir=/usr/share/doc/gettext-0.18.2.1
make
make install
}

Groff_1_22_2_C6(){

PAGE=A4 ./configure --prefix=/usr

make
mkdir -p /usr/share/doc/groff-1.22/pdf
make install
ln -sv eqn /usr/bin/geqn
ln -sv tbl /usr/bin/gtbl
}

Xz_5_0_4_C6(){

./configure --prefix=/usr --libdir=/lib --docdir=/usr/share/doc/xz-5.0.4
make
make pkgconfigdir=/usr/lib/pkgconfig install
}

GRUB_2_00_C6(){

sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-grub-emu-usb \
            --disable-efiemu       \
            --disable-werror
make
make install
}

Less_458_C6(){

./configure --prefix=/usr --sysconfdir=/etc
make
make install
}

Gzip_1_6_C6(){

./configure --prefix=/usr --bindir=/bin
make
make install
mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin
}

IPRoute2_3_9_0_C6(){

sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
sed -i 's/-Werror//' Makefile
make DESTDIR=
make DESTDIR=              \
     MANDIR=/usr/share/man \
     DOCDIR=/usr/share/doc/iproute2-3.9.0 install
}

Kbd_1_15_5_C6(){

patch -Np1 -i ../kbd-1.15.5-backspace-1.patch
sed -i -e '326 s/if/while/' src/loadkeys.analyze.l
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make install
mkdir -pv       /usr/share/doc/kbd-1.15.5
cp -R -v doc/* /usr/share/doc/kbd-1.15.5
}

Kmod_13_C6(){

./configure --prefix=/usr       \
            --bindir=/bin       \
            --libdir=/lib       \
            --sysconfdir=/etc   \
            --disable-manpages  \
            --with-xz           \
            --with-zlib
make
make pkgconfigdir=/usr/lib/pkgconfig install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sv ../bin/kmod /sbin/$target
done

ln -sv kmod /bin/lsmod
}

Libpipeline_1_2_4_C6(){

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr
make
make install
}

Make_3_82_C6(){

patch -Np1 -i ../make-3.82-upstream_fixes-3.patch
./configure --prefix=/usr
make
make install
}

Man_DB_2_6_3_C6(){

./configure --prefix=/usr                        \
            --libexecdir=/usr/lib                \
            --docdir=/usr/share/doc/man-db-2.6.3 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap
make
make install
}

Patch_2_7_1_C6(){

./configure --prefix=/usr
make
make install
}

Sysklogd_1_5_C6(){

make
make BINDIR=/sbin install
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

}

Sysvinit_2_88dsf_C6(){

sed -i 's@Sending processes@& configured via /etc/inittab@g' src/init.c
sed -i -e '/utmpdump/d' \
       -e '/mountpoint/d' src/Makefile
make -C src
make -C src install
}

Tar_1_26_C6(){

sed -i -e '/gets is a/d' gnu/stdio.in.h
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin \
            --libexecdir=/usr/sbin
make
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.26
}

Texinfo_5_1_C6(){

./configure --prefix=/usr
make
make install
make TEXMF=/usr/share/texmf install-tex
cd /usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done
}

Udev_204_Extracted_from_systemd_204__C6(){

tar -xvf ../udev-lfs-204-1.tar.bz2
make -f udev-lfs-204-1/Makefile.lfs
make -f udev-lfs-204-1/Makefile.lfs install
sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-204-1/init-net-rules.sh
build/udevadm hwdb --update
bash udev-lfs-204-1/init-net-rules.sh
}

Vim_7_3_C6(){

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr --enable-multibyte
make
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim73/doc /usr/share/doc/vim-7.3
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

}

Stripping_Again_C6(){

chroot $LFS /tools/bin/env -i \
    HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
/tools/bin/find /{,usr/}{bin,lib,sbin} -type f \
  -exec /tools/bin/strip --strip-debug '{}' ';'
}


export C6_InstallingBasicSystemSoftware="Introduction_C6 Preparing_Virtual_Kernel_File_Systems_C6 Package_Management_C6 Entering_the_Chroot_Environment_C6 Creating_Directories_C6 Creating_Essential_Files_and_Symlinks_C6 Linux_3_9_6_API_Headers_C6 Man_pages_3_51_C6 Glibc_2_17_C6 Adjusting_the_Toolchain_C6 Zlib_1_2_8_C6 File_5_14_C6 Binutils_2_23_2_C6 GMP_5_1_2_C6 MPFR_3_1_2_C6 MPC_1_0_1_C6 GCC_4_8_1_C6 Sed_4_2_2_C6 Bzip2_1_0_6_C6 Pkg_config_0_28_C6 Ncurses_5_9_C6 Shadow_4_1_5_1_C6 Util_linux_2_23_1_C6 Psmisc_22_20_C6 Procps_ng_3_3_8_C6 E2fsprogs_1_42_7_C6 Coreutils_8_21_C6 Iana_Etc_2_30_C6 M4_1_4_16_C6 Bison_2_7_1_C6 Grep_2_14_C6 Readline_6_2_C6 Bash_4_2_C6 Bc_1_06_95_C6 Libtool_2_4_2_C6 GDBM_1_10_C6 Inetutils_1_9_1_C6 Perl_5_18_0_C6 Autoconf_2_69_C6 Automake_1_13_4_C6 Diffutils_3_3_C6 Gawk_4_1_0_C6 Findutils_4_4_2_C6 Flex_2_5_37_C6 Gettext_0_18_2_1_C6 Groff_1_22_2_C6 Xz_5_0_4_C6 GRUB_2_00_C6 Less_458_C6 Gzip_1_6_C6 IPRoute2_3_9_0_C6 Kbd_1_15_5_C6 Kmod_13_C6 Libpipeline_1_2_4_C6 Make_3_82_C6 Man_DB_2_6_3_C6 Patch_2_7_1_C6 Sysklogd_1_5_C6 Sysvinit_2_88dsf_C6 Tar_1_26_C6 Texinfo_5_1_C6 Udev_204_Extracted_from_systemd_204__C6 Vim_7_3_C6 About_Debugging_Symbols_C6 Stripping_Again_C6 Cleaning_Up_C6 "


General_Network_Configuration_C7(){

cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.136.13
GATEWAY=192.168.136.2
PREFIX=24
BROADCAST=192.168.136.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain ibm.com
nameserver 192.168.136.2
nameserver 192.168.136.1

# End /etc/resolv.conf
EOF

}

Customizing_the_etc_hosts_File_C7(){

cat > /etc/hosts << "EOF"
# Begin /etc/hosts (network card version)

127.0.0.1 localhost
<192.168.1.1> <HOSTNAME.example.org> [alias1] [alias2 ...]

# End /etc/hosts (network card version)
EOF

cat > /etc/hosts << "EOF"
# Begin /etc/hosts (no network card version)

127.0.0.1 localhost
192.168.136.13	alfs

# End /etc/hosts (no network card version)
EOF

}

Creating_Custom_Symlinks_to_Devices_C7(){

sed -i -e 's/"write_cd_rules"/"write_cd_rules mode"/' \

cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", \
    SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f", ATTRS{vendor}=="0x109e", \
    SYMLINK+="tvtuner"

EOF

}

LFS_Bootscripts_20130515_C7(){

make install
}

How_Do_These_Bootscripts_Work__C7(){

cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF

}

Configuring_the_system_hostname_C7(){

echo "HOSTNAME=alfs" > /etc/sysconfig/network

}

Configuring_the_setclock_Script_C7(){

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

}

Configuring_the_Linux_Console_C7(){

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

KEYMAP="pl2"
FONT="lat2a-16 -m 8859-2"

# End /etc/sysconfig/console
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

KEYMAP="us"

FONT="lat0-16 -m 8859-15"

# End /etc/sysconfig/console
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="bg_bds-utf8"
FONT="LatArCyrHeb-16"

# End /etc/sysconfig/console
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="bg_bds-utf8"
FONT="cyr-sun16"

# End /etc/sysconfig/console
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="us"




# End /etc/sysconfig/console
EOF

}

The_Bash_Shell_Startup_Files_C7(){


cat > /etc/profile << "EOF"
# Begin /etc/profile

export LANG=en_US.utf8

# End /etc/profile
EOF

}

Creating_the_etc_inputrc_File_C7(){

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

}

export C7_SettingUpSystemBootscripts="Introduction_C7 General_Network_Configuration_C7 Customizing_the_etc_hosts_File_C7 Device_and_Module_Handling_on_an_LFS_System_C7 Creating_Custom_Symlinks_to_Devices_C7 LFS_Bootscripts_20130515_C7 How_Do_These_Bootscripts_Work__C7 Configuring_the_system_hostname_C7 Configuring_the_setclock_Script_C7 Configuring_the_Linux_Console_C7 Configuring_the_sysklogd_Script_C7 The_rc_site_File_C7 The_Bash_Shell_Startup_Files_C7 Creating_the_etc_inputrc_File_C7 "


Creating_the_etc_fstab_File_C8(){

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/vda1     /            ext3    defaults            1     1
/dev/vda2    swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF

}

Linux_3_9_6_C8(){

make mrproper
make LC_ALL= menuconfig

make -j4
make modules_install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-3.9.6-lfs-SVN-20130616
cp -v System.map /boot/System.map-3.9.6
cp -v .config /boot/config-3.9.6
install -d /usr/share/doc/linux-3.9.6
cp -r Documentation/* /usr/share/doc/linux-3.9.6
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

}

Using_GRUB_to_Set_Up_the_Boot_Process_C8(){

grub-install /dev/mapper/loop0
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,1)

menuentry "GNU/Linux, Linux 3.9.6-lfs-SVN-20130616" {
        linux   /boot/vmlinuz-3.9.6-lfs-SVN-20130616 root=/dev/vda1 ro
}
EOF

}

export C8_MakingtheLFSSystemBootable="Introduction_C8 Creating_the_etc_fstab_File_C8 Linux_3_9_6_C8 Using_GRUB_to_Set_Up_the_Boot_Process_C8 "


The_End_C9(){

echo SVN-20130616 > /etc/lfs-release
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="SVN-20130616"
DISTRIB_CODENAME="MAO"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF
}


export C9_TheEnd="The_End_C9 Get_Counted_C9 Rebooting_the_System_C9 What_Now__C9 "


export LFSCHAPTERS="C0_Preface C1_Introduction C2_PreparingaNewPartition C3_PackagesandPatches C4_FinalPreparations C5_ConstructingaTemporarySystem C6_InstallingBasicSystemSoftware C7_SettingUpSystemBootscripts C8_MakingtheLFSSystemBootable C9_TheEnd "
