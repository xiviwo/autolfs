#!/bin/bash
BLFS_Boot_Scripts_C2(){
: 
} 

Host_System_Requirements_C0(){

cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools

export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
echo "/bin/sh -> `readlink -f /bin/sh`"
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
if [ -e /usr/bin/yacc ];
  then echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
  else echo "yacc not found"; fi

bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
if [ -e /usr/bin/awk ];
  then echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
  else echo "awk not found"; fi

gcc --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
sed --version | head -n1
tar --version | head -n1
echo "Texinfo: `makeinfo --version | head -n1`"
xz --version | head -n1

echo 'main(){}' > dummy.c && gcc -o dummy dummy.c
if [ -x dummy ]
  then echo "gcc compilation OK";
  else echo "gcc compilation failed"; fi
rm -f dummy.c dummy
EOF

bash version-check.sh

}

export Host_System_Requirements_C0_download=""

export Host_System_Requirements_C0_packname=""


export C0_Preface="Foreword_C0 Audience_C0 LFS_Target_Architectures_C0 LFS_and_Standards_C0 Rationale_for_Packages_in_the_Book_C0 Prerequisites_C0 Host_System_Requirements_C0 Typography_C0 Structure_C0 Errata_C0 "


export C1_Introduction="How_to_Build_an_LFS_System_C1 What_s_new_since_the_last_release_C1 Changelog_C1 Resources_C1 Help_C1 "


Creating_a_File_System_on_the_Partition_C2(){

mke2fs -jv /dev/

debugfs -R feature /dev/

cd /tmp
tar -xzvf /path/to/sources/e2fsprogs-1.42.7.tar.gz
cd e2fsprogs-1.42.7
mkdir -pv build
cd build
../configure
make #note that we intentionally don't 'make install' here!
./misc/mke2fs -jv /dev/
cd /tmp
rm -rfv e2fsprogs-1.42.7

mkswap /dev/

}

Mounting_the_New_Partition_C2(){

export LFS=/mnt/lfs


mount -v -t ext3 /dev/mapper/loop0p1 /mnt/lfs

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


About_LFS_C4(){

echo $LFS
export LFS=/mnt/lfs
}

Creating_the_LFS_tools_Directory_C4(){

mkdir -pv $LFS/tools
ln -sfv $LFS/tools /
}

Adding_the_LFS_User_C4(){

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
passwd lfs << EOF
ping
ping
EOF
chown -R lfs $LFS/tools
chown -R lfs $LFS/sources
}

Setting_Up_the_Environment_C4(){

cat > ~/.bash_profile << "EOF"
. ~/.bashrc
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


General_Compilation_Instructions_C5(){

echo $LFS
}

Binutils_2_23_1_Pass_1_C5(){

mkdir -pv ../binutils-build
cd ../binutils-build
../binutils-2.23.1/configure     \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror
make
case $(uname -m) in
  x86_64) mkdir -pv /tools/lib && ln -sfv lib /tools/lib64 ;;
esac
make install
}

GCC_4_7_2_Pass_1_C5(){

tar -Jxf ../mpfr-3.1.1.tar.xz
mv -v mpfr-3.1.1 mpfr
tar -Jxf ../gmp-5.1.1.tar.xz
mv -v gmp-5.1.1 gmp
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
sed -i 's/BUILD_INFO=info/BUILD_INFO=/' gcc/configure
mkdir -pv ../gcc-build
cd ../gcc-build
../gcc-4.7.2/configure         \
    --target=$LFS_TGT          \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-newlib              \
    --without-headers          \
    --with-local-prefix=/tools \
    --with-native-system-header-dir=/tools/include \
    --disable-nls              \
    --disable-shared           \
    --disable-multilib         \
    --disable-decimal-float    \
    --disable-threads          \
    --disable-libmudflap       \
    --disable-libssp           \
    --disable-libgomp          \
    --disable-libquadmath      \
    --enable-languages=c       \
    --with-mpfr-include=$(pwd)/../gcc-4.7.2/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs
make
make install
ln -sfv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`
}

Linux_3_8_1_API_Headers_C5(){

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
      --prefix=/tools                                 \
      --host=$LFS_TGT                                 \
      --build=$(../glibc-2.17/scripts/config.guess) \
      --disable-profile                               \
      --enable-kernel=2.6.25                          \
      --with-headers=/tools/include                   \
      libc_cv_forced_unwind=yes                       \
      libc_cv_ctors_header=yes                        \
      libc_cv_c_cleanup=yes
make
make install
echo 'main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out
}

Binutils_2_23_1_Pass_2_C5(){

mkdir -pv ../binutils-build
cd ../binutils-build
CC=$LFS_TGT-gcc            \
AR=$LFS_TGT-ar             \
RANLIB=$LFS_TGT-ranlib     \
../binutils-2.23.1/configure \
    --prefix=/tools        \
    --disable-nls          \
    --with-lib-path=/tools/lib
make
make install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin
}

GCC_4_7_2_Pass_2_C5(){

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
tar -Jxf ../mpfr-3.1.1.tar.xz
mv -v mpfr-3.1.1 mpfr
tar -Jxf ../gmp-5.1.1.tar.xz
mv -v gmp-5.1.1 gmp
tar -zxf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc
sed -i 's/BUILD_INFO=info/BUILD_INFO=/' gcc/configure
mkdir -pv ../gcc-build
cd ../gcc-build
CC=$LFS_TGT-gcc \
AR=$LFS_TGT-ar                  \
RANLIB=$LFS_TGT-ranlib          \
../gcc-4.7.2/configure          \
    --prefix=/tools             \
    --with-local-prefix=/tools  \
    --with-native-system-header-dir=/tools/include \
    --enable-clocale=gnu        \
    --enable-shared             \
    --enable-threads=posix      \
    --enable-__cxa_atexit       \
    --enable-languages=c,c++    \
    --disable-libstdcxx-pch     \
    --disable-multilib          \
    --disable-bootstrap         \
    --disable-libgomp           \
    --with-mpfr-include=$(pwd)/../gcc-4.7.2/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs
make
make install
ln -sfv gcc /tools/bin/cc
echo 'main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out
}

Tcl_8_6_0_C5(){

cd unix
./configure --prefix=/tools
make
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /tools/bin/tclsh
}

Expect_5_45_C5(){

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools --with-tcl=/tools/lib \
  --with-tclinclude=/tools/include
make
make SCRIPTS="" install
}

DejaGNU_1_5_C5(){

./configure --prefix=/tools
make install
}

Check_0_9_9_C5(){

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

patch -Np1 -i ../bash-4.2-fixes-11.patch
./configure --prefix=/tools --without-bash-malloc
make
make install
ln -sfv bash /tools/bin/sh
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

Diffutils_3_2_C5(){

sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/tools
make
make install
}

File_5_13_C5(){

./configure --prefix=/tools
make
make install
}

Findutils_4_4_2_C5(){

./configure --prefix=/tools
make
make install
}

Gawk_4_0_2_C5(){

./configure --prefix=/tools
make
make install
}

Gettext_0_18_2_C5(){

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

Gzip_1_5_C5(){

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

Perl_5_16_2_C5(){

patch -Np1 -i ../perl-5.16.2-libc-1.patch
sh Configure -des -Dprefix=/tools
make
cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.16.2
cp -Rv lib/* /tools/lib/perl5/5.16.2
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

Texinfo_5_0_C5(){

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

export C5_ConstructingaTemporarySystem="Introduction_C5 Toolchain_Technical_Notes_C5 General_Compilation_Instructions_C5 Binutils_2_23_1_Pass_1_C5 GCC_4_7_2_Pass_1_C5 Linux_3_8_1_API_Headers_C5 Glibc_2_17_C5 Binutils_2_23_1_Pass_2_C5 GCC_4_7_2_Pass_2_C5 Tcl_8_6_0_C5 Expect_5_45_C5 DejaGNU_1_5_C5 Check_0_9_9_C5 Ncurses_5_9_C5 Bash_4_2_C5 Bzip2_1_0_6_C5 Coreutils_8_21_C5 Diffutils_3_2_C5 File_5_13_C5 Findutils_4_4_2_C5 Gawk_4_0_2_C5 Gettext_0_18_2_C5 Grep_2_14_C5 Gzip_1_5_C5 M4_1_4_16_C5 Make_3_82_C5 Patch_2_7_1_C5 Perl_5_16_2_C5 Sed_4_2_2_C5 Tar_1_26_C5 Texinfo_5_0_C5 Xz_5_0_4_C5 Stripping_C5 Changing_Ownership_C5 "


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



Entering_the_Chroot_Environment_C6(){

chroot "$LFS" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h
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
  ln -sfv share/{man,doc,info} $dir
done
case $(uname -m) in
 x86_64) ln -sfv lib /lib64 && ln -sfv lib /usr/lib64 ;;
esac
mkdir -pv /var/{log,mail,spool}
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
}

Creating_Essential_Files_and_Symlinks_C6(){

ln -sfv /tools/bin/{bash,cat,echo,pwd,stty} /bin
ln -sfv /tools/bin/perl /usr/bin
ln -sfv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sfv /tools/lib/libstdc++.so{,.6} /usr/lib
sed 's/tools/usr/' /tools/lib/libstdc++.la > /usr/lib/libstdc++.la
ln -sfv bash /bin/sh
touch /etc/mtab
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

Linux_3_8_1_API_Headers_C6(){

make mrproper
make headers_check
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete

cp -rv dest/include/* /usr/include
}

Man_pages_3_47_C6(){

make install
}

Glibc_2_17_C6(){

mkdir -pv ../glibc-build
cd ../glibc-build
../glibc-2.17/configure  \
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
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
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

tar -xf ../tzdata2012j.tar.gz

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
ln -sfv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld
gcc -dumpspecs | sed -e 's@/tools@@g' \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > \
    `dirname $(gcc --print-libgcc-file-name)`/specs
echo 'main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B1 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
}

Zlib_1_2_7_C6(){

./configure --prefix=/usr
make
make install
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/libz.so.1.2.7 /usr/lib/libz.so
}

File_5_13_C6(){

./configure --prefix=/usr
make
make install
}

Binutils_2_23_1_C6(){

expect -c "spawn ls"
rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in
patch -Np1 -i ../binutils-2.23.1-testsuite_fix-1.patch
mkdir -pv ../binutils-build
cd ../binutils-build
../binutils-2.23.1/configure --prefix=/usr --enable-shared
make tooldir=/usr
make tooldir=/usr install
cp -v ../binutils-2.23.1/include/libiberty.h /usr/include
}

GMP_5_1_1_C6(){


ABI=64 ./configure --prefix=/usr --enable-cxx
make
make install
mkdir -pv /usr/share/doc/gmp-5.1.1
cp    -v doc/{isa_abi_headache,configuration} doc/*.html \
         /usr/share/doc/gmp-5.1.1
}

MPFR_3_1_1_C6(){

./configure  --prefix=/usr        \
             --enable-thread-safe \
             --docdir=/usr/share/doc/mpfr-3.1.1
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

GCC_4_7_2_C6(){

sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
sed -i 's/BUILD_INFO=info/BUILD_INFO=/' gcc/configure
case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac
sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in
mkdir -pv ../gcc-build
cd ../gcc-build
../gcc-4.7.2/configure --prefix=/usr            \
                       --libexecdir=/usr/lib    \
                       --enable-shared          \
                       --enable-threads=posix   \
                       --enable-__cxa_atexit    \
                       --enable-clocale=gnu     \
                       --enable-languages=c,c++ \
                       --disable-multilib       \
                       --disable-bootstrap      \
                       --with-system-zlib
make
ulimit -s 32768
../gcc-4.7.2/contrib/test_summary
make install
ln -sfv ../usr/bin/cpp /lib
ln -sfv gcc /usr/bin/cc
echo 'main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
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
ln -sfv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sfv bzip2 /bin/bunzip2
ln -sfv bzip2 /bin/bzcat
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

Util_linux_2_22_2_C6(){

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

Procps_ng_3_3_6_C6(){

./configure --prefix=/usr                           \
            --exec-prefix=                          \
            --libdir=/usr/lib                       \
            --docdir=/usr/share/doc/procps-ng-3.3.6 \
            --disable-static                        \
            --disable-skill                         \
            --disable-kill
make
make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/libprocps.so.1.1.0 /usr/lib/libprocps.so
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

Shadow_4_1_5_1_C6(){

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' \
    etc/login.defs
./configure --sysconfdir=/etc
make
make install
mv -v /usr/bin/passwd /bin
pwconv
grpconv
sed -i 's/yes/no/' /etc/default/useradd
passwd root << EOF
ping
ping
EOF
}

Coreutils_8_21_C6(){

patch -Np1 -i ../coreutils-8.21-i18n-1.patch
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr         \
            --libexecdir=/usr/lib \
            --enable-no-install-program=kill,uptime
make
echo "dummy:x:1000:nobody" >> /etc/group
chown -Rv nobody . 
sed -i '/dummy/d' /etc/group
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

Bison_2_7_C6(){

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

patch -Np1 -i ../bash-4.2-fixes-11.patch
./configure --prefix=/usr                     \
            --bindir=/bin                     \
            --htmldir=/usr/share/doc/bash-4.2 \
            --without-bash-malloc             \
            --with-installed-readline
make
chown -Rv nobody .
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

Perl_5_16_2_C6(){

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

Automake_1_13_1_C6(){

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.13.1
make
make install
}

Diffutils_3_2_C6(){

sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/usr
make
make install
}

Gawk_4_0_2_C6(){

./configure --prefix=/usr --libexecdir=/usr/lib
make
make install
mkdir -pv /usr/share/doc/gawk-4.0.2
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.0.2
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
ln -sfv libfl.a /usr/lib/libl.a
cat > /usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex

exec /usr/bin/flex -l "$@"

# End /usr/bin/lex
EOF
chmod -v 755 /usr/bin/lex

}

Gettext_0_18_2_C6(){

./configure --prefix=/usr \
            --docdir=/usr/share/doc/gettext-0.18.2
make
make install
}

Groff_1_22_2_C6(){

PAGE=A4 ./configure --prefix=/usr

make
mkdir -p /usr/share/doc/groff-1.22/pdf
make install
ln -sfv eqn /usr/bin/geqn
ln -sfv tbl /usr/bin/gtbl
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

Less_451_C6(){

./configure --prefix=/usr --sysconfdir=/etc
make
make install
}

Gzip_1_5_C6(){

./configure --prefix=/usr --bindir=/bin
make
make install
mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin
}

IPRoute2_3_8_0_C6(){

sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
sed -i 's/-Werror//' Makefile
make DESTDIR=
make DESTDIR=              \
     MANDIR=/usr/share/man \
     DOCDIR=/usr/share/doc/iproute2-3.8.0 install
}

Kbd_1_15_5_C6(){

patch -Np1 -i ../kbd-1.15.5-backspace-1.patch
sed -i -e '326 s/if/while/' src/loadkeys.analyze.l
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' man/man8/Makefile.in
./configure --prefix=/usr --datadir=/lib/kbd \
  --disable-vlock
make
make install
mv -v /usr/bin/{kbd_mode,loadkeys,openvt,setfont} /bin
mkdir -pv /usr/share/doc/kbd-1.15.5
cp -R -v doc/* \
         /usr/share/doc/kbd-1.15.5
}

Kmod_12_C6(){

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
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod
}

Libpipeline_1_2_2_C6(){

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

Texinfo_5_0_C6(){

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

Udev_197_Extracted_from_systemd_197__C6(){

tar -xvf ../udev-lfs-197-2.tar.bz2
make -f udev-lfs-197-2/Makefile.lfs
make -f udev-lfs-197-2/Makefile.lfs install
build/udevadm hwdb --update
sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-197-2/init-net-rules.sh
bash udev-lfs-197-2/init-net-rules.sh
sed -i "s/\"00:0c:29:[^\".]*\"/\"00:0c:29:*:*:*\"/" /etc/udev/rules.d/70-persistent-net.rules 
}

Vim_7_3_C6(){

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr --enable-multibyte
make
make install
ln -sfv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sfv vim.1 $(dirname $L)/vi.1
done
ln -sfv ../vim/vim73/doc /usr/share/doc/vim-7.3
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

/tools/bin/find /{,usr/}{bin,lib,sbin} -type f \
  -exec /tools/bin/strip --strip-debug '{}' ';'
}

Cleaning_Up_C6(){

chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login
}

export C6_InstallingBasicSystemSoftware="Introduction_C6 Preparing_Virtual_Kernel_File_Systems_C6 Package_Management_C6 Entering_the_Chroot_Environment_C6 Creating_Directories_C6 Creating_Essential_Files_and_Symlinks_C6 Linux_3_8_1_API_Headers_C6 Man_pages_3_47_C6 Glibc_2_17_C6 Adjusting_the_Toolchain_C6 Zlib_1_2_7_C6 File_5_13_C6 Binutils_2_23_1_C6 GMP_5_1_1_C6 MPFR_3_1_1_C6 MPC_1_0_1_C6 GCC_4_7_2_C6 Sed_4_2_2_C6 Bzip2_1_0_6_C6 Pkg_config_0_28_C6 Ncurses_5_9_C6 Util_linux_2_22_2_C6 Psmisc_22_20_C6 Procps_ng_3_3_6_C6 E2fsprogs_1_42_7_C6 Shadow_4_1_5_1_C6 Coreutils_8_21_C6 Iana_Etc_2_30_C6 M4_1_4_16_C6 Bison_2_7_C6 Grep_2_14_C6 Readline_6_2_C6 Bash_4_2_C6 Libtool_2_4_2_C6 GDBM_1_10_C6 Inetutils_1_9_1_C6 Perl_5_16_2_C6 Autoconf_2_69_C6 Automake_1_13_1_C6 Diffutils_3_2_C6 Gawk_4_0_2_C6 Findutils_4_4_2_C6 Flex_2_5_37_C6 Gettext_0_18_2_C6 Groff_1_22_2_C6 Xz_5_0_4_C6 GRUB_2_00_C6 Less_451_C6 Gzip_1_5_C6 IPRoute2_3_8_0_C6 Kbd_1_15_5_C6 Kmod_12_C6 Libpipeline_1_2_2_C6 Make_3_82_C6 Man_DB_2_6_3_C6 Patch_2_7_1_C6 Sysklogd_1_5_C6 Sysvinit_2_88dsf_C6 Tar_1_26_C6 Texinfo_5_0_C6 Udev_197_Extracted_from_systemd_197__C6 Vim_7_3_C6 About_Debugging_Symbols_C6 Stripping_Again_C6 Cleaning_Up_C6 "


General_Network_Configuration_C7(){

cat /etc/udev/rules.d/70-persistent-net.rules
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.122.12
GATEWAY=192.168.122.2
PREFIX=24
BROADCAST=192.168.122.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain ibm.com
nameserver 192.168.122.1
nameserver 192.168.122.2

# End /etc/resolv.conf
EOF

}

Customizing_the_etc_hosts_File_C7(){

cat > /etc/hosts << "EOF"
# Begin /etc/hosts (network card version)


# End /etc/hosts (network card version)
EOF

cat > /etc/hosts << "EOF"
# Begin /etc/hosts (no network card version)

127.0.0.1 ALFS localhost
192.168.122.12	ALFS

# End /etc/hosts (no network card version)
EOF

}

Creating_Custom_Symlinks_to_Devices_C7(){

udevadm test /sys/block/hdd
sed -i -e 's/"write_cd_rules"/"write_cd_rules mode"/' \
    /etc/udev/rules.d/83-cdrom-symlinks.rules

udevadm info -a -p /sys/class/video4linux/video0
cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", \
    SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f", ATTRS{vendor}=="0x109e", \
    SYMLINK+="tvtuner"

EOF

}

LFS_Bootscripts_20130123_C7(){

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

echo "HOSTNAME=ALFS" > /etc/sysconfig/network

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

export C7_SettingUpSystemBootscripts="Introduction_C7 General_Network_Configuration_C7 Customizing_the_etc_hosts_File_C7 Device_and_Module_Handling_on_an_LFS_System_C7 Creating_Custom_Symlinks_to_Devices_C7 LFS_Bootscripts_20130123_C7 How_Do_These_Bootscripts_Work__C7 Configuring_the_system_hostname_C7 Configuring_the_setclock_Script_C7 Configuring_the_Linux_Console_C7 Configuring_the_sysklogd_Script_C7 The_rc_site_File_C7 The_Bash_Shell_Startup_Files_C7 Creating_the_etc_inputrc_File_C7 "


Creating_the_etc_fstab_File_C8(){

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/vda1     /            ext3    defaults            1     1
/dev/vda2     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF

}

Linux_3_8_1_C8(){

make mrproper
make LANG=en_US LC_ALL= menuconfig

make
make modules_install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-3.8.1-lfs-7.3
cp -v System.map /boot/System.map-3.8.1
cp -v .config /boot/config-3.8.1
install -d /usr/share/doc/linux-3.8.1
cp -r Documentation/* /usr/share/doc/linux-3.8.1
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

}

Using_GRUB_to_Set_Up_the_Boot_Process_C8(){

cd /boot/
mkinitramfs 3.8.1
mv -v initrd.img-3.8.1 initrd-3.8.1-lfs-7.3
grub-mkconfig -o grub/grub.cfg
sed -i 's/mapper\/loop0p1/vda1/' grub/grub.cfg


}

export C8_MakingtheLFSSystemBootable="Introduction_C8 Creating_the_etc_fstab_File_C8 Linux_3_8_1_C8 Using_GRUB_to_Set_Up_the_Boot_Process_C8 "


The_End_C9(){

echo 7.3 > /etc/lfs-release
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="7.3"
DISTRIB_CODENAME="<your name here>"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF
}

Rebooting_the_System_C9(){

umount -v $LFS/dev/pts

if [ -h $LFS/dev/shm ]; then
  link=$(readlink $LFS/dev/shm)
  umount -v $LFS/$link
  unset link
else
  umount -v $LFS/dev/shm
fi

umount -v $LFS/dev
umount -v $LFS/proc
umount -v $LFS/sys
umount -v $LFS
umount -v $LFS/usr
umount -v $LFS/home
umount -v $LFS
}

export C9_TheEnd="The_End_C9 Get_Counted_C9 Rebooting_the_System_C9 What_Now__C9 "


export LFSCHAPTERS="C0_Preface C1_Introduction C2_PreparingaNewPartition C3_PackagesandPatches C4_FinalPreparations C5_ConstructingaTemporarySystem C6_InstallingBasicSystemSoftware C7_SettingUpSystemBootscripts C8_MakingtheLFSSystemBootable C9_TheEnd "
BLFS_Boot_Scripts_C2(){
: 
} 

export C0_Preface="Foreword_C0 Who_Would_Want_to_Read_this_Book_C0 Organization_C0 "



export C1_WelcometoBLFS="Which_Sections_of_the_Book_Do_I_Want__C1 Conventions_Used_in_this_Book_C1 Book_Version_C1 Mirror_Sites_C1 Getting_the_Source_Packages_C1 Change_Log_C1 Mailing_Lists_C1 BLFS_Wiki_C1 Asking_for_Help_and_the_FAQ_C1 Credits_C1 Contact_Information_C1 "



export BLFS_Boot_Scripts_C2_download="http://www.linuxfromscratch.org/blfs/downloads/svn/blfs-bootscripts-20130324.tar.bz2 "

export BLFS_Boot_Scripts_C2_packname="blfs-bootscripts-20130324.tar.bz2"

Locale_Related_Issues_C2(){

find /usr/share/man -type f | xargs checkman.sh
}

export C2_ImportantInformation="Notes_on_Building_Software_C2 The_usr_Versus_usr_local_Debate_C2 Optional_Patches_C2 BLFS_Boot_Scripts_C2 Libraries_Static_or_shared__C2 Locale_Related_Issues_C2 Going_Beyond_BLFS_C2 "


Configuring_for_Adding_Users_C3(){

useradd -m mao

}

About_Devices_C3(){

mount --bind / /mnt
cp -a /dev/* /mnt/dev
rm /etc/rc.d/rcS.d/{S10udev,S50udev_retry}
umount /mnt
}

The_Bash_Shell_Startup_Files_C3(){

cat > /etc/profile << "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# modifications by Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}


# Set the initial path
export PATH=/bin:/usr/bin

if [ $EUID -eq 0 ] ; then
        pathappend /sbin:/usr/sbin
        unset HISTFILE
fi

# Setup some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

# Now to clean up
unset pathremove pathprepend pathappend

# End /etc/profile
EOF

install --directory --mode=0755 --owner=root --group=root /etc/profile.d
cat > /etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls to support color, the alias is in /etc/bashrc.
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)

        if [ -f "$HOME/.dircolors" ] ; then
                eval $(dircolors -b $HOME/.dircolors)
        fi
fi
alias ls='ls --color=auto'
EOF

cat > /etc/profile.d/extrapaths.sh << "EOF"
if [ -d /usr/local/lib/pkgconfig ] ; then
        pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
fi
if [ -d /usr/local/bin ]; then
        pathprepend /usr/local/bin
fi
if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
        pathprepend /usr/local/sbin
fi

if [ -d ~/bin ]; then
        pathprepend ~/bin
fi
#if [ $EUID -gt 99 ]; then
#        pathappend .
#fi
EOF

cat > /etc/profile.d/readline.sh << "EOF"
# Setup the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC
EOF

cat > /etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi
EOF

cat > /etc/profile.d/i18n.sh << "EOF"
# Set up i18n variables
export LANG=en_US.utf8
EOF

cat > /etc/bashrc << "EOF"
# Begin /etc/bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# System wide aliases and functions.

# System wide environment variables and startup programs should go into
# /etc/profile.  Personal environment variables and startup programs
# should go into ~/.bash_profile.  Personal aliases and functions should
# go into ~/.bashrc

# Provides a colored /bin/ls command.  Used in conjunction with code in
# /etc/profile.

alias ls='ls --color=auto'

# Provides prompt for non-login shells, specifically shells started
# in the X environment. [Review the LFS archive thread titled
# PS1 Environment Variable for a great case study behind this script
# addendum.]

NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

# End /etc/bashrc
EOF

cat > ~/.bash_profile << "EOF"
. ~/.bashrc
# Begin ~/.bash_profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

append () {
  # First remove the directory
  local IFS=':'
  local NEWPATH
  for DIR in $PATH; do
     if [ "$DIR" != "$1" ]; then
       NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
     fi
  done

  # Then append the directory
  export PATH=$NEWPATH:$1
}

if [ -f "$HOME/.bashrc" ] ; then
  source $HOME/.bashrc
fi

if [ -d "$HOME/bin" ] ; then
  append $HOME/bin
fi

unset append

# End ~/.bash_profile
EOF

cat > ~/.bashrc << "EOF"
# Begin ~/.bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal aliases and functions.

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.

if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi

# End ~/.bashrc
EOF

cat > ~/.bash_logout << "EOF"
# Begin ~/.bash_logout
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal items to perform on logout.

# End ~/.bash_logout
EOF

dircolors -p > /etc/dircolors
}

The_etc_shells_File_C3(){

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

}

Random_Number_Generation_C3(){

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-random
}

Compressing_Man_and_Info_Pages_C3(){

cat > /usr/sbin/compressdoc << "EOF"
#!/bin/bash
# VERSION: 20080421.1623
#
# Compress (with bzip2 or gzip) all man pages in a hierarchy and
# update symlinks - By Marc Heerdink <marc @ koelkast.net>
#
# Modified to be able to gzip or bzip2 files as an option and to deal
# with all symlinks properly by Mark Hymers <markh @ linuxfromscratch.org>
#
# Modified 20030930 by Yann E. Morin <yann.morin.1998 @ anciens.enib.fr>
# to accept compression/decompression, to correctly handle hard-links,
# to allow for changing hard-links into soft- ones, to specify the
# compression level, to parse the man.conf for all occurrences of MANPATH,
# to allow for a backup, to allow to keep the newest version of a page.
#
# Modified 20040330 by Tushar Teredesai to replace $0 by the name of the
# script.
#   (Note: It is assumed that the script is in the user's PATH)
#
# Modified 20050112 by Randy McMurchy to shorten line lengths and
# correct grammar errors.
#
# Modified 20060128 by Alexander E. Patrakov for compatibility with Man-DB.
#
# Modified 20060311 by Archaic to use Man-DB manpath utility which is a
# replacement for man --path from Man.
#
# Modified 20080421 by Dan Nicholson to properly execute the correct
# compressdoc when working recursively. This means the same compressdoc
# will be used whether a full path was given or it was resolved from PATH.
#
# Modified 20080421 by Dan Nicholson to be more robust with directories
# that don't exist or don't have sufficient permissions.
#
# Modified 20080421 by Lars Bamberger to (sort of) automatically choose
# a compression method based on the size of the manpage. A couple bug
# fixes were added by Dan Nicholson.
#
# Modified 20080421 by Dan Nicholson to suppress warnings from manpath
# since these are emitted when $MANPATH is set. Removed the TODO for
# using the $MANPATH variable since manpath(1) handles this already.
#
# TODO:
#     - choose a default compress method to be based on the available
#       tool : gzip or bzip2;
#     - offer an option to restore a previous backup;
#     - add other compression engines (compress, zip, etc?). Needed?

# Funny enough, this function prints some help.
function help ()
{
  if [ -n "$1" ]; then
    echo "Unknown option : $1"
  fi
  ( echo "Usage: $MY_NAME <comp_method> [options] [dirs]" && \
  cat << EOT
Where comp_method is one of :
  --gzip, --gz, -g
  --bzip2, --bz2, -b
                Compress using gzip or bzip2.
  --automatic
                Compress using either gzip or bzip2, depending on the
                size of the file to be compressed. Files larger than 5
                kB are bzipped, files larger than 1 kB are gzipped and
                files smaller than 1 kB are not compressed.

  --decompress, -d
                Decompress the man pages.

  --backup      Specify a .tar backup shall be done for all directories.
                In case a backup already exists, it is saved as .tar.old
                prior to making the new backup. If a .tar.old backup
                exists, it is removed prior to saving the backup.
                In backup mode, no other action is performed.

And where options are :
  -1 to -9, --fast, --best
                The compression level, as accepted by gzip and bzip2.
                When not specified, uses the default compression level
                for the given method (-6 for gzip, and -9 for bzip2).
                Not used when in backup or decompress modes.

  --force, -F   Force (re-)compression, even if the previous one was
                the same method. Useful when changing the compression
                ratio. By default, a page will not be re-compressed if
                it ends with the same suffix as the method adds
                (.bz2 for bzip2, .gz for gzip).

  --soft, -S    Change hard-links into soft-links. Use with _caution_
                as the first encountered file will be used as a
                reference. Not used when in backup mode.

  --hard, -H    Change soft-links into hard-links. Not used when in
                backup mode.

  --conf=dir, --conf dir
                Specify the location of man_db.conf. Defaults to /etc.

  --verbose, -v Verbose mode, print the name of the directory being
                processed. Double the flag to turn it even more verbose,
                and to print the name of the file being processed.

  --fake, -f    Fakes it. Print the actual parameters compressdoc will use.

  dirs          A list of space-separated _absolute_ pathnames to the
                man directories. When empty, and only then, use manpath
                to parse ${MAN_CONF}/man_db.conf for all valid occurrences
                of MANDATORY_MANPATH.

Note about compression:
  There has been a discussion on blfs-support about compression ratios of
  both gzip and bzip2 on man pages, taking into account the hosting fs,
  the architecture, etc... On the overall, the conclusion was that gzip
  was much more efficient on 'small' files, and bzip2 on 'big' files,
  small and big being very dependent on the content of the files.

  See the original post from Mickael A. Peters, titled
  "Bootable Utility CD", dated 20030409.1816(+0200), and subsequent posts:
  http://linuxfromscratch.org/pipermail/blfs-support/2003-April/038817.html

  On my system (x86, ext3), man pages were 35564KB before compression.
  gzip -9 compressed them down to 20372KB (57.28%), bzip2 -9 got down to
  19812KB (55.71%). That is a 1.57% gain in space. YMMV.

  What was not taken into consideration was the decompression speed. But
  does it make sense to? You gain fast access with uncompressed man
  pages, or you gain space at the expense of a slight overhead in time.
  Well, my P4-2.5GHz does not even let me notice this... :-)

EOT
) | less
}

# This function checks that the man page is unique amongst bzip2'd,
# gzip'd and uncompressed versions.
#  $1 the directory in which the file resides
#  $2 the file name for the man page
# Returns 0 (true) if the file is the latest and must be taken care of,
# and 1 (false) if the file is not the latest (and has therefore been
# deleted).
function check_unique ()
{
  # NB. When there are hard-links to this file, these are
  # _not_ deleted. In fact, if there are hard-links, they
  # all have the same date/time, thus making them ready
  # for deletion later on.

  # Build the list of all man pages with the same name
  DIR=$1
  BASENAME=`basename "${2}" .bz2`
  BASENAME=`basename "${BASENAME}" .gz`
  GZ_FILE="$BASENAME".gz
  BZ_FILE="$BASENAME".bz2

  # Look for, and keep, the most recent one
  LATEST=`(cd "$DIR"; ls -1rt "${BASENAME}" "${GZ_FILE}" "${BZ_FILE}" \
         2>/dev/null | tail -n 1)`
  for i in "${BASENAME}" "${GZ_FILE}" "${BZ_FILE}"; do
    [ "$LATEST" != "$i" ] && rm -f "$DIR"/"$i"
  done

  # In case the specified file was the latest, return 0
  [ "$LATEST" = "$2" ] && return 0
  # If the file was not the latest, return 1
  return 1
}

# Name of the script
MY_NAME=`basename $0`

# OK, parse the command-line for arguments, and initialize to some
# sensible state, that is: don't change links state, parse
# /etc/man_db.conf, be most silent, search man_db.conf in /etc, and don't
# force (re-)compression.
COMP_METHOD=
COMP_SUF=
COMP_LVL=
FORCE_OPT=
LN_OPT=
MAN_DIR=
VERBOSE_LVL=0
BACKUP=no
FAKE=no
MAN_CONF=/etc
while [ -n "$1" ]; do
  case $1 in
    --gzip|--gz|-g)
      COMP_SUF=.gz
      COMP_METHOD=$1
      shift
      ;;
    --bzip2|--bz2|-b)
      COMP_SUF=.bz2
      COMP_METHOD=$1
      shift
      ;;
    --automatic)
      COMP_SUF=TBD
      COMP_METHOD=$1
      shift
      ;;
    --decompress|-d)
      COMP_SUF=
      COMP_LVL=
      COMP_METHOD=$1
      shift
      ;;
    -[1-9]|--fast|--best)
      COMP_LVL=$1
      shift
      ;;
    --force|-F)
      FORCE_OPT=-F
      shift
      ;;
    --soft|-S)
      LN_OPT=-S
      shift
      ;;
    --hard|-H)
      LN_OPT=-H
      shift
      ;;
    --conf=*)
      MAN_CONF=`echo $1 | cut -d '=' -f2-`
      shift
      ;;
    --conf)
      MAN_CONF="$2"
      shift 2
      ;;
    --verbose|-v)
      let VERBOSE_LVL++
      shift
      ;;
    --backup)
      BACKUP=yes
      shift
      ;;
    --fake|-f)
      FAKE=yes
      shift
      ;;
    --help|-h)
      help
      exit 0
      ;;
    /*)
      MAN_DIR="${MAN_DIR} ${1}"
      shift
      ;;
    -*)
      help $1
      exit 1
      ;;
    *)
      echo "\"$1\" is not an absolute path name"
      exit 1
      ;;
  esac
done

# Redirections
case $VERBOSE_LVL in
  0)
     # O, be silent
     DEST_FD0=/dev/null
     DEST_FD1=/dev/null
     VERBOSE_OPT=
     ;;
  1)
     # 1, be a bit verbose
     DEST_FD0=/dev/stdout
     DEST_FD1=/dev/null
     VERBOSE_OPT=-v
     ;;
  *)
     # 2 and above, be most verbose
     DEST_FD0=/dev/stdout
     DEST_FD1=/dev/stdout
     VERBOSE_OPT="-v -v"
     ;;
esac

# Note: on my machine, 'man --path' gives /usr/share/man twice, once
# with a trailing '/', once without.
if [ -z "$MAN_DIR" ]; then
  MAN_DIR=`manpath -q -C "$MAN_CONF"/man_db.conf \
            | sed 's/:/\\n/g' \
            | while read foo; do dirname "$foo"/.; done \
            | sort -u \
            | while read bar; do echo -n "$bar "; done`
fi

# If no MANDATORY_MANPATH in ${MAN_CONF}/man_db.conf, abort as well
if [ -z "$MAN_DIR" ]; then
  echo "No directory specified, and no directory found with \`manpath'"
  exit 1
fi

# Check that the specified directories actually exist and are readable
for DIR in $MAN_DIR; do
  if [ ! -d "$DIR" -o ! -r "$DIR" ]; then
    echo "Directory '$DIR' does not exist or is not readable"
    exit 1
  fi
done

# Fake?
if [ "$FAKE" != "no" ]; then
  echo "Actual parameters used:"
  echo -n "Compression.......: "
  case $COMP_METHOD in
    --bzip2|--bz2|-b) echo -n "bzip2";;
    --gzip|--gz|-g) echo -n "gzip";;
    --automatic) echo -n "compressing";;
    --decompress|-d) echo -n "decompressing";;
    *) echo -n "unknown";;
  esac
  echo " ($COMP_METHOD)"
  echo "Compression level.: $COMP_LVL"
  echo "Compression suffix: $COMP_SUF"
  echo -n "Force compression.: "
  [ "foo$FORCE_OPT" = "foo-F" ] && echo "yes" || echo "no"
  echo "man_db.conf is....: ${MAN_CONF}/man_db.conf"
  echo -n "Hard-links........: "
  [ "foo$LN_OPT" = "foo-S" ] &&
  echo "convert to soft-links" || echo "leave as is"
  echo -n "Soft-links........: "
  [ "foo$LN_OPT" = "foo-H" ] &&
  echo "convert to hard-links" || echo "leave as is"
  echo "Backup............: $BACKUP"
  echo "Faking (yes!).....: $FAKE"
  echo "Directories.......: $MAN_DIR"
  echo "Verbosity level...: $VERBOSE_LVL"
  exit 0
fi

# If no method was specified, print help
if [ -z "${COMP_METHOD}" -a "${BACKUP}" = "no" ]; then
  help
  exit 1
fi

# In backup mode, do the backup solely
if [ "$BACKUP" = "yes" ]; then
  for DIR in $MAN_DIR; do
    cd "${DIR}/.."
    if [ ! -w "`pwd`" ]; then
      echo "Directory '`pwd`' is not writable"
      exit 1
    fi
    DIR_NAME=`basename "${DIR}"`
    echo "Backing up $DIR..." > $DEST_FD0
    [ -f "${DIR_NAME}.tar.old" ] && rm -f "${DIR_NAME}.tar.old"
    [ -f "${DIR_NAME}.tar" ] &&
    mv "${DIR_NAME}.tar" "${DIR_NAME}.tar.old"
    tar -cvf "${DIR_NAME}.tar" "${DIR_NAME}" > $DEST_FD1
  done
  exit 0
fi

# I know MAN_DIR has only absolute path names
# I need to take into account the localized man, so I'm going recursive
for DIR in $MAN_DIR; do
  MEM_DIR=`pwd`
  if [ ! -w "$DIR" ]; then
    echo "Directory '$DIR' is not writable"
    exit 1
  fi
  cd "$DIR"
  for FILE in *; do
    # Fixes the case were the directory is empty
    if [ "foo$FILE" = "foo*" ]; then continue; fi

    # Fixes the case when hard-links see their compression scheme change
    # (from not compressed to compressed, or from bz2 to gz, or from gz
    # to bz2)
    # Also fixes the case when multiple version of the page are present,
    # which are either compressed or not.
    if [ ! -L "$FILE" -a ! -e "$FILE" ]; then continue; fi

    # Do not compress whatis files
    if [ "$FILE" = "whatis" ]; then continue; fi

    if [ -d "$FILE" ]; then
      # We are going recursive to that directory
      echo "-> Entering ${DIR}/${FILE}..." > $DEST_FD0
      # I need not pass --conf, as I specify the directory to work on
      # But I need exit in case of error. We must change back to the
      # original directory so $0 is resolved correctly.
      (cd "$MEM_DIR" && eval "$0" ${COMP_METHOD} ${COMP_LVL} ${LN_OPT} \
        ${VERBOSE_OPT} ${FORCE_OPT} "${DIR}/${FILE}") || exit $?
      echo "<- Leaving ${DIR}/${FILE}." > $DEST_FD1

    else # !dir
      if ! check_unique "$DIR" "$FILE"; then continue; fi

      # With automatic compression, get the uncompressed file size of
      # the file (dereferencing symlinks), and choose an appropriate
      # compression method.
      if [ "$COMP_METHOD" = "--automatic" ]; then
        declare -i SIZE
        case "$FILE" in
          *.bz2)
            SIZE=$(bzcat "$FILE" | wc -c) ;;
          *.gz)
            SIZE=$(zcat "$FILE" | wc -c) ;;
          *)
            SIZE=$(wc -c < "$FILE") ;;
        esac
        if (( $SIZE >= (5 * 2**10) )); then
          COMP_SUF=.bz2
        elif (( $SIZE >= (1 * 2**10) )); then
          COMP_SUF=.gz
        else
          COMP_SUF=
        fi
      fi

      # Check if the file is already compressed with the specified method
      BASE_FILE=`basename "$FILE" .gz`
      BASE_FILE=`basename "$BASE_FILE" .bz2`
      if [ "${FILE}" = "${BASE_FILE}${COMP_SUF}" \
         -a "foo${FORCE_OPT}" = "foo" ]; then continue; fi

      # If we have a symlink
      if [ -h "$FILE" ]; then
        case "$FILE" in
          *.bz2)
            EXT=bz2 ;;
          *.gz)
            EXT=gz ;;
          *)
            EXT=none ;;
        esac

        if [ ! "$EXT" = "none" ]; then
          LINK=`ls -l "$FILE" | cut -d ">" -f2 \
               | tr -d " " | sed s/\.$EXT$//`
          NEWNAME=`echo "$FILE" | sed s/\.$EXT$//`
          mv "$FILE" "$NEWNAME"
          FILE="$NEWNAME"
        else
          LINK=`ls -l "$FILE" | cut -d ">" -f2 | tr -d " "`
        fi

        if [ "$LN_OPT" = "-H" ]; then
          # Change this soft-link into a hard- one
          rm -f "$FILE" && ln "${LINK}$COMP_SUF" "${FILE}$COMP_SUF"
          chmod --reference "${LINK}$COMP_SUF" "${FILE}$COMP_SUF"
        else
          # Keep this soft-link a soft- one.
          rm -f "$FILE" && ln -s "${LINK}$COMP_SUF" "${FILE}$COMP_SUF"
        fi
        echo "Relinked $FILE" > $DEST_FD1

      # else if we have a plain file
      elif [ -f "$FILE" ]; then
        # Take care of hard-links: build the list of files hard-linked
        # to the one we are {de,}compressing.
        # NB. This is not optimum has the file will eventually be
        # compressed as many times it has hard-links. But for now,
        # that's the safe way.
        inode=`ls -li "$FILE" | awk '{print $1}'`
        HLINKS=`find . \! -name "$FILE" -inum $inode`

        if [ -n "$HLINKS" ]; then
          # We have hard-links! Remove them now.
          for i in $HLINKS; do rm -f "$i"; done
        fi

        # Now take care of the file that has no hard-link
        # We do decompress first to re-compress with the selected
        # compression ratio later on...
        case "$FILE" in
          *.bz2)
            bunzip2 $FILE
            FILE=`basename "$FILE" .bz2`
          ;;
          *.gz)
            gunzip $FILE
            FILE=`basename "$FILE" .gz`
          ;;
        esac

        # Compress the file with the given compression ratio, if needed
        case $COMP_SUF in
          *bz2)
            bzip2 ${COMP_LVL} "$FILE" && chmod 644 "${FILE}${COMP_SUF}"
            echo "Compressed $FILE" > $DEST_FD1
            ;;
          *gz)
            gzip ${COMP_LVL} "$FILE" && chmod 644 "${FILE}${COMP_SUF}"
            echo "Compressed $FILE" > $DEST_FD1
            ;;
          *)
            echo "Uncompressed $FILE" > $DEST_FD1
            ;;
        esac

        # If the file had hard-links, recreate those (either hard or soft)
        if [ -n "$HLINKS" ]; then
          for i in $HLINKS; do
            NEWFILE=`echo "$i" | sed s/\.gz$// | sed s/\.bz2$//`
            if [ "$LN_OPT" = "-S" ]; then
              # Make this hard-link a soft- one
              ln -s "${FILE}$COMP_SUF" "${NEWFILE}$COMP_SUF"
            else
              # Keep the hard-link a hard- one
              ln "${FILE}$COMP_SUF" "${NEWFILE}$COMP_SUF"
            fi
            # Really work only for hard-links. Harmless for soft-links
            chmod 644 "${NEWFILE}$COMP_SUF"
          done
        fi

      else
        # There is a problem when we get neither a symlink nor a plain
        # file. Obviously, we shall never ever come here... :-(
        echo -n "Whaooo... \"${DIR}/${FILE}\" is neither a symlink "
        echo "nor a plain file. Please check:"
        ls -l "${DIR}/${FILE}"
        exit 1
      fi
    fi
  done # for FILE
done # for DIR

EOF

chmod -v 755 /usr/sbin/compressdoc
}

lsb_release_1_4_C3(){

./help2man -N --include ./lsb_release.examples \
              --alt_version_key=program_version ./lsb_release > lsb_release.1
install -v -m 644 lsb_release.1 /usr/share/man/man1/lsb_release.1 &&
install -v -m 755 lsb_release /usr/bin/lsb_release
}

export lsb_release_1_4_C3_download="http://sourceforge.net/projects/lsb/files/lsb_release/1.4/lsb-release-1.4.tar.gz "

export lsb_release_1_4_C3_packname="lsb-release-1.4.tar.gz"

export C3_AfterLFSConfigurationIssues="Creating_a_Custom_Boot_Device_C3 Configuring_for_Adding_Users_C3 About_System_Users_and_Groups_C3 About_Devices_C3 The_Bash_Shell_Startup_Files_C3 The_etc_vimrc_and_vimrc_Files_C3 Customizing_your_Logon_with_etc_issue_C3 The_etc_shells_File_C3 Random_Number_Generation_C3 Compressing_Man_and_Info_Pages_C3 lsb_release_1_4_C3 "


acl_2_2_51_C4(){

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' \
     include/builddefs.in &&

INSTALL_USER=root  \
INSTALL_GROUP=root \
./configure --prefix=/usr --libdir=/lib --libexecdir=/usr/lib &&
make
make install install-dev install-lib                           &&
chmod -v 0755 /lib/libacl.so.1.1.0                             &&
rm -v /lib/libacl.{a,la,so}                                    &&
ln -sfv ../../lib/libacl.so.1 /usr/lib/libacl.so               &&
sed -i "s|libdir='/lib'|libdir='/usr/lib'|" /usr/lib/libacl.la &&
install -v -m644 doc/*.txt /usr/share/doc/acl-2.2.51
}

export acl_2_2_51_C4_download="http://download.savannah.gnu.org/releases/acl/acl-2.2.51.src.tar.gz "

export acl_2_2_51_C4_packname="acl-2.2.51.src.tar.gz"

export acl_2_2_51_C4_required_or_recommended="attr_2_4_46_C4 "

attr_2_4_46_C4(){

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in &&

INSTALL_USER=root  \
INSTALL_GROUP=root \
./configure --prefix=/usr --libdir=/lib --libexecdir=/usr/lib &&
make
make install install-dev install-lib &&
chmod -v 0755 /lib/libattr.so.1.1.0           &&
rm -v /lib/libattr.{a,la,so}                  &&
sed -i 's@/lib@/usr/lib@' /usr/lib/libattr.la &&
ln -sfv ../../lib/libattr.so.1 /usr/lib/libattr.so
}

export attr_2_4_46_C4_download="http://download.savannah.gnu.org/releases/attr/attr-2.4.46.src.tar.gz "

export attr_2_4_46_C4_packname="attr-2.4.46.src.tar.gz"

Certificate_Authority_Certificates_C4(){

cat > /bin/make-cert.pl << "EOF"
#!/usr/bin/perl -w

# Used to generate PEM encoded files from Mozilla certdata.txt.
# Run as ./mkcrt.pl > certificate.crt
#
# Parts of this script courtesy of RedHat (mkcabundle.pl)
#
# This script modified for use with single file data (tempfile.cer) extracted
# from certdata.txt, taken from the latest version in the Mozilla NSS source.
# mozilla/security/nss/lib/ckfw/builtins/certdata.txt
#
# Authors: DJ Lucas
#          Bruce Dubbs
#
# Version 20120211

my $certdata = './tempfile.cer';

open( IN, "cat $certdata|" )
    || die "could not open $certdata";

my $incert = 0;

while ( <IN> )
{
    if ( /^CKA_VALUE MULTILINE_OCTAL/ )
    {
        $incert = 1;
        open( OUT, "|openssl x509 -text -inform DER -fingerprint" )
            || die "could not pipe to openssl x509";
    }

    elsif ( /^END/ && $incert )
    {
        close( OUT );
        $incert = 0;
        print "\n\n";
    }

    elsif ($incert)
    {
        my @bs = split( /\\/ );
        foreach my $b (@bs)
        {
            chomp $b;
            printf( OUT "%c", oct($b) ) unless $b eq '';
        }
    }
}
EOF

chmod +x /bin/make-cert.pl
cat > /bin/make-ca.sh << "EOF"
#!/bin/bash
# Begin make-ca.sh
# Script to populate OpenSSL's CApath from a bundle of PEM formatted CAs
#
# The file certdata.txt must exist in the local directory
# Version number is obtained from the version of the data.
#
# Authors: DJ Lucas
#          Bruce Dubbs
#
# Version 20120211

certdata="certdata.txt"

if [ ! -r $certdata ]; then
  echo "$certdata must be in the local directory"
  exit 1
fi

REVISION=$(grep CVS_ID $certdata | cut -f4 -d'$')

if [ -z "${REVISION}" ]; then
  echo "$certfile has no 'Revision' in CVS_ID"
  exit 1
fi

VERSION=$(echo $REVISION | cut -f2 -d" ")

TEMPDIR=$(mktemp -d)
TRUSTATTRIBUTES="CKA_TRUST_SERVER_AUTH"
BUNDLE="BLFS-ca-bundle-${VERSION}.crt"
CONVERTSCRIPT="/bin/make-cert.pl"
SSLDIR="/etc/ssl"

mkdir "${TEMPDIR}/certs"

# Get a list of staring lines for each cert
CERTBEGINLIST=$(grep -n "^# Certificate" "${certdata}" | cut -d ":" -f1)

# Get a list of ending lines for each cert
CERTENDLIST=`grep -n "^CKA_TRUST_STEP_UP_APPROVED" "${certdata}" | cut -d ":" -f 1`

# Start a loop
for certbegin in ${CERTBEGINLIST}; do
  for certend in ${CERTENDLIST}; do
    if test "${certend}" -gt "${certbegin}"; then
      break
    fi
  done

  # Dump to a temp file with the name of the file as the beginning line number
  sed -n "${certbegin},${certend}p" "${certdata}" > "${TEMPDIR}/certs/${certbegin}.tmp"
done

unset CERTBEGINLIST CERTDATA CERTENDLIST certebegin certend

mkdir -p certs
rm certs/*      # Make sure the directory is clean

for tempfile in ${TEMPDIR}/certs/*.tmp; do
  # Make sure that the cert is trusted...
  grep "CKA_TRUST_SERVER_AUTH" "${tempfile}" | \
    egrep "TRUST_UNKNOWN|NOT_TRUSTED" > /dev/null

  if test "${?}" = "0"; then
    # Throw a meaningful error and remove the file
    cp "${tempfile}" tempfile.cer
    perl ${CONVERTSCRIPT} > tempfile.crt
    keyhash=$(openssl x509 -noout -in tempfile.crt -hash)
    echo "Certificate ${keyhash} is not trusted!  Removing..."
    rm -f tempfile.cer tempfile.crt "${tempfile}"
    continue
  fi

  # If execution made it to here in the loop, the temp cert is trusted
  # Find the cert data and generate a cert file for it

  cp "${tempfile}" tempfile.cer
  perl ${CONVERTSCRIPT} > tempfile.crt
  keyhash=$(openssl x509 -noout -in tempfile.crt -hash)
  mv tempfile.crt "certs/${keyhash}.pem"
  rm -f tempfile.cer "${tempfile}"
  echo "Created ${keyhash}.pem"
done

# Remove blacklisted files
# MD5 Collision Proof of Concept CA
if test -f certs/8f111d69.pem; then
  echo "Certificate 8f111d69 is not trusted!  Removing..."
  rm -f certs/8f111d69.pem
fi

# Finally, generate the bundle and clean up.
cat certs/*.pem >  ${BUNDLE}
rm -r "${TEMPDIR}"
EOF

chmod +x /bin/make-ca.sh
cat > /bin/remove-expired-certs.sh << "EOF"
#!/bin/bash
# Begin /bin/remove-expired-certs.sh
#
# Version 20120211

# Make sure the date is parsed correctly on all systems
function mydate()
{
  local y=$( echo $1 | cut -d" " -f4 )
  local M=$( echo $1 | cut -d" " -f1 )
  local d=$( echo $1 | cut -d" " -f2 )
  local m

  if [ ${d} -lt 10 ]; then d="0${d}"; fi

  case $M in
    Jan) m="01";;
    Feb) m="02";;
    Mar) m="03";;
    Apr) m="04";;
    May) m="05";;
    Jun) m="06";;
    Jul) m="07";;
    Aug) m="08";;
    Sep) m="09";;
    Oct) m="10";;
    Nov) m="11";;
    Dec) m="12";;
  esac

  certdate="${y}${m}${d}"
}

OPENSSL=/usr/bin/openssl
DIR=/etc/ssl/certs

if [ $# -gt 0 ]; then
  DIR="$1"
fi

certs=$( find ${DIR} -type f -name "*.pem" -o -name "*.crt" )
today=$( date +%Y%m%d )

for cert in $certs; do
  notafter=$( $OPENSSL x509 -enddate -in "${cert}" -noout )
  date=$( echo ${notafter} |  sed 's/^notAfter=//' )
  mydate "$date"

  if [ ${certdate} -lt ${today} ]; then
     echo "${cert} expired on ${certdate}! Removing..."
     rm -f "${cert}"
  fi
done
EOF

chmod +x /bin/remove-expired-certs.sh
certhost='http://mxr.mozilla.org'                        &&
certdir='/mozilla/source/security/nss/lib/ckfw/builtins' &&
url="$certhost$certdir/certdata.txt?raw=1"               &&

wget --output-document certdata.txt $url &&
unset certhost certdir url               &&
make-ca.sh                               &&
remove-expired-certs.sh certs
SSLDIR=/etc/ssl                                     &&
install -d ${SSLDIR}/certs                          &&
cp -v certs/*.pem ${SSLDIR}/certs                   &&
c_rehash                                            &&
install BLFS-ca-bundle*.crt ${SSLDIR}/ca-bundle.crt &&
unset SSLDIR
rm -r certs BLFS-ca-bundle*
}

export Certificate_Authority_Certificates_C4_download=" "

export Certificate_Authority_Certificates_C4_packname=""

export Certificate_Authority_Certificates_C4_required_or_recommended="OpenSSL_1_0_1e_C4 "

ConsoleKit_0_4_6_C4(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/ConsoleKit \
            --enable-udev-acl \
            --enable-pam-module &&
make
make install
cat >> /etc/pam.d/system-session << "EOF"
# Begin ConsoleKit addition

session   optional    pam_loginuid.so
session   optional    pam_ck_connector.so nox11

# End ConsoleKit addition
EOF
cat > /usr/lib/ConsoleKit/run-session.d/pam-foreground-compat.ck << "EOF"
#!/bin/sh
TAGDIR=/var/run/console

[ -n "$CK_SESSION_USER_UID" ] || exit 1
[ "$CK_SESSION_IS_LOCAL" = "true" ] || exit 0

TAGFILE="$TAGDIR/`getent passwd $CK_SESSION_USER_UID | cut -f 1 -d:`"

if [ "$1" = "session_added" ]; then
    mkdir -p "$TAGDIR"
    echo "$CK_SESSION_ID" >> "$TAGFILE"
fi

if [ "$1" = "session_removed" ] && [ -e "$TAGFILE" ]; then
    sed -i "\%^$CK_SESSION_ID\$%d" "$TAGFILE"
    [ -s "$TAGFILE" ] || rm -f "$TAGFILE"
fi
EOF
chmod -v 755 /usr/lib/ConsoleKit/run-session.d/pam-foreground-compat.ck
}

export ConsoleKit_0_4_6_C4_download="http://anduin.linuxfromscratch.org/sources/BLFS/svn/c/ConsoleKit-0.4.6.tar.xz "

export ConsoleKit_0_4_6_C4_packname="ConsoleKit-0.4.6.tar.xz"

export ConsoleKit_0_4_6_C4_required_or_recommended="acl_2_2_51_C4 D_Bus_GLib_Bindings_C12 Xorg_Libraries_C24 Linux_PAM_1_1_6_C4 Polkit_0_110_C4 "

CrackLib_2_8_22_C4(){

./configure --prefix=/usr \
            --with-default-dict=/lib/cracklib/pw_dict \
            --disable-static &&
make
make install &&
mv -v /usr/lib/libcrack.so.2* /lib &&
ln -v -sf ../../lib/libcrack.so.2.8.1 /usr/lib/libcrack.so
install -v -m644 -D ../cracklib-words-20080507.gz \
    /usr/share/dict/cracklib-words.gz &&
gunzip -v /usr/share/dict/cracklib-words.gz &&
ln -v -s cracklib-words /usr/share/dict/words &&
echo $(hostname) >>/usr/share/dict/cracklib-extra-words &&
install -v -m755 -d /lib/cracklib &&
create-cracklib-dict /usr/share/dict/cracklib-words \
                     /usr/share/dict/cracklib-extra-words
}

export CrackLib_2_8_22_C4_download="http://downloads.sourceforge.net/cracklib/cracklib-2.8.22.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/cracklib-2.8.22.tar.gz http://downloads.sourceforge.net/cracklib/cracklib-words-20080507.gz "

export CrackLib_2_8_22_C4_packname="cracklib-2.8.22.tar.gz"

Cyrus_SASL_2_1_25_C4(){

patch -Np1 -i ../cyrus-sasl-2.1.25-fixes-1.patch &&
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --with-dbpath=/var/lib/sasl/sasldb2 \
            --with-saslauthd=/var/run/saslauthd &&
make
make install &&
install -v -m755 -d /usr/share/doc/cyrus-sasl-2.1.25 &&
install -v -m644 doc/{*.{html,txt,fig},ONEWS,TODO} \
    saslauthd/LDAP_SASLAUTHD /usr/share/doc/cyrus-sasl-2.1.25 &&
install -v -m700 -d /var/lib/sasl
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-saslauthd
}

export Cyrus_SASL_2_1_25_C4_download="http://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-2.1.25.tar.gz ftp://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-2.1.25.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-2.1.25-fixes-1.patch "

export Cyrus_SASL_2_1_25_C4_packname="cyrus-sasl-2.1.25.tar.gz"

export Cyrus_SASL_2_1_25_C4_required_or_recommended="OpenSSL_1_0_1e_C4 Berkeley_DB_5_3_21_C22 "

GnuPG_1_4_13_C4(){

./configure --prefix=/usr --libexecdir=/usr/lib &&
make
make -C doc pdf html
make install &&

install -v -m755 -d /usr/share/doc/gnupg-1.4.13 &&
cp      -v          /usr/share/gnupg/FAQ \
                    /usr/share/doc/gnupg-1.4.13 &&
install -v -m644    doc/{highlights-1.4.txt,OpenPGP,samplekeys.asc,DETAILS} \
                    /usr/share/doc/gnupg-1.4.13
cp -v -R doc/gnupg1.{html,pdf} /usr/share/doc/gnupg-1.4.13
}

export GnuPG_1_4_13_C4_download="http://anduin.linuxfromscratch.org/sources/BLFS/svn/g/gnupg-1.4.13.tar.bz2 ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.13.tar.bz2 "

export GnuPG_1_4_13_C4_packname="gnupg-1.4.13.tar.bz2"

GnuPG_2_0_19_C4(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/gnupg2 \
            --docdir=/usr/share/doc/gnupg-2.0.19 &&
make
make install
}

export GnuPG_2_0_19_C4_download="ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.19.tar.bz2 "

export GnuPG_2_0_19_C4_packname="gnupg-2.0.19.tar.bz2"

export GnuPG_2_0_19_C4_required_or_recommended="Pth_2_0_7_C9 libassuan_2_1_0_C9 libgcrypt_1_5_1_C9 Libksba_1_3_0_C9 PIN_Entry_0_8_2_C11 "

GnuTLS_3_1_10_C4(){

./configure --prefix=/usr    \
            --disable-static \
            --with-default-trust-store-file=/etc/ssl/ca-bundle.crt &&
make
make install
make -C doc/reference install-data-local
}

export GnuTLS_3_1_10_C4_download="ftp://ftp.gnutls.org/gcrypt/gnutls/v3.1/gnutls-3.1.10.tar.xz "

export GnuTLS_3_1_10_C4_packname="gnutls-3.1.10.tar.xz"

export GnuTLS_3_1_10_C4_required_or_recommended="Nettle_2_6_C4 Certificate_Authority_Certificates_C4 libtasn1_3_2_C9 "

GPGME_1_4_0_C4(){

./configure --prefix=/usr &&
make
make install
}

export GPGME_1_4_0_C4_download="ftp://ftp.gnupg.org/gcrypt/gpgme/gpgme-1.4.0.tar.bz2 "

export GPGME_1_4_0_C4_packname="gpgme-1.4.0.tar.bz2"

export GPGME_1_4_0_C4_required_or_recommended="libassuan_2_1_0_C9 "

Iptables_1_4_18_C4(){

./configure --prefix=/usr                          \
            --exec-prefix=                         \
            --bindir=/usr/bin                      \
            --with-xtlibdir=/lib/xtables           \
            --with-pkgconfigdir=/usr/lib/pkgconfig \
            --enable-libipq                        \
            --enable-devel &&
make
make install &&
ln -sfv ../../sbin/xtables-multi /usr/bin/iptables-xml &&
for file in libip4tc libip6tc libipq libiptc libxtables
do
  ln -sfv ../../lib/`readlink /lib/${file}.so` /usr/lib/${file}.so &&
  rm -v /lib/${file}.so &&
  mv -v /lib/${file}.la /usr/lib &&
  sed -i "s@libdir='@&/usr@g" /usr/lib/${file}.la
done
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-iptables
}

export Iptables_1_4_18_C4_download="http://www.netfilter.org/projects/iptables/files/iptables-1.4.18.tar.bz2 ftp://ftp.netfilter.org/pub/iptables/iptables-1.4.18.tar.bz2 "

export Iptables_1_4_18_C4_packname="iptables-1.4.18.tar.bz2"

Setting_Up_a_Network_Firewall_C4(){

/etc/rc.d/init.d/iptables start
cat > /etc/rc.d/rc.iptables << "EOF"
#!/bin/sh

# Begin rc.iptables

# Insert connection-tracking modules
# (not needed if built into the kernel)
modprobe nf_conntrack
modprobe xt_LOG

# Enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Disable Source Routed Packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route

# Enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Disable ICMP Redirect Acceptance
echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects

# Do not send Redirect Messages
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects

# Drop Spoofed Packets coming in on an interface, where responses
# would result in the reply going out a different interface.
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# Log packets with impossible addresses.
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
echo 1 > /proc/sys/net/ipv4/conf/default/log_martians

# be verbose on dynamic ip-addresses  (not needed in case of static IP)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# disable Explicit Congestion Notification
# too many routers are still ignorant
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# Set a known state
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# These lines are here in case rules are already in place and the
# script is ever rerun on the fly. We want to remove all rules and
# pre-existing user defined chains before we implement new rules.
iptables -F
iptables -X
iptables -Z

iptables -t nat -F

# Allow local-only connections
iptables -A INPUT  -i lo -j ACCEPT

# Free output on any interface to any ip for any service
# (equal to -P ACCEPT)
iptables -A OUTPUT -j ACCEPT

# Permit answers on already established connections
# and permit new connections related to established ones
# (e.g. port mode ftp)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Log everything else. What's Windows' latest exploitable vulnerability?
iptables -A INPUT -j LOG --log-prefix "FIREWALL:INPUT "

# End $rc_base/rc.iptables
EOF
chmod 700 /etc/rc.d/rc.iptables

cat > /etc/rc.d/rc.iptables << "EOF"
#!/bin/sh

# Begin rc.iptables

echo
echo "You're using the example configuration for a setup of a firewall"
echo "from Beyond Linux From Scratch."
echo "This example is far from being complete, it is only meant"
echo "to be a reference."
echo "Firewall security is a complex issue, that exceeds the scope"
echo "of the configuration rules below."
echo "You can find additional information"
echo "about firewalls in Chapter 4 of the BLFS book."
echo "http://www.linuxfromscratch.org/blfs"
echo

# Insert iptables modules (not needed if built into the kernel).

modprobe nf_conntrack
modprobe nf_conntrack_ftp
modprobe xt_conntrack
modprobe xt_LOG
modprobe xt_state

# Enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Disable Source Routed Packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route

# Enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Disable ICMP Redirect Acceptance
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects

# Don't send Redirect Messages
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects

# Drop Spoofed Packets coming in on an interface where responses
# would result in the reply going out a different interface.
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# Log packets with impossible addresses.
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians

# Be verbose on dynamic ip-addresses  (not needed in case of static IP)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# Disable Explicit Congestion Notification
# Too many routers are still ignorant
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# Set a known state
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# These lines are here in case rules are already in place and the
# script is ever rerun on the fly. We want to remove all rules and
# pre-existing user defined chains before we implement new rules.
iptables -F
iptables -X
iptables -Z

iptables -t nat -F

# Allow local connections
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow forwarding if the initiated on the intranet
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD  -i ! ppp+ -m conntrack --ctstate NEW      -j ACCEPT

# Do masquerading
# (not needed if intranet is not using private ip-addresses)
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE

# Log everything for debugging
# (last of all rules, but before policy rules)
iptables -A INPUT   -j LOG --log-prefix "FIREWALL:INPUT "
iptables -A FORWARD -j LOG --log-prefix "FIREWALL:FORWARD "
iptables -A OUTPUT  -j LOG --log-prefix "FIREWALL:OUTPUT "

# Enable IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
EOF
chmod 700 /etc/rc.d/rc.iptables

}

export Setting_Up_a_Network_Firewall_C4_download=""

export Setting_Up_a_Network_Firewall_C4_packname=""

libcap2_2_22_C4(){

make
make RAISE_SETFCAP=no install
}

export libcap2_2_22_C4_download="http://ftp.de.debian.org/debian/pool/main/libc/libcap2/libcap2_2.22.orig.tar.gz ftp://ftp.de.debian.org/debian/pool/main/libc/libcap2/libcap2_2.22.orig.tar.gz "

export libcap2_2_22_C4_packname="libcap2_2.22.orig.tar.gz"

export libcap2_2_22_C4_required_or_recommended="attr_2_4_46_C4 "

liboauth_1_0_0_C4(){

./configure --prefix=/usr --disable-static &&
make
make install
mkdir -pv /usr/share/doc/liboauth-1.0.0 &&
cp -rv doc/html/* /usr/share/doc/liboauth-1.0.0
}

export liboauth_1_0_0_C4_download="http://downloads.sourceforge.net/liboauth/liboauth-1.0.0.tar.gz "

export liboauth_1_0_0_C4_packname="liboauth-1.0.0.tar.gz"

export liboauth_1_0_0_C4_required_or_recommended="cURL_7_29_0_C17 OpenSSL_1_0_1e_C4 "

libpwquality_1_2_1_C4(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --with-securedir=/lib/security \
            --disable-python-bindings \
            --disable-static &&
make
make install
}

export libpwquality_1_2_1_C4_download="https://fedorahosted.org/releases/l/i/libpwquality/libpwquality-1.2.1.tar.bz2 "

export libpwquality_1_2_1_C4_packname="libpwquality-1.2.1.tar.bz2"

export libpwquality_1_2_1_C4_required_or_recommended="CrackLib_2_8_22_C4 "

Linux_PAM_1_1_6_C4(){

tar -xf ../Linux-PAM-1.1.6-docs.tar.bz2 --strip-components=1
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/Linux-PAM-1.1.6 \
            --disable-nis &&
make
install -v -m755 -d /etc/pam.d &&

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF
rm -rfv /etc/pam.d
make install &&
chmod -v 4755 /sbin/unix_chkpwd
}

export Linux_PAM_1_1_6_C4_download="http://linux-pam.org/library/Linux-PAM-1.1.6.tar.bz2 http://linux-pam.org/documentation/Linux-PAM-1.1.6-docs.tar.bz2 "

export Linux_PAM_1_1_6_C4_packname="Linux-PAM-1.1.6.tar.bz2"

MIT_Kerberos_V5_1_11_1_C4(){

gpg --verify krb5-1.11.1.tar.gz.asc krb5-1.11.1.tar.gz
gpg gpg --keyserver pgp.mit.edu --recv-keys 0xF376813D
cd src &&
sed -e "s@python2.5/Python.h@& python2.7/Python.h@g" \
    -e "s@-lpython2.5]@&,\n  AC_CHECK_LIB(python2.7,main,[PYTHON_LIB=-lpython2.7])@g" \
    -i configure.in &&
sed -e "s@interp->result@Tcl_GetStringResult(interp)@g" \
    -i kadmin/testing/util/tcl_kadm5.c &&
autoconf &&
./configure CPPFLAGS="-I/usr/include/et -I/usr/include/ss" \
            --prefix=/usr                                  \
            --localstatedir=/var/lib                       \
            --with-system-et                               \
            --with-system-ss                               \
            --enable-dns-for-realm &&
make
make install &&

for LIBRARY in gssapi_krb5 gssrpc k5crypto kadm5clnt_mit kadm5srv_mit \
               kdb5 kdb_ldap krb5 krb5support verto ; do
    [ -e  /usr/lib/lib$LIBRARY.so.*.* ] && chmod -v 755 /usr/lib/lib$LIBRARY.so.*.*
done &&

mv -v /usr/lib/libkrb5.so.3*        /lib &&
mv -v /usr/lib/libk5crypto.so.3*    /lib &&
mv -v /usr/lib/libkrb5support.so.0* /lib &&

ln -v -sf ../../lib/libkrb5.so.3.3        /usr/lib/libkrb5.so        &&
ln -v -sf ../../lib/libk5crypto.so.3.1    /usr/lib/libk5crypto.so    &&
ln -v -sf ../../lib/libkrb5support.so.0.1 /usr/lib/libkrb5support.so &&

mv -v /usr/bin/ksu /bin &&
chmod -v 755 /bin/ksu   &&

install -v -dm755 /usr/share/doc/krb5-1.11.1 &&
cp -vfr ../doc/*  /usr/share/doc/krb5-1.11.1 &&

unset LIBRARY
}

export MIT_Kerberos_V5_1_11_1_C4_download="http://web.mit.edu/kerberos/www/dist/krb5/1.11/krb5-1.11.1-signed.tar "

export MIT_Kerberos_V5_1_11_1_C4_packname="krb5-1.11.1-signed.tar"

Nettle_2_6_C4(){

./configure --prefix=/usr &&
make
make install &&
chmod -v 755 /usr/lib/libhogweed.so.2.3 /usr/lib/libnettle.so.4.5 &&
install -v -m755 -d /usr/share/doc/nettle-2.6 &&
install -v -m644 nettle.html /usr/share/doc/nettle-2.6
}

export Nettle_2_6_C4_download="http://ftp.gnu.org/gnu/nettle/nettle-2.6.tar.gz ftp://ftp.gnu.org/gnu/nettle/nettle-2.6.tar.gz "

export Nettle_2_6_C4_packname="nettle-2.6.tar.gz"

NSS_3_14_3_C4(){

patch -Np1 -i ../nss-3.14.3-standalone-1.patch &&
cd mozilla/security/nss                        &&
make nss_build_all BUILD_OPT=1                 \
  NSPR_INCLUDE_DIR=/usr/include/nspr           \
  USE_SYSTEM_ZLIB=1                            \
  ZLIB_LIBS=-lz                                \
  $([ $(uname -m) = x86_64 ] && echo USE_64=1) \
  $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1)
cd ../../dist &&
install -v -m755 Linux*/lib/*.so /usr/lib              &&
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib &&
install -v -m755 -d /usr/include/nss                   &&
cp -v -RL {public,private}/nss/* /usr/include/nss      &&
chmod 644 /usr/include/nss/*                           &&
install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin &&
install -v -m644 Linux*/lib/pkgconfig/nss.pc /usr/lib/pkgconfig
}

export NSS_3_14_3_C4_download="http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_14_3_RTM/src/nss-3.14.3.tar.gz ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_14_3_RTM/src/nss-3.14.3.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/nss-3.14.3-standalone-1.patch "

export NSS_3_14_3_C4_packname="nss-3.14.3.tar.gz"

export NSS_3_14_3_C4_required_or_recommended="NSPR_4_9_6_C9 SQLite_3_7_16_1_C22 "

OpenSSH_6_1p1_C4(){

install -v -m700 -d /var/lib/sshd &&
chown -R root:sys /var/lib/sshd &&
groupadd -g 50 sshd &&
useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd \
    -s /bin/false -u 50 sshd
./configure --prefix=/usr             \
            --sysconfdir=/etc/ssh     \
            --datadir=/usr/share/sshd \
            --with-md5-passwords      \
            --with-privsep-path=/var/lib/sshd &&
make
make install &&
install -v -m755 -d /usr/share/doc/openssh-6.1p1 &&
install -v -m644 INSTALL LICENCE OVERVIEW README* \
    /usr/share/doc/openssh-6.1p1
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
ssh-keygen &&
public_key="$(cat ~/.ssh/id_rsa.pub)" &&
ssh REMOTE_HOSTNAME "echo ${public_key} >> ~/.ssh/authorized_keys" &&
unset public_key
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config &&
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
sed 's@d/login@d/sshd@g' /etc/pam.d/login > /etc/pam.d/sshd &&
chmod 644 /etc/pam.d/sshd &&
echo "USEPAM yes" >> /etc/ssh/sshd_config
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-sshd
}

export OpenSSH_6_1p1_C4_download="http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.1p1.tar.gz ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.1p1.tar.gz "

export OpenSSH_6_1p1_C4_packname="openssh-6.1p1.tar.gz"

export OpenSSH_6_1p1_C4_required_or_recommended="OpenSSL_1_0_1e_C4 "

OpenSSL_1_0_1e_C4(){

patch -Np1 -i ../openssl-1.0.1e-fix_manpages-1.patch &&

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         shared                \
         zlib-dynamic &&
make
sed -i 's# libcrypto.a##;s# libssl.a##' Makefile
make MANDIR=/usr/share/man install              &&
install -dv -m755 /usr/share/doc/openssl-1.0.1e &&
cp -vfr doc/*     /usr/share/doc/openssl-1.0.1e
}

export OpenSSL_1_0_1e_C4_download="http://www.openssl.org/source/openssl-1.0.1e.tar.gz ftp://ftp.openssl.org/source/openssl-1.0.1e.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/openssl-1.0.1e-fix_manpages-1.patch "

export OpenSSL_1_0_1e_C4_packname="openssl-1.0.1e.tar.gz"

p11_kit_0_15_2_C4(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export p11_kit_0_15_2_C4_download="http://p11-glue.freedesktop.org/releases/p11-kit-0.15.2.tar.gz "

export p11_kit_0_15_2_C4_packname="p11-kit-0.15.2.tar.gz"

export p11_kit_0_15_2_C4_required_or_recommended="Certificate_Authority_Certificates_C4 libtasn1_3_2_C9 "

Polkit_0_110_C4(){

groupadd -fg 27 polkitd &&
useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
        -g polkitd -s /bin/false polkitd
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/polkit-1 \
            --with-authfw=shadow \
            --disable-static &&
make
make install
cat > /etc/pam.d/polkit-1 << "EOF"
# Begin /etc/pam.d/polkit-1

auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/polkit-1
EOF

}

export Polkit_0_110_C4_download="http://www.freedesktop.org/software/polkit/releases/polkit-0.110.tar.gz "

export Polkit_0_110_C4_packname="polkit-0.110.tar.gz"

export Polkit_0_110_C4_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 SpiderMonkey_1_0_0_C11 "

Shadow_4_1_5_1_C4(){

sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs
sed -i 's/groups$(EXEEXT) //' src/Makefile.in &&
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \; &&
sed -i -e 's/ ko//' -e 's/ zh_CN zh_TW//' man/Makefile.in &&

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs &&

sed -i -e 's@PATH=/sbin:/bin:/usr/sbin:/usr/bin@&:/usr/local/sbin:/usr/local/bin@' \
       -e 's@PATH=/bin:/usr/bin@&:/usr/local/bin@' etc/login.defs &&

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install &&
mv -v /usr/bin/passwd /bin
sed -i 's/yes/no/' /etc/default/useradd
install -v -m644 /etc/login.defs /etc/login.defs.orig &&
for FUNCTION in FAIL_DELAY FAILLOG_ENAB \
                LASTLOG_ENAB \
                MAIL_CHECK_ENAB \
                OBSCURE_CHECKS_ENAB \
                PORTTIME_CHECKS_ENAB \
                QUOTAS_ENAB \
                CONSOLE MOTD_FILE \
                FTMP_FILE NOLOGINS_FILE \
                ENV_HZ PASS_MIN_LEN \
                SU_WHEEL_ONLY \
                CRACKLIB_DICTPATH \
                PASS_CHANGE_TRIES \
                PASS_ALWAYS_WARN \
                CHFN_AUTH ENCRYPT_METHOD \
                ENVIRON_FILE
do
    sed -i "s/^${FUNCTION}/# &/" /etc/login.defs
done
cat > /etc/pam.d/system-account << "EOF"
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > /etc/pam.d/system-auth << "EOF"
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# check new passwords for strength (man pam_cracklib)
password  required    pam_cracklib.so   type=Linux retry=3 difok=5 \
                                        difignore=23 minlen=9 dcredit=1 \
                                        ucredit=1 lcredit=1 ocredit=1 \
                                        dictpath=/lib/cracklib/pw_dict
# use sha512 hash for encryption, use shadow, and use the
# authentication token (chosen password) set by pam_cracklib
# above (or any previous modules)
password  required    pam_unix.so       sha512 shadow use_authtok

# End /etc/pam.d/system-password
EOF

cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# use sha512 hash for encryption, use shadow, and try to use any previously
# defined authentication token (chosen password) set by any prior module
password  required    pam_unix.so       sha512 shadow try_first_pass

# End /etc/pam.d/system-password
EOF

cat > /etc/pam.d/system-session << "EOF"
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

cat > /etc/pam.d/login << "EOF"
# Begin /etc/pam.d/login

# Set failure delay before next prompt to 3 seconds
auth      optional    pam_faildelay.so  delay=3000000

# Check to make sure that the user is allowed to login
auth      requisite   pam_nologin.so

# Check to make sure that root is allowed to login
# Disabled by default. You will need to create /etc/securetty
# file for this module to function. See man 5 securetty.
#auth      required    pam_securetty.so

# Additional group memberships - disabled by default
#auth      optional    pam_group.so

# include the default auth settings
auth      include     system-auth

# check access for the user
account   required    pam_access.so

# include the default account settings
account   include     system-account

# Set default environment variables for the user
session   required    pam_env.so

# Set resource limits for the user
session   required    pam_limits.so

# Display date of last login - Disabled by default
#session   optional    pam_lastlog.so

# Display the message of the day - Disabled by default
#session   optional    pam_motd.so

# Check user's mail - Disabled by default
#session   optional    pam_mail.so      standard quiet

# include the default session and password settings
session   include     system-session
password  include     system-password

# End /etc/pam.d/login
EOF

cat > /etc/pam.d/passwd << "EOF"
# Begin /etc/pam.d/passwd

password  include     system-password

# End /etc/pam.d/passwd
EOF

cat > /etc/pam.d/su << "EOF"
# Begin /etc/pam.d/su

# always allow root
auth      sufficient  pam_rootok.so
auth      include     system-auth

# include the default account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session defaults
session   include     system-session

# End /etc/pam.d/su
EOF

cat > /etc/pam.d/chage << "EOF"
#Begin /etc/pam.d/chage

# always allow root
auth      sufficient  pam_rootok.so

# include system defaults for auth account and session
auth      include     system-auth
account   include     system-account
session   include     system-session

# Always permit for authentication updates
password  required    pam_permit.so

# End /etc/pam.d/chage
EOF

for PROGRAM in chfn chgpasswd chpasswd chsh groupadd groupdel \
               groupmems groupmod newusers useradd userdel usermod
do
    install -v -m644 /etc/pam.d/chage /etc/pam.d/${PROGRAM}
    sed -i "s/chage/$PROGRAM/" /etc/pam.d/${PROGRAM}
done
cat > /etc/pam.d/other << "EOF"
# Begin /etc/pam.d/other

auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

# End /etc/pam.d/other
EOF

[ -f /etc/login.access ] && mv -v /etc/login.access{,.NOUSE}
[ -f /etc/limits ] && mv -v /etc/limits{,.NOUSE}
}

export Shadow_4_1_5_1_C4_download="http://pkg-shadow.alioth.debian.org/releases/shadow-4.1.5.1.tar.bz2 http://www.deer-run.com/~hal/sysadmin/pam_cracklib.html "

export Shadow_4_1_5_1_C4_packname="shadow-4.1.5.1.tar.bz2"

export Shadow_4_1_5_1_C4_required_or_recommended="Linux_PAM_1_1_6_C4 "

stunnel_4_54_C4(){

groupadd -g 51 stunnel &&
useradd -c "stunnel Daemon" -d /var/lib/stunnel \
        -g stunnel -s /bin/false -u 51 stunnel
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --disable-libwrap &&
make
make docdir=/usr/share/doc/stunnel-4.54 install
install -v -m750 -o stunnel -g stunnel -d /var/lib/stunnel/run
cat >/etc/stunnel/stunnel.conf << "EOF"
; File: /etc/stunnel/stunnel.conf

pid    = /run/stunnel.pid
chroot = /var/lib/stunnel
client = no
setuid = stunnel
setgid = stunnel
cert   = /etc/stunnel/stunnel.pem

EOF
chmod -v 644 /etc/stunnel/stunnel.conf

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-stunnel
}

export stunnel_4_54_C4_download="http://mirrors.zerg.biz/stunnel/stunnel-4.54.tar.gz ftp://ftp.stunnel.org/stunnel/stunnel-4.54.tar.gz "

export stunnel_4_54_C4_packname="stunnel-4.54.tar.gz"

export stunnel_4_54_C4_required_or_recommended="OpenSSL_1_0_1e_C4 "

Sudo_1_8_6p3_C4(){

./configure --prefix=/usr                   \
            --libexecdir=/usr/lib/sudo      \
            --docdir=/usr/share/doc/sudo-1.8.6p3 \
            --with-all-insults              \
            --with-env-editor               \
            --without-pam                   \
            --without-sendmail &&
make
make install
cat > /etc/pam.d/sudo << "EOF"
# Begin /etc/pam.d/sudo

# include the default auth settings
auth      include     system-auth

# include the default account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session defaults
session   include     system-session

# End /etc/pam.d/sudo
EOF
chmod 644 /etc/pam.d/sudo
}

export Sudo_1_8_6p3_C4_download="http://www.sudo.ws/sudo/dist/sudo-1.8.6p3.tar.gz ftp://ftp.twaren.net/Unix/Security/Sudo/sudo-1.8.6p3.tar.gz "

export Sudo_1_8_6p3_C4_packname="sudo-1.8.6p3.tar.gz"

Tripwire_2_4_2_2_C4(){

sed -i -e 's@TWDB="${prefix}@TWDB="/var@' install/install.cfg            &&
sed -i -e 's/!Equal/!this->Equal/' src/cryptlib/algebra.h                &&
sed -i -e '/stdtwadmin.h/i#include <unistd.h>' src/twadmin/twadmincl.cpp &&

./configure --prefix=/usr --sysconfdir=/etc/tripwire                     &&
make
make install &&
cp -v policy/*.txt /usr/doc/tripwire
twadmin --create-polfile --site-keyfile /etc/tripwire/site.key \
    /etc/tripwire/twpol.txt &&
tripwire --init
tripwire --check > /etc/tripwire/report.txt

twadmin --create-polfile /etc/tripwire/twpol.txt &&
tripwire --init
}

export Tripwire_2_4_2_2_C4_download="http://downloads.sourceforge.net/tripwire/tripwire-2.4.2.2-src.tar.bz2 "

export Tripwire_2_4_2_2_C4_packname="tripwire-2.4.2.2-src.tar.bz2"

export Tripwire_2_4_2_2_C4_required_or_recommended="OpenSSL_1_0_1e_C4 "

export C4_Security="Vulnerabilities_C4 acl_2_2_51_C4 attr_2_4_46_C4 Certificate_Authority_Certificates_C4 ConsoleKit_0_4_6_C4 CrackLib_2_8_22_C4 Cyrus_SASL_2_1_25_C4 GnuPG_1_4_13_C4 GnuPG_2_0_19_C4 GnuTLS_3_1_10_C4 GPGME_1_4_0_C4 Iptables_1_4_18_C4 Setting_Up_a_Network_Firewall_C4 libcap2_2_22_C4 liboauth_1_0_0_C4 libpwquality_1_2_1_C4 Linux_PAM_1_1_6_C4 MIT_Kerberos_V5_1_11_1_C4 Nettle_2_6_C4 NSS_3_14_3_C4 OpenSSH_6_1p1_C4 OpenSSL_1_0_1e_C4 p11_kit_0_15_2_C4 Polkit_0_110_C4 Shadow_4_1_5_1_C4 stunnel_4_54_C4 Sudo_1_8_6p3_C4 Tripwire_2_4_2_2_C4 "


About_initramfs_C5(){

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

binfiles="sh cat cp dd killall ls mkdir mknod mount "
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
mkdir -p $WDIR/{bin,dev,lib/firmware,run,sbin,sys,proc}
mkdir -p $WDIR/etc/{modprobe.d,udev/rules.d}
touch $WDIR/etc/modprobe.d/modprobe.conf
ln -s lib $WDIR/lib64

# Create necessary device nodes
mknod -m 640 $WDIR/dev/console c 5 1
mknod -m 664 $WDIR/dev/null    c 1 3

# Install the udev configuration files
cp /etc/udev/udev.conf $WDIR/etc/udev/udev.conf

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
if [ -x /sbin/lvm ] ; then sbinfiles="$sbinfiles lvm"; fi

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
  ln -s kmod $WDIR/bin/lsmod
  ln -s kmod $WDIR/bin/insmod
fi

# Add lvm symlinks if appropriate
if  [ -x /sbin/lvm ] ; then
  ln -s lvm $WDIR/sbin/lvchange
  ln -s lvm $WDIR/sbin/lvrename
  ln -s lvm $WDIR/sbin/lvextend
  ln -s lvm $WDIR/sbin/lvcreate
  ln -s lvm $WDIR/sbin/lvdisplay
  ln -s lvm $WDIR/sbin/lvscan

  ln -s lvm $WDIR/sbin/pvchange
  ln -s lvm $WDIR/sbin/pvck
  ln -s lvm $WDIR/sbin/pvcreate
  ln -s lvm $WDIR/sbin/pvdisplay
  ln -s lvm $WDIR/sbin/pvscan

  ln -s lvm $WDIR/sbin/vgchange
  ln -s lvm $WDIR/sbin/vgcreate
  ln -s lvm $WDIR/sbin/vgscan
  ln -s lvm $WDIR/sbin/vgrename
  ln -s lvm $WDIR/sbin/vgck
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
  find                                                                        \
     /lib/modules/$KERNEL_VERSION/kernel/{crypto,fs,lib}                      \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/{block,ata,md,firewire}      \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/{scsi,message,pcmcia,virtio} \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/usb/{host,storage}           \
     -type f 2> /dev/null | cpio --make-directories -p --quiet $WDIR

  cp /lib/modules/$KERNEL_VERSION/modules.{builtin,order}                     \
            $WDIR/lib/modules/$KERNEL_VERSION

  depmod -b $WDIR $KERNEL_VERSION
fi

( cd $WDIR ; find . | cpio -o -H newc --quiet | gzip -9 ) > $INITRAMFS_FILE

# Remove the temporary directory and file
rm -rf $WDIR $unsorted
printf "done.\n"

EOF

chmod 0755 /sbin/mkinitramfs

mkdir -p /usr/share/mkinitramfs &&
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

if [ -f /etc/mdadm.conf ] ; then mdadm -As                                    ; fi
if [ -x /sbin/vgchange  ] ; then /sbin/vgchange --noudevsync -a y > /dev/null ; fi
if [ -n "$rootdelay"    ] ; then sleep "$rootdelay"                           ; fi

do_mount_root

killall -w ${UDEV_PATH}/udevd

exec switch_root /.root "$init" "$@"

EOF

}

export About_initramfs_C5_required_or_recommended="cpio_2_11_C12 "

Fuse_2_9_2_C5(){

./configure --prefix=/usr --disable-static INIT_D_PATH=/tmp/init.d &&
make
make install &&

mv -v   /usr/lib/libfuse.so.* /lib &&
ln -sfv ../../lib/libfuse.so.2.9.2 /usr/lib/libfuse.so &&
rm -rf  /tmp/init.d &&

install -v -m755 -d /usr/share/doc/fuse-2.9.2 &&
install -v -m644    doc/{how-fuse-works,kernel.txt} \
                    /usr/share/doc/fuse-2.9.2
install -v -m755 -d /usr/share/doc/fuse-2.9.2/api &&
install -v -m644    doc/html/* \
                    /usr/share/doc/fuse-2.9.2/api
cat > /etc/fuse.conf << "EOF"
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
EOF
}

export Fuse_2_9_2_C5_download="http://downloads.sourceforge.net/fuse/fuse-2.9.2.tar.gz "

export Fuse_2_9_2_C5_packname="fuse-2.9.2.tar.gz"

jfsutils_1_1_15_C5(){

sed "s@<unistd.h>@&\n#include <sys/types.h>@g" -i fscklog/extract.c &&
./configure &&
make
make install
}

export jfsutils_1_1_15_C5_download="http://jfs.sourceforge.net/project/pub/jfsutils-1.1.15.tar.gz "

export jfsutils_1_1_15_C5_packname="jfsutils-1.1.15.tar.gz"

LVM2_2_02_98_C5(){

./configure --prefix=/usr       \
            --exec-prefix=      \
            --with-confdir=/etc \
            --enable-applib     \
            --enable-cmdlib     \
            --enable-pkgconfig  \
            --enable-udev_sync &&
make
make install
}

export LVM2_2_02_98_C5_download="ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.98.tgz "

export LVM2_2_02_98_C5_packname="LVM2.2.02.98.tgz"

About_RAID_C5(){

/sbin/mdadm -Cv /dev/md0 --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1
/sbin/mdadm -Cv /dev/md1 --level=1 --raid-devices=2 /dev/sda2 /dev/sdb2
/sbin/mdadm -Cv /dev/md3 --level=0 --raid-devices=2 /dev/sdc1 /dev/sdd1
/sbin/mdadm -Cv /dev/md2 --level=5 --raid-devices=4 \
        /dev/sda4 /dev/sdb4 /dev/sdc2 /dev/sdd2 
}

mdadm_3_2_6_C5(){

make everything
make install
}

export mdadm_3_2_6_C5_download="http://www.kernel.org/pub//linux/utils/raid/mdadm/mdadm-3.2.6.tar.xz "

export mdadm_3_2_6_C5_packname="mdadm-3.2.6.tar.xz"

ntfs_3g_2013_1_13_C5(){

./configure --prefix=/usr --disable-static &&
make
make install &&
ln -sfv ../bin/ntfs-3g /sbin/mount.ntfs &&
ln -sfv /usr/share/man/man8/{ntfs-3g,mount.ntfs}.8
chmod -v 4755 /sbin/mount.ntfs
chmod -v 777 /mnt/usb
}

export ntfs_3g_2013_1_13_C5_download="http://tuxera.com/opensource/ntfs-3g_ntfsprogs-2013.1.13.tgz "

export ntfs_3g_2013_1_13_C5_packname="ntfs-3g_ntfsprogs-2013.1.13.tgz"

gptfdisk_0_8_6_C5(){

patch -Np1 -i ../gptfdisk-0.8.6-convenience-1.patch &&
make
make install
}

export gptfdisk_0_8_6_C5_download="http://downloads.sourceforge.net/project/gptfdisk/gptfdisk/0.8.6/gptfdisk-0.8.6.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/gptfdisk-0.8.6-convenience-1.patch "

export gptfdisk_0_8_6_C5_packname="gptfdisk-0.8.6.tar.gz"

parted_3_1_C5(){

./configure --prefix=/usr --disable-static &&
make &&

make -C doc html                                       &&
makeinfo --html      -o doc/html       doc/parted.texi &&
makeinfo --plaintext -o doc/parted.txt doc/parted.texi
texi2pdf             -o doc/parted.pdf doc/parted.texi &&
texi2dvi             -o doc/parted.dvi doc/parted.texi &&
dvips                -o doc/parted.ps  doc/parted.dvi
make install &&
install -v -m755 -d /usr/share/doc/parted-3.1/html &&
install -v -m644    doc/html/* \
                    /usr/share/doc/parted-3.1/html &&
install -v -m644    doc/{FAT,API,parted.{txt,html}} \
                    /usr/share/doc/parted-3.1
install -v -m644 doc/FAT doc/API doc/parted.{pdf,ps,dvi} \
                    /usr/share/doc/parted-3.1
}

export parted_3_1_C5_download="http://ftp.gnu.org/gnu/parted/parted-3.1.tar.xz "

export parted_3_1_C5_packname="parted-3.1.tar.xz"

export parted_3_1_C5_required_or_recommended="LVM2_2_02_98_C5 "

reiserfsprogs_3_6_21_C5(){

./configure --prefix=/usr --sbindir=/sbin &&
make
make install &&
ln -sf reiserfsck /sbin/fsck.reiserfs &&
ln -sf mkreiserfs /sbin/mkfs.reiserfs
}

export reiserfsprogs_3_6_21_C5_download="ftp://anduin.linuxfromscratch.org/BLFS/svn/r/reiserfsprogs-3.6.21.tar.bz2 "

export reiserfsprogs_3_6_21_C5_packname="reiserfsprogs-3.6.21.tar.bz2"

sshfs_fuse_2_4_C5(){

./configure --prefix=/usr &&
make
make install
sshfs THINGY:~ ~/MOUNTPATH
fusermount -u ~/MOUNTPATH
}

export sshfs_fuse_2_4_C5_download="http://downloads.sourceforge.net/fuse/sshfs-fuse-2.4.tar.gz "

export sshfs_fuse_2_4_C5_packname="sshfs-fuse-2.4.tar.gz"

export sshfs_fuse_2_4_C5_required_or_recommended="Fuse_2_9_2_C5 GLib_2_34_3_C9 OpenSSH_6_1p1_C4 "

xfsprogs_3_1_10_C5(){

make DEBUG=-DNDEBUG INSTALL_USER=root INSTALL_GROUP=root \
     LOCAL_CONFIGURE_OPTIONS="--enable-readline"
make install install-dev &&
rm -rfv /lib/libhandle.{a,la,so} &&
ln -sfv ../../lib/libhandle.so.1 /usr/lib/libhandle.so &&
sed -i "s@libdir='/lib@libdir='/usr/lib@g" /usr/lib/libhandle.la
}

export xfsprogs_3_1_10_C5_download="http://anduin.linuxfromscratch.org/sources/BLFS/svn/x/xfsprogs-3.1.10.tar.gz ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-3.1.10.tar.gz "

export xfsprogs_3_1_10_C5_packname="xfsprogs-3.1.10.tar.gz"

export C5_FileSystemsandDiskManagement="About_initramfs_C5 Fuse_2_9_2_C5 jfsutils_1_1_15_C5 LVM2_2_02_98_C5 About_RAID_C5 mdadm_3_2_6_C5 ntfs_3g_2013_1_13_C5 gptfdisk_0_8_6_C5 parted_3_1_C5 reiserfsprogs_3_6_21_C5 sshfs_fuse_2_4_C5 xfsprogs_3_1_10_C5 "


Bluefish_2_2_4_C6(){

./configure --prefix=/usr &&
make
make install
}

export Bluefish_2_2_4_C6_download="http://www.bennewitz.com/bluefish/stable/source/bluefish-2.2.4.tar.bz2 "

export Bluefish_2_2_4_C6_packname="bluefish-2.2.4.tar.bz2"

export Bluefish_2_2_4_C6_required_or_recommended="GTK_2_24_17_C25 "

Ed_1_7_C6(){

./configure --prefix=/usr --bindir=/bin &&
make
make install
}

export Ed_1_7_C6_download="http://ftp.gnu.org/pub/gnu/ed/ed-1.7.tar.gz ftp://ftp.gnu.org/pub/gnu/ed/ed-1.7.tar.gz "

export Ed_1_7_C6_packname="ed-1.7.tar.gz"

Emacs_24_2_C6(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib \
            --localstatedir=/var &&
make bootstrap
make install &&
chown -R -R root:root /usr/share/emacs/24.2
}

export Emacs_24_2_C6_download="http://ftp.gnu.org/pub/gnu/emacs/emacs-24.2.tar.bz2 ftp://ftp.gnu.org/pub/gnu/emacs/emacs-24.2.tar.bz2 "

export Emacs_24_2_C6_packname="emacs-24.2.tar.bz2"

JOE_3_7_C6(){

./configure --sysconfdir=/etc --prefix=/usr &&
make
make install
}

export JOE_3_7_C6_download="http://downloads.sourceforge.net/joe-editor/joe-3.7.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/joe-3.7.tar.gz "

export JOE_3_7_C6_packname="joe-3.7.tar.gz"

Nano_2_3_1_C6(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --enable-utf8 &&
make
make install &&
install -v -m644 doc/nanorc.sample /etc &&
install -v -m755 -d /usr/share/doc/nano-2.3.1 &&
install -v -m644 doc/{,man/,texinfo/}*.html /usr/share/doc/nano-2.3.1
}

export Nano_2_3_1_C6_download="http://ftp.gnu.org/gnu/nano/nano-2.3.1.tar.gz ftp://ftp.gnu.org/gnu/nano/nano-2.3.1.tar.gz "

export Nano_2_3_1_C6_packname="nano-2.3.1.tar.gz"

Vim_7_3_C61(){

patch -Np1 -i ../vim-7.3-fixes-524.patch
tar -xf ../vim-7.2-lang.tar.gz --strip-components=1
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h &&
echo '#define SYS_GVIMRC_FILE "/etc/gvimrc"' >> src/feature.h &&
./configure --prefix=/usr --with-features=huge &&
make
make install
ln -snfv ../vim/vim73/doc /usr/share/doc/vim-7.3
rsync -avzcP --delete --exclude="/dos/" --exclude="/spell/" \
    ftp.nluug.nl::Vim/runtime/ ./runtime/
make -C src installruntime &&
vim -c ":helptags /usr/share/doc/vim-7.3" -c ":q"
}

export Vim_7_3_C6_download="ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/vim-7.3-fixes-524.patch ftp://ftp.vim.org/pub/vim/extra/vim-7.2-lang.tar.gz "

export Vim_7_3_C6_packname="vim-7.3.tar.bz2"

#export Vim_7_3_C6_required_or_recommended="XWindowSystemEnvironment "

export C6_Editors="Bluefish_2_2_4_C6 Ed_1_7_C6 Emacs_24_2_C6 JOE_3_7_C6 Nano_2_3_1_C6 Vim_7_3_C6 Other_Editors_C6 "


Dash_0_5_7_C7(){

./configure --bindir=/bin --mandir=/usr/share/man &&
make
make install
ln -sfvf dash /bin/sh
cat >> /etc/shells << "EOF"
/bin/dash
EOF

}

export Dash_0_5_7_C7_download="http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.7.tar.gz "

export Dash_0_5_7_C7_packname="dash-0.5.7.tar.gz"

Tcsh_6_18_01_C7(){

sed -i -e 's|\$\*|#&|' -e 's|fR/g|&m|' tcsh.man2html &&
./configure --prefix=/usr --bindir=/bin &&
make &&
sh ./tcsh.man2html
make install install.man &&
ln -v -sf tcsh   /bin/csh &&
ln -v -sf tcsh.1 /usr/share/man/man1/csh.1 &&
install -v -m755 -d          /usr/share/doc/tcsh-6.18.01/html &&
install -v -m644 tcsh.html/* /usr/share/doc/tcsh-6.18.01/html &&
install -v -m644 FAQ         /usr/share/doc/tcsh-6.18.01
cat >> /etc/shells << "EOF"
/bin/tcsh
/bin/csh
EOF

}

export Tcsh_6_18_01_C7_download="http://www.sfr-fresh.com/unix/misc/tcsh-6.18.01.tar.gz ftp://ftp.astron.com/pub/tcsh/tcsh-6.18.01.tar.gz "

export Tcsh_6_18_01_C7_packname="tcsh-6.18.01.tar.gz"

zsh_5_0_0_C7(){

tar --strip-components=1 -xvf ../zsh-5.0.0-doc.tar.bz2
./configure --prefix=/usr \
            --bindir=/bin \
            --sysconfdir=/etc/zsh \
            --enable-etcdir=/etc/zsh &&
make &&

makeinfo  Doc/zsh.texi --html      -o Doc/html             &&
makeinfo  Doc/zsh.texi --html --no-split --no-headers      \
                                   -o Doc/zsh.html &&
makeinfo  Doc/zsh.texi --plaintext -o Doc/zsh.txt
texi2pdf  Doc/zsh.texi -o Doc/zsh.pdf
make install &&
make infodir=/usr/share/info install.info

install -v -m755 -d /usr/share/doc/zsh-5.0.0/html &&
install -v -m644    Doc/html/* \
                    /usr/share/doc/zsh-5.0.0/html &&
install -v -m644    Doc/zsh.{html,txt} \
                    /usr/share/doc/zsh-5.0.0
make htmldir=/usr/share/doc/zsh-5.0.0/html install.html &&
install -v -m644 Doc/zsh.dvi /usr/share/doc/zsh-5.0.0
install -v -m644 Doc/zsh.pdf \
        /usr/share/doc/zsh-5.0.0
mv -v /usr/lib/libpcre.so.* /lib &&
ln -v -sf ../../lib/libpcre.so.0 /usr/lib/libpcre.so

mv -v /usr/lib/libgdbm.so.* /lib &&
ln -v -sf ../../lib/libgdbm.so.3 /usr/lib/libgdbm.so
cat >> /etc/shells << "EOF"
/bin/zsh
/bin/zsh-5.0.0
EOF

}

export zsh_5_0_0_C7_download="http://downloads.sourceforge.net/zsh/zsh-5.0.0.tar.bz2 http://downloads.sourceforge.net/zsh/zsh-5.0.0-doc.tar.bz2 "

export zsh_5_0_0_C7_packname="zsh-5.0.0.tar.bz2"

export C7_Shells="Dash_0_5_7_C7 Tcsh_6_18_01_C7 zsh_5_0_0_C7 "


qemu_1_4_0_C8(){

egrep '^flags.*(vmx|svm)' /proc/cpuinfo
export LIBRARY_PATH=/opt/xorg/lib
patch -Np1 -i ../qemu-1.4.0-fixes-1.patch
./configure --prefix=/usr                \
            --sysconfdir=/etc            \
            --target-list=x86_64-softmmu &&
make
make install
ln -sfv qemu-system-x86_64 /usr/bin/qemu
qemu-img create -f qcow2 vdisk.img 10G
qemu -enable-kvm -hda vdisk.img            \
     -cdrom Fedora-16-x86_64-Live-LXDE.iso \
     -boot d                               \
     -m 384
qemu -enable-kvm vdisk.img -m 384
sysctl -w net.ipv4.ip_forward=1
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
EOF
cat >> /etc/qemu-ifup << EOF
#!/bin/bash

switch=br0

if [ -n "\$1" ]; then
  # Add new tap0 interface to bridge
  /sbin/ip link set \$1 up
  sleep 0.5s
  /usr/sbin/brctl addif \$switch \$1
else
  echo "Error: no interface specified"
  exit 1
fi

exit 0
EOF

chmod +x /etc/qemu-ifup
cat >> /etc/qemu-ifdown << EOF
#!/bin/bash

switch=br0

if [ -n "\$1" ]; then
  # Remove tap0 interface from bridge
  /usr/sbin/brctl delif \$switch \$1
else
  echo "Error: no interface specified"
  exit 1
fi

exit 0
EOF

chmod +x /etc/qemu-ifdown
}

export qemu_1_4_0_C8_download="http://wiki.qemu.org/download/qemu-1.4.0.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/qemu-1.4.0-fixes-1.patch "

export qemu_1_4_0_C8_packname="qemu-1.4.0.tar.bz2"

export qemu_1_4_0_C8_required_or_recommended="GLib_2_34_3_C9 Python_2_7_3_C13 SDL_1_2_15_C38 XWindowSystemEnvironment "

export C8_Virtualization="qemu_1_4_0_C8 "


Apr_1_4_6_C9(){

./configure --prefix=/usr --disable-static \
  --with-installbuilddir=/usr/share/apr-1/build &&
make
make install
}

export Apr_1_4_6_C9_download="http://archive.apache.org/dist/apr/apr-1.4.6.tar.bz2 ftp://ftp.mirrorservice.org/sites/ftp.apache.org/apr/apr-1.4.6.tar.bz2 "

export Apr_1_4_6_C9_packname="apr-1.4.6.tar.bz2"

Aspell_0_60_6_1_C9(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d /usr/share/doc/aspell-0.60.6.1/aspell{,-dev}.html &&
install -v -m644 manual/aspell.html/* \
    /usr/share/doc/aspell-0.60.6.1/aspell.html &&
install -v -m644 manual/aspell-dev.html/* \
    /usr/share/doc/aspell-0.60.6.1/aspell-dev.html
install -v -m 755 scripts/ispell /usr/bin/
install -v -m 755 scripts/spell /usr/bin/
./configure &&
make
make install
}

export Aspell_0_60_6_1_C9_download="http://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz ftp://ftp.gnu.org/gnu/aspell/dict "

export Aspell_0_60_6_1_C9_packname="aspell-0.60.6.1.tar.gz"

export Aspell_0_60_6_1_C9_required_or_recommended="Which_2_20_and_Alternatives_C12 "

Boost_1_53_0_C9(){

./bootstrap.sh --prefix=/usr &&
./b2 stage threading=multi link=shared
./b2 install threading=multi link=shared
}

export Boost_1_53_0_C9_download="http://downloads.sourceforge.net/boost/boost_1_53_0.tar.bz2 "

export Boost_1_53_0_C9_packname="boost_1_53_0.tar.bz2"

enchant_1_6_0_C9(){

./configure --prefix=/usr &&
make
make install
}

export enchant_1_6_0_C9_download="http://www.abisource.com/downloads/enchant/1.6.0/enchant-1.6.0.tar.gz ftp://ftp.netbsd.org/pub/pkgsrc/distfiles/enchant-1.6.0.tar.gz "

export enchant_1_6_0_C9_packname="enchant-1.6.0.tar.gz"

export enchant_1_6_0_C9_required_or_recommended="GLib_2_34_3_C9 Aspell_0_60_6_1_C9 "

Exempi_2_2_0_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Exempi_2_2_0_C9_download="http://libopenraw.freedesktop.org/download/exempi-2.2.0.tar.bz2 "

export Exempi_2_2_0_C9_packname="exempi-2.2.0.tar.bz2"

export Exempi_2_2_0_C9_required_or_recommended="Boost_1_53_0_C9 "

Expat_2_1_0_C9(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d /usr/share/doc/expat-2.1.0 &&
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0
}

export Expat_2_1_0_C9_download="http://downloads.sourceforge.net/expat/expat-2.1.0.tar.gz "

export Expat_2_1_0_C9_packname="expat-2.1.0.tar.gz"

Gamin_0_1_10_C9(){

sed -i 's/G_CONST_RETURN/const/' server/gam_{node,subscription}.{c,h} &&
./configure --prefix=/usr --libexecdir=/usr/sbin --disable-static &&
make
make install &&
install -v -m755 -d /usr/share/doc/gamin-0.1.10 &&
install -v -m644 doc/*.{html,fig,gif,txt} /usr/share/doc/gamin-0.1.10
}

export Gamin_0_1_10_C9_download="http://www.gnome.org/~veillard/gamin/sources/gamin-0.1.10.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/gamin-0.1.10.tar.gz "

export Gamin_0_1_10_C9_packname="gamin-0.1.10.tar.gz"

export Gamin_0_1_10_C9_required_or_recommended="GLib_2_34_3_C9 "

GLib_2_34_3_C9(){

./configure --prefix=/usr --with-pcre=system &&
make
make install
}

export GLib_2_34_3_C9_download="http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz "

export GLib_2_34_3_C9_packname="glib-2.34.3.tar.xz"

export GLib_2_34_3_C9_required_or_recommended="libffi_3_0_13_C9 pkg_config_0_28_C13 Python_2_7_3_C13 PCRE_8_32_C9 "

GLibmm_2_34_1_C9(){

./configure --prefix=/usr &&
make
make install
}

export GLibmm_2_34_1_C9_download="http://ftp.gnome.org/pub/gnome/sources/glibmm/2.34/glibmm-2.34.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/glibmm/2.34/glibmm-2.34.1.tar.xz "

export GLibmm_2_34_1_C9_packname="glibmm-2.34.1.tar.xz"

export GLibmm_2_34_1_C9_required_or_recommended="GLib_2_34_3_C9 libsigc_2_2_11_C9 "

GMime_2_6_15_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export GMime_2_6_15_C9_download="http://ftp.gnome.org/pub/gnome/sources/gmime/2.6/gmime-2.6.15.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gmime/2.6/gmime-2.6.15.tar.xz "

export GMime_2_6_15_C9_packname="gmime-2.6.15.tar.xz"

export GMime_2_6_15_C9_required_or_recommended="GLib_2_34_3_C9 "

gobject_introspection_1_34_2_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export gobject_introspection_1_34_2_C9_download="http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.34/gobject-introspection-1.34.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.34/gobject-introspection-1.34.2.tar.xz "

export gobject_introspection_1_34_2_C9_packname="gobject-introspection-1.34.2.tar.xz"

export gobject_introspection_1_34_2_C9_required_or_recommended="GLib_2_34_3_C9 "

Gsl_1_15_C9(){

./configure --prefix=/usr --disable-static &&
make &&
make html
make install &&
mkdir -pv /usr/share/doc/gsl-1.15 &&
cp doc/gsl-ref.html/* /usr/share/doc/gsl-1.15
}

export Gsl_1_15_C9_download="http://ftp.gnu.org/pub/gnu/gsl/gsl-1.15.tar.gz ftp://ftp.gnu.org/pub/gnu/gsl/gsl-1.15.tar.gz "

export Gsl_1_15_C9_packname="gsl-1.15.tar.gz"

ICU_51_1_C9(){

cd source &&
./configure --prefix=/usr &&
make
make install
}

export ICU_51_1_C9_download="http://download.icu-project.org/files/icu4c/51.1/icu4c-51_1-src.tgz "

export ICU_51_1_C9_packname="icu4c-51_1-src.tgz"

ISO_Codes_3_40_C9(){

./configure --prefix=/usr &&
make
make install
}

export ISO_Codes_3_40_C9_download="http://pkg-isocodes.alioth.debian.org/downloads/iso-codes-3.40.tar.xz "

export ISO_Codes_3_40_C9_packname="iso-codes-3.40.tar.xz"

JSON_C_0_10_C9(){

sed -e 's/json_object.c/json_object.c json_object_iterator.c/'    \
    -e 's/json_object.h/json_object.h json_object_iterator.h/'    \
    -e 's/json_object.lo/json_object.lo json_object_iterator.lo/' \
    -i Makefile.in &&
./configure --prefix=/usr --disable-static &&
make
make install
}

export JSON_C_0_10_C9_download="https://github.com/downloads/json-c/json-c/json-c-0.10.tar.gz "

export JSON_C_0_10_C9_packname="json-c-0.10.tar.gz"

JSON_GLib_0_15_2_C9(){

./configure --prefix=/usr &&
make
make install
}

export JSON_GLib_0_15_2_C9_download="http://ftp.gnome.org/pub/gnome/sources/json-glib/0.15/json-glib-0.15.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/json-glib/0.15/json-glib-0.15.2.tar.xz "

export JSON_GLib_0_15_2_C9_packname="json-glib-0.15.2.tar.xz"

export JSON_GLib_0_15_2_C9_required_or_recommended="GLib_2_34_3_C9 "

keyutils_1_5_5_C9(){

make
make install
}

export keyutils_1_5_5_C9_download="http://people.redhat.com/~dhowells/keyutils/keyutils-1.5.5.tar.bz2 "

export keyutils_1_5_5_C9_packname="keyutils-1.5.5.tar.bz2"

libassuan_2_1_0_C9(){

./configure --prefix=/usr &&
make
make -C doc pdf ps
make install
install -v -dm755 /usr/share/doc/libassuan-2.1.0 &&
install -v -m644  doc/assuan.{pdf,ps,dvi} \
                  /usr/share/doc/libassuan-2.1.0
}

export libassuan_2_1_0_C9_download="ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.1.0.tar.bz2 "

export libassuan_2_1_0_C9_packname="libassuan-2.1.0.tar.bz2"

export libassuan_2_1_0_C9_required_or_recommended="libgpg_error_1_11_C9 "

libatasmart_0_19_C9(){

./configure --prefix=/usr --disable-static &&
make
make docdir=/usr/share/doc/libatasmart-0.19 install
}

export libatasmart_0_19_C9_download="http://0pointer.de/public/libatasmart-0.19.tar.xz "

export libatasmart_0_19_C9_packname="libatasmart-0.19.tar.xz"

libatomic_ops_7_2d_C9(){

sed -i 's#AM_CONFIG_HEADER#AC_CONFIG_HEADERS#' configure.ac &&
sed -i 's#AC_PROG_RANLIB#AC_LIBTOOL_DLOPEN\nAC_PROG_LIBTOOL#' configure.ac &&
sed -i 's#b_L#b_LTL#;s#\.a#.la#g;s#_a_#_la_#' src/Makefile.am &&
sed -i 's#\.a#.so#g;s#\.\./src/#../src/.libs/#g' tests/Makefile.am &&
sed -i 's#pkgdata#doc#' doc/Makefile.am &&
autoreconf -fi &&
./configure --prefix=/usr \
            --docdir=/usr/share/doc/libatomic_ops-7.2d \
            --disable-static &&
make
make install
}

export libatomic_ops_7_2d_C9_download="http://www.hpl.hp.com/research/linux/atomic_ops/download/libatomic_ops-7.2d.tar.gz "

export libatomic_ops_7_2d_C9_packname="libatomic_ops-7.2d.tar.gz"

libcroco_0_6_8_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libcroco_0_6_8_C9_download="http://ftp.gnome.org/pub/gnome/sources/libcroco/0.6/libcroco-0.6.8.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libcroco/0.6/libcroco-0.6.8.tar.xz "

export libcroco_0_6_8_C9_packname="libcroco-0.6.8.tar.xz"

export libcroco_0_6_8_C9_required_or_recommended="GLib_2_34_3_C9 libxml2_2_9_0_C9 "

libdaemon_0_14_C9(){

./configure --prefix=/usr --disable-static &&
make
make -C doc doxygen
make docdir=/usr/share/doc/libdaemon-0.14 install
install -v -m755 -d /usr/share/doc/libdaemon-0.14/api &&
install -v -m644 doc/reference/html/* /usr/share/doc/libdaemon-0.14/api &&
install -v -m644 doc/reference/man/man3/* /usr/share/man/man3
}

export libdaemon_0_14_C9_download="http://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz "

export libdaemon_0_14_C9_packname="libdaemon-0.14.tar.gz"

libdbusmenu_qt_0_9_2_C9(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR \
      -DWITH_DOC=OFF .. &&
make
make install
}

export libdbusmenu_qt_0_9_2_C9_download="http://launchpad.net/libdbusmenu-qt/trunk/0.9.2/+download/libdbusmenu-qt-0.9.2.tar.bz2 "

export libdbusmenu_qt_0_9_2_C9_packname="libdbusmenu-qt-0.9.2.tar.bz2"

export libdbusmenu_qt_0_9_2_C9_required_or_recommended="Qt_4_8_4_C25 "

libdrm_2_4_43_C9(){

sed -e "/pthread-stubs/d" -i configure.ac &&
autoreconf -fi &&
./configure --prefix=/usr --enable-udev &&
make
make install
}

export libdrm_2_4_43_C9_download="http://dri.freedesktop.org/libdrm/libdrm-2.4.43.tar.bz2 "

export libdrm_2_4_43_C9_packname="libdrm-2.4.43.tar.bz2"

export libdrm_2_4_43_C9_required_or_recommended="Xorg_Libraries_C24 "

libESMTP_1_0_6_C9(){

./configure --prefix=/usr &&
make
make install
}

export libESMTP_1_0_6_C9_download="http://www.stafford.uklinux.net/libesmtp/libesmtp-1.0.6.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libesmtp-1.0.6.tar.bz2 "

export libESMTP_1_0_6_C9_packname="libesmtp-1.0.6.tar.bz2"

libffi_3_0_13_C9(){

patch -Np1 -i ../libffi-3.0.13-includedir-1.patch &&
./configure --prefix=/usr --disable-static &&
make
make install
}

export libffi_3_0_13_C9_download="ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/libffi-3.0.13-includedir-1.patch "

export libffi_3_0_13_C9_packname="libffi-3.0.13.tar.gz"

libgcrypt_1_5_1_C9(){

./configure --prefix=/usr --disable-static &&
make
make -C doc pdf ps html &&
makeinfo --html --no-split -o doc/gcrypt_nochunks.html doc/gcrypt.texi &&
makeinfo --plaintext       -o doc/gcrypt.txt           doc/gcrypt.texi
make install &&
install -v -dm755   /usr/share/doc/libgcrypt-1.5.1 &&
install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} \
                    /usr/share/doc/libgcrypt-1.5.1
install -v -dm755   /usr/share/doc/libgcrypt-1.5.1/html &&
install -v -m644 doc/gcrypt.html/* \
                    /usr/share/doc/libgcrypt-1.5.1/html &&
install -v -m644 doc/gcrypt_nochunks.html \
                    /usr/share/doc/libgcrypt-1.5.1 &&
install -v -m644 doc/gcrypt.{pdf,ps,dvi,txt,texi} \
                    /usr/share/doc/libgcrypt-1.5.1
}

export libgcrypt_1_5_1_C9_download="ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.1.tar.bz2 "

export libgcrypt_1_5_1_C9_packname="libgcrypt-1.5.1.tar.bz2"

export libgcrypt_1_5_1_C9_required_or_recommended="libgpg_error_1_11_C9 "

libglade_2_6_4_C9(){

sed -i '/DG_DISABLE_DEPRECATED/d' glade/Makefile.in &&
./configure --prefix=/usr &&
make
make install
}

export libglade_2_6_4_C9_download="http://ftp.gnome.org/pub/gnome/sources/libglade/2.6/libglade-2.6.4.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libglade/2.6/libglade-2.6.4.tar.bz2 "

export libglade_2_6_4_C9_packname="libglade-2.6.4.tar.bz2"

export libglade_2_6_4_C9_required_or_recommended="libxml2_2_9_0_C9 GTK_2_24_17_C25 "

libgpg_error_1_11_C9(){

./configure --prefix=/usr --disable-static &&
make
make install &&
install -v -m644 -D README /usr/share/doc/libgpg-error-1.11/README
}

export libgpg_error_1_11_C9_download="ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.11.tar.bz2 "

export libgpg_error_1_11_C9_packname="libgpg-error-1.11.tar.bz2"

libgsf_1_14_26_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libgsf_1_14_26_C9_download="http://ftp.gnome.org/pub/gnome/sources/libgsf/1.14/libgsf-1.14.26.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgsf/1.14/libgsf-1.14.26.tar.xz "

export libgsf_1_14_26_C9_packname="libgsf-1.14.26.tar.xz"

export libgsf_1_14_26_C9_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 libxml2_2_9_0_C9 gdk_pixbuf_2_26_5_C25 "

libgusb_0_1_6_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libgusb_0_1_6_C9_download="http://people.freedesktop.org/~hughsient/releases/libgusb-0.1.6.tar.xz "

export libgusb_0_1_6_C9_packname="libgusb-0.1.6.tar.xz"

export libgusb_0_1_6_C9_required_or_recommended="GLib_2_34_3_C9 libusb_1_0_9_C9 gobject_introspection_1_34_2_C9 Udev_Installed_LFS_Version_C12 Vala_0_18_1_C13 "

libical_0_48_C9(){

./configure --prefix=/usr --enable-cxx &&
make
make install &&
install -v -m755 -d /usr/share/doc/libical-0.48 &&
install -v -m644    README doc/{Adding,Using}*.txt \
                    /usr/share/doc/libical-0.48
}

export libical_0_48_C9_download="http://downloads.sourceforge.net/freeassociation/libical-0.48.tar.gz "

export libical_0_48_C9_packname="libical-0.48.tar.gz"

LibIDL_0_8_14_C9(){

./configure --prefix=/usr &&
make &&

makeinfo --plaintext -o libIDL2.txt libIDL2.texi
make pdf ps
make install

install -v -m755 -d /usr/share/doc/libIDL-0.8.14 &&
install -v -m644    README libIDL2.{txt,texi} \
                    /usr/share/doc/libIDL-0.8.14
install -v -m644 libIDL2.{pdf,dvi,ps} \
                 /usr/share/doc/libIDL-0.8.14
}

export LibIDL_0_8_14_C9_download="http://ftp.gnome.org/pub/gnome/sources/libIDL/0.8/libIDL-0.8.14.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libIDL/0.8/libIDL-0.8.14.tar.bz2 "

export LibIDL_0_8_14_C9_packname="libIDL-0.8.14.tar.bz2"

export LibIDL_0_8_14_C9_required_or_recommended="GLib_2_34_3_C9 "

Libidn_1_25_C9(){

./configure --prefix=/usr --disable-static &&
make
make install &&

find doc -name "Makefile*" -delete            &&
rm -rf -v doc/{gdoc,idn.1,stamp-vti,man,texi} &&
mkdir -pv       /usr/share/doc/libidn-1.25     &&
cp -r -v doc/* /usr/share/doc/libidn-1.25
}

export Libidn_1_25_C9_download="http://ftp.gnu.org/gnu/libidn/libidn-1.25.tar.gz ftp://ftp.gnu.org/gnu/libidn/libidn-1.25.tar.gz "

export Libidn_1_25_C9_packname="libidn-1.25.tar.gz"

Libksba_1_3_0_C9(){

./configure --prefix=/usr &&
make
make install
}

export Libksba_1_3_0_C9_download="ftp://ftp.gnupg.org/gcrypt/libksba/libksba-1.3.0.tar.bz2 "

export Libksba_1_3_0_C9_packname="libksba-1.3.0.tar.bz2"

export Libksba_1_3_0_C9_required_or_recommended="libgpg_error_1_11_C9 "

libsigc_2_2_11_C9(){

./configure --prefix=/usr &&
make
make install
}

export libsigc_2_2_11_C9_download="http://ftp.gnome.org/pub/gnome/sources/libsigc++/2.2/libsigc++-2.2.11.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libsigc++/2.2/libsigc++-2.2.11.tar.xz "

export libsigc_2_2_11_C9_packname="libsigc++-2.2.11.tar.xz"

libtasn1_3_2_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
make -C doc/reference install-data-local
}

export libtasn1_3_2_C9_download="http://ftp.gnu.org/gnu/libtasn1/libtasn1-3.2.tar.gz ftp://ftp.gnu.org/gnu/libtasn1/libtasn1-3.2.tar.gz "

export libtasn1_3_2_C9_packname="libtasn1-3.2.tar.gz"

libunique_3_0_2_C9(){

./configure --prefix=/usr &&
make
make install
}

export libunique_3_0_2_C9_download="http://ftp.gnome.org/pub/gnome/sources/libunique/3.0/libunique-3.0.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libunique/3.0/libunique-3.0.2.tar.xz "

export libunique_3_0_2_C9_packname="libunique-3.0.2.tar.xz"

export libunique_3_0_2_C9_required_or_recommended="GTK_3_6_4_C25 gobject_introspection_1_34_2_C9 "

libunistring_0_9_3_C9(){

./configure --prefix=/usr &&
make
make install
}

export libunistring_0_9_3_C9_download="http://ftp.gnu.org/gnu/libunistring/libunistring-0.9.3.tar.gz ftp://ftp.gnu.org/gnu/libunistring/libunistring-0.9.3.tar.gz "

export libunistring_0_9_3_C9_packname="libunistring-0.9.3.tar.gz"

libusb_1_0_9_C9(){

./configure --prefix=/usr --disable-static &&
make
make -C doc docs
make install
install -v -d -m755 /usr/share/doc/libusb-1.0.9/apidocs &&
install -v -m644    doc/html/* \
                    /usr/share/doc/libusb-1.0.9/apidocs
}

export libusb_1_0_9_C9_download="http://downloads.sourceforge.net/libusb/libusb-1.0.9.tar.bz2 "

export libusb_1_0_9_C9_packname="libusb-1.0.9.tar.bz2"

libusb_compat_0_1_4_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libusb_compat_0_1_4_C9_download="http://downloads.sourceforge.net/libusb/libusb-compat-0.1.4.tar.bz2 "

export libusb_compat_0_1_4_C9_packname="libusb-compat-0.1.4.tar.bz2"

export libusb_compat_0_1_4_C9_required_or_recommended="libusb_1_0_9_C9 pkg_config_0_28_C13 "

libxml2_2_9_0_C9(){

tar xf ../xmlts20080827.tar.gz
./configure --prefix=/usr --disable-static &&
make
make install
}

export libxml2_2_9_0_C9_download="http://xmlsoft.org/sources/libxml2-2.9.0.tar.gz ftp://xmlsoft.org/libxml2/libxml2-2.9.0.tar.gz http://www.w3.org/XML/Test/xmlts20080827.tar.gz "

export libxml2_2_9_0_C9_packname="libxml2-2.9.0.tar.gz"

export libxml2_2_9_0_C9_required_or_recommended="Python_2_7_3_C13 "

libxslt_1_1_28_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libxslt_1_1_28_C9_download="http://xmlsoft.org/sources/libxslt-1.1.28.tar.gz ftp://xmlsoft.org/libxslt/libxslt-1.1.28.tar.gz "

export libxslt_1_1_28_C9_packname="libxslt-1.1.28.tar.gz"

export libxslt_1_1_28_C9_required_or_recommended="libxml2_2_9_0_C9 "

LZO_2_06_C9(){

./configure --prefix=/usr                    \
            --enable-shared                  \
            --docdir=/usr/share/doc/lzo-2.06 &&
make
make install
}

export LZO_2_06_C9_download="http://www.oberhumer.com/opensource/lzo/download/lzo-2.06.tar.gz "

export LZO_2_06_C9_packname="lzo-2.06.tar.gz"

mtdev_1_1_3_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export mtdev_1_1_3_C9_download="http://bitmath.org/code/mtdev/mtdev-1.1.3.tar.bz2 "

export mtdev_1_1_3_C9_packname="mtdev-1.1.3.tar.bz2"

NSPR_4_9_6_C9(){

cd mozilla/nsprpub &&
sed -ri 's#^(RELEASE_BINS =).*#\1#' pr/src/misc/Makefile.in &&
sed -i 's#$(LIBRARY) ##' config/rules.mk &&
./configure --prefix=/usr \
            --with-mozilla \
            --with-pthreads \
            $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
make
make install
}

export NSPR_4_9_6_C9_download="http://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.9.6/src/nspr-4.9.6.tar.gz ftp://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.9.6/src/nspr-4.9.6.tar.gz "

export NSPR_4_9_6_C9_packname="nspr-4.9.6.tar.gz"

OpenOBEX_1_6_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export OpenOBEX_1_6_C9_download="http://downloads.sourceforge.net/openobex/openobex-1.6-Source.tar.gz "

export OpenOBEX_1_6_C9_packname="openobex-1.6-Source.tar.gz"

export OpenOBEX_1_6_C9_required_or_recommended="BlueZ_4_101_C12 libusb_compat_0_1_4_C9 "

PCRE_8_32_C9(){

./configure --prefix=/usr                     \
            --docdir=/usr/share/doc/pcre-8.32 \
            --enable-utf                      \
            --enable-unicode-properties       \
            --enable-pcregrep-libz            \
            --enable-pcregrep-libbz2          \
            --disable-static                 &&
make
make install                     &&
mv -v /usr/lib/libpcre.so.* /lib &&
ln -sfv ../../lib/libpcre.so.1.2.0 /usr/lib/libpcre.so
}

export PCRE_8_32_C9_download="http://downloads.sourceforge.net/pcre/pcre-8.32.tar.bz2 ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.32.tar.bz2 "

export PCRE_8_32_C9_packname="pcre-8.32.tar.bz2"

Popt_1_16_C9(){

./configure --prefix=/usr &&
make
make install
install -v -m755 -d /usr/share/doc/popt-1.16 &&
install -v -m644 doxygen/html/* /usr/share/doc/popt-1.16
}

export Popt_1_16_C9_download="http://rpm5.org/files/popt/popt-1.16.tar.gz ftp://anduin.linuxfromscratch.org/BLFS/svn/p/popt-1.16.tar.gz "

export Popt_1_16_C9_packname="popt-1.16.tar.gz"

Pth_2_0_7_C9(){

sed -i 's#$(LOBJS): Makefile#$(LOBJS): pth_p.h Makefile#' Makefile.in &&
./configure --prefix=/usr           \
            --disable-static        \
            --mandir=/usr/share/man &&
make
make install &&
install -v -m755 -d /usr/share/doc/pth-2.0.7 &&
install -v -m644    README PORTING SUPPORT TESTS \
                    /usr/share/doc/pth-2.0.7
}

export Pth_2_0_7_C9_download="http://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz ftp://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz "

export Pth_2_0_7_C9_packname="pth-2.0.7.tar.gz"

Ptlib_2_10_10_C9(){

./configure --prefix=/usr &&
make
make install &&
chmod -v 755 /usr/lib/libpt.so.2.10.10
}

export Ptlib_2_10_10_C9_download="http://ftp.gnome.org/pub/gnome/sources/ptlib/2.10/ptlib-2.10.10.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/ptlib/2.10/ptlib-2.10.10.tar.xz "

export Ptlib_2_10_10_C9_packname="ptlib-2.10.10.tar.xz"

export Ptlib_2_10_10_C9_required_or_recommended="pkg_config_0_28_C13 alsa_lib_1_0_26_C38 Expat_2_1_0_C9 OpenSSL_1_0_1e_C4 "

Qca_2_0_3_C9(){

sed -i '217s@set@this->set@' src/botantools/botan/botan/secmem.h &&
./configure --prefix=$QTDIR \
            --certstore-path=/etc/ssl/ca-bundle.crt &&
make
make install
}

export Qca_2_0_3_C9_download="http://delta.affinix.com/download/qca/2.0/qca-2.0.3.tar.bz2 "

export Qca_2_0_3_C9_packname="qca-2.0.3.tar.bz2"

export Qca_2_0_3_C9_required_or_recommended="Qt_4_8_4_C25 Which_2_20_and_Alternatives_C12 "

SBC_1_0_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export SBC_1_0_C9_download="http://www.kernel.org/pub/linux/bluetooth/sbc-1.0.tar.xz ftp://www.kernel.org/pub/linux/bluetooth/sbc-1.0.tar.xz "

export SBC_1_0_C9_packname="sbc-1.0.tar.xz"

SLIB_3b3_C9(){

sed -i 's|usr/lib|usr/share|' RScheme.init                      &&
./configure --prefix=/usr --libdir=/usr/share                   &&

sed -i 's# scm$# guile#;s#ginstall-info#install-info#' Makefile &&

makeinfo -o slib.txt --plaintext slib.texi                      &&
makeinfo -o slib.html --html --no-split slib.texi
make install                                            &&
ln -v -s ../slib /usr/share/guile                       &&
guile -c "(use-modules (ice-9 slib)) (require 'printf)" &&
install -v -m755 -d /usr/share/doc/slib-3b3             &&
install -v -m644 ANNOUNCE FAQ README slib.{txt,html} /usr/share/doc/slib-3b3
}

export SLIB_3b3_C9_download="http://groups.csail.mit.edu/mac/ftpdir/scm/slib-3b3.tar.gz "

export SLIB_3b3_C9_packname="slib-3b3.tar.gz"

export SLIB_3b3_C9_required_or_recommended="Guile_2_0_7_C13 "

Talloc_2_0_8_C9(){

./configure --prefix=/usr &&
make
make install
}

export Talloc_2_0_8_C9_download="http://samba.org/ftp/talloc/talloc-2.0.8.tar.gz ftp://samba.org/pub/talloc/talloc-2.0.8.tar.gz "

export Talloc_2_0_8_C9_packname="talloc-2.0.8.tar.gz"

telepathy_glib_0_20_1_C9(){

./configure --prefix=/usr \
            --enable-vala-bindings \
            --disable-static &&
make
make install
}

export telepathy_glib_0_20_1_C9_download="http://telepathy.freedesktop.org/releases/telepathy-glib/telepathy-glib-0.20.1.tar.gz "

export telepathy_glib_0_20_1_C9_packname="telepathy-glib-0.20.1.tar.gz"

export telepathy_glib_0_20_1_C9_required_or_recommended="D_Bus_GLib_Bindings_C12 libxslt_1_1_28_C9 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

telepathy_logger_0_8_0_C9(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/telepathy \
            --disable-static &&
make
make install
}

export telepathy_logger_0_8_0_C9_download="http://telepathy.freedesktop.org/releases/telepathy-logger/telepathy-logger-0.8.0.tar.bz2 "

export telepathy_logger_0_8_0_C9_packname="telepathy-logger-0.8.0.tar.bz2"

export telepathy_logger_0_8_0_C9_required_or_recommended="Intltool_0_50_2_C11 SQLite_3_7_16_1_C22 telepathy_glib_0_20_1_C9 gobject_introspection_1_34_2_C9 "

telepathy_farstream_0_6_0_C9(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export telepathy_farstream_0_6_0_C9_download="http://telepathy.freedesktop.org/releases/telepathy-farstream/telepathy-farstream-0.6.0.tar.gz "

export telepathy_farstream_0_6_0_C9_packname="telepathy-farstream-0.6.0.tar.gz"

export telepathy_farstream_0_6_0_C9_required_or_recommended="Farstream_0_2_2_C38 telepathy_glib_0_20_1_C9 "

telepathy_mission_control_5_14_0_C9(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/telepathy \
            --enable-gnome-keyring \
            --disable-static &&
make
make install
}

export telepathy_mission_control_5_14_0_C9_download="http://telepathy.freedesktop.org/releases/telepathy-mission-control/telepathy-mission-control-5.14.0.tar.gz "

export telepathy_mission_control_5_14_0_C9_packname="telepathy-mission-control-5.14.0.tar.gz"

export telepathy_mission_control_5_14_0_C9_required_or_recommended="telepathy_glib_0_20_1_C9 libgnome_keyring_3_6_0_C30 NetworkManager_0_9_8_0_C16 UPower_0_9_20_C12 "

wv_1_2_9_C9(){

./configure --prefix=/usr &&
make
make install
}

export wv_1_2_9_C9_download="http://www.abisource.com/downloads/wv/1.2.9/wv-1.2.9.tar.gz wv.html "

export wv_1_2_9_C9_packname="wv-1.2.9.tar.gz"

export wv_1_2_9_C9_required_or_recommended="libgsf_1_14_26_C9 libpng_1_5_14_C10 "

export C9_GeneralLibraries="Apr_1_4_6_C9 Aspell_0_60_6_1_C9 Boost_1_53_0_C9 enchant_1_6_0_C9 Exempi_2_2_0_C9 Expat_2_1_0_C9 Gamin_0_1_10_C9 GLib_2_34_3_C9 GLibmm_2_34_1_C9 GMime_2_6_15_C9 gobject_introspection_1_34_2_C9 Gsl_1_15_C9 ICU_51_1_C9 ISO_Codes_3_40_C9 JSON_C_0_10_C9 JSON_GLib_0_15_2_C9 keyutils_1_5_5_C9 libassuan_2_1_0_C9 libatasmart_0_19_C9 libatomic_ops_7_2d_C9 libcroco_0_6_8_C9 libdaemon_0_14_C9 libdbusmenu_qt_0_9_2_C9 libdrm_2_4_43_C9 libESMTP_1_0_6_C9 libffi_3_0_13_C9 libgcrypt_1_5_1_C9 libglade_2_6_4_C9 libgpg_error_1_11_C9 libgsf_1_14_26_C9 libgusb_0_1_6_C9 libical_0_48_C9 LibIDL_0_8_14_C9 Libidn_1_25_C9 Libksba_1_3_0_C9 libsigc_2_2_11_C9 libtasn1_3_2_C9 libunique_3_0_2_C9 libunistring_0_9_3_C9 libusb_1_0_9_C9 libusb_compat_0_1_4_C9 libxml2_2_9_0_C9 libxslt_1_1_28_C9 LZO_2_06_C9 mtdev_1_1_3_C9 NSPR_4_9_6_C9 OpenOBEX_1_6_C9 PCRE_8_32_C9 Popt_1_16_C9 Pth_2_0_7_C9 Ptlib_2_10_10_C9 Qca_2_0_3_C9 SBC_1_0_C9 SLIB_3b3_C9 Talloc_2_0_8_C9 telepathy_glib_0_20_1_C9 telepathy_logger_0_8_0_C9 telepathy_farstream_0_6_0_C9 telepathy_mission_control_5_14_0_C9 wv_1_2_9_C9 "


AAlib_1_4rc5_C10(){

sed -i -e '/AM_PATH_AALIB,/s/AM_PATH_AALIB/[&]/' aalib.m4
./configure --prefix=/usr \
            --infodir=/usr/share/info \
            --mandir=/usr/share/man \
            --disable-static &&
make
make install
}

export AAlib_1_4rc5_C10_download="http://downloads.sourceforge.net/aa-project/aalib-1.4rc5.tar.gz ftp://ftp.ratmir.tver.ru/pub/FreeBsd/ports/distfiles/aalib-1.4rc5.tar.gz "

export AAlib_1_4rc5_C10_packname="aalib-1.4rc5.tar.gz"

babl_0_1_10_C10(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d /usr/share/gtk-doc/html/babl/graphics &&
install -v -m644 docs/*.{css,html} /usr/share/gtk-doc/html/babl &&
install -v -m644 docs/graphics/*.{html,png,svg} /usr/share/gtk-doc/html/babl/graphics

}

export babl_0_1_10_C10_download="ftp://ftp.gimp.org/pub/babl/0.1//babl-0.1.10.tar.bz2 "

export babl_0_1_10_C10_packname="babl-0.1.10.tar.bz2"

export babl_0_1_10_C10_required_or_recommended="pkg_config_0_28_C13 "

Exiv2_0_23_C10(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Exiv2_0_23_C10_download="http://www.exiv2.org/exiv2-0.23.tar.gz "

export Exiv2_0_23_C10_packname="exiv2-0.23.tar.gz"

export Exiv2_0_23_C10_required_or_recommended="Expat_2_1_0_C9 "

FreeType_2_4_11_C10(){

tar -xf ../freetype-doc-2.4.11.tar.bz2 \
    --strip-components=2 -C docs
sed -i -r 's:.*(#.*SUBPIXEL.*) .*:\1:' \
          include/freetype/config/ftoption.h &&
./configure --prefix=/usr --disable-static &&
make
make install &&
install -v -m755 -d /usr/share/doc/freetype-2.4.11 &&
cp -v -R docs/*     /usr/share/doc/freetype-2.4.11
}

export FreeType_2_4_11_C10_download="http://downloads.sourceforge.net/freetype/freetype-2.4.11.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/freetype-2.4.11.tar.bz2 http://downloads.sourceforge.net/freetype/freetype-doc-2.4.11.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/freetype-doc-2.4.11.tar.bz2 "

export FreeType_2_4_11_C10_packname="freetype-2.4.11.tar.bz2"

Fontconfig_2_10_2_C10(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --docdir=/usr/share/doc/fontconfig-2.10.2 \
            --disable-docs \
            --disable-static &&
make
make install
install -v -dm755 \
        /usr/share/{man/man{3,5},doc/fontconfig-2.10.2/fontconfig-devel} &&
install -v -m644 fc-*/*.1          /usr/share/man/man1 &&
install -v -m644 doc/*.3           /usr/share/man/man3 &&
install -v -m644 doc/fonts-conf.5  /usr/share/man/man5 &&
install -v -m644 doc/fontconfig-devel/* \
        /usr/share/doc/fontconfig-2.10.2/fontconfig-devel &&
install -v -m644 doc/*.{pdf,sgml,txt,html} \
       /usr/share/doc/fontconfig-2.10.2
}

export Fontconfig_2_10_2_C10_download="http://fontconfig.org/release/fontconfig-2.10.2.tar.bz2 "

export Fontconfig_2_10_2_C10_packname="fontconfig-2.10.2.tar.bz2"

export Fontconfig_2_10_2_C10_required_or_recommended="FreeType_2_4_11_C10 Expat_2_1_0_C9 "

FriBidi_0_19_5_C10(){

sed -i "s|glib/gstrfuncs\.h|glib.h|" charset/fribidi-char-sets.c &&
sed -i "s|glib/gmem\.h|glib.h|"      lib/mem.h                   &&
./configure --prefix=/usr                                        &&
make
make install
}

export FriBidi_0_19_5_C10_download="http://fribidi.org/download/fribidi-0.19.5.tar.bz2 "

export FriBidi_0_19_5_C10_packname="fribidi-0.19.5.tar.bz2"

gegl_0_2_0_C10(){

sed -e '274cerr = avformat_open_input (&p->ic, o->path, NULL, NULL);' \
    -i operations/external/ff-load.c &&
./configure --prefix=/usr &&
make
make install &&
install -v -m644 docs/*.{css,html} /usr/share/gtk-doc/html/gegl &&
install -d -v -m755 /usr/share/gtk-doc/html/gegl/images &&
install -v -m644 docs/images/* /usr/share/gtk-doc/html/gegl/images

}

export gegl_0_2_0_C10_download="ftp://ftp.gimp.org/pub/gegl/0.2/gegl-0.2.0.tar.bz2 "

export gegl_0_2_0_C10_packname="gegl-0.2.0.tar.bz2"

export gegl_0_2_0_C10_required_or_recommended="babl_0_1_10_C10 "

giflib_4_1_6_C10(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d /usr/share/doc/giflib-4.1.6/html &&
install -v -m644 doc/*.{png,html} \
    /usr/share/doc/giflib-4.1.6/html &&
install -v -m644 doc/*.txt \
    /usr/share/doc/giflib-4.1.6
}

export giflib_4_1_6_C10_download="http://downloads.sourceforge.net/giflib/giflib-4.1.6.tar.bz2 "

export giflib_4_1_6_C10_packname="giflib-4.1.6.tar.bz2"

Harfbuzz_0_9_14_C10(){

./configure --prefix=/usr &&
make
make install
}

export Harfbuzz_0_9_14_C10_download="http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.14.tar.bz2 "

export Harfbuzz_0_9_14_C10_packname="harfbuzz-0.9.14.tar.bz2"

export Harfbuzz_0_9_14_C10_required_or_recommended="GLib_2_34_3_C9 ICU_51_1_C9 FreeType_2_4_11_C10 "

IJS_0_35_C10(){

./configure --prefix=/usr \
            --mandir=/usr/share/man \
            --enable-shared \
            --disable-static &&
make
make install
}

export IJS_0_35_C10_download="http://www.openprinting.org/download/ijs/download/ijs-0.35.tar.bz2 "

export IJS_0_35_C10_packname="ijs-0.35.tar.bz2"

Imlib2_1_4_5_C10(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d /usr/share/doc/imlib2-1.4.5 &&
install -v -m644    doc/{*.gif,index.html} \
                    /usr/share/doc/imlib2-1.4.5
}

export Imlib2_1_4_5_C10_download="http://downloads.sourceforge.net/enlightenment/imlib2-1.4.5.tar.bz2 "

export Imlib2_1_4_5_C10_packname="imlib2-1.4.5.tar.bz2"

export Imlib2_1_4_5_C10_required_or_recommended="FreeType_2_4_11_C10 libpng_1_5_14_C10 libjpeg_turbo_1_2_1_C10 XWindowSystemEnvironment "

JasPer_1_900_1_C10(){

patch -Np1 -i ../jasper-1.900.1-security_fixes-1.patch &&
./configure --prefix=/usr --enable-shared &&
make
make install
install -v -m755 -d /usr/share/doc/jasper-1.900.1 &&
install -v -m644 doc/*.pdf /usr/share/doc/jasper-1.900.1
}

export JasPer_1_900_1_C10_download="http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-1.900.1.zip http://www.linuxfromscratch.org/patches/blfs/svn/jasper-1.900.1-security_fixes-1.patch "

export JasPer_1_900_1_C10_packname="jasper-1.900.1.zip"

export JasPer_1_900_1_C10_required_or_recommended="UnZip_6_0_C12 "

Little_CMS_1_19_C10(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d /usr/share/doc/lcms-1.19 &&
install -v -m644    README.1ST doc/* \
                    /usr/share/doc/lcms-1.19
}

export Little_CMS_1_19_C10_download="http://sourceforge.net/projects/lcms/files/lcms/1.19/lcms-1.19.tar.gz "

export Little_CMS_1_19_C10_packname="lcms-1.19.tar.gz"

Little_CMS_2_4_C10(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Little_CMS_2_4_C10_download="http://downloads.sourceforge.net/lcms/lcms2-2.4.tar.gz "

export Little_CMS_2_4_C10_packname="lcms2-2.4.tar.gz"

libart_lgpl_2_3_21_C10(){

patch -Np1 -i ../libart_lgpl-2.3.21-upstream_fixes-1.patch &&
./configure --prefix=/usr &&
make
make install
}

export libart_lgpl_2_3_21_C10_download="http://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3/libart_lgpl-2.3.21.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3/libart_lgpl-2.3.21.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/libart_lgpl-2.3.21-upstream_fixes-1.patch "

export libart_lgpl_2_3_21_C10_packname="libart_lgpl-2.3.21.tar.bz2"

libexif_0_6_21_C10(){

./configure --prefix=/usr \
            --with-doc-dir=/usr/share/doc/libexif-0.6.21 \
            --disable-static &&
make
make install
}

export libexif_0_6_21_C10_download="http://downloads.sourceforge.net/libexif/libexif-0.6.21.tar.bz2 "

export libexif_0_6_21_C10_packname="libexif-0.6.21.tar.bz2"

libjpeg_turbo_1_2_1_C10(){

./configure --prefix=/usr \
            --mandir=/usr/share/man \
            --with-jpeg8 \
            --disable-static &&
make
docsdir=/usr/share/doc/libjpeg-turbo-1.2.1 &&
make docdir=$docsdir exampledir=$docsdir install &&
unset docsdir
}

export libjpeg_turbo_1_2_1_C10_download="http://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.2.1.tar.gz "

export libjpeg_turbo_1_2_1_C10_packname="libjpeg-turbo-1.2.1.tar.gz"

export libjpeg_turbo_1_2_1_C10_required_or_recommended="NASM_2_10_07_C13 "

libmng_1_0_10_C10(){

cp makefiles/makefile.linux Makefile         &&
sed -i -e 's/unroll-loops/& -fPIC/' Makefile &&
make
make prefix=/usr install &&
install -v -m644 doc/man/*.3 /usr/share/man/man3 &&
install -v -m644 doc/man/*.5 /usr/share/man/man5 &&
install -v -m755 -d /usr/share/doc/libmng-1.0.10 &&
install -v -m644 doc/*.{png,txt} /usr/share/doc/libmng-1.0.10
}

export libmng_1_0_10_C10_download="http://downloads.sourceforge.net/libmng/libmng-1.0.10.tar.bz2 "

export libmng_1_0_10_C10_packname="libmng-1.0.10.tar.bz2"

export libmng_1_0_10_C10_required_or_recommended="libjpeg_turbo_1_2_1_C10 Little_CMS_1_19_C10 "

libpng_1_5_14_C10(){

gzip -cd ../libpng-1.5.14-apng.patch.gz | patch -p1
./configure --prefix=/usr --disable-static &&
make
make install &&
mkdir -pv /usr/share/doc/libpng-1.5.14 &&
cp -v README libpng-manual.txt /usr/share/doc/libpng-1.5.14
}

export libpng_1_5_14_C10_download="http://downloads.sourceforge.net/libpng/libpng-1.5.14.tar.xz http://downloads.sourceforge.net/libpng-apng/libpng-1.5.14-apng.patch.gz "

export libpng_1_5_14_C10_packname="libpng-1.5.14.tar.xz"

librsvg_2_36_4_C10(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export librsvg_2_36_4_C10_download="http://ftp.gnome.org/pub/gnome/sources/librsvg/2.36/librsvg-2.36.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/librsvg/2.36/librsvg-2.36.4.tar.xz "

export librsvg_2_36_4_C10_packname="librsvg-2.36.4.tar.xz"

export librsvg_2_36_4_C10_required_or_recommended="gdk_pixbuf_2_26_5_C25 libcroco_0_6_8_C9 Pango_1_32_5_C25 GTK_2_24_17_C25 GTK_3_6_4_C25 "

LibTIFF_4_0_3_C10(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export LibTIFF_4_0_3_C10_download="http://download.osgeo.org/libtiff/tiff-4.0.3.tar.gz ftp://ftp.remotesensing.org/libtiff/tiff-4.0.3.tar.gz "

export LibTIFF_4_0_3_C10_packname="tiff-4.0.3.tar.gz"

OpenJPEG_1_5_1_C10(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export OpenJPEG_1_5_1_C10_download="http://openjpeg.googlecode.com/files/openjpeg-1.5.1.tar.gz "

export OpenJPEG_1_5_1_C10_packname="openjpeg-1.5.1.tar.gz"

export OpenJPEG_1_5_1_C10_required_or_recommended="pkg_config_0_28_C13 "

Pixman_0_28_2_C10(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Pixman_0_28_2_C10_download="http://cairographics.org/releases/pixman-0.28.2.tar.gz "

export Pixman_0_28_2_C10_packname="pixman-0.28.2.tar.gz"

Poppler_0_22_2_C10(){

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-zlib     \
            --disable-static  \
            --enable-xpdf-headers &&
make
make install &&
install -v -m755 -d      /usr/share/doc/poppler-0.22.2 &&
install -v -m644 README* /usr/share/doc/poppler-0.22.2
tar -xf ../poppler-data-0.4.6.tar.gz &&
cd poppler-data-0.4.6
make prefix=/usr install
}

export Poppler_0_22_2_C10_download="http://poppler.freedesktop.org/poppler-0.22.2.tar.gz http://poppler.freedesktop.org/poppler-data-0.4.6.tar.gz "

export Poppler_0_22_2_C10_packname="poppler-0.22.2.tar.gz"

export Poppler_0_22_2_C10_required_or_recommended="Fontconfig_2_10_2_C10 Cairo_1_12_14_C25 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 "

Qpdf_4_0_1_C10(){

./configure --prefix=/usr --disable-static &&
make
make docdir=/usr/share/doc/qpdf-4.0.1 install
}

export Qpdf_4_0_1_C10_download="http://downloads.sourceforge.net/qpdf/qpdf-4.0.1.tar.gz "

export Qpdf_4_0_1_C10_packname="qpdf-4.0.1.tar.gz"

export Qpdf_4_0_1_C10_required_or_recommended="PCRE_8_32_C9 "

export C10_GraphicsandFontLibraries="AAlib_1_4rc5_C10 babl_0_1_10_C10 Exiv2_0_23_C10 FreeType_2_4_11_C10 Fontconfig_2_10_2_C10 FriBidi_0_19_5_C10 gegl_0_2_0_C10 giflib_4_1_6_C10 Harfbuzz_0_9_14_C10 IJS_0_35_C10 Imlib2_1_4_5_C10 JasPer_1_900_1_C10 Little_CMS_1_19_C10 Little_CMS_2_4_C10 libart_lgpl_2_3_21_C10 libexif_0_6_21_C10 libjpeg_turbo_1_2_1_C10 libmng_1_0_10_C10 libpng_1_5_14_C10 librsvg_2_36_4_C10 LibTIFF_4_0_3_C10 OpenJPEG_1_5_1_C10 Pixman_0_28_2_C10 Poppler_0_22_2_C10 Qpdf_4_0_1_C10 "


Apr_Util_1_5_1_C11(){

./configure --prefix=/usr --with-apr=/usr --with-gdbm=/usr &&
make
make install
}

export Apr_Util_1_5_1_C11_download="http://archive.apache.org/dist/apr/apr-util-1.5.1.tar.bz2 ftp://ftp.mirrorservice.org/sites/ftp.apache.org/apr/apr-util-1.5.1.tar.bz2 "

export Apr_Util_1_5_1_C11_packname="apr-util-1.5.1.tar.bz2"

export Apr_Util_1_5_1_C11_required_or_recommended="Apr_1_4_6_C9 "

bc_1_06_95_C11(){

./configure --prefix=/usr --with-readline &&
make
echo "quit" | ./bc/bc -l Test/checklib.b
make install
}

export bc_1_06_95_C11_download="http://alpha.gnu.org/gnu//bc/bc-1.06.95.tar.bz2 ftp://alpha.gnu.org/gnu//bc/bc-1.06.95.tar.bz2 "

export bc_1_06_95_C11_packname="bc-1.06.95.tar.bz2"

Compface_1_5_2_C11(){

./configure --prefix=/usr &&
make
make install &&
install -m755 -v xbm2xface.pl /usr/bin
}

export Compface_1_5_2_C11_download="http://ftp.xemacs.org/pub/xemacs/aux/compface-1.5.2.tar.gz "

export Compface_1_5_2_C11_packname="compface-1.5.2.tar.gz"

desktop_file_utils_0_21_C11(){

./configure --prefix=/usr &&
make
make install
update-desktop-database /usr/share/applications
}

export desktop_file_utils_0_21_C11_download="http://freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.21.tar.xz "

export desktop_file_utils_0_21_C11_packname="desktop-file-utils-0.21.tar.xz"

export desktop_file_utils_0_21_C11_required_or_recommended="GLib_2_34_3_C9 "

Gperf_3_0_4_C11(){

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4 &&
make
make install &&

install -m644 -v doc/gperf.{dvi,ps,pdf} \
                 /usr/share/doc/gperf-3.0.4 &&

pushd /usr/share/info &&
rm -v dir &&
for FILENAME in *; do
    install-info $FILENAME dir 2>/dev/null
done &&
popd
}

export Gperf_3_0_4_C11_download="http://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz ftp://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz "

export Gperf_3_0_4_C11_packname="gperf-3.0.4.tar.gz"

Graphviz_2_30_1_C11(){

./configure --prefix=/usr --disable-static &&
make
make install
ln -v -s /usr/share/graphviz/doc \
         /usr/share/doc/graphviz-2.30.1
}

export Graphviz_2_30_1_C11_download="http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.30.1.tar.gz "

export Graphviz_2_30_1_C11_packname="graphviz-2.30.1.tar.gz"

export Graphviz_2_30_1_C11_required_or_recommended="Expat_2_1_0_C9 FreeType_2_4_11_C10 Fontconfig_2_10_2_C10 Freeglut_2_8_0_C25 gdk_pixbuf_2_26_5_C25 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 librsvg_2_36_4_C10 Pango_1_32_5_C25 Xorg_Libraries_C24 "

GTK_Doc_1_18_C11(){

./configure --prefix=/usr &&
make
make install
}

export GTK_Doc_1_18_C11_download="http://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.18/gtk-doc-1.18.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.18/gtk-doc-1.18.tar.xz "

export GTK_Doc_1_18_C11_packname="gtk-doc-1.18.tar.xz"

export GTK_Doc_1_18_C11_required_or_recommended="docbook_xml_4_5_C45 docbook_xsl_1_77_1_C45 libxslt_1_1_28_C9 pkg_config_0_28_C13 "

Hd2u_1_0_3_C11(){

./configure --prefix=/usr &&
make
make install
}

export Hd2u_1_0_3_C11_download="http://www.megaloman.com/~hany/_data/hd2u/hd2u-1.0.3.tgz "

export Hd2u_1_0_3_C11_packname="hd2u-1.0.3.tgz"

export Hd2u_1_0_3_C11_required_or_recommended="Popt_1_16_C9 "

icon_naming_utils_0_8_90_C11(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/icon-naming-utils &&
make
make install
}

export icon_naming_utils_0_8_90_C11_download="http://tango.freedesktop.org/releases/icon-naming-utils-0.8.90.tar.bz2 "

export icon_naming_utils_0_8_90_C11_packname="icon-naming-utils-0.8.90.tar.bz2"

export icon_naming_utils_0_8_90_C11_required_or_recommended="XML_Simple_2_20_C13 "

ImageMagick_6_8_2_8_C11(){

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --with-modules    \
            --with-perl       \
            --disable-static  &&
make
make install
}

export ImageMagick_6_8_2_8_C11_download="ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.8.2-8.tar.xz "

export ImageMagick_6_8_2_8_C11_packname="ImageMagick-6.8.2-8.tar.xz"

export ImageMagick_6_8_2_8_C11_required_or_recommended="XWindowSystemEnvironment "

Intltool_0_50_2_C11(){

./configure --prefix=/usr &&
make
make install &&
install -v -m644 -D doc/I18N-HOWTO \
    /usr/share/doc/intltool-0.50.2/I18N-HOWTO
}

export Intltool_0_50_2_C11_download="http://launchpad.net/intltool/trunk/0.50.2/+download/intltool-0.50.2.tar.gz "

export Intltool_0_50_2_C11_packname="intltool-0.50.2.tar.gz"

export Intltool_0_50_2_C11_required_or_recommended="XML_Parser_2_41_C13 "

libiodbc_3_52_8_C11(){

./configure --prefix=/usr                   \
            --with-iodbc-inidir=/etc/iodbc  \
            --includedir=/usr/include/iodbc \
            --disable-libodbc               &&
make
make install
}

export libiodbc_3_52_8_C11_download="http://downloads.sourceforge.net/project/iodbc/iodbc/3.52.8/libiodbc-3.52.8.tar.gz "

export libiodbc_3_52_8_C11_packname="libiodbc-3.52.8.tar.gz"

export libiodbc_3_52_8_C11_required_or_recommended="GTK_2_24_17_C25 "

PIN_Entry_0_8_2_C11(){

./configure --prefix=/usr &&
make
make install
}

export PIN_Entry_0_8_2_C11_download="ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-0.8.2.tar.bz2 "

export PIN_Entry_0_8_2_C11_packname="pinentry-0.8.2.tar.bz2"

Rarian_0_8_1_C11(){

./configure --prefix=/usr \
            --localstatedir=/var &&
make
make install
}

export Rarian_0_8_1_C11_download="http://ftp.gnome.org/pub/gnome/sources/rarian/0.8/rarian-0.8.1.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/rarian/0.8/rarian-0.8.1.tar.bz2 "

export Rarian_0_8_1_C11_packname="rarian-0.8.1.tar.bz2"

export Rarian_0_8_1_C11_required_or_recommended="libxslt_1_1_28_C9 docbook_xml_4_5_C45 "

Rep_gtk_0_90_8_1_C11(){

./configure --prefix=/usr &&
make
make install
}

export Rep_gtk_0_90_8_1_C11_download="http://download.tuxfamily.org/librep/rep-gtk/rep-gtk-0.90.8.1.tar.xz "

export Rep_gtk_0_90_8_1_C11_packname="rep-gtk-0.90.8.1.tar.xz"

export Rep_gtk_0_90_8_1_C11_required_or_recommended="libglade_2_6_4_C9 Librep_0_92_2_1_C13 "

rxvt_unicode_9_15_C11(){

./configure --prefix=/usr --enable-everything &&
make
make install
cat >> /etc/X11/app-defaults/URxvt << "EOF"
URxvt*perl-ext: matcher
URxvt*urlLauncher: firefox
URxvt.background: black
URxvt.foreground: yellow
URxvt*font: xft:Monospace:pixelsize=12
EOF

# Start the urxvtd daemon
urxvtd -q -f -o &

}

export rxvt_unicode_9_15_C11_download="http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-9.15.tar.bz2 "

export rxvt_unicode_9_15_C11_packname="rxvt-unicode-9.15.tar.bz2"

export rxvt_unicode_9_15_C11_required_or_recommended="XWindowSystemEnvironment pkg_config_0_28_C13 "

Screen_4_0_3_C11(){

./configure --prefix=/usr                     \
            --with-socket-dir=/var/run/screen \
            --with-pty-group=4                \
            --with-sys-screenrc=/etc/screenrc                    &&
sed -i -e "s%/usr/local/etc/screenrc%/etc/screenrc%" {etc,doc}/* &&
make
make install &&
install -m 644 etc/etcscreenrc /etc/screenrc
}

export Screen_4_0_3_C11_download="http://ftp.uni-erlangen.de/pub/utilities/screen/screen-4.0.3.tar.gz ftp://ftp.uni-erlangen.de/pub/utilities/screen/screen-4.0.3.tar.gz "

export Screen_4_0_3_C11_packname="screen-4.0.3.tar.gz"

Sharutils_4_13_3_C11(){

./configure --prefix=/usr &&
make
make install
}

export Sharutils_4_13_3_C11_download="http://ftp.gnu.org/gnu/sharutils/sharutils-4.13.3.tar.xz ftp://ftp.gnu.org/gnu/sharutils/sharutils-4.13.3.tar.xz "

export Sharutils_4_13_3_C11_packname="sharutils-4.13.3.tar.xz"

SpiderMonkey_1_0_0_C11(){

cd js/src &&
sed -i 's#s \($(SHLIB_\(ABI\|EXACT\)_VER)\)#s $(notdir \1)#' Makefile.in &&
./configure --prefix=/usr --enable-threadsafe --with-system-nspr &&
make
make install
}

export SpiderMonkey_1_0_0_C11_download="http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz ftp://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz "

export SpiderMonkey_1_0_0_C11_packname="js185-1.0.0.tar.gz"

export SpiderMonkey_1_0_0_C11_required_or_recommended="NSPR_4_9_6_C9 Python_2_7_3_C13 Zip_3_0_C12 "

HTML_Tidy_cvs_20101110_C11(){

./configure --prefix=/usr &&
make
make install &&

install -v -m644 -D htmldoc/tidy.1 \
                    /usr/share/man/man1/tidy.1 &&
install -v -m755 -d /usr/share/doc/tidy-cvs_20101110 &&
install -v -m644    htmldoc/*.{html,gif,css} \
                    /usr/share/doc/tidy-cvs_20101110
}

export HTML_Tidy_cvs_20101110_C11_download="http://anduin.linuxfromscratch.org/sources/BLFS/svn/t/tidy-cvs_20101110.tar.bz2 "

export HTML_Tidy_cvs_20101110_C11_packname="tidy-cvs_20101110.tar.bz2"

unixODBC_2_3_1_C11(){

./configure --prefix=/usr \
            --sysconfdir=/etc/unixODBC &&
make
make install &&

find doc -name "Makefile*" -exec rm {} \; &&
chmod 644 doc/{lst,ProgrammerManual/Tutorial}/* &&

install -v -m755 -d /usr/share/doc/unixODBC-2.3.1 &&
cp -v -R doc/* /usr/share/doc/unixODBC-2.3.1
}

export unixODBC_2_3_1_C11_download="http://www.unixodbc.org/unixODBC-2.3.1.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/unixODBC-2.3.1.tar.gz "

export unixODBC_2_3_1_C11_packname="unixODBC-2.3.1.tar.gz"

XScreenSaver_5_21_C11(){

./configure --prefix=/usr --libexecdir=/usr/lib &&
make
make install
cat > /etc/pam.d/xscreensaver << "EOF"
# Begin /etc/pam.d/xscreensaver

auth    include system-auth
account include system-account

# End /etc/pam.d/xscreensaver
EOF

}

export XScreenSaver_5_21_C11_download="http://www.jwz.org/xscreensaver/xscreensaver-5.21.tar.gz "

export XScreenSaver_5_21_C11_packname="xscreensaver-5.21.tar.gz"

export XScreenSaver_5_21_C11_required_or_recommended="bc_1_06_95_C11 libglade_2_6_4_C9 Xorg_Applications_C24 "

export C11_GeneralUtilities="Apr_Util_1_5_1_C11 bc_1_06_95_C11 Compface_1_5_2_C11 desktop_file_utils_0_21_C11 Gperf_3_0_4_C11 Graphviz_2_30_1_C11 GTK_Doc_1_18_C11 Hd2u_1_0_3_C11 icon_naming_utils_0_8_90_C11 ImageMagick_6_8_2_8_C11 Intltool_0_50_2_C11 libiodbc_3_52_8_C11 PIN_Entry_0_8_2_C11 Rarian_0_8_1_C11 Rep_gtk_0_90_8_1_C11 rxvt_unicode_9_15_C11 Screen_4_0_3_C11 Sharutils_4_13_3_C11 SpiderMonkey_1_0_0_C11 HTML_Tidy_cvs_20101110_C11 unixODBC_2_3_1_C11 XScreenSaver_5_21_C11 "


apache_ant_1_8_4_C12(){

sed -i 's;jars,test-jar;jars;' build.xml
cp -v /usr/share/junit-4.10/junit-4.10.jar lib/optional/junit.jar
./build.sh -Ddist.dir=/opt/ant-1.8.4 dist &&
ln -v -sfn ant-1.8.4 /opt/ant
}

export apache_ant_1_8_4_C12_download="http://archive.apache.org/dist/ant/source/apache-ant-1.8.4-src.tar.bz2 "

export apache_ant_1_8_4_C12_packname="apache-ant-1.8.4-src.tar.bz2"

export apache_ant_1_8_4_C12_required_or_recommended="OpenJDK_1_7_0_9_C13 JUnit_4_10_C13 "

at_3_1_13_C12(){

groupadd -g 17 atd                                                  &&
useradd -d /dev/null -c "atd daemon" -g atd -s /bin/false -u 17 atd &&
mkdir -p /var/spool/cron
./configure --with-daemon_username=atd  \
            --with-daemon_groupname=atd &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-atd
}

export at_3_1_13_C12_download="http://ftp.de.debian.org/debian/pool/main/a/at/at_3.1.13.orig.tar.gz ftp://ftp.de.debian.org/debian/pool/main/a/at/at_3.1.13.orig.tar.gz "

export at_3_1_13_C12_packname="at_3.1.13.orig.tar.gz"

autofs_5_0_7_C12(){

./configure --prefix=/ --mandir=/usr/share/man &&
make
make install
mv /etc/auto.master /etc/auto.master.bak &&
cat > /etc/auto.master << "EOF"
# Begin /etc/auto.master

/media/auto  /etc/auto.misc  --ghost
#/home        /etc/auto.home

# End /etc/auto.master
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-autofs
}

export autofs_5_0_7_C12_download="http://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.7.tar.xz ftp://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.7.tar.xz "

export autofs_5_0_7_C12_packname="autofs-5.0.7.tar.xz"

export autofs_5_0_7_C12_required_or_recommended="OpenLDAP_2_4_34_C23 Cyrus_SASL_2_1_25_C4 MIT_Kerberos_V5_1_11_1_C4 "

BlueZ_4_101_C12(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/lib \
            --enable-bccmd \
            --enable-dfutool \
            --enable-dund \
            --enable-hid2hci \
            --enable-hidd \
            --enable-pand \
            --enable-tools \
            --enable-wiimote \
            --disable-test \
            --without-systemdunitdir &&
make
make install
for CONFFILE in audio input network serial ; do
    install -v -m644 ${CONFFILE}/${CONFFILE}.conf /etc/bluetooth/${CONFFILE}.conf
done
unset CONFFILE
install -v -m755 -d /usr/share/doc/bluez-4.101 &&
install -v -m644 doc/*.txt /usr/share/doc/bluez-4.101
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-bluetooth
}

export BlueZ_4_101_C12_download="http://www.kernel.org/pub/linux/bluetooth/bluez-4.101.tar.xz ftp://ftp.kernel.org/pub/linux/bluetooth/bluez-4.101.tar.xz "

export BlueZ_4_101_C12_packname="bluez-4.101.tar.xz"

export BlueZ_4_101_C12_required_or_recommended="D_Bus_1_6_8_C12 GLib_2_34_3_C9 "

Colord_0_1_31_C12(){

groupadd -g 71 colord &&
useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71 \
        -g colord -s /bin/false colord
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/colord \
            --with-daemon-user=colord \
            --enable-vala \
            --disable-systemd-login \
            --disable-static &&
make
make install
}

export Colord_0_1_31_C12_download="http://www.freedesktop.org/software/colord/releases/colord-0.1.31.tar.xz "

export Colord_0_1_31_C12_packname="colord-0.1.31.tar.xz"

export Colord_0_1_31_C12_required_or_recommended="D_Bus_1_6_8_C12 libgusb_0_1_6_C9 Little_CMS_2_4_C10 SQLite_3_7_16_1_C22 gobject_introspection_1_34_2_C9 Polkit_0_110_C4 Udev_Installed_LFS_Version_C12 Vala_0_18_1_C13 "

cpio_2_11_C12(){

sed -i -e '/gets is a/d' gnu/stdio.in.h &&
./configure --prefix=/usr     \
            --bindir=/bin     \
            --libexecdir=/tmp \
            --enable-mt       \
            --with-rmt=/usr/sbin/rmt &&
make &&
 
make install 
 
}

export cpio_2_11_C12_download="http://ftp.gnu.org/pub/gnu/cpio/cpio-2.11.tar.bz2 ftp://ftp.gnu.org/pub/gnu/cpio/cpio-2.11.tar.bz2 "

export cpio_2_11_C12_packname="cpio-2.11.tar.bz2"

D_Bus_1_6_8_C12(){

groupadd -g 18 messagebus &&
useradd -c "D-Bus Message Daemon User" -d /var/run/dbus \
        -u 18 -g messagebus -s /bin/false messagebus
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/dbus-1.0 \
            --with-console-auth-dir=/run/console/ \
            --without-systemdsystemunitdir \
            --disable-systemd \
            --disable-static &&
make
make install &&
mv -v /usr/share/doc/dbus /usr/share/doc/dbus-1.6.8
dbus-uuidgen --ensure
make distclean &&
./configure --enable-tests --enable-asserts &&
make &&
make distclean
cat > /etc/dbus-1/session-local.conf << "EOF"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <!-- Search for .service files in /usr/local -->
  <servicedir>/usr/local/share/dbus-1/services</servicedir>

</busconfig>
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-dbus
# Start the D-Bus session daemon
eval `dbus-launch`
export DBUS_SESSION_BUS_ADDRESS

# Kill the D-Bus session daemon
kill $DBUS_SESSION_BUS_PID

}

export D_Bus_1_6_8_C12_download="http://dbus.freedesktop.org/releases/dbus/dbus-1.6.8.tar.gz http://www.linuxfromscratch.org/hints/downloads/files/execute-session-scripts-using-kdm.txt "

export D_Bus_1_6_8_C12_packname="dbus-1.6.8.tar.gz"

export D_Bus_1_6_8_C12_required_or_recommended="Expat_2_1_0_C9 Xorg_Libraries_C24 "

export Introduction_to_D_Bus_Bindings_C12_download=""

export Introduction_to_D_Bus_Bindings_C12_packname=""

D_Bus_GLib_Bindings_C12(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/dbus-1.0 \
            --disable-static &&
make
make install
}

export D_Bus_GLib_Bindings_C12_download="http://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.100.2.tar.gz "

export D_Bus_GLib_Bindings_C12_packname="dbus-glib-0.100.2.tar.gz"

export D_Bus_GLib_Bindings_C12_required_or_recommended="D_Bus_1_6_8_C12 Expat_2_1_0_C9 GLib_2_34_3_C9 "

D_Bus_Python_Bindings_C12(){

./configure --prefix=/usr \
            --docdir=/usr/share/doc/dbus-python-1.1.1 &&
make
make install
install -v -m755 -d /usr/share/doc/dbus-python-1.1.1/api &&
install -v -m644    api/* \
                    /usr/share/doc/dbus-python-1.1.1/api
}

export D_Bus_Python_Bindings_C12_download="http://dbus.freedesktop.org/releases/dbus-python/dbus-python-1.1.1.tar.gz "

export D_Bus_Python_Bindings_C12_packname="dbus-python-1.1.1.tar.gz"

export D_Bus_Python_Bindings_C12_required_or_recommended="Python_2_7_3_C13 D_Bus_GLib_Bindings_C12 "

Eject_2_1_5_C12(){

./configure --prefix=/usr &&
make
make install
}

export Eject_2_1_5_C12_download="http://www.paldo.org/paldo/sources/eject/eject-2.1.5.tar.bz2 ftp://mirrors.kernel.org/slackware/slackware-13.1/source/a/eject/eject-2.1.5.tar.bz2 "

export Eject_2_1_5_C12_packname="eject-2.1.5.tar.bz2"

Fcron_3_1_2_C12(){

cat >> /etc/syslog.conf << "EOF"
# Begin fcron addition to /etc/syslog.conf

cron.* -/var/log/cron.log

# End fcron addition
EOF

/etc/rc.d/init.d/sysklogd reload
groupadd -g 22 fcron &&
useradd -d /dev/null -c "Fcron User" -g fcron -s /bin/false -u 22 fcron
./configure --prefix=/usr --sysconfdir=/etc \
    --localstatedir=/var --without-sendmail --with-boot-install=no \
    --with-dsssl-dir=/usr/share/sgml/docbook/dsssl-stylesheets-1.79 &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-fcron
}

export Fcron_3_1_2_C12_download="http://fcron.free.fr/archives/fcron-3.1.2.src.tar.gz ftp://ftp.seul.org/pub/fcron/fcron-3.1.2.src.tar.gz "

export Fcron_3_1_2_C12_packname="fcron-3.1.2.src.tar.gz"

GPM_1_20_7_C12(){

./autogen.sh                                &&
./configure --prefix=/usr --sysconfdir=/etc &&
make
make install                                          &&

install-info --dir-file=/usr/share/info/dir           \
             /usr/share/info/gpm.info                 &&

ln -v -sfn libgpm.so.2.1.0 /usr/lib/libgpm.so         &&
install -v -m644 conf/gpm-root.conf /etc              &&

install -v -m755 -d /usr/share/doc/gpm-1.20.7/support &&
install -v -m644    doc/support/*                     \
                    /usr/share/doc/gpm-1.20.7/support &&
install -v -m644    doc/{FAQ,HACK_GPM,README*}        \
                    /usr/share/doc/gpm-1.20.7
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-gpm
cat > /etc/sysconfig/mouse << "EOF"
# Begin /etc/sysconfig/mouse

MDEVICE="<yourdevice>"
PROTOCOL="<yourprotocol>"
GPMOPTS="<additional options>"

# End /etc/sysconfig/mouse
EOF

}

export GPM_1_20_7_C12_download="http://www.nico.schottelius.org/software/gpm/archives/gpm-1.20.7.tar.bz2 "

export GPM_1_20_7_C12_packname="gpm-1.20.7.tar.bz2"

Hdparm_9_43_C12(){

make
make install
make binprefix=/usr/ install
}

export Hdparm_9_43_C12_download="http://downloads.sourceforge.net/hdparm/hdparm-9.43.tar.gz "

export Hdparm_9_43_C12_packname="hdparm-9.43.tar.gz"

IBus_1_5_1_C12(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/ibus \
            --disable-gtk2 &&
make
make install
}

export IBus_1_5_1_C12_download="http://ibus.googlecode.com/files/ibus-1.5.1.tar.gz "

export IBus_1_5_1_C12_packname="ibus-1.5.1.tar.gz"

export IBus_1_5_1_C12_required_or_recommended="DConf_0_14_1_C30 ISO_Codes_3_40_C9 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

LSB_Tools_for_managing_bootscripts_C12(){

./configure --prefix=/usr &&
make
make install
}

export LSB_Tools_for_managing_bootscripts_C12_download="http://people.freedesktop.org/~dbn/initd-tools/releases/initd-tools-0.1.3.tar.gz "

export LSB_Tools_for_managing_bootscripts_C12_packname="initd-tools-0.1.3.tar.gz"

libarchive_3_1_2_C12(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libarchive_3_1_2_C12_download="http://www.libarchive.org/downloads/libarchive-3.1.2.tar.gz "

export libarchive_3_1_2_C12_packname="libarchive-3.1.2.tar.gz"

lm_sensors_3_3_3_C12(){

make PREFIX=/usr        \
     BUILD_STATIC_LIB=0 \
     MANDIR=/usr/share/man
make PREFIX=/usr        \
     BUILD_STATIC_LIB=0 \
     MANDIR=/usr/share/man install &&
install -v -m755 -d /usr/share/doc/lm_sensors-3.3.3 &&
cp -rv              README INSTALL doc/* \
                    /usr/share/doc/lm_sensors-3.3.3
sensors-detect
}

export lm_sensors_3_3_3_C12_download="http://dl.lm-sensors.org/lm-sensors/releases/lm_sensors-3.3.3.tar.bz2 ftp://ftp.netroedge.com/pub/lm-sensors/lm_sensors-3.3.3.tar.bz2 "

export lm_sensors_3_3_3_C12_packname="lm_sensors-3.3.3.tar.bz2"

export lm_sensors_3_3_3_C12_required_or_recommended="Which_2_20_and_Alternatives_C12 "

MC_4_8_6_C12(){

./configure --prefix=/usr     \
            --enable-charset  \
            --disable-static  \
            --sysconfdir=/etc \
            --with-screen=ncurses &&
make
make install &&
cp -v doc/keybind-migration.txt /usr/share/mc
}

export MC_4_8_6_C12_download="https://www.midnight-commander.org/downloads/mc-4.8.6.tar.xz "

export MC_4_8_6_C12_packname="mc-4.8.6.tar.xz"

export MC_4_8_6_C12_required_or_recommended="GLib_2_34_3_C9 PCRE_8_32_C9 "

obex_data_server_0_4_6_C12(){

patch -Np1 -i ../obex-data-server-0.4.6-build-fixes-1.patch &&
./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export obex_data_server_0_4_6_C12_download="http://tadas.dailyda.com/software/obex-data-server-0.4.6.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/obex-data-server-0.4.6-build-fixes-1.patch "

export obex_data_server_0_4_6_C12_packname="obex-data-server-0.4.6.tar.gz"

export obex_data_server_0_4_6_C12_required_or_recommended="D_Bus_GLib_Bindings_C12 ImageMagick_6_8_2_8_C11 OpenOBEX_1_6_C9 "

Obexd_0_48_C12(){

sed -i 's/#include <string.h>/&\n#include <stdio.h>/' plugins/mas.c &&
./configure --prefix=/usr --libexecdir=/usr/lib/obex &&
make
make install
}

export Obexd_0_48_C12_download="http://www.kernel.org/pub/linux/bluetooth/obexd-0.48.tar.xz ftp://ftp.kernel.org/pub/linux/bluetooth/obexd-0.48.tar.xz "

export Obexd_0_48_C12_packname="obexd-0.48.tar.xz"

export Obexd_0_48_C12_required_or_recommended="BlueZ_4_101_C12 libical_0_48_C9 "

PCI_Utils_3_1_10_C12(){

make PREFIX=/usr \
     SHAREDIR=/usr/share/misc \
     MANDIR=/usr/share/man \
     SHARED=yes ZLIB=no all
make PREFIX=/usr \
     SHAREDIR=/usr/share/misc \
     MANDIR=/usr/share/man \
     SHARED=yes ZLIB=no \
     install install-lib
}

export PCI_Utils_3_1_10_C12_download="http://ftp.kernel.org/pub/software/utils/pciutils/pciutils-3.1.10.tar.xz ftp://ftp.kernel.org/pub/software/utils/pciutils/pciutils-3.1.10.tar.xz "

export PCI_Utils_3_1_10_C12_packname="pciutils-3.1.10.tar.xz"

Raptor_2_0_9_C12(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Raptor_2_0_9_C12_download="http://download.librdf.org/source/raptor2-2.0.9.tar.gz "

export Raptor_2_0_9_C12_packname="raptor2-2.0.9.tar.gz"

export Raptor_2_0_9_C12_required_or_recommended="cURL_7_29_0_C17 libxslt_1_1_28_C9 "

Rasqal_0_9_30_C12(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Rasqal_0_9_30_C12_download="http://download.librdf.org/source/rasqal-0.9.30.tar.gz "

export Rasqal_0_9_30_C12_packname="rasqal-0.9.30.tar.gz"

export Rasqal_0_9_30_C12_required_or_recommended="Raptor_2_0_9_C12 "

Redland_1_0_16_C12(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Redland_1_0_16_C12_download="http://download.librdf.org/source/redland-1.0.16.tar.gz "

export Redland_1_0_16_C12_packname="redland-1.0.16.tar.gz"

export Redland_1_0_16_C12_required_or_recommended="Rasqal_0_9_30_C12 "

sg3_utils_1_35_C12(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export sg3_utils_1_35_C12_download="http://sg.danny.cz/sg/p/sg3_utils-1.35.tar.xz "

export sg3_utils_1_35_C12_packname="sg3_utils-1.35.tar.xz"

Strigi_0_7_8_C12(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr .. &&
make
make install
}

export Strigi_0_7_8_C12_download="http://www.vandenoever.info/software/strigi/strigi-0.7.8.tar.bz2 "

export Strigi_0_7_8_C12_packname="strigi-0.7.8.tar.bz2"

export Strigi_0_7_8_C12_required_or_recommended="CMake_2_8_10_2_C13 Expat_2_1_0_C9 Qt_4_8_4_C25 D_Bus_1_6_8_C12 "

Sysstat_10_0_5_C12(){

sa_lib_dir=/usr/lib/sa    \
sa_dir=/var/log/sa        \
conf_dir=/etc/sysconfig   \
./configure --prefix=/usr \
            --disable-man-group &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-sysstat
}

export Sysstat_10_0_5_C12_download="http://perso.wanadoo.fr/sebastien.godard/sysstat-10.0.5.tar.bz2 "

export Sysstat_10_0_5_C12_packname="sysstat-10.0.5.tar.bz2"

Udev_Installed_LFS_Version_C12(){

./configure --prefix=/usr                  \
            --sysconfdir=/etc              \
            --sbindir=/sbin                \
            --with-rootlibdir=/lib         \
            --libexecdir=/lib              \
            --with-systemdsystemunitdir=no \
            --disable-introspection        \
            --docdir=/usr/share/doc/1.8.8 &&
make
make install
}

export Udev_Installed_LFS_Version_C12_download=" "

export Udev_Installed_LFS_Version_C12_packname=""

export Udev_Installed_LFS_Version_C12_required_or_recommended="acl_2_2_51_C4 GLib_2_34_3_C9 Gperf_3_0_4_C11 PCI_Utils_3_1_10_C12 USB_Utils_006_C12 "

Udev_Extras_from_systemd__C12(){

tar -xf ../udev-lfs-186.tar.bz2
sed -i -e '/samsung-9/d' udev-lfs-197-2/makefile-incl.keymap
make -f udev-lfs-186/Makefile.lfs keymap
make -f udev-lfs-186/Makefile.lfs install-keymap
make -f udev-lfs-186/Makefile.lfs gudev
make -f udev-lfs-186/Makefile.lfs install-gudev
make -f udev-lfs-186/Makefile.lfs gir-data
make -f udev-lfs-186/Makefile.lfs install-gir-data
}

export Udev_Extras_from_systemd__C12_download=" "

export Udev_Extras_from_systemd__C12_packname=""

export Udev_Extras_from_systemd__C12_required_or_recommended="http://anduin.linuxfromscratch.org/sources/other/ GLib_2_34_3_C9 Gperf_3_0_4_C11 gobject_introspection_1_34_2_C9 "

UDisks_1_0_4_C12(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/udisks &&
make
make install
}

export UDisks_1_0_4_C12_download="http://hal.freedesktop.org/releases/udisks-1.0.4.tar.gz "

export UDisks_1_0_4_C12_packname="udisks-1.0.4.tar.gz"

export UDisks_1_0_4_C12_required_or_recommended="D_Bus_GLib_Bindings_C12 libatasmart_0_19_C9 LVM2_2_02_98_C5 parted_3_1_C5 Polkit_0_110_C4 sg3_utils_1_35_C12 Udev_Installed_LFS_Version_C12 "

UDisks_2_1_0_C12(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --disable-static &&
make
make install
}

export UDisks_2_1_0_C12_download="http://udisks.freedesktop.org/releases/udisks-2.1.0.tar.bz2 "

export UDisks_2_1_0_C12_packname="udisks-2.1.0.tar.bz2"

export UDisks_2_1_0_C12_required_or_recommended="acl_2_2_51_C4 libatasmart_0_19_C9 libxslt_1_1_28_C9 Polkit_0_110_C4 Udev_Installed_LFS_Version_C12 "

UnRar_4_2_4_C12(){

make -f makefile.unix
install -v -m755 unrar /usr/bin
}

export UnRar_4_2_4_C12_download="http://www.rarlab.com/rar/unrarsrc-4.2.4.tar.gz unrar.html "

export UnRar_4_2_4_C12_packname="unrarsrc-4.2.4.tar.gz"

UnZip_6_0_C12(){



case `uname -m` in
  i?86)
    sed -i -e 's/DASM"/DASM -DNO_LCHMOD"/' unix/Makefile
    make -f unix/Makefile linux
    ;;
  *)
    sed -i -e 's/CFLAGS="-O -Wall/& -DNO_LCHMOD/' unix/Makefile
    make -f unix/Makefile linux_noasm
    ;;
esac
make prefix=/usr install
}

export UnZip_6_0_C12_download="http://downloads.sourceforge.net/infozip/unzip60.tar.gz "

export UnZip_6_0_C12_packname="unzip60.tar.gz"

UPower_0_9_20_C12(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/upower \
            --enable-deprecated \
            --disable-static &&
make
make install
}

export UPower_0_9_20_C12_download="http://upower.freedesktop.org/releases/upower-0.9.20.tar.xz "

export UPower_0_9_20_C12_packname="upower-0.9.20.tar.xz"

export UPower_0_9_20_C12_required_or_recommended="D_Bus_GLib_Bindings_C12 Intltool_0_50_2_C11 libusb_1_0_9_C9 Polkit_0_110_C4 Udev_Installed_LFS_Version_C12 "

USB_Utils_006_C12(){

./configure --prefix=/usr \
            --datadir=/usr/share/misc \
            --disable-zlib &&
make
make install &&
mv -v /usr/sbin/update-usbids.sh /usr/sbin/update-usbids
}

export USB_Utils_006_C12_download="http://ftp.kernel.org/pub/linux/utils/usb/usbutils/usbutils-006.tar.xz ftp://ftp.kernel.org/pub/linux/utils/usb/usbutils/usbutils-006.tar.xz "

export USB_Utils_006_C12_packname="usbutils-006.tar.xz"

export USB_Utils_006_C12_required_or_recommended="libusb_1_0_9_C9 pkg_config_0_28_C13 "

Which_2_20_and_Alternatives_C12(){

./configure --prefix=/usr &&
make
make install
cat > /usr/bin/which << "EOF"
#!/bin/bash
type -pa "$@" | head -n 1 ; exit ${PIPESTATUS[0]}
EOF
chmod -v 755 /usr/bin/which
chown -R root:root /usr/bin/which

}

export Which_2_20_and_Alternatives_C12_download="http://www.xs4all.nl/~carlo17/which/which-2.20.tar.gz ftp://ftp.gnu.org/gnu/which/which-2.20.tar.gz "

export Which_2_20_and_Alternatives_C12_packname="which-2.20.tar.gz"

Zip_3_0_C12(){

make -f unix/Makefile generic_gcc
make prefix=/usr -f unix/Makefile install
}

export Zip_3_0_C12_download="http://downloads.sourceforge.net/infozip/zip30.tar.gz ftp://ftp.info-zip.org/pub/infozip/src/zip30.tgz "

export Zip_3_0_C12_packname="zip30.tar.gz"

export C12_SystemUtilities="apache_ant_1_8_4_C12 at_3_1_13_C12 autofs_5_0_7_C12 BlueZ_4_101_C12 Colord_0_1_31_C12 cpio_2_11_C12 D_Bus_1_6_8_C12 D_Bus_Bindings_C12 Eject_2_1_5_C12 Fcron_3_1_2_C12 GPM_1_20_7_C12 Hdparm_9_43_C12 IBus_1_5_1_C12 LSB_Tools_for_managing_bootscripts_C12 libarchive_3_1_2_C12 lm_sensors_3_3_3_C12 MC_4_8_6_C12 obex_data_server_0_4_6_C12 Obexd_0_48_C12 PCI_Utils_3_1_10_C12 Raptor_2_0_9_C12 Rasqal_0_9_30_C12 Redland_1_0_16_C12 sg3_utils_1_35_C12 Strigi_0_7_8_C12 Sysstat_10_0_5_C12 Udev_Installed_LFS_Version_C12 Udev_Extras_from_systemd__C12 UDisks_1_0_4_C12 UDisks_2_1_0_C12 UnRar_4_2_4_C12 UnZip_6_0_C12 UPower_0_9_20_C12 USB_Utils_006_C12 Which_2_20_and_Alternatives_C12 Zip_3_0_C12 "


bzr_2_5_0_C13(){

tar -xf ../Pyrex-0.9.9.tar.gz
pushd Pyrex-0.9.9                        &&
python setup.py install                  &&
install -v -m755 -d /usr/share/doc/Pyrex &&
cp      -v -R Doc/* /usr/share/doc/Pyrex &&
popd 
python setup.py install
}

export bzr_2_5_0_C13_download="https://launchpad.net/bzr/2.5/2.5.0/+download/bzr-2.5.0.tar.gz  "

export bzr_2_5_0_C13_packname="bzr-2.5.0.tar.gz"

export bzr_2_5_0_C13_required_or_recommended="Python_2_7_3_C13 "

Check_0_9_9_C13(){

./configure --prefix=/usr --disable-static &&
make
}

export Check_0_9_9_C13_download="http://downloads.sourceforge.net/check/check-0.9.9.tar.gz "

export Check_0_9_9_C13_packname="check-0.9.9.tar.gz"

CMake_2_8_10_2_C13(){

./bootstrap --prefix=/usr       \
            --system-libs       \
            --mandir=/share/man \
            --docdir=/share/doc/cmake-2.8.10.2 &&
make
make install
}

export CMake_2_8_10_2_C13_download="http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz "

export CMake_2_8_10_2_C13_packname="cmake-2.8.10.2.tar.gz"

export CMake_2_8_10_2_C13_required_or_recommended="cURL_7_29_0_C17 libarchive_3_1_2_C12 Expat_2_1_0_C9 "

CVS_1_11_23_C13(){

patch -Np1 -i ../cvs-1.11.23-zlib-1.patch
sed -i -e 's/getline /get_line /' lib/getline.{c,h}
./configure --prefix=/usr &&
make
make -C doc html txt
sed -e 's/rsh};/ssh};/' \
    -e 's/g=rw,o=r$/g=r,o=r/' \
    -i src/sanity.sh
make install &&
install -v -m755 -d         /usr/share/doc/cvs-1.11.23 &&
install -v -m644 FAQ README /usr/share/doc/cvs-1.11.23 &&
install -v -m644 doc/*.pdf  /usr/share/doc/cvs-1.11.23
install -v -m644 doc/*.txt /usr/share/doc/cvs-1.11.23                   &&
install -v -m755 -d        /usr/share/doc/cvs-1.11.23/html/cvs{,client} &&
install -v -m644 doc/cvs.html/* \
                           /usr/share/doc/cvs-1.11.23/html/cvs          &&
install -v -m644 doc/cvsclient.html/* \
                           /usr/share/doc/cvs-1.11.23/html/cvsclient
}

export CVS_1_11_23_C13_download="http://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23/cvs-1.11.23.tar.bz2 ftp://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23/cvs-1.11.23.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/cvs-1.11.23-zlib-1.patch "

export CVS_1_11_23_C13_packname="cvs-1.11.23.tar.bz2"


DejaGnu_1_5_1_C13(){

./configure --prefix=/usr &&
makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi &&
makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi
make install &&
install -v -dm755   /usr/share/doc/dejagnu-1.5.1 &&
install -v -m644    doc/dejagnu.{html,txt} \
                    /usr/share/doc/dejagnu-1.5.1
}

export DejaGnu_1_5_1_C13_download="http://ftp.gnu.org/pub/gnu/dejagnu/dejagnu-1.5.1.tar.gz ftp://ftp.gnu.org/pub/gnu/dejagnu/dejagnu-1.5.1.tar.gz "

export DejaGnu_1_5_1_C13_packname="dejagnu-1.5.1.tar.gz"

export DejaGnu_1_5_1_C13_required_or_recommended="Expect_5_45_C13 "

Doxygen_1_8_3_1_C13(){

./configure --prefix /usr \
            --docdir /usr/share/doc/doxygen-1.8.3.1 &&
make
make install
make install_docs
}

export Doxygen_1_8_3_1_C13_download="http://ftp.stack.nl/pub/doxygen/doxygen-1.8.3.1.src.tar.gz ftp://ftp.stack.nl/pub/doxygen/doxygen-1.8.3.1.src.tar.gz "

export Doxygen_1_8_3_1_C13_packname="doxygen-1.8.3.1.src.tar.gz"

Expect_5_45_C13(){

./configure --prefix=/usr \
            --with-tcl=/usr/lib \
            --with-tclinclude=/usr/include \
            --enable-shared &&
make
make install &&
ln -sfvf expect5.45/libexpect5.45.so /usr/lib
}

export Expect_5_45_C13_download="http://prdownloads.sourceforge.net/expect/expect5.45.tar.gz "

export Expect_5_45_C13_packname="expect5.45.tar.gz"

export Expect_5_45_C13_required_or_recommended="Tcl_8_6_0_C13 "

GCC_4_7_2_C13(){

make ins-all prefix=<Your build directory>/gnat

cd .. &&
rm -rf gnat-2011-*
PATH_HOLD=$PATH &&
export PATH=<Your build directory>/gnat/bin:$PATH_HOLD

find <Your build directory>/gnat -name ld -exec mv -v \{\} \{\}.old \;
find <Your build directory>/gnat -name as -exec mv -v \{\} \{\}.old \;

sed -i 's/\(install.*:\) install-.*recursive/\1/' libffi/Makefile.in &&
sed -i 's/\(install-data-am:\).*/\1/' libffi/include/Makefile.in &&
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in &&
sed -i 's@\./fixinc\.sh@-c true@'        gcc/Makefile.in       &&

case `uname -m` in
      i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac &&

mkdir ../gcc-build &&
cd    ../gcc-build &&

../gcc-4.7.2/configure         \
    --prefix=/usr              \
    --libdir=/usr/lib          \
    --libexecdir=/usr/lib      \
    --with-system-zlib         \
    --enable-shared            \
    --enable-threads=posix     \
    --enable-__cxa_atexit      \
    --disable-multilib         \
    --enable-clocale=gnu       \
    --enable-lto               \
    --enable-languages=c,c++,fortran,ada,go,java,objc,obj-c++ &&

make &&

../gcc-4.7.2/contrib/test_summary
make install &&

ln -v -sf ../usr/bin/cpp /lib &&
ln -v -sf gcc /usr/bin/cc &&

chown -R -R root:root \
    /usr/lib/gcc/*linux-gnu/4.7.2/include{,-fixed} \
    /usr/lib/gcc/*linux-gnu/4.7.2/ada{lib,include}
rm -rf <Your build directory>/gnat &&
export PATH=$PATH_HOLD &&
unset PATH_HOLD

}

export GCC_4_7_2_C13_download="http://ftp.gnu.org/gnu/gcc/gcc-4.7.2/gcc-4.7.2.tar.bz2 ftp://ftp.gnu.org/gnu/gcc/gcc-4.7.2/gcc-4.7.2.tar.bz2  "

export GCC_4_7_2_C13_packname="gcc-4.7.2.tar.bz2"

export GCC_4_7_2_C13_required_or_recommended="DejaGnu_1_5_1_C13 Zip_3_0_C12 UnZip_6_0_C12 Which_2_20_and_Alternatives_C12 "

GC_7_2d_C13(){

sed -i 's#AM_CONFIG_HEADER#AC_CONFIG_HEADERS#' configure.ac &&
sed -i 's#AM_CONFIG_HEADER#AC_CONFIG_HEADERS#' libatomic_ops/configure.ac &&
sed -i 's#pkgdata#doc#' doc/doc.am &&
autoreconf -fi  &&
./configure --prefix=/usr      \
            --enable-cplusplus \
            --disable-static   \
            --docdir=/usr/share/doc/gc-7.2d &&
make
make install &&
install -v -m644 doc/gc.man /usr/share/man/man3/gc_malloc.3 &&
ln -sfv gc_malloc.3 /usr/share/man/man3/gc.3 
}

export GC_7_2d_C13_download="http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/gc-7.2d.tar.gz "

export GC_7_2d_C13_packname="gc-7.2d.tar.gz"

GDB_7_5_C13(){

./configure --prefix=/usr &&
make
make -C gdb install
}

export GDB_7_5_C13_download="http://ftp.gnu.org/gnu/gdb/gdb-7.5.tar.bz2 ftp://ftp.gnu.org/gnu/gdb/gdb-7.5.tar.bz2 "

export GDB_7_5_C13_packname="gdb-7.5.tar.bz2"

Git_1_8_2_C13(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib \
            --with-gitconfig=/etc/gitconfig &&
make
make html
make man
make install
make install-man
make htmldir=/usr/share/doc/git-1.8.2 install-html              &&
mkdir -p /usr/share/doc/git-1.8.2/man-pages/{html,text}         &&
mv       /usr/share/doc/git-1.8.2/{git*.txt,man-pages/text}     &&
mv       /usr/share/doc/git-1.8.2/{git*.,index.,man-pages/}html &&
mkdir -pv /usr/share/doc/git-1.8.2/technical/{html,text}         &&
mv       /usr/share/doc/git-1.8.2/technical/{*.txt,text}        &&
mv       /usr/share/doc/git-1.8.2/technical/{*.,}html           &&
mkdir -pv /usr/share/doc/git-1.8.2/howto/{html,text}             &&
mv       /usr/share/doc/git-1.8.2/howto/{*.txt,text}            &&
mv       /usr/share/doc/git-1.8.2/howto/{*.,}html
tar -xf ../git-manpages-1.8.2.tar.gz -C /usr/share/man --no-same-owner
mkdir -p /usr/share/doc/git-1.8.2/man-pages/{html,text}         &&

tar -xf  ../git-htmldocs-1.8.2.tar.gz \
    -C   /usr/share/doc/git-1.8.2 --no-same-owner               &&

mv       /usr/share/doc/git-1.8.2/{git*.txt,man-pages/text}     &&
mv       /usr/share/doc/git-1.8.2/{git*.,index.,man-pages/}html &&
mkdir -pv /usr/share/doc/git-1.8.2/technical/{html,text}         &&
mv       /usr/share/doc/git-1.8.2/technical/{*.txt,text}        &&
mv       /usr/share/doc/git-1.8.2/technical/{*.,}html           &&
mkdir -pv /usr/share/doc/git-1.8.2/howto/{html,text}             &&
mv       /usr/share/doc/git-1.8.2/howto/{*.txt,text}            &&
mv       /usr/share/doc/git-1.8.2/howto/{*.,}html
git config --system http.sslCAPath /etc/ssl/certs
}

export Git_1_8_2_C13_download="http://git-core.googlecode.com/files/git-1.8.2.tar.gz http://git-core.googlecode.com/files/git-manpages-1.8.2.tar.gz http://git-core.googlecode.com/files/git-htmldocs-1.8.2.tar.gz "

export Git_1_8_2_C13_packname="git-1.8.2.tar.gz"

export Git_1_8_2_C13_required_or_recommended="cURL_7_29_0_C17 Expat_2_1_0_C9 OpenSSL_1_0_1e_C4 Python_2_7_3_C13 "

Guile_2_0_7_C13(){

sed -e "/SUBDIRS/d" -i doc/Makefile.am &&
autoreconf -fi &&
./configure --prefix=/usr --disable-static &&
make
make install
}

export Guile_2_0_7_C13_download="http://ftp.gnu.org/pub/gnu/guile/guile-2.0.7.tar.xz ftp://ftp.gnu.org/pub/gnu/guile/guile-2.0.7.tar.xz "

export Guile_2_0_7_C13_packname="guile-2.0.7.tar.xz"

export Guile_2_0_7_C13_required_or_recommended="pkg_config_0_28_C13 GC_7_2d_C13 libffi_3_0_13_C9 libunistring_0_9_3_C9 "

OpenJDK_1_7_0_9_C13(){

install -vdm755 /opt/OpenJDK-1.7.0.9-bin &&
mv -v * /opt/OpenJDK-1.7.0.9-bin         &&
chown -R root:root /opt/OpenJDK-1.7.0.9-bin
export CLASSPATH=.:/usr/share/java &&
export PATH=$PATH:/opt/OpenJDK-1.7.0.9-bin/bin
unzip ../rhino1_7R3.zip             &&
install -v -d -m755 /usr/share/java &&
install -v -m755 rhino1_7R3/*.jar /usr/share/java
cp -v ../corba.tar.gz     . &&
cp -v ../hotspot.tar.gz   . &&
cp -v ../jaxp.tar.gz      . &&
cp -v ../jaxws.tar.gz     . &&
cp -v ../jdk.tar.gz       . &&
cp -v ../langtools.tar.gz . &&
cp -v ../openjdk.tar.gz   .
patch -Np1 -i ../icedtea-2.3.3-add_cacerts-1.patch
patch -Np1 -i ../icedtea-2.3.3-fixed_paths-1.patch
patch -Np1 -i ../icedtea-2.3.3-fix_tests-1.patch
unset JAVA_HOME &&
./autogen.sh &&
./configure --with-jdk-home=/opt/OpenJDK-1.7.0.9-bin \
            --enable-nss \
            --enable-pulse-java &&
make
chmod 0644 openjdk.build/j2sdk-image/lib/sa-jdi.jar  &&
cp -R openjdk.build/j2sdk-image /opt/OpenJDK-1.7.0.9 &&
chown -R root:root /opt/OpenJDK-1.7.0.9
ln -v -nsf OpenJDK-1.7.0.9-bin /opt/jdk
cat > /etc/profile.d/openjdk.sh << "EOF"
# Begin /etc/profile.d/openjdk.sh

# Set JAVA_HOME directory
JAVA_HOME=/opt/jdk

# Adjust PATH
pathappend $JAVA_HOME/bin PATH

# Auto Java CLASSPATH
# Copy jar files to, or create symlinks in this directory

AUTO_CLASSPATH_DIR=/usr/share/java

pathprepend . CLASSPATH

for dir in `find ${AUTO_CLASSPATH_DIR} -type d 2>/dev/null`; do
    pathappend $dir CLASSPATH
done

for jar in `find ${AUTO_CLASSPATH_DIR} -name "*.jar" 2>/dev/null`; do
    pathappend $jar CLASSPATH
done

export JAVA_HOME CLASSPATH
unset AUTO_CLASSPATH_DIR dir jar

# End /etc/profile.d/openjdk.sh
EOF

cat >> /etc/man_db.conf << "EOF"
MANDATORY_MANPATH     /opt/jdk/man
MANPATH_MAP           /opt/jdk/bin     /opt/jdk/man
MANDB_MAP             /opt/jdk/man     /var/cache/man/jdk
EOF
mandb -c /opt/OpenJDK/man

}

export OpenJDK_1_7_0_9_C13_download="http://icedtea.classpath.org/download/source/icedtea-2.3.3.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/corba.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/hotspot.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/openjdk.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/jaxp.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/jaxws.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/langtools.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/jdk.tar.gz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/OpenJDK-1.7.0.9-i686-bin.tar.xz http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.9/OpenJDK-1.7.0.9-x86_64-bin.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/icedtea-2.3.3-add_cacerts-1.patch http://www.linuxfromscratch.org/patches/blfs/svn/icedtea-2.3.3-fixed_paths-1.patch http://www.linuxfromscratch.org/patches/blfs/svn/icedtea-2.3.3-fix_tests-1.patch ftp://ftp.mozilla.org/pub/mozilla.org/js/rhino1_7R3.zip "

export OpenJDK_1_7_0_9_C13_packname="icedtea-2.3.3.tar.gz"

export OpenJDK_1_7_0_9_C13_required_or_recommended="Certificate_Authority_Certificates_C4 Cups_1_6_2_C42 GTK_3_6_4_C25 giflib_4_1_6_C10 NSPR_4_9_6_C9 PulseAudio_3_0_C38 Xorg_Libraries_C24 "

JUnit_4_10_C13(){

install -v -m755 -d /usr/share/{,doc/}junit-4.10 &&
chown -R root:root .                             &&
cp -v -R junit* org  /usr/share/junit-4.10       &&
cp -v -R *.html *doc /usr/share/doc/junit-4.10
export CLASSPATH=$CLASSPATH:\
   /usr/share/junit-4.10/junit-4.10.jar:/usr/share/junit-4.10
java org.junit.runner.JUnitCore org.junit.tests.AllTests
}

export JUnit_4_10_C13_download="http://downloads.sourceforge.net/junit/junit4.10.zip "

export JUnit_4_10_C13_packname="junit4.10.zip"

export JUnit_4_10_C13_required_or_recommended="UnZip_6_0_C12 "

Librep_0_92_2_1_C13(){

./configure --prefix=/usr &&
make
make install
}

export Librep_0_92_2_1_C13_download="http://download.tuxfamily.org/librep/librep-0.92.2.1.tar.xz "

export Librep_0_92_2_1_C13_packname="librep-0.92.2.1.tar.xz"

LLVM_3_2_C13(){

tar -xf ../clang-3.2.src.tar.gz -C tools &&
tar -xf ../compiler-rt-3.2.src.tar.gz -C projects &&

mv tools/clang-3.2.src tools/clang &&
mv projects/compiler-rt-3.2.src projects/compiler-rt &&

sed -e "s@../lib/libprofile_rt.a@../lib/llvm/libprofile_rt.a@g" \
    -i tools/clang/lib/Driver/Tools.cpp
patch -Np1 -i ../R600-Mesa-9.1.patch &&
patch -Np1 -i ../llvm-3.2-r600_fixes-1.patch
patch -Np1 -i ../llvm-3.2-blfs_paths-1.patch &&
CC=gcc CXX=g++                         \
./configure --prefix=/usr              \
            --sysconfdir=/etc          \
            --libdir=/usr/lib/llvm     \
            --enable-libffi            \
            --enable-optimized         \
            --enable-shared            \
            --enable-targets=all       \
            --disable-assertions       \
            --disable-debug-runtime    \
            --disable-expensive-checks \
            --enable-experimental-targets=R600 &&
make
make -C docs -f Makefile.sphinx man
make install &&
chmod -v 644 /usr/lib/llvm/*.a &&
echo /usr/lib/llvm >> /etc/ld.so.conf &&
ldconfig
install -m644 docs/_build/man/* /usr/share/man/man1
}

export LLVM_3_2_C13_download="http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/llvm-3.2-blfs_paths-1.patch http://people.freedesktop.org/~tstellar/llvm/3.2/R600-Mesa-9.1.patch http://www.linuxfromscratch.org/patches/blfs/svn/llvm-3.2-r600_fixes-1.patch http://llvm.org/releases/3.2/clang-3.2.src.tar.gz http://llvm.org/releases/3.2/compiler-rt-3.2.src.tar.gz "

export LLVM_3_2_C13_packname="llvm-3.2.src.tar.gz"

export LLVM_3_2_C13_required_or_recommended="libffi_3_0_13_C9 "

mercurial_2_5_2_C13(){

make build
make doc
make PREFIX=/usr install-bin
make PREFIX=/usr install-doc
}

export mercurial_2_5_2_C13_download="http://mercurial.selenic.com/release/mercurial-2.5.2.tar.gz "

export mercurial_2_5_2_C13_packname="mercurial-2.5.2.tar.gz"

export mercurial_2_5_2_C13_required_or_recommended="Python_2_7_3_C13 "

NASM_2_10_07_C13(){

tar -xf ../nasm-2.10.07-xdoc.tar.xz --strip-components=1
./configure --prefix=/usr &&
make
make install
install -m755 -d         /usr/share/doc/nasm-2.10.07/html &&
cp -v doc/html/*.html    /usr/share/doc/nasm-2.10.07/html &&
cp -v doc/*.{txt,ps,pdf} /usr/share/doc/nasm-2.10.07      &&
cp -v doc/info/*         /usr/share/info                         &&
install-info /usr/share/info/nasm.info /usr/share/info/dir
}

export NASM_2_10_07_C13_download="http://www.nasm.us/pub/nasm/releasebuilds/2.10.07/nasm-2.10.07.tar.xz http://www.nasm.us/pub/nasm/releasebuilds/2.10.07/nasm-2.10.07-xdoc.tar.xz "

export NASM_2_10_07_C13_packname="nasm-2.10.07.tar.xz"

export Archive_Zip_1_30_C13_download="http://www.cpan.org/authors/id/A/AD/ADAMK/Archive-Zip-1.30.tar.gz "

export Archive_Zip_1_30_C13_packname="Archive-Zip-1.30.tar.gz"

Archive_Zip_1_30_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export Crypt_SSLeay_0_64_C13_download="http://www.cpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz "

export Crypt_SSLeay_0_64_C13_packname="Crypt-SSLeay-0.64.tar.gz"

Crypt_SSLeay_0_64_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Crypt_SSLeay_0_64_C13_required_or_recommended="OpenSSL_1_0_1e_C4   LWP_Protocol_https  Try_Tiny  "


export LWP_Protocol_https_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/LWP-Protocol-https-6.03.tar.gz"
export LWP_Protocol_https_C13_packname="LWP-Protocol-https-6.03.tar.gz"



export Try_Tiny_C13_download="http://search.cpan.org/CPAN/authors/id/D/DO/DOY/Try-Tiny-0.12.tar.gz"
export Try_Tiny_C13_packname="Try-Tiny-0.12.tar.gz"

LWP_Protocol_https_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Try_Tiny_C13(){ 
perl Makefile.PL &&
make &&
make install
}
LWP_Protocol_https_C13_required_or_recommended="libwww_perl_6_04  IO_Socket_SSL  Mozilla_CA  "


export IO_Socket_SSL_C13_download="http://search.cpan.org/CPAN/authors/id/B/BE/BEHROOZI/IO-Socket-SSL-0.97.tar.gz"
export IO_Socket_SSL_C13_packname="IO-Socket-SSL-0.97.tar.gz"



export Mozilla_CA_C13_download="http://search.cpan.org/CPAN/authors/id/A/AB/ABH/Mozilla-CA-20130114.tar.gz"
export Mozilla_CA_C13_packname="Mozilla-CA-20130114.tar.gz"

IO_Socket_SSL_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Mozilla_CA_C13(){ 
perl Makefile.PL &&
make &&
make install
}
IO_Socket_SSL_C13_required_or_recommended="Net_SSLeay  "


export Net_SSLeay_C13_download="http://search.cpan.org/CPAN/authors/id/M/MI/MIKEM/Net-SSLeay-1.54.tar.gz"
export Net_SSLeay_C13_packname="Net-SSLeay-1.54.tar.gz"

Net_SSLeay_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export Date_Manip_6_38_C13_download="http://www.cpan.org/authors/id/S/SB/SBECK/Date-Manip-6.38.tar.gz "

export Date_Manip_6_38_C13_packname="Date-Manip-6.38.tar.gz"

Date_Manip_6_38_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Date_Manip_6_38_C13_required_or_recommended="Test_Inter  "


export Test_Inter_C13_download="http://search.cpan.org/CPAN/authors/id/S/SB/SBECK/Test-Inter-1.05.tar.gz"
export Test_Inter_C13_packname="Test-Inter-1.05.tar.gz"

Test_Inter_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export Finance_Quote_1_18_C13_download="http://www.cpan.org/authors/id/E/EC/ECOCODE/Finance-Quote-1.18.tar.gz "

export Finance_Quote_1_18_C13_packname="Finance-Quote-1.18.tar.gz"

Finance_Quote_1_18_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Finance_Quote_1_18_C13_required_or_recommended="libwww_perl_6_04  Crypt_SSLeay_0_64  HTML_TableExtract_2_11  "
export Glib_1_280_C13_download="http://www.cpan.org/authors/id/T/TS/TSCH/Glib-1.280.tar.gz "

export Glib_1_280_C13_packname="Glib-1.280.tar.gz"

Glib_1_280_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Glib_1_280_C13_required_or_recommended="ExtUtils_PkgConfig  "


export ExtUtils_PkgConfig_C13_download="http://search.cpan.org/CPAN/authors/id/X/XA/XAOC/ExtUtils-PkgConfig-1.14.tar.gz"
export ExtUtils_PkgConfig_C13_packname="ExtUtils-PkgConfig-1.14.tar.gz"

ExtUtils_PkgConfig_C13(){ 
perl Makefile.PL &&
make &&
make install
}
ExtUtils_PkgConfig_C13_required_or_recommended="ExtUtils_Depends  "


export ExtUtils_Depends_C13_download="http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/ExtUtils-Depends-0.304.tar.gz"
export ExtUtils_Depends_C13_packname="ExtUtils-Depends-0.304.tar.gz"

ExtUtils_Depends_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export HTML_Parser_3_69_C13_download="http://www.cpan.org/authors/id/G/GA/GAAS/HTML-Parser-3.69.tar.gz "

export HTML_Parser_3_69_C13_packname="HTML-Parser-3.69.tar.gz"

HTML_Parser_3_69_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTML_Parser_3_69_C13_required_or_recommended="HTML_Tagset  libwww_perl_6_04  "


export HTML_Tagset_C13_download="http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz"
export HTML_Tagset_C13_packname="HTML-Tagset-3.20.tar.gz"

HTML_Tagset_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export HTML_TableExtract_2_11_C13_download="http://cpan.org/authors/id/M/MS/MSISK/HTML-TableExtract-2.11.tar.gz "

export HTML_TableExtract_2_11_C13_packname="HTML-TableExtract-2.11.tar.gz"

HTML_TableExtract_2_11_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTML_TableExtract_2_11_C13_required_or_recommended="HTML_Element_Extended  "


export HTML_Element_Extended_C13_download="http://search.cpan.org/CPAN/authors/id/M/MS/MSISK/HTML-Element-Extended-1.18.tar.gz"
export HTML_Element_Extended_C13_packname="HTML-Element-Extended-1.18.tar.gz"

HTML_Element_Extended_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTML_Element_Extended_C13_required_or_recommended="HTML_Tree  "


export HTML_Tree_C13_download="http://search.cpan.org/CPAN/authors/id/C/CJ/CJM/HTML-Tree-5.902-TRIAL.tar.gz"
export HTML_Tree_C13_packname="HTML-Tree-5.902-TRIAL.tar.gz"

HTML_Tree_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTML_Tree_C13_required_or_recommended="HTML_Parser_3_69  Test_Fatal  "


export Test_Fatal_C13_download="http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS/Test-Fatal-0.010.tar.gz"
export Test_Fatal_C13_packname="Test-Fatal-0.010.tar.gz"

Test_Fatal_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Test_Fatal_C13_required_or_recommended="Try_Tiny  "


export Try_Tiny_C13_download="http://search.cpan.org/CPAN/authors/id/D/DO/DOY/Try-Tiny-0.12.tar.gz"
export Try_Tiny_C13_packname="Try-Tiny-0.12.tar.gz"

Try_Tiny_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export libwww_perl_6_04_C13_download="http://cpan.org/authors/id/G/GA/GAAS/libwww-perl-6.04.tar.gz "

export libwww_perl_6_04_C13_packname="libwww-perl-6.04.tar.gz"

libwww_perl_6_04_C13(){ 
perl Makefile.PL &&
make &&
make install
}
libwww_perl_6_04_C13_required_or_recommended="Encode_Locale  HTML_Form  HTTP_Cookies  HTTP_Negotiate  Net_HTTP  WWW_RobotRules  HTTP_Daemon  File_Listing  "


export Encode_Locale_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Encode-Locale-1.03.tar.gz"
export Encode_Locale_C13_packname="Encode-Locale-1.03.tar.gz"



export HTML_Form_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTML-Form-6.03.tar.gz"
export HTML_Form_C13_packname="HTML-Form-6.03.tar.gz"



export HTTP_Cookies_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTTP-Cookies-6.01.tar.gz"
export HTTP_Cookies_C13_packname="HTTP-Cookies-6.01.tar.gz"



export HTTP_Negotiate_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTTP-Negotiate-6.01.tar.gz"
export HTTP_Negotiate_C13_packname="HTTP-Negotiate-6.01.tar.gz"



export Net_HTTP_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Net-HTTP-6.06.tar.gz"
export Net_HTTP_C13_packname="Net-HTTP-6.06.tar.gz"



export WWW_RobotRules_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/WWW-RobotRules-6.02.tar.gz"
export WWW_RobotRules_C13_packname="WWW-RobotRules-6.02.tar.gz"



export HTTP_Daemon_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTTP-Daemon-6.01.tar.gz"
export HTTP_Daemon_C13_packname="HTTP-Daemon-6.01.tar.gz"



export File_Listing_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/File-Listing-6.04.tar.gz"
export File_Listing_C13_packname="File-Listing-6.04.tar.gz"

Encode_Locale_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTML_Form_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTTP_Cookies_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTTP_Negotiate_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Net_HTTP_C13(){ 
perl Makefile.PL &&
make &&
make install
}
WWW_RobotRules_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTTP_Daemon_C13(){ 
perl Makefile.PL &&
make &&
make install
}
File_Listing_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTML_Form_C13_required_or_recommended="URI_1_60  HTML_Parser_3_69  HTTP_Message  "


export HTTP_Message_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTTP-Message-6.06.tar.gz"
export HTTP_Message_C13_packname="HTTP-Message-6.06.tar.gz"

HTTP_Message_C13(){ 
perl Makefile.PL &&
make &&
make install
}
HTTP_Message_C13_required_or_recommended="HTTP_Date  IO_HTML  LWP_MediaTypes  "


export HTTP_Date_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTTP-Date-6.02.tar.gz"
export HTTP_Date_C13_packname="HTTP-Date-6.02.tar.gz"



export IO_HTML_C13_download="http://search.cpan.org/CPAN/authors/id/C/CJ/CJM/IO-HTML-1.00.tar.gz"
export IO_HTML_C13_packname="IO-HTML-1.00.tar.gz"



export LWP_MediaTypes_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/LWP-MediaTypes-6.02.tar.gz"
export LWP_MediaTypes_C13_packname="LWP-MediaTypes-6.02.tar.gz"

HTTP_Date_C13(){ 
perl Makefile.PL &&
make &&
make install
}
IO_HTML_C13(){ 
perl Makefile.PL &&
make &&
make install
}
LWP_MediaTypes_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export Net_DNS_0_70_C13_download="http://www.cpan.org/authors/id/N/NL/NLNETLABS/Net-DNS-0.70.tar.gz "

export Net_DNS_0_70_C13_packname="Net-DNS-0.70.tar.gz"

Net_DNS_0_70_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Net_DNS_0_70_C13_required_or_recommended="Digest_HMAC  IO_Socket_INET  "


export Digest_HMAC_C13_download="http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Digest-HMAC-1.03.tar.gz"
export Digest_HMAC_C13_packname="Digest-HMAC-1.03.tar.gz"

export IO_Socket_INET_C13_download="http://search.cpan.org/~gbarr/IO/lib/IO/Socket/INET.pm "

export IO_Socket_INET_C13_packname="INET.pm"

Digest_HMAC_C13(){ 
perl Makefile.PL &&
make &&
make install
}
IO_Socket_INET_C13(){ 
perl Makefile.PL &&
make &&
make install
}
IO_Socket_INET_C13_required_or_recommended="Socket6  "


export Socket6_C13_download="http://search.cpan.org/CPAN/authors/id/U/UM/UMEMOTO/Socket6-0.23.tar.gz"
export Socket6_C13_packname="Socket6-0.23.tar.gz"

Socket6_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export SGMLSpm_1_1_C13_download="http://search.cpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz "

export SGMLSpm_1_1_C13_packname="SGMLSpm-1.1.tar.gz"

SGMLSpm_1_1_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export URI_1_60_C13_download="http://www.cpan.org/authors/id/G/GA/GAAS/URI-1.60.tar.gz "

export URI_1_60_C13_packname="URI-1.60.tar.gz"

URI_1_60_C13(){ 
perl Makefile.PL &&
make &&
make install
}
export XML_Parser_2_41_C13_download="http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/XML-Parser-2.41.tar.gz "

export XML_Parser_2_41_C13_packname="XML-Parser-2.41.tar.gz"

XML_Parser_2_41_C13(){ 
perl Makefile.PL &&
make &&
make install
}
XML_Parser_2_41_C13_required_or_recommended="Expat_2_1_0_C9   libwww_perl_6_04  "
export XML_Simple_2_20_C13_download="http://cpan.org/authors/id/G/GR/GRANTM/XML-Simple-2.20.tar.gz "

export XML_Simple_2_20_C13_packname="XML-Simple-2.20.tar.gz"

XML_Simple_2_20_C13(){ 
perl Makefile.PL &&
make &&
make install
}
XML_Simple_2_20_C13_required_or_recommended="XML_SAX_Expat  XML_SAX  XML_LibXML  Tie_IxHash  "


export XML_SAX_Expat_C13_download="http://search.cpan.org/CPAN/authors/id/B/BJ/BJOERN/XML-SAX-Expat-0.40.tar.gz"
export XML_SAX_Expat_C13_packname="XML-SAX-Expat-0.40.tar.gz"



export XML_SAX_C13_download="http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-SAX-0.99.tar.gz"
export XML_SAX_C13_packname="XML-SAX-0.99.tar.gz"



export XML_LibXML_C13_download="http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF/XML-LibXML-2.0016.tar.gz"
export XML_LibXML_C13_packname="XML-LibXML-2.0016.tar.gz"



export Tie_IxHash_C13_download="http://search.cpan.org/CPAN/authors/id/C/CH/CHORNY/Tie-IxHash-1.23.tar.gz"
export Tie_IxHash_C13_packname="Tie-IxHash-1.23.tar.gz"

XML_SAX_Expat_C13(){ 
perl Makefile.PL &&
make &&
make install
}
XML_SAX_C13(){ 
perl Makefile.PL &&
make &&
make install
}
XML_LibXML_C13(){ 
perl Makefile.PL &&
make &&
make install
}
Tie_IxHash_C13(){ 
perl Makefile.PL &&
make &&
make install
}
XML_SAX_Expat_C13_required_or_recommended="XML_Parser_2_41  "
XML_SAX_C13_required_or_recommended="XML_NamespaceSupport  XML_SAX_Base  "


export XML_NamespaceSupport_C13_download="http://search.cpan.org/CPAN/authors/id/P/PE/PERIGRIN/XML-NamespaceSupport-1.11.tar.gz"
export XML_NamespaceSupport_C13_packname="XML-NamespaceSupport-1.11.tar.gz"



export XML_SAX_Base_C13_download="http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-SAX-Base-1.08.tar.gz"
export XML_SAX_Base_C13_packname="XML-SAX-Base-1.08.tar.gz"

XML_NamespaceSupport_C13(){ 
perl Makefile.PL &&
make &&
make install
}
XML_SAX_Base_C13(){ 
perl Makefile.PL &&
make &&
make install
}
PHP_5_4_11_C13(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --with-apxs2 \
            --with-config-file-path=/etc \
            --with-zlib \
            --enable-bcmath \
            --with-bz2 \
            --enable-calendar \
            --enable-dba=shared \
            --with-gdbm \
            --with-gmp \
            --enable-ftp \
            --with-gettext \
            --enable-mbstring \
            --with-readline &&
make
make install &&
install -v -m644 php.ini-production /etc/php.ini &&

install -v -m755 -d /usr/share/doc/php-5.4.11 &&
install -v -m644    CODING_STANDARDS EXTENSIONS INSTALL NEWS \
                    README* UPGRADING* php.gif \
                    /usr/share/doc/php-5.4.11 &&
ln -v -sfn          /usr/lib/php/doc/Archive_Tar/docs/Archive_Tar.txt \
                    /usr/share/doc/php-5.4.11 &&
ln -v -sfn          /usr/lib/php/doc/Structures_Graph/docs \
                    /usr/share/doc/php-5.4.11
install -v -m644 ../php_manual_en.html.gz \
    /usr/share/doc/php-5.4.11 &&
gunzip -v /usr/share/doc/php-5.4.11/php_manual_en.html.gz
tar -xvf ../php_manual_en.tar.gz \
    -C /usr/share/doc/php-5.4.11 --no-same-owner
sed -i 's@php/includes"@&\ninclude_path = ".:/usr/lib/php"@' \
    /etc/php.ini
}

export PHP_5_4_11_C13_download="http://us2.php.net/distributions/php-5.4.11.tar.bz2 ftp://ftp.isu.edu.tw/pub/Unix/Web/PHP/distributions/php-5.4.11.tar.bz2 http://www.php.net/download-docs.php "

export PHP_5_4_11_C13_packname="php-5.4.11.tar.bz2"

export PHP_5_4_11_C13_required_or_recommended="Apache_2_4_3_C20 libxml2_2_9_0_C9 "

pkg_config_0_28_C13(){

./configure --prefix=/usr \
            --docdir=/usr/share/doc/pkg-config-0.28 \
            --with-internal-glib \
            --disable-host-tool &&
make
make install
}

export pkg_config_0_28_C13_download="http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz pkgconfig.html "

export pkg_config_0_28_C13_packname="pkg-config-0.28.tar.gz"

Python_2_7_3_C13(){

sed -i "s/ndbm_libs = \[\]/ndbm_libs = ['gdbm', 'gdbm_compat']/" setup.py &&
patch -Np1 -i ../Python-2.7.3-bsddb_fix-1.patch &&
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --enable-unicode=ucs4 &&
make
make -C Doc html
make install &&
chmod -v 755 /usr/lib/libpython2.7.so.1.0
install -v -m755 -d /usr/share/doc/Python-2.7.3 &&
cp -rfv Doc/build/html/* /usr/share/doc/python-2.7.3
install -v -m755 -d /usr/share/doc/Python-2.7.3 &&
tar --strip-components=1 -C /usr/share/doc/Python-2.7.3 \
    -xvf ../python-2.7.3-docs-html.tar.bz2                      &&
find /usr/share/doc/Python-2.7.3 -type d -exec chmod 0755 {} \; &&
find /usr/share/doc/Python-2.7.3 -type f -exec chmod 0644 {} \;
export PYTHONDOCS=/usr/share/doc/Python-2.7.3
}

export Python_2_7_3_C13_download="http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tar.xz http://docs.python.org/ftp/python/doc/2.7.3/python-2.7.3-docs-html.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/Python-2.7.3-bsddb_fix-1.patch "

export Python_2_7_3_C13_packname="Python-2.7.3.tar.xz"

export Python_2_7_3_C13_required_or_recommended="Expat_2_1_0_C9 libffi_3_0_13_C9 pkg_config_0_28_C13 "

Python_3_3_0_C13(){

sed -i "s/ndbm_libs = \[\]/ndbm_libs = ['gdbm', 'gdbm_compat']/" setup.py &&
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi &&
make
make install &&
chmod -v 755 /usr/lib/libpython3.3m.so &&
chmod -v 755 /usr/lib/libpython3.so
install -v -m755 -d /usr/share/doc/Python-3.3.0/html &&
tar --strip-components=1 \
    --no-same-owner \
    --no-same-permissions \
    -C /usr/share/doc/Python-3.3.0/html \
    -xvf ../python-3.3.0-docs-html.tar.bz2
export PYTHONDOCS=/usr/share/doc/Python-3.3.0/html
}

export Python_3_3_0_C13_download="http://www.python.org/ftp/python/3.3.0/Python-3.3.0.tar.xz http://docs.python.org/ftp/python/doc/3.3.0/python-3.3.0-docs-html.tar.bz2 "

export Python_3_3_0_C13_packname="Python-3.3.0.tar.xz"

export Python_3_3_0_C13_required_or_recommended="Expat_2_1_0_C9 libffi_3_0_13_C9 pkg_config_0_28_C13 "

export Introduction_to_Python_Modules_C13_download=""

export Introduction_to_Python_Modules_C13_packname=""

Notify_Python_0_1_1_C13(){

patch -Np1 -i ../notify-python-0.1.1-libnotify-0.7-1.patch &&
./configure --prefix=/usr &&
make
make install
}

export Notify_Python_0_1_1_C13_download="http://www.galago-project.org/files/releases/source/notify-python/notify-python-0.1.1.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/notify-python-0.1.1-libnotify-0.7-1.patch "

export Notify_Python_0_1_1_C13_packname="notify-python-0.1.1.tar.bz2"

export Notify_Python_0_1_1_C13_required_or_recommended="libnotify_0_7_5_C25 PyGTK_2_24_0_C13 GTK_2_24_17_C25 "

Py2cairo_1_10_0_C13(){

./waf configure --prefix=/usr &&
./waf build
./waf install
}

export Py2cairo_1_10_0_C13_download="http://cairographics.org/releases/py2cairo-1.10.0.tar.bz2 "

export Py2cairo_1_10_0_C13_packname="py2cairo-1.10.0.tar.bz2"

export Py2cairo_1_10_0_C13_required_or_recommended="Python_2_7_3_C13 Cairo_1_12_14_C25 "

PyGObject_2_28_6_C13(){

patch -p1 < ../pygobject-2.28.6-introspection-1.patch &&
./configure --prefix=/usr &&
make
make install
}

export PyGObject_2_28_6_C13_download="http://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-2.28.6.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-2.28.6.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/pygobject-2.28.6-introspection-1.patch "

export PyGObject_2_28_6_C13_packname="pygobject-2.28.6.tar.xz"

export PyGObject_2_28_6_C13_required_or_recommended="GLib_2_34_3_C9 Py2cairo_1_10_0_C13 "

PyGObject_3_4_2_C13(){

./configure --prefix=/usr &&
make
make install
}

export PyGObject_3_4_2_C13_download="http://ftp.gnome.org/pub/gnome/sources/pygobject/3.4/pygobject-3.4.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/pygobject/3.4/pygobject-3.4.2.tar.xz "

export PyGObject_3_4_2_C13_packname="pygobject-3.4.2.tar.xz"

export PyGObject_3_4_2_C13_required_or_recommended="gobject_introspection_1_34_2_C9 Py2cairo_1_10_0_C13 "

PyGTK_2_24_0_C13(){

./configure --prefix=/usr &&
make
make install
}

export PyGTK_2_24_0_C13_download="http://ftp.gnome.org/pub/gnome/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2 "

export PyGTK_2_24_0_C13_packname="pygtk-2.24.0.tar.bz2"

export PyGTK_2_24_0_C13_required_or_recommended="PyGObject_2_28_6_C13 ATK_2_6_0_C25 Pango_1_32_5_C25 Py2cairo_1_10_0_C13 Pango_1_32_5_C25 Py2cairo_1_10_0_C13 GTK_2_24_17_C25 Py2cairo_1_10_0_C13 libglade_2_6_4_C9 "

pyatspi2_2_6_0_C13(){

./configure --prefix=/usr &&
make
make install
}

export pyatspi2_2_6_0_C13_download="http://ftp.gnome.org/pub/gnome/sources/pyatspi/2.6/pyatspi-2.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/pyatspi/2.6/pyatspi-2.6.0.tar.xz "

export pyatspi2_2_6_0_C13_packname="pyatspi-2.6.0.tar.xz"

export pyatspi2_2_6_0_C13_required_or_recommended="PyGObject_3_4_2_C13 at_spi2_core_2_6_3_C25 "

Pyrex_0_9_9_C13(){

python setup.py install
}

export Pyrex_0_9_9_C13_download="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/Pyrex-0.9.9.tar.gz "

export Pyrex_0_9_9_C13_packname="Pyrex-0.9.9.tar.gz"

export Pyrex_0_9_9_C13_required_or_recommended="Python_2_7_3_C13 "

Ruby_1_9_3_p392_C13(){

./configure --prefix=/usr --enable-shared &&
make
make install
}

export Ruby_1_9_3_p392_C13_download="ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p392.tar.bz2 "

export Ruby_1_9_3_p392_C13_packname="ruby-1.9.3-p392.tar.bz2"

S_Lang_2_2_4_C13(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install_doc_dir=/usr/share/doc/slang-2.2.4   \
     SLSH_DOC_DIR=/usr/share/doc/slang-2.2.4/slsh \
     install-all &&

chmod -v 755 /usr/lib/libslang.so.2.2.4 \
             /usr/lib/slang/v2/modules/*.so
}

export S_Lang_2_2_4_C13_download="ftp://space.mit.edu/pub/davis/slang/v2.2/slang-2.2.4.tar.bz2 "

export S_Lang_2_2_4_C13_packname="slang-2.2.4.tar.bz2"

Subversion_1_7_8_C13(){

./configure --prefix=/usr --disable-static &&
make
make javahl
sed -i 's#Makefile.PL.in$#& libsvn_swig_perl#' Makefile.in &&
make swig-pl &&
make swig-py
make install &&
install -v -m755 -d /usr/share/doc/subversion-1.7.8 &&
cp      -v -R       doc/* \
                    /usr/share/doc/subversion-1.7.8
make install-javahl
make install-swig-pl &&
make install-swig-py
}

export Subversion_1_7_8_C13_download="http://archive.apache.org/dist/subversion/subversion-1.7.8.tar.bz2 "

export Subversion_1_7_8_C13_packname="subversion-1.7.8.tar.bz2"

export Subversion_1_7_8_C13_required_or_recommended="SQLite_3_7_16_1_C22 Apr_Util_1_5_1_C11 neon_0_29_6_C17 "

Setting_up_a_Subversion_Server__C13(){

groupadd -g 56 svn &&
useradd -c "SVN Owner" -d /home/svn -m -g svn -s /bin/false -u 56 svn
groupadd -g 57 svntest &&
usermod -G svntest -a svn
mv /usr/bin/svn /usr/bin/svn.orig &&
mv /usr/bin/svnserve /usr/bin/svnserve.orig &&
cat >> /usr/bin/svn << "EOF"
#!/bin/sh
umask 002
/usr/bin/svn.orig "$@"
EOF
cat >> /usr/bin/svnserve << "EOF"
#!/bin/sh
umask 002
/usr/bin/svnserve.orig "$@"
EOF
chmod 0755 /usr/bin/svn{,serve}

install -v -m 0755 -d /srv &&
install -v -m 0755 -o svn -g svn -d /srv/svn/repositories &&
svnadmin create --fs-type fsfs /srv/svn/repositories/svntest
svn import -m "Initial import." \
    </path/to/source/tree>      \
    file:///srv/svn/repositories/svntest

chown -R svn:svntest /srv/svn/repositories/svntest    &&
chmod -R g+w         /srv/svn/repositories/svntest    &&
chmod g+s            /srv/svn/repositories/svntest/db &&
usermod -G svn,svntest -a mao

svnlook tree /srv/svn/repositories/svntest/
cp /srv/svn/repositories/svntest/conf/svnserve.conf \
   /srv/svn/repositories/svntest/conf/svnserve.conf.default &&

cat > /srv/svn/repositories/svntest/conf/svnserve.conf << "EOF"
[general]
anon-access = read
auth-access = write
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-svn
}

Tcl_8_6_0_C13(){

tar -xf ../tcl8.6.0-html.tar.gz --strip-components=1
cd unix &&
./configure --prefix=/usr \
            --mandir=/usr/share/man \
            $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
make &&

sed -e "s@^\(TCL_SRC_DIR='\).*@\1/usr/include'@" \
    -e "/TCL_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" \
    -i tclConfig.sh
make install &&
make install-private-headers &&
ln -v -sf tclsh8.6 /usr/bin/tclsh &&
chmod -v 755 /usr/lib/libtcl8.6.so
mkdir -pv -p /usr/share/doc/tcl-8.6.0 &&
cp -v -r  ../html/* /usr/share/doc/tcl-8.6.0
}

export Tcl_8_6_0_C13_download="http://downloads.sourceforge.net/tcl/tcl8.6.0-src.tar.gz http://downloads.sourceforge.net/tcl/tcl8.6.0-html.tar.gz "

export Tcl_8_6_0_C13_packname="tcl8.6.0-src.tar.gz"

Tk_8_6_0_C13(){

cd unix &&
./configure --prefix=/usr \
            --mandir=/usr/share/man \
            $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&

make &&

sed -e "s@^\(TK_SRC_DIR='\).*@\1/usr/include'@" \
    -e "/TK_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" \
    -i tkConfig.sh
make install &&
make install-private-headers &&
ln -v -sf wish8.6 /usr/bin/wish &&
chmod -v 755 /usr/lib/libtk8.6.so
}

export Tk_8_6_0_C13_download="http://downloads.sourceforge.net/tcl/tk8.6.0-src.tar.gz "

export Tk_8_6_0_C13_packname="tk8.6.0-src.tar.gz"

export Tk_8_6_0_C13_required_or_recommended="Tcl_8_6_0_C13 Xorg_Libraries_C24 "

Vala_0_18_1_C13(){

./configure --prefix=/usr &&
make
make install
}

export Vala_0_18_1_C13_download="http://ftp.gnome.org/pub/gnome/sources/vala/0.18/vala-0.18.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/vala/0.18/vala-0.18.1.tar.xz "

export Vala_0_18_1_C13_packname="vala-0.18.1.tar.xz"

export Vala_0_18_1_C13_required_or_recommended="GLib_2_34_3_C9 "

yasm_1_2_0_C13(){

sed -i 's#) ytasm.*#)#' Makefile.in &&
./configure --prefix=/usr &&
make
make install
}

export yasm_1_2_0_C13_download="http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz "

export yasm_1_2_0_C13_packname="yasm-1.2.0.tar.gz"

export Other_Programming_Tools_C13_download=" http://www.aplusdev.org/Download/index.html  http://homepages.cwi.nl/~steven/abc/implementations.html http://www.informatik.uni-kiel.de/~mh/systems/ALF.html    http://www.cl.cam.ac.uk/users/mr/BCPL.html         http://www.cminusminus.org/code.html    http://www.cs.chalmers.se/~augustss/cayenne/get.html   http://wiki.clean.cs.ru.nl/Clean http://wiki.clean.cs.ru.nl/Download_Clean  http://cornlanguage.com/download/download.html     http://www.digitalmars.com/dscript/index.html   http://www.gnu.org/software/dotgnu/pnet-packages.html  http://www.opendylan.org/downloading.phtml    http://www.elasticworld.org/download.html  http://www.erlang.org/download.html  http://www.rapideuphoria.com/v20.htm  http://felix-lang.org/web/download.html  http://www.ferite.org/download.html  http://www.forth.org/compilers.html    http://www.cs.chalmers.se/~augustss/hbc/hbc.html http://www.cs.uu.nl/wiki/bin/view/Helium/WebHome   http://www.plantation-productions.com/Webster/HighLevelAsm/index.html http://www.plantation-productions.com/Webster/HighLevelAsm/dnld.html      http://www.jsoftware.com/stable.htm http://judoscript.org/jamaica.html http://judoscript.org/download.html http://www.latrobe.edu.au/phimvt/joy.html http://judoscript.org/home.html http://judoscript.org/download.html  http://www.brics.dk/JWIG/download.html http://lavape.sourceforge.net/index.htm http://javalab.cs.uni-bonn.de/research/darwin/#The%20Lava%20Language http://mathias.tripod.com/IavaHomepage.html  http://www.lua.org/download.html  http://www.mercury.csse.unimelb.edu.au/download.html http://www.mono-project.com/Main_Page    http://nemerle.org/Main_Page http://nemerle.org/Download  http://www.gnu.org/software/octave/download.html      http://pike.ida.liu.se/download/pub/pike     http://cran.r-project.org/mirrors.html  http://downloads.sourceforge.net/regina-rexx    http://sdcc.sourceforge.net/snap.php#Source     http://www.cs.arizona.edu/sr/index.html    http://www.dina.kvl.dk/~sestoft/mosml.html         http://yorick.sourceforge.net/index.php  http://www.cs.washington.edu/research/zpl/home/index.html http://www.cs.washington.edu/research/zpl/download/download.html http://jakarta.apache.org/bcel/index.html   http://choco.sourceforge.net/download.html  http://www.fftw.org/download.html http://www.5z.com/jirka/gob.html  http://www.gtk.org/language-bindings.html  http://www.gtkmm.org/download.shtml    http://downloads.sourceforge.net/gtk2-perl       http://www.a-a-p.org/index.html http://www.a-a-p.org/download.html http://projects.gnome.org/anjuta/index.shtml http://projects.gnome.org/anjuta/downloads.shtml    http://www.mozart-oz.org/download/view.cgi  http://downloads.sourceforge.net/cachecc1      http://distcc.samba.org/download.html              http://valgrind.org/downloads/source_code.html "

export Other_Programming_Tools_C13_packname="index.html"

export C13_Programming="bzr_2_5_0_C13 Check_0_9_9_C13 CMake_2_8_10_2_C13 CVS_1_11_23_C13 Running_a_CVS_Server_C13 DejaGnu_1_5_1_C13 Doxygen_1_8_3_1_C13 Expect_5_45_C13 GCC_4_7_2_C13 GC_7_2d_C13 GDB_7_5_C13 Git_1_8_2_C13 Guile_2_0_7_C13 OpenJDK_1_7_0_9_C13 JUnit_4_10_C13 Librep_0_92_2_1_C13 LLVM_3_2_C13 mercurial_2_5_2_C13 NASM_2_10_07_C13 Perl_Modules_C13 PHP_5_4_11_C13 pkg_config_0_28_C13 Python_2_7_3_C13 Python_3_3_0_C13 Python_Modules_C13 Ruby_1_9_3_p392_C13 S_Lang_2_2_4_C13 Subversion_1_7_8_C13 Running_a_Subversion_Server_C13 Tcl_8_6_0_C13 Tk_8_6_0_C13 Vala_0_18_1_C13 yasm_1_2_0_C13 Other_Programming_Tools_C13 "


dhcpcd_5_6_7_C14(){

./configure --libexecdir=/lib/dhcpcd \
            --dbdir=/run             \
            --sysconfdir=/etc &&
make
make install
sed -i "s;/var/lib;/run;g" dhcpcd-hooks/50-dhcpcd-compat &&
install -v -m 644 dhcpcd-hooks/50-dhcpcd-compat /lib/dhcpcd/dhcpcd-hooks/
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-service-dhcpcd
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhcpcd"
DHCP_START="-b -q <insert appropriate start options here>"
DHCP_STOP="-k <insert additional stop options here>"
EOF

}

export dhcpcd_5_6_7_C14_download="http://roy.marples.name/downloads/dhcpcd/dhcpcd-5.6.7.tar.bz2 ftp://ftp.osuosl.org/pub/gentoo/distfiles/dhcpcd-5.6.7.tar.bz2 "

export dhcpcd_5_6_7_C14_packname="dhcpcd-5.6.7.tar.bz2"

DHCP_4_2_5_P1_C14(){

patch -Np1 -i ../dhcp-4.2.5-P1-missing_ipv6-1.patch
patch -Np1 -i ../dhcp-4.2.5-P1-client_script-1.patch &&
CFLAGS="-D_PATH_DHCLIENT_SCRIPT='\"/sbin/dhclient-script\"'         \
        -D_PATH_DHCPD_CONF='\"/etc/dhcp/dhcpd.conf\"'               \
        -D_PATH_DHCLIENT_CONF='\"/etc/dhcp/dhclient.conf\"'"        \
./configure --prefix=/usr                                           \
            --sysconfdir=/etc/dhcp                                  \
            --localstatedir=/var                                    \
            --with-srv-lease-file=/var/lib/dhcpd/dhcpd.leases       \
            --with-srv6-lease-file=/var/lib/dhcpd/dhcpd6.leases     \
            --with-cli-lease-file=/var/lib/dhclient/dhclient.leases \
            --with-cli6-lease-file=/var/lib/dhclient/dhclient6.leases &&
make
make -C client install         &&
mv -v /usr/sbin/dhclient /sbin &&
install -v -m755 client/scripts/linux /sbin/dhclient-script
make -C server install
make install                   &&
mv -v /usr/sbin/dhclient /sbin &&
install -v -m755 client/scripts/linux /sbin/dhclient-script
cat > /etc/dhcp/dhclient.conf << "EOF"
# Begin /etc/dhcp/dhclient.conf
#
# Basic dhclient.conf(5)

#prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        netbios-name-servers, netbios-scope, interface-mtu,
        ntp-servers;
require subnet-mask, domain-name-servers;
#timeout 60;
#retry 60;
#reboot 10;
#select-timeout 5;
#initial-interval 2;

# End /etc/dhcp/dhclient.conf
EOF

install -v -dm 755 /var/lib/dhclient
dhclient eth0

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-service-dhclient
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhclient"
DHCP_START=""
DHCP_STOP=""

# Set PRINTIP="yes" to have the script print
# the DHCP assigned IP address
PRINTIP="no"

# Set PRINTALL="yes" to print the DHCP assigned values for
# IP, SM, DG, and 1st NS. This requires PRINTIP="yes".
PRINTALL="no"
EOF

cat > /etc/dhcp/dhcpd.conf << "EOF"
# Begin /etc/dhcp/dhcpd.conf
#
# Example dhcpd.conf(5)

# Use this to enble / disable dynamic dns updates globally.
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

# This is a very basic subnet declaration.
subnet 10.254.239.0 netmask 255.255.255.224 {
  range 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
}

# End /etc/dhcp/dhcpd.conf
EOF

install -v -dm 755 /var/lib/dhcpd
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-dhcpd
}

export DHCP_4_2_5_P1_C14_download="ftp://ftp.isc.org/isc/dhcp/4.2.5-P1/dhcp-4.2.5-P1.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/dhcp-4.2.5-P1-client_script-1.patch http://www.linuxfromscratch.org/patches/blfs/svn/dhcp-4.2.5-P1-missing_ipv6-1.patch "

export DHCP_4_2_5_P1_C14_packname="dhcp-4.2.5-P1.tar.gz"

export C14_ConnectingtoaNetwork="dhcpcd_5_6_7_C14 DHCP_4_2_5_P1_C14 "


bridge_utils_1_5_C15(){

patch -Np1 -i ../bridge-utils-1.5-linux_3.8_fix-1.patch &&
autoconf -o configure configure.in                      &&
./configure --prefix=/usr                               &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-service-bridge
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/ifconfig.br0 << "EOF"
ONBOOT=yes
IFACE=br0
SERVICE="bridge ipv4-static"  # Space separated
IP=192.168.122.12
GATEWAY=192.168.122.2
PREFIX=24
BROADCAST=192.168.122.255
CHECK_LINK=no                 # Don't check before bridge is created
STP=no                        # Spanning tree protocol, default no
INTERFACE_COMPONENTS="eth0"   # Add to IFACE, space separated devices
IP_FORWARD=true
EOF

}

export bridge_utils_1_5_C15_download="http://sourceforge.net/projects/bridge/files/bridge/bridge-utils-1.5.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/bridge-utils-1.5-linux_3.8_fix-1.patch "

export bridge_utils_1_5_C15_packname="bridge-utils-1.5.tar.gz"

cifs_utils_5_7_C15(){

./configure --prefix=/usr &&
make
make install
}

export cifs_utils_5_7_C15_download="ftp://ftp.samba.org/pub/linux-cifs/cifs-utils/cifs-utils-5.7.tar.bz2 "

export cifs_utils_5_7_C15_packname="cifs-utils-5.7.tar.bz2"

export cifs_utils_5_7_C15_required_or_recommended="Samba_3_6_12_C15 "

NcFTP_3_2_5_C15(){

./configure --prefix=/usr --sysconfdir=/etc &&
make -C libncftp shared &&
make
make -C libncftp soinstall &&
make install
./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export NcFTP_3_2_5_C15_download="ftp://ftp.ncftp.com/ncftp/ncftp-3.2.5-src.tar.bz2 "

export NcFTP_3_2_5_C15_packname="ncftp-3.2.5-src.tar.bz2"

Net_tools_CVS_20101030_C15(){

sed -i -e '/Token/s/y$/n/'        config.in &&
sed -i -e '/HAVE_HWSTRIP/s/y$/n/' config.in &&
yes "" | make config                 &&
make
make update
}

export Net_tools_CVS_20101030_C15_download="http://anduin.linuxfromscratch.org/sources/BLFS/svn/n/net-tools-CVS_20101030.tar.gz ftp://anduin.linuxfromscratch.org/BLFS/svn/n/net-tools-CVS_20101030.tar.gz "

export Net_tools_CVS_20101030_C15_packname="net-tools-CVS_20101030.tar.gz"

NFS_Utilities_1_2_6_C15(){

groupadd -g 99 nogroup &&
useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup \
    -s /bin/false -u 99 nobody
patch -Np1 -i ../nfs-utils-1.2.6-fix_configure-1.patch &&

autoreconf &&

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --without-tcp-wrappers \
            --disable-nfsv4        \
            --disable-nfsv41       \
            --disable-gss &&
make
make install
/home <192.168.0.0/24>(rw,subtree_check,anonuid=99,anongid=99)

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-nfs-server
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/nfs-server << "EOF"
PORT="2049"
PROCESSES="8"
QUOTAS="no"
KILLDELAY="10"
EOF

<server-name>:/home  /home nfs   rw,_netdev,rsize=8192,wsize=8192 0 0
<server-name>:/usr   /usr  nfs   ro,_netdev,rsize=8192            0 0

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-nfs-client
}

export NFS_Utilities_1_2_6_C15_download="http://downloads.sourceforge.net/nfs/nfs-utils-1.2.6.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/nfs-utils-1.2.6-fix_configure-1.patch "

export NFS_Utilities_1_2_6_C15_packname="nfs-utils-1.2.6.tar.bz2"

export NFS_Utilities_1_2_6_C15_required_or_recommended="libtirpc_0_2_3_C17 pkg_config_0_28_C13 rpcbind_0_2_0_C15 "

Configuring_for_Network_Filesystems_C15(){

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-netfs
}

ntp_4_2_6p5_C15(){

groupadd -g 87 ntp &&
useradd -c "Network Time Protocol" -d /var/lib/ntp -u 87 \
        -g ntp -s /bin/false ntp
./configure --prefix=/usr --sysconfdir=/etc \
            --with-binsubdir=sbin &&
make
make install &&
install -v -m755 -d /usr/share/doc/ntp-4.2.6p5 &&
cp -v -R html/* /usr/share/doc/ntp-4.2.6p5/
cat > /etc/ntp.conf << "EOF"
# Asia
server 0.asia.pool.ntp.org

# Australia
server 0.oceania.pool.ntp.org

# Europe
server 0.europe.pool.ntp.org

# North America
server 0.north-america.pool.ntp.org

# South America
server 2.south-america.pool.ntp.org

driftfile /var/cache/ntp.drift
pidfile   /var/run/ntpd.pid
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-ntpd
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
ln -v -sf ../init.d/setclock /etc/rc.d/rc0.d/K46setclock &&
ln -v -sf ../init.d/setclock /etc/rc.d/rc6.d/K46setclock
}

export ntp_4_2_6p5_C15_download="http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.6p5.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/ntp-4.2.6p5.tar.gz "

export ntp_4_2_6p5_C15_packname="ntp-4.2.6p5.tar.gz"

export ntp_4_2_6p5_C15_required_or_recommended="libcap2_2_22_C4 "

rpcbind_0_2_0_C15(){

sed -i 's/^sunrpc/rpcbind/' /etc/services
./configure --prefix=/usr --bindir=/sbin &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-rpcbind
}

export rpcbind_0_2_0_C15_download="http://downloads.sourceforge.net/rpcbind/rpcbind-0.2.0.tar.bz2 "

export rpcbind_0_2_0_C15_packname="rpcbind-0.2.0.tar.bz2"

export rpcbind_0_2_0_C15_required_or_recommended="libtirpc_0_2_3_C17 "

rsync_3_0_9_C15(){

groupadd -g 48 rsyncd &&
useradd -c "rsyncd Daemon" -d /home/rsync -g rsyncd \
    -s /bin/false -u 48 rsyncd
./configure --prefix=/usr &&
make
pushd doc &&
docbook2pdf             rsync.sgml &&
docbook2ps              rsync.sgml &&
docbook2dvi             rsync.sgml &&
docbook2txt             rsync.sgml &&
docbook2html --nochunks rsync.sgml &&
popd
make install
install -v -m755 -d          /usr/share/doc/rsync-3.0.9/api &&
install -v -m644 dox/html/*  /usr/share/doc/rsync-3.0.9/api &&
install -v -m644 doc/rsync.* /usr/share/doc/rsync-3.0.9
cat > /etc/rsyncd.conf << "EOF"
# This is a basic rsync configuration file
# It exports a single module without user authentication.

motd file = /home/rsync/welcome.msg
use chroot = yes

[localhost]
    path = /home/rsync
    comment = Default rsync module
    read only = yes
    list = yes
    uid = rsyncd
    gid = rsyncd

EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-rsyncd
}

export rsync_3_0_9_C15_download="http://samba.org/ftp/rsync/src/rsync-3.0.9.tar.gz ftp://ftp.samba.org/pub/rsync/src/rsync-3.0.9.tar.gz "

export rsync_3_0_9_C15_packname="rsync-3.0.9.tar.gz"

Samba_3_6_12_C15(){

cd source3 &&

sed -i -e "s/python2.6 python2.5/python2.7 &/" \
       -e "s/python2.6-config python2.5-config/python2.7-config &/" \
          configure &&

./configure                            \
    --prefix=/usr                      \
    --sysconfdir=/etc                  \
    --localstatedir=/var               \
    --with-piddir=/run/samba           \
    --with-pammodulesdir=/lib/security \
    --with-fhs                         \
    --enable-nss-wrapper               \
    --enable-socket-wrapper            &&
sed -i "s/-ldl/& -ltirpc -lpthread/" Makefile &&
make
make install &&

install -v -m644 pkgconfig/*.pc /usr/lib/pkgconfig        &&
install -v -m755 ../nsswitch/libnss_win{s,bind}.so /lib   &&
ln -v -sf libnss_winbind.so /lib/libnss_winbind.so.2      &&
ln -v -sf libnss_wins.so    /lib/libnss_wins.so.2         &&

install -v -m644 ../examples/smb.conf.default /etc/samba  &&

if [ -d /etc/openldap/schema ]; then
    install -v -m644    ../examples/LDAP/README              \
                        /etc/openldap/schema/README.LDAP     &&
    install -v -m644    ../examples/LDAP/samba*              \
                        /etc/openldap/schema
    install -v -m755    ../examples/LDAP/{convert*,get*,ol*} \
                        /etc/openldap/schema
fi &&

install -v -m755 -d /usr/share/doc/samba-3.6.12 &&
install -v -m644    ../docs/*.pdf \
                    /usr/share/doc/samba-3.6.12 &&
ln -v -s ../../samba/swat  /usr/share/doc/samba-3.6.12
ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
groupadd -g 99 nogroup &&
useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup \
    -s /bin/false -u 99 nobody
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-samba
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-winbindd
echo "swat            905/tcp" >> /etc/services
cat >> /etc/xinetd.d/swat << "EOF"
# Begin /etc/xinetd.d/swat

service swat
{
    port            = 905
    socket_type     = stream
    wait            = no
    instances       = 5
    only_from       = 127.0.0.1
    user            = root
    server          = /usr/sbin/swat
    log_on_failure += USERID
}

# End /etc/xinetd.d/swat
EOF

cat >> /etc/stunnel/swat.conf << "EOF"
; File: /etc/stunnel/swat.conf

pid    = /run/stunnel-swat.pid
setuid = root
setgid = root
cert   = /etc/stunnel/stunnel.pem

[swat]
accept = swat
exec   = /usr/sbin/swat

EOF

make install-swat
}

export Samba_3_6_12_C15_download="http://ftp.samba.org/pub/samba/stable/samba-3.6.12.tar.gz ftp://ftp.samba.org/pub/samba/stable/samba-3.6.12.tar.gz file:///usr/share/samba/swat/using_samba/toc.html file:///usr/share/samba/swat/help/Samba-HOWTO-Collection/index.html file:///usr/share/samba/swat/help/Samba-Guide/index.html file:///usr/share/samba/swat/help/samba.7.html "

export Samba_3_6_12_C15_packname="samba-3.6.12.tar.gz"

export Samba_3_6_12_C15_required_or_recommended="libtirpc_0_2_3_C17 "

Wget_1_14_C15(){

./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
make
make install
echo ca-directory=/etc/ssl/certs >> /etc/wgetrc
}

export Wget_1_14_C15_download="http://ftp.gnu.org/gnu/wget/wget-1.14.tar.xz ftp://ftp.gnu.org/gnu/wget/wget-1.14.tar.xz "

export Wget_1_14_C15_packname="wget-1.14.tar.xz"

export Wget_1_14_C15_required_or_recommended="OpenSSL_1_0_1e_C4 "

Wireless_Tools_29_C15(){

make
make PREFIX=/usr INSTALL_MAN=/usr/share/man install
}

export Wireless_Tools_29_C15_download="http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.29.tar.gz "

export Wireless_Tools_29_C15_packname="wireless_tools.29.tar.gz"

wpa_supplicant_2_0_C15(){

cat > wpa_supplicant/.config << "EOF"
CONFIG_BACKEND=file
CONFIG_CTRL_IFACE=y
CONFIG_DEBUG_FILE=y
CONFIG_DEBUG_SYSLOG=y
CONFIG_DEBUG_SYSLOG_FACILITY=LOG_DAEMON
CONFIG_DRIVER_NL80211=y
CONFIG_DRIVER_WEXT=y
CONFIG_DRIVER_WIRED=y
CONFIG_EAP_GTC=y
CONFIG_EAP_LEAP=y
CONFIG_EAP_MD5=y
CONFIG_EAP_MSCHAPV2=y
CONFIG_EAP_OTP=y
CONFIG_EAP_PEAP=y
CONFIG_EAP_TLS=y
CONFIG_EAP_TTLS=y
CONFIG_IEEE8021X_EAPOL=y
CONFIG_IPV6=y
CONFIG_LIBNL32=y
CONFIG_PEERKEY=y
CONFIG_PKCS12=y
CONFIG_READLINE=y
CONFIG_SMARTCARD=y
CONFIG_WPS=y
CFLAGS += -I/usr/include/libnl3
EOF
cat >> wpa_supplicant/.config << "EOF"
CONFIG_CTRL_IFACE_DBUS=y
CONFIG_CTRL_IFACE_DBUS_NEW=y
CONFIG_CTRL_IFACE_DBUS_INTRO=y
EOF
cd wpa_supplicant &&
make BINDIR=/sbin LIBDIR=/lib
pushd wpa_gui-qt4 &&
qmake wpa_gui.pro &&
make &&
popd
install -v -m755 wpa_{cli,passphrase,supplicant} /sbin/ &&
install -v -m644 doc/docbook/wpa_supplicant.conf.5 /usr/share/man/man5/ &&
install -v -m644 doc/docbook/wpa_{cli,passphrase,supplicant}.8 /usr/share/man/man8/
install -v -m644 dbus/fi.{epitest.hostap.WPASupplicant,w1.wpa_supplicant1}.service \
                 /usr/share/dbus-1/system-services/ &&
install -v -m644 dbus/dbus-wpa_supplicant.conf \
                 /etc/dbus-1/system.d/wpa_supplicant.conf
install -v -m755 wpa_gui-qt4/wpa_gui /usr/bin/ &&
install -v -m644 doc/docbook/wpa_gui.8 /usr/share/man/man8/ &&
install -v -m644 wpa_gui-qt4/wpa_gui.desktop /usr/share/applications/ &&
install -v -m644 wpa_gui-qt4/icons/wpa_gui.svg /usr/share/pixmaps/
update-desktop-database
wpa_passphrase SSID SECRET_PASSWORD > /etc/sysconfig/wpa_supplicant-wifi0.conf

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-service-wpa
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/ifconfig.wifi0 << "EOF"
ONBOOT="yes"
IFACE="wlan0"
SERVICE="wpa"

# Additional arguments to wpa_supplicant
WPA_ARGS=""

WPA_SERVICE="dhclient"
DHCP_START=""
DHCP_STOP=""

# Set PRINTIP="yes" to have the script print
# the DHCP assigned IP address
PRINTIP="no"

# Set PRINTALL="yes" to print the DHCP assigned values for
# IP, SM, DG, and 1st NS. This requires PRINTIP="yes".
PRINTALL="no"
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/ifconfig.wifi0 << "EOF"
ONBOOT="yes"
IFACE="wlan0"
SERVICE="wpa"

# Additional arguments to wpa_supplicant
WPA_ARGS=""

WPA_SERVICE="dhcpcd"
DHCP_START="-b -q <insert appropriate start options here>"
DHCP_STOP="-k <insert additional stop options here>"
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/sysconfig/ifconfig.wifi0 << "EOF"
ONBOOT="yes"
IFACE="wlan0"
SERVICE="wpa"

# Additional arguments to wpa_supplicant
WPA_ARGS=""

WPA_SERVICE="ipv4-static"
IP="192.168.1.1"
GATEWAY="192.168.1.2"
PREFIX="24"
BROADCAST="192.168.1.255"
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
ifup wifi0

}

export wpa_supplicant_2_0_C15_download="http://hostap.epitest.fi/releases/wpa_supplicant-2.0.tar.gz "

export wpa_supplicant_2_0_C15_packname="wpa_supplicant-2.0.tar.gz"

export wpa_supplicant_2_0_C15_required_or_recommended="libnl_3_2_21_C17 OpenSSL_1_0_1e_C4 "

export C15_NetworkingPrograms="bridge_utils_1_5_C15 cifs_utils_5_7_C15 NcFTP_3_2_5_C15 Net_tools_CVS_20101030_C15 NFS_Utilities_1_2_6_C15 Configuring_for_Network_Filesystems_C15 ntp_4_2_6p5_C15 rpcbind_0_2_0_C15 rsync_3_0_9_C15 Samba_3_6_12_C15 Wget_1_14_C15 Wireless_Tools_29_C15 wpa_supplicant_2_0_C15 Other_Networking_Programs_C15 "


Avahi_0_6_31_C16(){

groupadd -fg 84 avahi &&
useradd -c "Avahi Daemon Owner" -d /var/run/avahi-daemon -u 84 \
        -g avahi -s /bin/false avahi
groupadd -fg 86 netdev
./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-static     \
            --disable-mono       \
            --disable-monodoc    \
            --disable-python     \
            --disable-qt3        \
            --disable-qt4        \
            --enable-core-docs   \
            --with-distro=none &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-avahi
}

export Avahi_0_6_31_C16_download="http://avahi.org/download/avahi-0.6.31.tar.gz "

export Avahi_0_6_31_C16_packname="avahi-0.6.31.tar.gz"

export Avahi_0_6_31_C16_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 "

BIND_Utilities_9_9_2_P2_C16(){

./configure --prefix=/usr &&
make -C lib/dns &&
make -C lib/isc &&
make -C lib/bind9 &&
make -C lib/isccfg &&
make -C lib/lwres &&
make -C bin/dig
make -C bin/dig install
}

export BIND_Utilities_9_9_2_P2_C16_download="ftp://ftp.isc.org/isc/bind9/9.9.2-P2/bind-9.9.2-P2.tar.gz "

export BIND_Utilities_9_9_2_P2_C16_packname="bind-9.9.2-P2.tar.gz"

mod_dnssd_0_6_C16(){

./configure --prefix=/usr \
            --disable-lynx &&
make
make install
}

export mod_dnssd_0_6_C16_download="http://0pointer.de/lennart/projects/mod_dnssd/mod_dnssd-0.6.tar.gz "

export mod_dnssd_0_6_C16_packname="mod_dnssd-0.6.tar.gz"

export mod_dnssd_0_6_C16_required_or_recommended="Apache_2_4_3_C20 Avahi_0_6_31_C16 "

NetworkManager_0_9_8_0_C16(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/NetworkManager \
            --without-systemdsystemunitdir \
            --disable-ppp &&
make
make install
cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
[main]
plugins=keyfile
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-networkmanager
}

export NetworkManager_0_9_8_0_C16_download="http://ftp.gnome.org/pub/gnome/sources/NetworkManager/0.9/NetworkManager-0.9.8.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/NetworkManager/0.9/NetworkManager-0.9.8.0.tar.xz "

export NetworkManager_0_9_8_0_C16_packname="NetworkManager-0.9.8.0.tar.xz"

export NetworkManager_0_9_8_0_C16_required_or_recommended="D_Bus_GLib_Bindings_C12 Intltool_0_50_2_C11 libnl_3_2_21_C17 NSS_3_14_3_C4 Udev_Installed_LFS_Version_C12 ConsoleKit_0_4_6_C4 dhcpcd_5_6_7_C14 gobject_introspection_1_34_2_C9 Iptables_1_4_18_C4 libsoup_2_40_3_C17 Polkit_0_110_C4 UPower_0_9_20_C12 Vala_0_18_1_C13 "

Nmap_6_01_C16(){

./configure --prefix=/usr &&
make
make install
}

export Nmap_6_01_C16_download="http://anduin.linuxfromscratch.org/sources/BLFS/svn/n/nmap-6.01.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/nmap-6.01.tar.bz2 "

export Nmap_6_01_C16_packname="nmap-6.01.tar.bz2"

Traceroute_2_0_19_C16(){

make
make prefix=/usr install &&
mv /usr/bin/traceroute /bin
}

export Traceroute_2_0_19_C16_download="http://downloads.sourceforge.net/traceroute/traceroute-2.0.19.tar.gz "

export Traceroute_2_0_19_C16_packname="traceroute-2.0.19.tar.gz"

Whois_5_0_20_C16(){

make
make prefix=/usr install-whois
make prefix=/usr install-mkpasswd
make prefix=/usr install-pos
}

export Whois_5_0_20_C16_download="http://ftp.debian.org/debian/pool/main/w/whois/whois_5.0.20.tar.xz ftp://ftp.debian.org/debian/pool/main/w/whois/whois_5.0.20.tar.xz "

export Whois_5_0_20_C16_packname="whois_5.0.20.tar.xz"

Wicd_1_7_2_4_C16(){

sed -i '/wpath.logrotate\|wpath.systemd/d' setup.py &&
python setup.py configure --no-install-kde \
                          --no-install-acpi \
                          --no-install-pmutils \
                          --no-install-init
python setup.py install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-wicd
}

export Wicd_1_7_2_4_C16_download="http://launchpad.net/wicd/1.7/1.7.2.4/+download/wicd-1.7.2.4.tar.gz "

export Wicd_1_7_2_4_C16_packname="wicd-1.7.2.4.tar.gz"

export Wicd_1_7_2_4_C16_required_or_recommended="Python_2_7_3_C13 D_Bus_Python_Bindings_C12 Wireless_Tools_29_C15 Net_tools_CVS_20101030_C15 PyGTK_2_24_0_C13 wpa_supplicant_2_0_C15 dhcpcd_5_6_7_C14 "

Wireshark_1_8_3_C16(){

cat > svnversion.h << "EOF"
#define SVNVERSION "BLFS"
#define SVNPATH "source"
EOF

cat > make-version.pl << "EOF"
#!/usr/bin/perl
EOF
groupadd -g 62 wireshark
./configure --prefix=/usr --sysconfdir=/etc &&
make
make install &&

install -v -m755 -d /usr/share/doc/wireshark-1.8.3 &&
install -v -m755 -d /usr/share/pixmaps/wireshark &&

install -v -m644    README{,.linux} doc/README.* doc/*.{pod,txt} \
                    /usr/share/doc/wireshark-1.8.3 &&

pushd /usr/share/doc/wireshark-1.8.3 &&
   for FILENAME in ../../wireshark/*.html; do
      ln -s -v $FILENAME .
   done &&
popd &&

install -v -m644 -D wireshark.desktop \
                    /usr/share/applications/wireshark.desktop &&

install -v -m644 -D image/wsicon48.png \
                    /usr/share/pixmaps/wireshark.png &&

install -v -m644    image/*.{png,ico,xpm,bmp} \
                    /usr/share/pixmaps/wireshark
install -v -m644 <Downloaded_Files> /usr/share/doc/wireshark-1.8.3

chown -R root:wireshark /usr/bin/{tshark,dumpcap} &&
chmod -v 6550 /usr/bin/{tshark,dumpcap}
}

export Wireshark_1_8_3_C16_download="http://www.wireshark.org/download/src/all-versions/wireshark-1.8.3.tar.bz2  "

export Wireshark_1_8_3_C16_packname="wireshark-1.8.3.tar.bz2"

export Wireshark_1_8_3_C16_required_or_recommended="GLib_2_34_3_C9 libpcap_1_3_0_C17 "

export C16_NetworkingUtilities="Avahi_0_6_31_C16 BIND_Utilities_9_9_2_P2_C16 mod_dnssd_0_6_C16 NetworkManager_0_9_8_0_C16 Nmap_6_01_C16 Traceroute_2_0_19_C16 Whois_5_0_20_C16 Wicd_1_7_2_4_C16 Wireshark_1_8_3_C16 "


cURL_7_29_0_C17(){

patch -Np1 -i ../curl-7.29.0-upstream_fixes-1.patch &&
sed -i '/--static-libs)/{N;s#echo .*#echo #;}' curl-config.in &&
./configure --prefix=/usr              \
            --disable-static           \
            --enable-threaded-resolver \
            --with-ca-path=/etc/ssl/certs &&
make
make install &&
find docs \( -name "Makefile*" -o -name "*.1" -o -name "*.3" \) -exec rm {} \; &&
install -v -d -m755 /usr/share/doc/curl-7.29.0 &&
cp -v -R docs/*     /usr/share/doc/curl-7.29.0
}

export cURL_7_29_0_C17_download="http://curl.haxx.se/download/curl-7.29.0.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/curl-7.29.0-upstream_fixes-1.patch "

export cURL_7_29_0_C17_packname="curl-7.29.0.tar.bz2"

export cURL_7_29_0_C17_required_or_recommended="Certificate_Authority_Certificates_C4 OpenSSL_1_0_1e_C4 "

GeoClue_0_12_0_C17(){

patch -Np1 -i ../geoclue-0.12.0-gpsd_fix-1.patch &&
sed -i "s@ -Werror@@" configure &&
sed -i "s@libnm_glib@libnm-glib@g" configure &&
sed -i "s@geoclue/libgeoclue.la@& -lgthread-2.0@g" \
       providers/skyhook/Makefile.in &&
./configure --prefix=/usr --libexecdir=/usr/lib/geoclue &&
make
make install
}

export GeoClue_0_12_0_C17_download="https://launchpad.net/geoclue/trunk/0.12/+download/geoclue-0.12.0.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/geoclue-0.12.0-gpsd_fix-1.patch "

export GeoClue_0_12_0_C17_packname="geoclue-0.12.0.tar.gz"

export GeoClue_0_12_0_C17_required_or_recommended="D_Bus_GLib_Bindings_C12 GConf_3_2_6_C30 libxslt_1_1_28_C9 libsoup_2_40_3_C17 NetworkManager_0_9_8_0_C16 "

glib_networking_2_34_2_C17(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/glib-networking \
            --with-ca-certificates=/etc/ssl/ca-bundle.crt \
            --disable-static &&
make
make install
}

export glib_networking_2_34_2_C17_download="http://ftp.gnome.org/pub/gnome/sources/glib-networking/2.34/glib-networking-2.34.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/glib-networking/2.34/glib-networking-2.34.2.tar.xz "

export glib_networking_2_34_2_C17_packname="glib-networking-2.34.2.tar.xz"

export glib_networking_2_34_2_C17_required_or_recommended="GnuTLS_3_1_10_C4 gsettings_desktop_schemas_3_6_1_C30 p11_kit_0_15_2_C4 "

libevent_2_0_21_C17(){

./configure --prefix=/usr --disable-static &&
make
make install
install -v -m755 -d /usr/share/doc/libevent-2.0.21/api &&
cp      -v -R       doxygen/html/* \
                    /usr/share/doc/libevent-2.0.21/api
}

export libevent_2_0_21_C17_download="https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz "

export libevent_2_0_21_C17_packname="libevent-2.0.21-stable.tar.gz"

export libevent_2_0_21_C17_required_or_recommended="OpenSSL_1_0_1e_C4 "

libnice_0_1_3_C17(){

./configure --prefix=/usr \
            --disable-static \
            --without-gstreamer-0.10 &&
make
make install
}

export libnice_0_1_3_C17_download="http://nice.freedesktop.org/releases/libnice-0.1.3.tar.gz "

export libnice_0_1_3_C17_packname="libnice-0.1.3.tar.gz"

export libnice_0_1_3_C17_required_or_recommended="GLib_2_34_3_C9 gst_plugins_base_1_0_6_C38 "

libnl_3_2_21_C17(){

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static &&
make
make install
}

export libnl_3_2_21_C17_download="http://www.infradead.org/~tgr/libnl/files/libnl-3.2.21.tar.gz "

export libnl_3_2_21_C17_packname="libnl-3.2.21.tar.gz"

libpcap_1_3_0_C17(){

./configure --prefix=/usr &&
make
make install
}

export libpcap_1_3_0_C17_download="http://www.tcpdump.org/release/libpcap-1.3.0.tar.gz "

export libpcap_1_3_0_C17_packname="libpcap-1.3.0.tar.gz"

librest_0_7_90_C17(){

./configure --prefix=/usr \
            --with-ca-certificates=/etc/ssl/ca-bundle.crt &&
make
make install
}

export librest_0_7_90_C17_download="http://ftp.gnome.org/pub/gnome/sources/rest/0.7/rest-0.7.90.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/rest/0.7/rest-0.7.90.tar.xz "

export librest_0_7_90_C17_packname="rest-0.7.90.tar.xz"

export librest_0_7_90_C17_required_or_recommended="Certificate_Authority_Certificates_C4 libsoup_2_40_3_C17 gobject_introspection_1_34_2_C9 "

libsoup_2_40_3_C17(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libsoup_2_40_3_C17_download="http://ftp.gnome.org/pub/gnome/sources/libsoup/2.40/libsoup-2.40.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libsoup/2.40/libsoup-2.40.3.tar.xz "

export libsoup_2_40_3_C17_packname="libsoup-2.40.3.tar.xz"

export libsoup_2_40_3_C17_required_or_recommended="glib_networking_2_34_2_C17 libxml2_2_9_0_C9 gobject_introspection_1_34_2_C9 libgnome_keyring_3_6_0_C30 SQLite_3_7_16_1_C22 "

libtirpc_0_2_3_C17(){

if [ ! -r /usr/include/rpc/rpc.h ]; then
   tar -xvf ../rpcnis-headers.tar.bz2 -C /usr/include
fi
patch -Np1 -i ../libtirpc-0.2.3-remove_nis-1.patch &&
sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac &&
autoreconf -fi &&
./configure --prefix=/usr --sysconfdir=/etc CFLAGS="-fPIC" &&
make
make install &&
mv -v /usr/lib/libtirpc.so.* /lib &&
ln -sfv ../../lib/libtirpc.so.1.0.10 /usr/lib/libtirpc.so
}

export libtirpc_0_2_3_C17_download="http://downloads.sourceforge.net/project/libtirpc/libtirpc/0.2.3/libtirpc-0.2.3.tar.bz2 ftp://anduin.linuxfromscratch.org/other/rpcnis-headers.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/libtirpc-0.2.3-remove_nis-1.patch "

export libtirpc_0_2_3_C17_packname="libtirpc-0.2.3.tar.bz2"

export libtirpc_0_2_3_C17_required_or_recommended="pkg_config_0_28_C13 "

neon_0_29_6_C17(){

./configure --prefix=/usr --enable-shared --disable-static &&
make
make install
}

export neon_0_29_6_C17_download="http://www.webdav.org/neon/neon-0.29.6.tar.gz "

export neon_0_29_6_C17_packname="neon-0.29.6.tar.gz"

export neon_0_29_6_C17_required_or_recommended="libxml2_2_9_0_C9 "

export C17_NetworkingLibraries="cURL_7_29_0_C17 GeoClue_0_12_0_C17 glib_networking_2_34_2_C17 libevent_2_0_21_C17 libnice_0_1_3_C17 libnl_3_2_21_C17 libpcap_1_3_0_C17 librest_0_7_90_C17 libsoup_2_40_3_C17 libtirpc_0_2_3_C17 neon_0_29_6_C17 "


Links_2_7_C18(){

./configure --prefix=/usr &&
make
make install &&
install -v -d -m755 /usr/share/doc/links-2.7 &&
install -v -m644 doc/links_cal/* KEYS BRAILLE_HOWTO \
    /usr/share/doc/links-2.7
}

export Links_2_7_C18_download="http://links.twibright.com/download/links-2.7.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/links-2.7.tar.bz2 "

export Links_2_7_C18_packname="links-2.7.tar.bz2"

export Links_2_7_C18_required_or_recommended="GPM_1_20_7_C12 OpenSSL_1_0_1e_C4 "

Lynx_2_8_8dev_15_C18(){

./configure --prefix=/usr          \
            --sysconfdir=/etc/lynx \
            --datadir=/usr/share/doc/lynx-2.8.8dev.15 \
            --with-zlib            \
            --with-bzlib           \
            --with-screen=ncursesw \
            --enable-locale-charset &&
make
make install-full &&
chgrp -v -R root /usr/share/doc/lynx-2.8.8dev.15/lynx_doc
echo "#define USE_OPENSSL_INCL 1" >> lynx_cfg.h
sed -i 's/#\(LOCALE_CHARSET\):FALSE/\1:TRUE/' /etc/lynx/lynx.cfg
sed -i 's/#\(DEFAULT_EDITOR\):/\1:vi/' /etc/lynx/lynx.cfg
sed -i 's/#\(PERSISTENT_COOKIES\):FALSE/\1:TRUE/' /etc/lynx/lynx.cfg
}

export Lynx_2_8_8dev_15_C18_download="http://lynx.isc.org/current/lynx2.8.8dev.15.tar.bz2 ftp://lynx.isc.org/current/lynx2.8.8dev.15.tar.bz2 "

export Lynx_2_8_8dev_15_C18_packname="lynx2.8.8dev.15.tar.bz2"

W3m_0_5_3_C18(){

patch -p1 < ../w3m-0.5.3-bdwgc72-1.patch &&
sed -i 's/file_handle/file_foo/' istream.{c,h} &&
sed -i 's#gdk-pixbuf-xlib-2.0#& x11#' configure &&
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib &&
make
make install &&
install -v -m644 -D doc/keymap.default /etc/w3m/keymap &&
install -v -m644    doc/menu.default /etc/w3m/menu &&
install -v -m755 -d /usr/share/doc/w3m-0.5.3 &&
install -v -m644    doc/{HISTORY,READ*,keymap.*,menu.*,*.html} \
                    /usr/share/doc/w3m-0.5.3
}

export W3m_0_5_3_C18_download="http://downloads.sourceforge.net/w3m/w3m-0.5.3.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/w3m-0.5.3-bdwgc72-1.patch "

export W3m_0_5_3_C18_packname="w3m-0.5.3.tar.gz"

export W3m_0_5_3_C18_required_or_recommended="GC_7_2d_C13 "

export C18_TextWebBrowsers="Links_2_7_C18 Lynx_2_8_8dev_15_C18 W3m_0_5_3_C18 "


mailx_12_4_C19(){

patch -Np1 -i ../mailx-12.4-openssl_1.0.0_build_fix-1.patch &&
make SENDMAIL=/usr/sbin/sendmail
make PREFIX=/usr UCBINSTALL=/usr/bin/install install &&
ln -v -sf mailx /usr/bin/mail &&
ln -v -sf mailx /usr/bin/nail &&
install -v -m755 -d /usr/share/doc/mailx-12.4 &&
install -v -m644 README mailx.1.html /usr/share/doc/mailx-12.4
}

export mailx_12_4_C19_download="http://downloads.sourceforge.net/heirloom/mailx-12.4.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/mailx-12.4-openssl_1.0.0_build_fix-1.patch "

export mailx_12_4_C19_packname="mailx-12.4.tar.bz2"

Procmail_3_22_C19(){

sed -i 's/getline/get_line/' src/*.[ch] &&
make LOCKINGTEST=/tmp install &&
make install-suid
}

export Procmail_3_22_C19_download="http://www.ring.gr.jp/archives/net/mail/procmail/procmail-3.22.tar.gz ftp://ftp.psg.com/pub/unix/procmail/procmail-3.22.tar.gz "

export Procmail_3_22_C19_packname="procmail-3.22.tar.gz"

Fetchmail_6_3_21_C19(){

./configure --prefix=/usr --with-ssl --enable-fallback=procmail &&
make
make install
cat > ~/.fetchmailrc << "EOF"
set logfile /var/log/fetchmail.log
set no bouncemail
set postmaster root

poll SERVERNAME :
    user mao pass ping;
    mda "/usr/bin/procmail -f %F -d %T";
EOF

chmod -v 0600 ~/.fetchmailrc

}

export Fetchmail_6_3_21_C19_download="http://downloads.sourceforge.net/fetchmail.berlios/fetchmail-6.3.21.tar.xz ftp://ftp.at.gnucash.org/pub/infosys/mail/fetchmail/fetchmail-6.3.21.tar.xz "

export Fetchmail_6_3_21_C19_packname="fetchmail-6.3.21.tar.xz"

export Fetchmail_6_3_21_C19_required_or_recommended="OpenSSL_1_0_1e_C4 Procmail_3_22_C19 "

Mutt_1_5_21_C19(){

groupadd -g 34 mail
chgrp -v mail /var/mail
./configure --prefix=/usr --sysconfdir=/etc \
            --with-docdir=/usr/share/doc/mutt-1.5.21 \
            --enable-pop --enable-imap \
            --enable-hcache --without-qdbm \
            --without-tokyocabinet \
            --with-gdbm --without-bdb &&
make
make -C doc manual.pdf
make install
install -v -m644 doc/manual.{pdf,tex} \
    /usr/share/doc/mutt-1.5.21
cat /usr/share/doc/mutt-1.5.21/samples/gpg.rc >> ~/.muttrc
ln -v -s gpg2 /usr/bin/gpg
}

export Mutt_1_5_21_C19_download="http://downloads.sourceforge.net/mutt/mutt-1.5.21.tar.gz ftp://ftp.mutt.org/mutt/devel/mutt-1.5.21.tar.gz "

export Mutt_1_5_21_C19_packname="mutt-1.5.21.tar.gz"

Re_alpine_2_02_C19(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --without-ldap \
            --without-krb5 \
            --with-ssl-dir=/usr \
            --with-passfile=.pine-passfile &&
make
make install
}

export Re_alpine_2_02_C19_download="http://sourceforge.net/projects/re-alpine/files/re-alpine-2.02.tar.bz2 "

export Re_alpine_2_02_C19_packname="re-alpine-2.02.tar.bz2"

export Re_alpine_2_02_C19_required_or_recommended="OpenSSL_1_0_1e_C4 "

export C19_MailNewsClients="mailx_12_4_C19 Procmail_3_22_C19 Fetchmail_6_3_21_C19 Mutt_1_5_21_C19 Re_alpine_2_02_C19 Other_Mail_and_News_Programs_C19 "


Apache_2_4_3_C20(){

groupadd -g 25 apache &&
useradd -c "Apache Server" -d /srv/www -g apache \
        -s /bin/false -u 25 apache
patch -Np1 -i ../httpd-2.4.3-blfs_layout-1.patch &&
./configure --enable-layout=BLFS \
            --enable-mods-shared="all cgi" \
            --enable-mpms-shared=all \
            --with-apr=/usr/bin/apr-1-config \
            --with-apr-util=/usr/bin/apu-1-config \
            --enable-suexec=shared \
            --with-suexec-bin=/usr/lib/httpd/suexec \
            --with-suexec-docroot=/srv/www \
            --with-suexec-caller=apache \
            --with-suexec-userdir=public_html \
            --with-suexec-logfile=/var/log/httpd/suexec.log \
            --with-suexec-uidmin=100 &&
make
make install &&

mv -v /usr/sbin/suexec /usr/lib/httpd/suexec &&
chgrp apache /usr/lib/httpd/suexec &&
chmod 4754 /usr/lib/httpd/suexec &&

chown -R -R apache:apache /srv/www
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-httpd
}

export Apache_2_4_3_C20_download="http://archive.apache.org/dist/httpd/httpd-2.4.3.tar.bz2 ftp://apache.mirrors.pair.com/httpd/httpd-2.4.3.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/httpd-2.4.3-blfs_layout-1.patch "

export Apache_2_4_3_C20_packname="httpd-2.4.3.tar.bz2"

export Apache_2_4_3_C20_required_or_recommended="Apr_Util_1_5_1_C11 OpenSSL_1_0_1e_C4 "

BIND_9_9_2_P2_C20(){

patch -Np1 -i ../bind-9.9.2-P2-use_iproute2-1.patch
./configure --prefix=/usr           \
            --sysconfdir=/etc       \
            --localstatedir=/var    \
            --mandir=/usr/share/man \
            --enable-threads        \
            --with-libtool          &&
make
bin/tests/system/ifconfig.sh up
bin/tests/system/ifconfig.sh down
grep "R:PASS" check.log | wc -l
make install &&
chmod -v 0755 /usr/lib/lib{bind9,isc{,cc,cfg},lwres,dns}.so.*.?.? &&

install -v -m755 -d /usr/share/doc/bind-9.9.2-P2/{arm,misc} &&
install -v -m644    doc/arm/*.html \
                    /usr/share/doc/bind-9.9.2-P2/arm &&
install -v -m644 \
    doc/misc/{dnssec,ipv6,migrat*,options,rfc-compliance,roadmap,sdb} \
    /usr/share/doc/bind-9.9.2-P2/misc
groupadd -g 20 named &&
useradd -c "BIND Owner" -g named -s /bin/false -u 20 named &&
install -d -m770 -o named -g named /srv/named
cd /srv/named &&
mkdir -p dev etc/namedb/{slave,pz} usr/lib/engines var/run/named &&
mknod /srv/named/dev/null c 1 3 &&
mknod /srv/named/dev/random c 1 8 &&
chmod 666 /srv/named/dev/{null,random} &&
cp /etc/localtime etc &&
touch /srv/named/managed-keys.bind &&
cp /usr/lib/engines/libgost.so usr/lib/engines &&
[ $(uname -m) = x86_64 ] && ln -sfv lib usr/lib64
rndc-confgen -r /dev/urandom -b 512 > /etc/rndc.conf &&
sed '/conf/d;/^#/!d;s:^# ::' /etc/rndc.conf > /srv/named/etc/named.conf
cat >> /srv/named/etc/named.conf << "EOF"
options {
    directory "/etc/namedb";
    pid-file "/var/run/named.pid";
    statistics-file "/var/run/named.stats";

};
zone "." {
    type hint;
    file "root.hints";
};
zone "0.0.127.in-addr.arpa" {
    type master;
    file "pz/127.0.0";
};

// Bind 9 now logs by default through syslog (except debug).
// These are the default logging rules.

logging {
    category default { default_syslog; default_debug; };
    category unmatched { null; };

  channel default_syslog {
      syslog daemon;                      // send to syslog's daemon
                                          // facility
      severity info;                      // only send priority info
                                          // and higher
  };

  channel default_debug {
      file "named.run";                   // write to named.run in
                                          // the working directory
                                          // Note: stderr is used instead
                                          // of "named.run"
                                          // if the server is started
                                          // with the '-f' option.
      severity dynamic;                   // log at the server's
                                          // current debug level
  };

  channel default_stderr {
      stderr;                             // writes to stderr
      severity info;                      // only send priority info
                                          // and higher
  };

  channel null {
      null;                               // toss anything sent to
                                          // this channel
  };
};
EOF

cat > /srv/named/etc/namedb/pz/127.0.0 << "EOF"
$TTL 3D
@      IN      SOA     ns.local.domain. hostmaster.local.domain. (
                        1       ; Serial
                        8H      ; Refresh
                        2H      ; Retry
                        4W      ; Expire
                        1D)     ; Minimum TTL
                NS      ns.local.domain.
1               PTR     localhost.
EOF

cat > /srv/named/etc/namedb/root.hints << "EOF"
.                       6D  IN      NS      A.ROOT-SERVERS.NET.
.                       6D  IN      NS      B.ROOT-SERVERS.NET.
.                       6D  IN      NS      C.ROOT-SERVERS.NET.
.                       6D  IN      NS      D.ROOT-SERVERS.NET.
.                       6D  IN      NS      E.ROOT-SERVERS.NET.
.                       6D  IN      NS      F.ROOT-SERVERS.NET.
.                       6D  IN      NS      G.ROOT-SERVERS.NET.
.                       6D  IN      NS      H.ROOT-SERVERS.NET.
.                       6D  IN      NS      I.ROOT-SERVERS.NET.
.                       6D  IN      NS      J.ROOT-SERVERS.NET.
.                       6D  IN      NS      K.ROOT-SERVERS.NET.
.                       6D  IN      NS      L.ROOT-SERVERS.NET.
.                       6D  IN      NS      M.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.     6D  IN      A       198.41.0.4
B.ROOT-SERVERS.NET.     6D  IN      A       192.228.79.201
C.ROOT-SERVERS.NET.     6D  IN      A       192.33.4.12
D.ROOT-SERVERS.NET.     6D  IN      A       128.8.10.90
E.ROOT-SERVERS.NET.     6D  IN      A       192.203.230.10
F.ROOT-SERVERS.NET.     6D  IN      A       192.5.5.241
G.ROOT-SERVERS.NET.     6D  IN      A       192.112.36.4
H.ROOT-SERVERS.NET.     6D  IN      A       128.63.2.53
I.ROOT-SERVERS.NET.     6D  IN      A       192.36.148.17
J.ROOT-SERVERS.NET.     6D  IN      A       192.58.128.30
K.ROOT-SERVERS.NET.     6D  IN      A       193.0.14.129
L.ROOT-SERVERS.NET.     6D  IN      A       199.7.83.42
M.ROOT-SERVERS.NET.     6D  IN      A       202.12.27.33
EOF

cp /etc/resolv.conf /etc/resolv.conf.bak &&
cat > /etc/resolv.conf << "EOF"
search <yourdomain.com>
EOF

chown -R named:named /srv/named
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-bind
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
/etc/rc.d/init.d/bind start
dig -x 127.0.0.1
dig www.linuxfromscratch.org &&
dig www.linuxfromscratch.org
}

export BIND_9_9_2_P2_C20_download="ftp://ftp.isc.org/isc/bind9/9.9.2-P2/bind-9.9.2-P2.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/bind-9.9.2-P2-use_iproute2-1.patch "

export BIND_9_9_2_P2_C20_packname="bind-9.9.2-P2.tar.gz"

ProFTPD_1_3_4b_C20(){

groupadd -g 46 proftpd &&
useradd -c proftpd -d /srv/ftp -g proftpd \
        -s /usr/bin/proftpdshell -u 46 proftpd &&
install -v -d -m775 -o proftpd -g proftpd /srv/ftp &&
ln -v -s /bin/false /usr/bin/proftpdshell &&
echo /usr/bin/proftpdshell >> /etc/shells
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/run &&
make
make install
cat > /etc/proftpd.conf << "EOF"
# This is a basic ProFTPD configuration file
# It establishes a single server and a single anonymous login.

ServerName                      "ProFTPD Default Installation"
ServerType                      standalone
DefaultServer                   on

# Port 21 is the standard FTP port.
Port                            21
# Umask 022 is a good standard umask to prevent new dirs and files
# from being group and world writable.
Umask                           022

# To prevent DoS attacks, set the maximum number of child processes
# to 30.  If you need to allow more than 30 concurrent connections
# at once, simply increase this value.  Note that this ONLY works
# in standalone mode, in inetd mode you should use an inetd server
# that allows you to limit maximum number of processes per service

MaxInstances                    30

# Set the user and group that the server normally runs at.
User                            proftpd
Group                           proftpd

# Normally, files should be overwritable.
<Directory /*>
  AllowOverwrite                on
</Directory>

# A basic anonymous configuration, no upload directories.
<Anonymous ~proftpd>
  User                          proftpd
  Group                         proftpd
  # Clients should be able to login with "anonymous" as well as "proftpd"
  UserAlias                     anonymous proftpd

  # Limit the maximum number of anonymous logins
  MaxClients                    10

  # 'welcome.msg' should be displayed at login, and '.message' displayed
  # in each newly chdired directory.
  DisplayLogin                  welcome.msg
  DisplayChdir                  .message

  # Limit WRITE everywhere in the anonymous chroot
  <Limit WRITE>
    DenyAll
  </Limit>
</Anonymous>
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-proftpd
}

export ProFTPD_1_3_4b_C20_download="ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.4b.tar.gz "

export ProFTPD_1_3_4b_C20_packname="proftpd-1.3.4b.tar.gz"

vsftpd_3_0_2_C20(){

install -v -d -m 0755 /var/ftp/empty &&
install -v -d -m 0755 /home/ftp      &&
groupadd -g 47 vsftpd                &&
groupadd -g 45 ftp                   &&
useradd -c "vsftpd User"  -d /dev/null -g vsftpd -s /bin/false -u 47 vsftpd &&
useradd -c anonymous_user -d /home/ftp -g ftp    -s /bin/false -u 45 ftp
sed -i -e 's|#define VSF_SYSDEP_HAVE_LIBCAP|//&|' sysdeputil.c
make
install -v -m 755 vsftpd        /usr/sbin/vsftpd    &&
install -v -m 644 vsftpd.8      /usr/share/man/man8 &&
install -v -m 644 vsftpd.conf.5 /usr/share/man/man5 &&
install -v -m 644 vsftpd.conf   /etc
cat >> /etc/vsftpd.conf << "EOF"
background=YES
listen=YES
nopriv_user=vsftpd
secure_chroot_dir=/var/ftp/empty
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-vsftpd
}

export vsftpd_3_0_2_C20_download="https://security.appspot.com/downloads/vsftpd-3.0.2.tar.gz "

export vsftpd_3_0_2_C20_packname="vsftpd-3.0.2.tar.gz"

export C20_MajorServers="Apache_2_4_3_C20 BIND_9_9_2_P2_C20 ProFTPD_1_3_4b_C20 vsftpd_3_0_2_C20 "


Exim_4_80_1_C21(){

groupadd -g 31 exim &&
useradd -d /dev/null -c "Exim Daemon" -g exim -s /bin/false -u 31 exim
sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,' \
    -e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,' \
    -e 's,^EXIM_USER.*$,EXIM_USER=exim,' \
    -e 's,^EXIM_MONITOR,#EXIM_MONITOR,' src/EDITME > Local/Makefile &&
make
make install &&
install -v -m644 doc/exim.8 /usr/share/man/man8 &&
install -v -d -m755 /usr/share/doc/exim-4.80.1 &&
install -v -m644 doc/* /usr/share/doc/exim-4.80.1 &&
ln -sfv exim /usr/sbin/sendmail
cat >> /etc/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root
EOF
exim -v -bi &&
/usr/sbin/exim -bd -q15m

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-exim
}

export Exim_4_80_1_C21_download="http://ftp.exim.org/pub/exim/exim4/exim-4.80.1.tar.bz2 ftp://ftp.exim.org/pub/exim/exim4/exim-4.80.1.tar.bz2 http://exim.org/docs.html "

export Exim_4_80_1_C21_packname="exim-4.80.1.tar.bz2"

export Exim_4_80_1_C21_required_or_recommended="Berkeley_DB_5_3_21_C22 http://sourceforge.net/projects/tdb "

export Introduction_to_Postfix_C21_download="ftp://ftp.porcupine.org/mirrors/postfix-release/official/postfix-2.10.0.tar.gz "

export Introduction_to_Postfix_C21_packname="postfix-2.10.0.tar.gz"

export Introduction_to_Postfix_C21_required_or_recommended="Berkeley_DB_5_3_21_C22 Cyrus_SASL_2_1_25_C4 OpenSSL_1_0_1e_C4 "

Installation_of_Postfix_C21(){

groupadd -g 32 postfix &&
groupadd -g 33 postdrop &&
useradd -c "Postfix Daemon User" -d /var/spool/postfix -g postfix \
        -s /bin/false -u 32 postfix &&
chown -R postfix:postfix /var/mail
sed -i 's/.\x08//g' README_FILES/*
make CCARGS="-DNO_NIS -DUSE_TLS -I/usr/include/openssl/            \
             -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl" \
     AUXLIBS="-lssl -lcrypto -lsasl2"                              \
     makefiles &&
make
sh postfix-install -non-interactive \
   daemon_directory=/usr/lib/postfix \
   manpage_directory=/usr/share/man \
   html_directory=/usr/share/doc/postfix-2.10.0/html \
   readme_directory=/usr/share/doc/postfix-2.10.0/readme
}

Configuring_Postfix_C21(){

cat >> /etc/aliases << "EOF"
# Begin /etc/aliases

MAILER-DAEMON:    postmaster
postmaster:       root

root:             <LOGIN>
# End /etc/aliases
EOF

/usr/sbin/postfix upgrade-configuration
/usr/sbin/postfix check &&
/usr/sbin/postfix start
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-postfix
}

Qpopper_4_1_0_C21(){

./configure --prefix=/usr --enable-standalone &&
make
make install &&
install -D -m644 GUIDE.pdf /usr/share/doc/qpopper-4.1.0/GUIDE.pdf
echo "local0.notice;local0.debug /var/log/POP.log" >> /etc/syslog.conf &&
killall -HUP syslogd
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-qpopper
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
cat > /etc/mail/qpopper.conf << "EOF"
# Qpopper configuration file

set debug = false

set spool-dir = /var/spool/mail/
set temp-dir  = /var/spool/mail/

set downcase-user = true
set trim-domain = true

set statistics = true

# End /etc/shells
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
echo "pop3 stream tcp nowait root /usr/sbin/popper popper" >> /etc/inetd.conf &&
killall inetd || inetd
}

export Qpopper_4_1_0_C21_download="ftp://ftp.qualcomm.com/eudora/servers/unix/popper/qpopper4.1.0.tar.gz "

export Qpopper_4_1_0_C21_packname="qpopper4.1.0.tar.gz"

export Qpopper_4_1_0_C21_required_or_recommended="Chapter_21_&nbsp;Mail_Server_Software "

sendmail_8_14_5_C21(){

groupadd -g 26 smmsp &&
useradd -c "Sendmail Daemon" -g smmsp -d /dev/null \
        -s /bin/false -u 26 smmsp &&
chmod -v 1777 /var/mail &&
install -v -m700 -d /var/spool/mqueue
cat >> devtools/Site/site.config.m4 << "EOF"
APPENDDEF(`confENVDEF',`-DSTARTTLS -DSASL -DLDAPMAP')
APPENDDEF(`confLIBS', `-lssl -lcrypto -lsasl2 -lldap -llber')
APPENDDEF(`confINCDIRS', `-I/usr/include/sasl')
EOF

cat >> devtools/Site/site.config.m4 << "EOF"
define(`confMANGRP',`root')
define(`confMANOWN',`root')
define(`confSBINGRP',`root')
define(`confUBINGRP',`root')
define(`confUBINOWN',`root')
EOF
cd sendmail &&
sh Build &&
cd ../cf/cf &&
cp generic-linux.mc sendmail.mc &&
sh Build sendmail.cf

install -v -d -m755 /etc/mail &&
sh Build install-cf &&

cd ../.. &&
sh Build install &&

install -v -m644 cf/cf/{submit,sendmail}.mc /etc/mail &&
cp -v -R cf/* /etc/mail &&

install -v -m755 -d /usr/share/doc/sendmail-8.14.5/{cf,sendmail} &&
install -v -m644 \
        CACerts FAQ KNOWNBUGS LICENSE PGPKEYS README RELEASE_NOTES \
        /usr/share/doc/sendmail-8.14.5 &&
install -v -m644 sendmail/{README,SECURITY,TRACEFLAGS,TUNING} \
        /usr/share/doc/sendmail-8.14.5/sendmail &&
install -v -m644 cf/README /usr/share/doc/sendmail-8.14.5/cf &&

for manpage in sendmail editmap mailstats makemap praliases smrsh
do
    install -v -m444 $manpage/$manpage.8 /usr/share/man/man8
done &&
install -v -m444 sendmail/aliases.5    /usr/share/man/man5 &&
install -v -m444 sendmail/mailq.1      /usr/share/man/man1 &&
install -v -m444 sendmail/newaliases.1 /usr/share/man/man1 &&
install -v -m444 vacation/vacation.1   /usr/share/man/man1
cd doc/op &&
sed -i 's/groff/GROFF_NO_SGR=1 groff/' Makefile &&
make op.txt op.pdf
install -v -d -m755 /usr/share/doc/sendmail-8.14.5 &&
install -v -m644 op.ps op.txt op.pdf /usr/share/doc/sendmail-8.14.5 &&
cd ../..
echo $(hostname) > /etc/mail/local-host-names
cat > /etc/mail/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root

EOF
newaliases -v

m4 m4/cf.m4 sendmail.mc > sendmail.cf
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-sendmail
}

export sendmail_8_14_5_C21_download="http://www.sendmail.org/ftp/sendmail.8.14.5.tar.gz ftp://ftp.sendmail.org/pub/sendmail/sendmail.8.14.5.tar.gz "

export sendmail_8_14_5_C21_packname="sendmail.8.14.5.tar.gz"

export sendmail_8_14_5_C21_required_or_recommended="OpenLDAP_2_4_34_C23 "

export C21_MailServerSoftware="Exim_4_80_1_C21 Postfix_2_10_0_C21 Qpopper_4_1_0_C21 sendmail_8_14_5_C21 "


Berkeley_DB_5_3_21_C22(){

cd build_unix                        &&
../dist/configure --prefix=/usr      \
                  --enable-compat185 \
                  --enable-dbm       \
                  --disable-static   \
                  --enable-cxx       &&
make
make docdir=/usr/share/doc/db-5.3.21 install &&
chown -R -R root:root                        \
      /usr/bin/db_*                          \
      /usr/include/db{,_185,_cxx}.h          \
      /usr/lib/libdb*.{so,la}                \
      /usr/share/doc/db-5.3.21
}

export Berkeley_DB_5_3_21_C22_download="http://download.oracle.com/berkeley-db/db-5.3.21.tar.gz "

export Berkeley_DB_5_3_21_C22_packname="db-5.3.21.tar.gz"

MySQL_5_5_30_C22(){

groupadd -g 40 mysql &&
useradd -c "MySQL Server" -d /srv/mysql -g mysql -s /bin/false -u 40 mysql
patch -Np1 -i ../mysql-5.5.30-embedded_library_shared-1.patch
sed -i "/ADD_SUBDIRECTORY(sql\/share)/d" CMakeLists.txt &&
sed -i "s/ADD_SUBDIRECTORY(libmysql)/&\\nADD_SUBDIRECTORY(sql\/share)/" CMakeLists.txt &&
sed -i "s@data/test@\${INSTALL_MYSQLSHAREDIR}@g" sql/CMakeLists.txt &&
sed -i "s@data/mysql@\${INSTALL_MYSQLTESTDIR}@g" sql/CMakeLists.txt &&
mkdir build &&
cd build &&
cmake -DCMAKE_BUILD_TYPE=Release                    \
      -DCMAKE_INSTALL_PREFIX=/usr                   \
      -DINSTALL_DOCDIR=share/doc/mysql              \
      -DINSTALL_DOCREADMEDIR=share/doc/mysql        \
      -DINSTALL_INCLUDEDIR=include/mysql            \
      -DINSTALL_INFODIR=share/info                  \
      -DINSTALL_MANDIR=share/man                    \
      -DINSTALL_MYSQLDATADIR=/srv/mysql             \
      -DINSTALL_MYSQLSHAREDIR=share/mysql           \
      -DINSTALL_MYSQLTESTDIR=share/mysql/test       \
      -DINSTALL_PLUGINDIR=lib/mysql                 \
      -DINSTALL_SBINDIR=sbin                        \
      -DINSTALL_SCRIPTDIR=bin                       \
      -DINSTALL_SQLBENCHDIR=share/mysql/bench       \
      -DINSTALL_SUPPORTFILESDIR=share/mysql/support \
      -DMYSQL_DATADIR=/srv/mysql                    \
      -DMYSQL_UNIX_ADDR=/var/run/mysqld/mysql.sock  \
      -DSYSCONFDIR=/etc/mysql                       \
      -DWITH_PARTITION_STORAGE_ENGINE=OFF           \
      -DWITH_PERFSCHEMA_STORAGE_ENGINE=OFF          \
      -DWITH_READLINE=system                        \
      -DWITH_SSL=system                             \
      .. &&
make
make install
install -v -Dm644 /usr/share/mysql/support/my-medium.cnf /etc/mysql/my.cnf &&
sed -i 's/^log-bin/#log-bin/' /etc/mysql/my.cnf &&
sed -i 's/^binlog/#binlog/' /etc/mysql/my.cnf
mysql_install_db --basedir=/usr --datadir=/srv/mysql --user=mysql &&
chown -R mysql:mysql /srv/mysql
install -v -m755 -o mysql -g mysql -d /var/run/mysqld &&
mysqld_safe --user=mysql 2>&1 >/dev/null &
mysqladmin -u root password ping

mysqladmin -p shutdown
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-mysql
}

export MySQL_5_5_30_C22_download="http://cdn.mysql.com/Downloads/MySQL-5.5/mysql-5.5.30.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/mysql-5.5.30-embedded_library_shared-1.patch  "

export MySQL_5_5_30_C22_packname="mysql-5.5.30.tar.gz"

export MySQL_5_5_30_C22_required_or_recommended="CMake_2_8_10_2_C13 OpenSSL_1_0_1e_C4 "

PostgreSQL_9_2_2_C22(){

./configure --prefix=/usr          \
            --enable-thread-safety \
            --docdir=/usr/share/doc/postgresql-9.2.2 &&
make
make install      &&
make install-docs
install -v -m700 -d /srv/pgsql/data &&
groupadd -g 41 postgres &&
useradd -c "PostgreSQL Server" -g postgres -d /srv/pgsql/data \
        -u 41 postgres &&
chown -R postgres /srv/pgsql/data &&
su - postgres -c '/usr/bin/initdb -D /srv/pgsql/data'
su - postgres -c '/usr/bin/postmaster -D /srv/pgsql/data > \
    /srv/pgsql/data/logfile 2>&1 &'
su - postgres -c '/usr/bin/createdb test' &&
echo "create table t1 ( name varchar(20), state_province varchar(20) );" \
    | (su - postgres -c '/usr/bin/psql test ') &&
echo "insert into t1 values ('Billy', 'NewYork');" \
    | (su - postgres -c '/usr/bin/psql test ') &&
echo "insert into t1 values ('Evanidus', 'Quebec');" \
    | (su - postgres -c '/usr/bin/psql test ') &&
echo "insert into t1 values ('Jesse', 'Ontario');" \
    | (su - postgres -c '/usr/bin/psql test ') &&
echo "select * from t1;" | (su - postgres -c '/usr/bin/psql test')
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-postgresql
}

export PostgreSQL_9_2_2_C22_download="ftp://ftp5.us.postgresql.org/pub/PostgreSQL/source/v9.2.2/postgresql-9.2.2.tar.bz2 "

export PostgreSQL_9_2_2_C22_packname="postgresql-9.2.2.tar.bz2"

SQLite_3_7_16_1_C22(){

unzip -q ../sqlite-doc-3071601.zip
./configure --prefix=/usr --disable-static        \
            CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 \
            -DSQLITE_ENABLE_COLUMN_METADATA=1     \
            -DSQLITE_ENABLE_UNLOCK_NOTIFY=1       \
            -DSQLITE_SECURE_DELETE=1" &&
make
make install
install -v -m755 -d /usr/share/doc/sqlite-3.7.16.1 &&
cp -v -R sqlite-doc-3071601/* /usr/share/doc/sqlite-3.7.16.1
}

export SQLite_3_7_16_1_C22_download="http://sqlite.org/2013/sqlite-autoconf-3071601.tar.gz http://sqlite.org/2013/sqlite-doc-3071601.zip "

export SQLite_3_7_16_1_C22_packname="sqlite-autoconf-3071601.tar.gz"

export C22_Databases="Berkeley_DB_5_3_21_C22 MySQL_5_5_30_C22 PostgreSQL_9_2_2_C22 SQLite_3_7_16_1_C22 "


OpenLDAP_2_4_34_C23(){

patch -Np1 -i ../openldap-2.4.34-ntlm-1.patch
patch -Np1 -i ../openldap-2.4.34-blfs_paths-1.patch &&
patch -Np1 -i ../openldap-2.4.34-symbol_versions-1.patch &&
autoconf &&
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-dynamic  \
            --disable-debug   \
            --disable-slapd &&
make depend &&
make
patch -Np1 -i ../openldap-2.4.34-blfs_paths-1.patch &&
patch -Np1 -i ../openldap-2.4.34-symbol_versions-1.patch &&
autoconf &&
./configure --prefix=/usr         \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libexecdir=/usr/lib \
            --disable-static      \
            --disable-debug       \
            --enable-dynamic      \
            --enable-crypt        \
            --enable-spasswd      \
            --enable-modules      \
            --enable-rlookups     \
            --enable-backends=mod \
            --enable-overlays=mod \
            --disable-ndb         \
            --disable-sql &&
make depend &&
make
make install &&

install -v -dm755  /usr/share/doc/openldap-2.4.34 &&
cp -vfr doc/drafts /usr/share/doc/openldap-2.4.34 &&
cp -vfr doc/rfc    /usr/share/doc/openldap-2.4.34 &&
cp -vfr doc/guide  /usr/share/doc/openldap-2.4.34
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-slapd
/etc/rc.d/init.d/slapd start
ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts
}

export OpenLDAP_2_4_34_C23_download="ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.34.tgz http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.34-blfs_paths-1.patch http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.34-symbol_versions-1.patch http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.34-ntlm-1.patch   "

export OpenLDAP_2_4_34_C23_packname="openldap-2.4.34.tgz"

export OpenLDAP_2_4_34_C23_required_or_recommended="Berkeley_DB_5_3_21_C22 Cyrus_SASL_2_1_25_C4 OpenSSL_1_0_1e_C4 "

Virtuoso_6_1_6_C23(){

sed -i "s|virt_iodbc_dir/include|&/iodbc|" configure  &&
./configure --prefix=/usr                             \
            --sysconfdir=/etc                         \
            --localstatedir=/var                      \
            --with-iodbc=/usr                         \
            --with-readline                           \
            --without-internal-zlib                   \
            --program-transform-name="s/isql/isql-v/" \
            --disable-all-vads                        \
            --disable-static                          &&
make
make install &&
install -v -m755 -d /usr/share/doc/virtuoso-6.1.6 &&
ln -s   -v          ../../virtuoso/doc \
                    /usr/share/doc/virtuoso-6.1.6
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-virtuoso
}

export Virtuoso_6_1_6_C23_download="http://downloads.sourceforge.net/virtuoso/virtuoso-opensource-6.1.6.tar.gz "

export Virtuoso_6_1_6_C23_packname="virtuoso-opensource-6.1.6.tar.gz"

export Virtuoso_6_1_6_C23_required_or_recommended="libiodbc_3_52_8_C11 libxml2_2_9_0_C9 OpenSSL_1_0_1e_C4 OpenLDAP_2_4_34_C23 "

Soprano_2_9_0_C23(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release  \
      .. &&
make
make install
install -m755 -d /srv/soprano
cat > /etc/sysconfig/soprano <<EOF
# Begin /etc/sysconfig/soprano

SOPRANO_STORAGE="/srv/soprano"
SOPRANO_BACKEND="virtuoso"                       # virtuoso, sesame2, redland
#SOPRANO_OPTIONS="$SOPRANO_OPTIONS --port 4711"  # Default port is 5000

# End /etc/sysconfig/soprano
EOF
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-soprano
}

export Soprano_2_9_0_C23_download="http://downloads.sourceforge.net/soprano/soprano-2.9.0.tar.bz2 "

export Soprano_2_9_0_C23_packname="soprano-2.9.0.tar.bz2"

export Soprano_2_9_0_C23_required_or_recommended="D_Bus_1_6_8_C12 CMake_2_8_10_2_C13 Qt_4_8_4_C25 Redland_1_0_16_C12 libiodbc_3_52_8_C11 Virtuoso_6_1_6_C23 "

xinetd_2_3_15_C23(){

sed -i -e "/^LIBS/s/-lpset/& -ltirpc/" xinetd/Makefile.in       &&
sed -i -e "/register unsigned count/s/register//" xinetd/itox.c &&
./configure --prefix=/usr --with-loadavg                        &&
make
make install
cat > /etc/xinetd.conf << "EOF"
# Begin /etc/xinetd
# Configuration file for xinetd

defaults
{
      instances       = 60
      log_type        = SYSLOG daemon
      log_on_success  = HOST PID USERID
      log_on_failure  = HOST USERID
      cps             = 25 30
}

# All service files are stored in the /etc/xinetd.d directory

includedir /etc/xinetd.d

# End /etc/xinetd
EOF

install -v -d -m755 /etc/xinetd.d &&

cat > /etc/xinetd.d/systat << "EOF"
# Begin /etc/xinetd.d/systat

service systat
{
   disable           = yes
   socket_type       = stream
   wait              = no
   user              = nobody
   server            = /usr/bin/ps
   server_args       = -auwwx
   only_from         = 128.138.209.0
   log_on_success    = HOST
}

# End /etc/xinetd.d/systat
EOF

cat > /etc/xinetd.d/echo << "EOF"
# Begin /etc/xinetd.d/echo

service echo
{
   disable     = yes
   type        = INTERNAL
   id          = echo-stream
   socket_type = stream
   protocol    = tcp
   user        = root
   wait        = no
}

service echo
{
   disable     = yes
   type        = INTERNAL
   id          = echo-dgram
   socket_type = dgram
   protocol    = udp
   user        = root
   wait        = yes
}

# End /etc/xinetd.d/echo
EOF

cat > /etc/xinetd.d/chargen << "EOF"
# Begin /etc/xinetd.d/chargen

service chargen
{
   disable        = yes
   type           = INTERNAL
   id             = chargen-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}

service chargen
{
   disable        = yes
   type           = INTERNAL
   id             = chargen-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}

# End /etc/xinetd.d/chargen
EOF

cat > /etc/xinetd.d/daytime << "EOF"
# Begin /etc/xinetd.d/daytime

service daytime
{
   disable        = yes
   type           = INTERNAL
   id             = daytime-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}

service daytime
{
   disable        = yes
   type           = INTERNAL
   id             = daytime-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}

# End /etc/xinetd.d/daytime
EOF

cat > /etc/xinetd.d/time << "EOF"
# Begin /etc/xinetd.d/time

service time
{
   disable        = yes
   type           = INTERNAL
   id             = time-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}

service time
{
   disable        = yes
   type           = INTERNAL
   id             = time-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}

# End /etc/xinetd.d/time
EOF

exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-xinetd
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
/etc/rc.d/init.d/xinetd start
}

export xinetd_2_3_15_C23_download="http://www.xinetd.org/xinetd-2.3.15.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xinetd-2.3.15.tar.gz "

export xinetd_2_3_15_C23_packname="xinetd-2.3.15.tar.gz"

export xinetd_2_3_15_C23_required_or_recommended="libtirpc_0_2_3_C17 "

export C23_OtherServerSoftware="OpenLDAP_2_4_34_C23 Virtuoso_6_1_6_C23 Soprano_2_9_0_C23 xinetd_2_3_15_C23 "


Introduction_to_Xorg_7_7_C24(){

mkdir xc &&
cd xc
export XORG_PREFIX="/opt"

export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"
cat > /etc/profile.d/xorg.sh << "EOF"
XORG_PREFIX="/opt"
XORG_CONFIG="--prefix=$XORG_PREFIX \
             --sysconfdir=/etc \
             --localstatedir=/var \
             --disable-static"
export XORG_PREFIX XORG_CONFIG
EOF
chmod 644 /etc/profile.d/xorg.sh

cat >> /etc/profile.d/xorg.sh << "EOF"

pathappend $XORG_PREFIX/bin PATH
pathappend $XORG_PREFIX/lib/pkgconfig PKG_CONFIG_PATH
pathappend $XORG_PREFIX/share/pkgconfig PKG_CONFIG_PATH
export PATH PKG_CONFIG_PATH
EOF
echo "${XORG_PREFIX}/lib" >> /etc/ld.so.conf
sed 's@/usr/X11R6@/opt@g' -i /etc/man_db.conf

install -v -m755 -d $XORG_PREFIX &&
install -v -m755 -d $XORG_PREFIX/lib &&
ln -s lib $XORG_PREFIX/lib64
}

util_macros_1_17_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export util_macros_1_17_C24_download="http://xorg.freedesktop.org/releases/individual/util/util-macros-1.17.tar.bz2 ftp://ftp.x.org/pub/individual/util/util-macros-1.17.tar.bz2 "

export util_macros_1_17_C24_packname="util-macros-1.17.tar.bz2"

Xorg_Protocol_Headers_C24(){

cat > proto-7.7.md5 << "EOF"
1a05fb01fa1d5198894c931cf925c025  bigreqsproto-1.1.2.tar.bz2
98482f65ba1e74a08bf5b056a4031ef0  compositeproto-0.4.2.tar.bz2
998e5904764b82642cc63d97b4ba9e95  damageproto-1.2.1.tar.bz2
4ee175bbd44d05c34d43bb129be5098a  dmxproto-2.3.1.tar.bz2
b2721d5d24c04d9980a0c6540cb5396a  dri2proto-2.8.tar.bz2
e7431ab84d37b2678af71e29355e101d  fixesproto-5.0.tar.bz2
c5f4f1fb4ba7766eedbc9489e81f3be2  fontsproto-2.1.2.tar.bz2
3847963c1b88fd04a030b932b0aece07  glproto-1.4.16.tar.bz2
94db391e60044e140c9854203d080654  inputproto-2.3.tar.bz2
677ea8523eec6caca86121ad2dca0b71  kbproto-1.0.6.tar.bz2
ce4d0b05675968e4c83e003cc809660d  randrproto-1.4.0.tar.bz2
1b4e5dede5ea51906f1530ca1e21d216  recordproto-1.14.2.tar.bz2
a914ccc1de66ddeb4b611c6b0686e274  renderproto-0.11.1.tar.bz2
cfdb57dae221b71b2703f8e2980eaaf4  resourceproto-1.2.0.tar.bz2
edd8a73775e8ece1d69515dd17767bfb  scrnsaverproto-1.2.2.tar.bz2
c3b348c6e2031b72b11ae63fc7f805c2  videoproto-2.3.1.tar.bz2
5f4847c78e41b801982c8a5e06365b24  xcmiscproto-1.2.2.tar.bz2
eaac343af094e6b608cf15cfba0f77c5  xextproto-7.2.1.tar.bz2
120e226ede5a4687b25dd357cc9b8efe  xf86bigfontproto-1.2.0.tar.bz2
a036dc2fcbf052ec10621fd48b68dbb1  xf86dgaproto-2.1.tar.bz2
1d716d0dac3b664e5ee20c69d34bc10e  xf86driproto-2.1.1.tar.bz2
e793ecefeaecfeabd1aed6a01095174e  xf86vidmodeproto-2.3.1.tar.bz2
9959fe0bfb22a0e7260433b8d199590a  xineramaproto-1.2.1.tar.bz2
d4d241a4849167e4e694fe73371c328c  xproto-7.0.23.tar.bz2
EOF
mkdir proto &&
cd proto &&
grep -v '^#' ../proto-7.7.md5 | awk '{print $2}' | wget -i- -c \
    -B http://xorg.freedesktop.org/releases/individual/proto/ &&
md5sum -c ../proto-7.7.md5
as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root
for package in $(grep -v '^#' ../proto-7.7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  ./configure $XORG_CONFIG
  as_root make install
  popd
  rm -r $packagedir
done
}

export Xorg_Protocol_Headers_C24_download="  "

export Xorg_Protocol_Headers_C24_packname=""

export Xorg_Protocol_Headers_C24_required_or_recommended="util_macros_1_17_C24 Sudo_1_8_6p3_C4 Wget_1_14_C15 "

makedepend_1_0_4_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export makedepend_1_0_4_C24_download="http://xorg.freedesktop.org/releases/individual/util/makedepend-1.0.4.tar.bz2 ftp://ftp.x.org/pub/individual/util/makedepend-1.0.4.tar.bz2 "

export makedepend_1_0_4_C24_packname="makedepend-1.0.4.tar.bz2"

export makedepend_1_0_4_C24_required_or_recommended="Xorg_Protocol_Headers_C24 pkg_config_0_28_C13 "

libXau_1_0_7_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export libXau_1_0_7_C24_download="http://xorg.freedesktop.org/releases/individual/lib/libXau-1.0.7.tar.bz2 ftp://ftp.x.org/pub/individual/lib/libXau-1.0.7.tar.bz2 "

export libXau_1_0_7_C24_packname="libXau-1.0.7.tar.bz2"

export libXau_1_0_7_C24_required_or_recommended="Xorg_Protocol_Headers_C24 "

libXdmcp_1_1_1_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export libXdmcp_1_1_1_C24_download="http://xorg.freedesktop.org/releases/individual/lib/libXdmcp-1.1.1.tar.bz2 ftp://ftp.x.org/pub/individual/lib/libXdmcp-1.1.1.tar.bz2 "

export libXdmcp_1_1_1_C24_packname="libXdmcp-1.1.1.tar.bz2"

export libXdmcp_1_1_1_C24_required_or_recommended="Xorg_Protocol_Headers_C24 "

xcb_proto_1_8_C24(){

./configure $XORG_CONFIG
make install
}

export xcb_proto_1_8_C24_download="http://xcb.freedesktop.org/dist/xcb-proto-1.8.tar.bz2 "

export xcb_proto_1_8_C24_packname="xcb-proto-1.8.tar.bz2"

export xcb_proto_1_8_C24_required_or_recommended="Python_2_7_3_C13 "

libxcb_1_9_C24(){

sed -e "s/pthread-stubs//" -i configure.ac &&
autoreconf -fi &&
./configure $XORG_CONFIG --enable-xinput --docdir='${datadir}'/doc/libxcb-1.9 &&
make
make install
}

export libxcb_1_9_C24_download="http://xcb.freedesktop.org/dist/libxcb-1.9.tar.bz2 "

export libxcb_1_9_C24_packname="libxcb-1.9.tar.bz2"

export libxcb_1_9_C24_required_or_recommended="libXau_1_0_7_C24 libXdmcp_1_1_1_C24 libxslt_1_1_28_C9 xcb_proto_1_8_C24 "

Xorg_Libraries_C24(){

cat > lib-7.7.md5 << "EOF"
84c66908cf003ad8c272b0eecbdbaee3  xtrans-1.2.7.tar.bz2
78b4b3bab4acbdf0abcfca30a8c70cc6  libX11-1.5.0.tar.bz2
71251a22bc47068d60a95f50ed2ec3cf  libXext-1.3.1.tar.bz2
645f83160cf7b562734e2038045106d1  libFS-1.0.4.tar.bz2
471b5ca9f5562ac0d6eac7a0bf650738  libICE-1.0.8.tar.bz2
766de9d1e1ecf8bf74cebe2111d8e2bd  libSM-1.2.1.tar.bz2
7a773b16165e39e938650bcc9027c1d5  libXScrnSaver-1.2.2.tar.bz2
a6f137ae100e74ebe3b71eb4a38c40b3  libXt-1.1.3.tar.bz2
a4efff8de85bd45dd3da124285d10c00  libXmu-1.1.1.tar.bz2
7ae7eff7a14d411e84a67bd166bcec1a  libXpm-3.5.10.tar.bz2
f39942f2cab379fc9b4c3731bf191b84  libXaw-1.0.11.tar.bz2
678071bd7f9f7467e2fc712d81022318  libXfixes-5.0.tar.bz2
f7a218dcbf6f0848599c6c36fc65c51a  libXcomposite-0.4.4.tar.bz2
ee62f4c7f0f16ced4da63308963ccad2  libXrender-0.9.7.tar.bz2
52efa81b7f26c8eda13510a2fba98eea  libXcursor-1.1.13.tar.bz2
0cf292de2a9fa2e9a939aefde68fd34f  libXdamage-1.1.4.tar.bz2
a2a861f142c3b4367f14fc14239fc1f7  libfontenc-1.1.1.tar.bz2
6851da5dae0a6cf5f7c9b9e2b05dd3b4  libXfont-1.4.5.tar.bz2
78d64dece560c9e8699199f3faa521c0  libXft-2.3.1.tar.bz2
d77922d822cb3abdbdfb92cd66440576  libXi-1.7.tar.bz2
cb45d6672c93a608f003b6404f1dd462  libXinerama-1.1.2.tar.bz2
0c843636124cc1494e3d87df16957672  libXrandr-1.4.0.tar.bz2
80d0c6d8522fa7a645e4f522e9a9cd20  libXres-1.0.6.tar.bz2
e8abc5c00c666f551cf26aa53819d592  libXtst-1.2.1.tar.bz2
5e1ac203ccd3ce3e89755ed1fbe75b0b  libXv-1.0.7.tar.bz2
3340c99ff556ea2457b4be47f5cb96fa  libXvMC-1.0.7.tar.bz2
b7f38465c46e7145782d37dbb9da8c09  libXxf86dga-1.1.3.tar.bz2
ffd93bcedd8b2b5aeabf184e7b91f326  libXxf86vm-1.1.2.tar.bz2
782ced3a9e754dfeb53a8a006a75eb1a  libdmx-1.1.2.tar.bz2
399a419ac6a54f0fc07c69c9bdf452dc  libpciaccess-0.13.1.tar.bz2
19e6533ae64abba0773816a23f2b9507  libxkbfile-1.0.8.tar.bz2
EOF
mkdir lib &&
cd lib &&
grep -v '^#' ../lib-7.7.md5 | awk '{print $2}' | wget -i- -c \
    -B http://xorg.freedesktop.org/releases/individual/lib/ &&
md5sum -c ../lib-7.7.md5
as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root
for package in $(grep -v '^#' ../lib-7.7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  case $packagedir in
    libXfont-[0-9]* )
      ./configure $XORG_CONFIG --disable-devel-docs
    ;;
    libXt-[0-9]* )
      ./configure $XORG_CONFIG \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;
    * )
      ./configure $XORG_CONFIG
    ;;
  esac
  make
  as_root make install
  popd
  rm -r $packagedir
  as_root /sbin/ldconfig
done
ln -sfv $XORG_PREFIX/lib/X11 /usr/lib/X11 &&
ln -sfv $XORG_PREFIX/include/X11 /usr/include/X11
}

export Xorg_Libraries_C24_download="  "

export Xorg_Libraries_C24_packname=""

export Xorg_Libraries_C24_required_or_recommended="Fontconfig_2_10_2_C10 Xorg_Protocol_Headers_C24 libXdmcp_1_1_1_C24 libxcb_1_9_C24 "

xcb_util_0_3_9_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export xcb_util_0_3_9_C24_download="http://xcb.freedesktop.org/dist/xcb-util-0.3.9.tar.bz2 "

export xcb_util_0_3_9_C24_packname="xcb-util-0.3.9.tar.bz2"

export xcb_util_0_3_9_C24_required_or_recommended="libxcb_1_9_C24 "

xcb_util_image_0_3_9_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export xcb_util_image_0_3_9_C24_download="http://xorg.freedesktop.org/releases/individual/xcb/xcb-util-image-0.3.9.tar.bz2 ftp://ftp.x.org/pub/individual/xcb/xcb-util-image-0.3.9.tar.bz2 "

export xcb_util_image_0_3_9_C24_packname="xcb-util-image-0.3.9.tar.bz2"

export xcb_util_image_0_3_9_C24_required_or_recommended="xcb_util_0_3_9_C24 "

xcb_util_renderutil_0_3_8_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export xcb_util_renderutil_0_3_8_C24_download="http://xorg.freedesktop.org/releases/individual/xcb/xcb-util-renderutil-0.3.8.tar.bz2 ftp://ftp.x.org/pub/individual/xcb/xcb-util-renderutil-0.3.8.tar.bz2 "

export xcb_util_renderutil_0_3_8_C24_packname="xcb-util-renderutil-0.3.8.tar.bz2"

export xcb_util_renderutil_0_3_8_C24_required_or_recommended="libxcb_1_9_C24 "

MesaLib_9_1_1_C24(){

patch -Np1 -i ../MesaLib-9.1.1-add_xdemos-1.patch
autoreconf -fi &&
./configure CFLAGS="-O2" CXXFLAGS="-O2"    \
            --prefix=/usr                  \
            --sysconfdir=/etc              \
            --enable-texture-float         \
            --enable-gles1                 \
            --enable-gles2                 \
            --enable-openvg                \
            --enable-osmesa                \
            --enable-xa                    \
            --enable-gbm                   \
            --enable-gallium-egl           \
            --enable-gallium-gbm           \
            --enable-glx-tls               \
            --with-llvm-shared-libs        \
            --with-egl-platforms="drm,x11" \
            --with-gallium-drivers="nouveau,r300,r600,radeonsi,svga,swrast" &&
make
make -C xdemos DEMOS_PREFIX=/usr
make install
make -C xdemos DEMOS_PREFIX=/usr install
install -v -dm755 /usr/share/doc/MesaLib-9.1.1 &&
cp -rfv docs/* /usr/share/doc/MesaLib-9.1.1
./configure --prefix=/usr --disable-static &&
make
make install
}

export MesaLib_9_1_1_C24_download="ftp://ftp.freedesktop.org/pub/mesa/9.1.1/MesaLib-9.1.1.tar.bz2 ftp://ftp.freedesktop.org/pub/mesa/glu/glu-9.0.0.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/MesaLib-9.1.1-add_xdemos-1.patch "

export MesaLib_9_1_1_C24_packname="MesaLib-9.1.1.tar.bz2"

export MesaLib_9_1_1_C24_required_or_recommended="Expat_2_1_0_C9 libdrm_2_4_43_C9 libxml2_2_9_0_C9 makedepend_1_0_4_C24 Xorg_Libraries_C24 LLVM_3_2_C13 "

xbitmaps_1_1_1_C24(){

./configure $XORG_CONFIG
make install
}

export xbitmaps_1_1_1_C24_download="http://xorg.freedesktop.org/releases/individual/data/xbitmaps-1.1.1.tar.bz2 ftp://ftp.x.org/pub/individual/data/xbitmaps-1.1.1.tar.bz2 "

export xbitmaps_1_1_1_C24_packname="xbitmaps-1.1.1.tar.bz2"

Xorg_Applications_C24(){

cat > app-7.7.md5 << "EOF"
4a7a4a848c43c42f7d499b60666434a4  bdftopcf-1.0.3.tar.bz2
08e3f6b523da8b0af179f22f339508b2  iceauth-1.0.5.tar.bz2
c4a3664e08e5a47c120ff9263ee2f20c  luit-1.1.1.tar.bz2
18c429148c96c2079edda922a2b67632  mkfontdir-1.0.7.tar.bz2
414fcb053418fb1418e3a39f4a37e0f7  mkfontscale-1.1.0.tar.bz2
e99172cbd72700eeeae99f64632b5dc2  sessreg-1.0.7.tar.bz2
1001771344608e120e943a396317c33a  setxkbmap-1.3.0.tar.bz2
edce41bd7562dcdfb813e05dbeede8ac  smproxy-1.0.5.tar.bz2
5c3c7431a38775caaea6051312a49bc9  x11perf-1.5.4.tar.bz2
cbcbd8f2156a53b609800bec4c6b6c0e  xauth-1.0.7.tar.bz2
c9891d6a3f3129d56cede72daa0ba26c  xbacklight-1.1.2.tar.bz2
5812be48cbbec1068e7b718eec801766  xcmsdb-1.0.4.tar.bz2
09f56978a62854534deacc8aa8ff3031  xcursorgen-1.0.5.tar.bz2
1ef08f4c8d0e669c2edd49e4a1bf650d  xdpyinfo-1.3.0.tar.bz2
3d3cad4d754e10e325438193433d59fd  xdriinfo-1.0.4.tar.bz2
2727c72f3eba0c23f8f6b2e618d195a2  xev-1.2.0.tar.bz2
c06067f572bc4a5298f324f27340da95  xgamma-1.0.5.tar.bz2
a0fcd2cb6ddd9f378944cc6f4f83cd7c  xhost-1.0.5.tar.bz2
d2459d35b4e0b41ded26a1d1159b7ac6  xinput-1.6.0.tar.bz2
a0fc1ac3fc4fe479ade09674347c5aa0  xkbcomp-1.2.4.tar.bz2
37ed71525c63a9acd42e7cde211dcc5b  xkbevd-1.1.3.tar.bz2
52ad6d8d87577a8ac736ab5488bec210  xkbutils-1.0.3.tar.bz2
e7f0d57b6ba49c384e9cf8c9ff3243c1  xkill-1.0.3.tar.bz2
9d0e16d116d1c89e6b668c1b2672eb57  xlsatoms-1.1.1.tar.bz2
760099f0af112401735801e3b9aa8595  xlsclients-1.1.2.tar.bz2
d9b65f6881afe0d6d9863b30e1081bde  xmodmap-1.0.7.tar.bz2
6101f04731ffd40803df80eca274ec4b  xpr-1.0.4.tar.bz2
d5529dc8d811efabd136ca2d8e857deb  xprop-1.2.1.tar.bz2
9735173a84dca9b05e06fd4686196b07  xrandr-1.3.5.tar.bz2
ed2e48cf33584455d74615ad4bbe4246  xrdb-1.0.9.tar.bz2
2f63f88ad0dcecd33c8cf000f38e9250  xrefresh-1.0.4.tar.bz2
d44e0057d6722b25d5a314e82e0b7e7c  xset-1.2.2.tar.bz2
b78a2da4cf128775031a5a3422fc0b78  xsetroot-1.1.0.tar.bz2
c88feb501083951a8f47a21aaeb1529d  xvinfo-1.1.1.tar.bz2
2113126f9ac9c02bb8547c112c5d037e  xwd-1.0.5.tar.bz2
9e8b58c8aa6172e87ab4f9cf3612fedd  xwininfo-1.1.2.tar.bz2
3025b152b4f13fdffd0c46d0be587be6  xwud-1.0.4.tar.bz2
EOF
mkdir app &&
cd app &&
grep -v '^#' ../app-7.7.md5 | awk '{print $2}' | wget -i- -c \
    -B http://xorg.freedesktop.org/releases/individual/app/ &&
md5sum -c ../app-7.7.md5
as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root
for package in $(grep -v '^#' ../app-7.7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  ./configure $XORG_CONFIG
  make
  as_root make install
  popd
  rm -r $packagedir
done
}

export Xorg_Applications_C24_download="  "

export Xorg_Applications_C24_packname=""

export Xorg_Applications_C24_required_or_recommended="libpng_1_5_14_C10 MesaLib_9_1_1_C24 xbitmaps_1_1_1_C24 xcb_util_0_3_9_C24 Xorg_Libraries_C24 "

xcursor_themes_1_0_3_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export xcursor_themes_1_0_3_C24_download="http://xorg.freedesktop.org/releases/individual/data/xcursor-themes-1.0.3.tar.bz2 ftp://ftp.x.org/pub/individual/data/xcursor-themes-1.0.3.tar.bz2 "

export xcursor_themes_1_0_3_C24_packname="xcursor-themes-1.0.3.tar.bz2"

export xcursor_themes_1_0_3_C24_required_or_recommended="Xorg_Applications_C24 "

Xorg_Fonts_C24(){

cat > font-7.7.md5 << "EOF"
ddfc8a89d597651408369d940d03d06b  font-util-1.3.0.tar.bz2
0f2d6546d514c5cc4ecf78a60657a5c1  encodings-1.0.4.tar.bz2
1347c3031b74c9e91dc4dfa53b12f143  font-adobe-100dpi-1.0.3.tar.bz2
6c9f26c92393c0756f3e8d614713495b  font-adobe-75dpi-1.0.3.tar.bz2
66fb6de561648a6dce2755621d6aea17  font-adobe-utopia-100dpi-1.0.4.tar.bz2
e99276db3e7cef6dccc8a57bc68aeba7  font-adobe-utopia-75dpi-1.0.4.tar.bz2
fcf24554c348df3c689b91596d7f9971  font-adobe-utopia-type1-1.0.4.tar.bz2
6d25f64796fef34b53b439c2e9efa562  font-alias-1.0.3.tar.bz2
cc0726e4a277d6ed93b8e09c1f195470  font-arabic-misc-1.0.3.tar.bz2
9f11ade089d689b9d59e0f47d26f39cd  font-bh-100dpi-1.0.3.tar.bz2
565494fc3b6ac08010201d79c677a7a7  font-bh-75dpi-1.0.3.tar.bz2
c8b73a53dcefe3e8d3907d3500e484a9  font-bh-lucidatypewriter-100dpi-1.0.3.tar.bz2
f6d65758ac9eb576ae49ab24c5e9019a  font-bh-lucidatypewriter-75dpi-1.0.3.tar.bz2
e8ca58ea0d3726b94fe9f2c17344be60  font-bh-ttf-1.0.3.tar.bz2
53ed9a42388b7ebb689bdfc374f96a22  font-bh-type1-1.0.3.tar.bz2
6b223a54b15ecbd5a1bc52312ad790d8  font-bitstream-100dpi-1.0.3.tar.bz2
d7c0588c26fac055c0dd683fdd65ac34  font-bitstream-75dpi-1.0.3.tar.bz2
5e0c9895d69d2632e2170114f8283c11  font-bitstream-type1-1.0.3.tar.bz2
e452b94b59b9cfd49110bb49b6267fba  font-cronyx-cyrillic-1.0.3.tar.bz2
3e0069d4f178a399cffe56daa95c2b63  font-cursor-misc-1.0.3.tar.bz2
0571bf77f8fab465a5454569d9989506  font-daewoo-misc-1.0.3.tar.bz2
6e7c5108f1b16d7a1c7b2c9760edd6e5  font-dec-misc-1.0.3.tar.bz2
bfb2593d2102585f45daa960f43cb3c4  font-ibm-type1-1.0.3.tar.bz2
a2401caccbdcf5698e001784dbd43f1a  font-isas-misc-1.0.3.tar.bz2
cb7b57d7800fd9e28ec35d85761ed278  font-jis-misc-1.0.3.tar.bz2
143c228286fe9c920ab60e47c1b60b67  font-micro-misc-1.0.3.tar.bz2
96109d0890ad2b6b0e948525ebb0aba8  font-misc-cyrillic-1.0.3.tar.bz2
6306c808f7d7e7d660dfb3859f9091d2  font-misc-ethiopic-1.0.3.tar.bz2
e3e7b0fda650adc7eb6964ff3c486b1c  font-misc-meltho-1.0.3.tar.bz2
c88eb44b3b903d79fb44b860a213e623  font-misc-misc-1.1.2.tar.bz2
56b0296e8862fc1df5cdbb4efe604e86  font-mutt-misc-1.0.3.tar.bz2
e805feb7c4f20e6bfb1118d19d972219  font-schumacher-misc-1.1.2.tar.bz2
6f3fdcf2454bf08128a651914b7948ca  font-screen-cyrillic-1.0.4.tar.bz2
beef61a9b0762aba8af7b736bb961f86  font-sony-misc-1.0.3.tar.bz2
948f2e07810b4f31195185921470f68d  font-sun-misc-1.0.3.tar.bz2
829a3159389b7f96f629e5388bfee67b  font-winitzki-cyrillic-1.0.3.tar.bz2
3eeb3fb44690b477d510bbd8f86cf5aa  font-xfree86-type1-1.0.4.tar.bz2
EOF
mkdir font &&
cd font &&
grep -v '^#' ../font-7.7.md5 | awk '{print $2}' | wget -i- -c \
    -B http://xorg.freedesktop.org/releases/individual/font/ &&
md5sum -c ../font-7.7.md5
as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root
for package in $(grep -v '^#' ../font-7.7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  ./configure $XORG_CONFIG
  make
  as_root make install
  popd
  rm -r $packagedir
done
install -v -d -m755 /usr/share/fonts                               &&
ln -sfvfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF &&
ln -sfvfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF
}

export Xorg_Fonts_C24_download="  "

export Xorg_Fonts_C24_packname=""

export Xorg_Fonts_C24_required_or_recommended="Xorg_Applications_C24 xcursor_themes_1_0_3_C24 "

XKeyboardConfig_2_8_C24(){

./configure $XORG_CONFIG --with-xkb-rules-symlink=xorg &&
make
make install
}

export XKeyboardConfig_2_8_C24_download="http://xorg.freedesktop.org/releases/individual/data/xkeyboard-config/xkeyboard-config-2.8.tar.bz2 ftp://ftp.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-2.8.tar.bz2 "

export XKeyboardConfig_2_8_C24_packname="xkeyboard-config-2.8.tar.bz2"

export XKeyboardConfig_2_8_C24_required_or_recommended="Intltool_0_50_2_C11 Xorg_Applications_C24 "

Xorg_Server_1_14_0_C24(){

patch -Np1 -i ../xorg-server-1.14.0-add_prime_support-1.patch
./configure $XORG_CONFIG \
           --with-xkb-output=/var/lib/xkb \
           --enable-install-setuid &&
make
make install &&
mkdir -pv /etc/X11/xorg.conf.d &&
cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix dir 1777 root root
/tmp/.X11-unix dir 1777 root root
EOF
}

export Xorg_Server_1_14_0_C24_download="http://xorg.freedesktop.org/releases/individual/xserver/xorg-server-1.14.0.tar.bz2 ftp://ftp.x.org/pub/individual/xserver/xorg-server-1.14.0.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/xorg-server-1.14.0-add_prime_support-1.patch "

export Xorg_Server_1_14_0_C24_packname="xorg-server-1.14.0.tar.bz2"

export Xorg_Server_1_14_0_C24_required_or_recommended="MesaLib_9_1_1_C24 OpenSSL_1_0_1e_C4 Pixman_0_28_2_C10 Xorg_Fonts_C24 XKeyboardConfig_2_8_C24 "

export Introduction_to_Xorg_Drivers_C24_download=""

export Introduction_to_Xorg_Drivers_C24_packname=""

Glamor_EGL_0_5_0_C24(){

patch -Np1 -i ../glamor-egl-0.5.0-fixes-1.patch &&
autoreconf -fi &&
./configure $XORG_CONFIG --enable-glx-tls &&
make
make install
}

export Glamor_EGL_0_5_0_C24_download="http://anduin.linuxfromscratch.org/sources/other/glamor-egl-0.5.0.tar.xz ftp://anduin.linuxfromscratch.org/other/glamor-egl-0.5.0.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/glamor-egl-0.5.0-fixes-1.patch "

export Glamor_EGL_0_5_0_C24_packname="glamor-egl-0.5.0.tar.xz"

export Glamor_EGL_0_5_0_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_Evdev_Driver_2_8_0_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Evdev_Driver_2_8_0_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-input-evdev-2.8.0.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-input-evdev-2.8.0.tar.bz2 "

export Xorg_Evdev_Driver_2_8_0_C24_packname="xf86-input-evdev-2.8.0.tar.bz2"

export Xorg_Evdev_Driver_2_8_0_C24_required_or_recommended="Xorg_Server_1_14_0_C24 mtdev_1_1_3_C9 "

Xorg_Synaptics_Driver_1_6_3_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Synaptics_Driver_1_6_3_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-input-synaptics-1.6.3.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-input-synaptics-1.6.3.tar.bz2 "

export Xorg_Synaptics_Driver_1_6_3_C24_packname="xf86-input-synaptics-1.6.3.tar.bz2"

export Xorg_Synaptics_Driver_1_6_3_C24_required_or_recommended="mtdev_1_1_3_C9 Xorg_Server_1_14_0_C24 "

Xorg_VMMouse_Driver_13_0_0_C24(){

./configure $XORG_CONFIG \
            --with-udev-rules-dir=/lib/udev/rules.d \
            --without-hal-callouts-dir \
            --without-hal-fdi-dir &&
make
make install
}

export Xorg_VMMouse_Driver_13_0_0_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-input-vmmouse-13.0.0.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-input-vmmouse-13.0.0.tar.bz2 "

export Xorg_VMMouse_Driver_13_0_0_C24_packname="xf86-input-vmmouse-13.0.0.tar.bz2"

export Xorg_VMMouse_Driver_13_0_0_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_Wacom_Driver_0_20_0_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Wacom_Driver_0_20_0_C24_download="http://downloads.sourceforge.net/linuxwacom/xf86-input-wacom-0.20.0.tar.bz2 "

export Xorg_Wacom_Driver_0_20_0_C24_packname="xf86-input-wacom-0.20.0.tar.bz2"

export Xorg_Wacom_Driver_0_20_0_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_ATI_Driver_7_1_0_C24(){

./configure $XORG_CONFIG --enable-glamor &&
make
make install
cat >> /etc/X11/xorg.conf << "EOF"
Section "Module"
        Load "dri2"
        Load "glamoregl"
EndSection

Section "Device"
        Identifier "radeon"
        Driver "radeon"
        Option "AccelMethod" "glamor"
EndSection
EOF

}

export Xorg_ATI_Driver_7_1_0_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-ati-7.1.0.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-ati-7.1.0.tar.bz2 "

export Xorg_ATI_Driver_7_1_0_C24_packname="xf86-video-ati-7.1.0.tar.bz2"

export Xorg_ATI_Driver_7_1_0_C24_required_or_recommended="Glamor_EGL_0_5_0_C24 "

Xorg_Fbdev_Driver_0_4_3_C24(){

sed -e "/mibstore.h/d" -e "/miInitializeBackingStore/d" \
    -i src/fbdev.c &&
./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Fbdev_Driver_0_4_3_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-fbdev-0.4.3.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-fbdev-0.4.3.tar.bz2 "

export Xorg_Fbdev_Driver_0_4_3_C24_packname="xf86-video-fbdev-0.4.3.tar.bz2"

export Xorg_Fbdev_Driver_0_4_3_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_Intel_Driver_2_21_5_C24(){

./configure $XORG_CONFIG &&
make
make install
cat >> /etc/X11/xorg.conf << "EOF"
Section "Device"
        Identifier "intel"
        Driver "intel"
        Option "AccelMethod" "sna"
EndSection
EOF

}

export Xorg_Intel_Driver_2_21_5_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-intel-2.21.5.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-intel-2.21.5.tar.bz2 "

export Xorg_Intel_Driver_2_21_5_C24_packname="xf86-video-intel-2.21.5.tar.bz2"

export Xorg_Intel_Driver_2_21_5_C24_required_or_recommended="xcb_util_0_3_9_C24 Xorg_Server_1_14_0_C24 "

Xorg_Mach64_Driver_6_9_4_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Mach64_Driver_6_9_4_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-mach64-6.9.4.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-mach64-6.9.4.tar.bz2 "

export Xorg_Mach64_Driver_6_9_4_C24_packname="xf86-video-mach64-6.9.4.tar.bz2"

export Xorg_Mach64_Driver_6_9_4_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_MGA_Driver_1_6_2_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_MGA_Driver_1_6_2_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-mga-1.6.2.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-mga-1.6.2.tar.bz2 "

export Xorg_MGA_Driver_1_6_2_C24_packname="xf86-video-mga-1.6.2.tar.bz2"

export Xorg_MGA_Driver_1_6_2_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_Nouveau_Driver_1_0_7_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Nouveau_Driver_1_0_7_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-nouveau-1.0.7.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-nouveau-1.0.7.tar.bz2 "

export Xorg_Nouveau_Driver_1_0_7_C24_packname="xf86-video-nouveau-1.0.7.tar.bz2"

export Xorg_Nouveau_Driver_1_0_7_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_OpenChrome_Driver_0_3_2_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_OpenChrome_Driver_0_3_2_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-openchrome-0.3.2.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-openchrome-0.3.2.tar.bz2 "

export Xorg_OpenChrome_Driver_0_3_2_C24_packname="xf86-video-openchrome-0.3.2.tar.bz2"

export Xorg_OpenChrome_Driver_0_3_2_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_R128_Driver_6_9_1_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_R128_Driver_6_9_1_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-r128-6.9.1.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-r128-6.9.1.tar.bz2 "

export Xorg_R128_Driver_6_9_1_C24_packname="xf86-video-r128-6.9.1.tar.bz2"

export Xorg_R128_Driver_6_9_1_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_Savage_Driver_2_3_6_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export Xorg_Savage_Driver_2_3_6_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-savage-2.3.6.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-savage-2.3.6.tar.bz2 "

export Xorg_Savage_Driver_2_3_6_C24_packname="xf86-video-savage-2.3.6.tar.bz2"

export Xorg_Savage_Driver_2_3_6_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_SiS_Driver_0_10_7_C24(){

patch -Np1 -i ../xf86-video-sis-0.10.7-upstream_fixes-1.patch &&
./configure $XORG_CONFIG &&
make
make install
}

export Xorg_SiS_Driver_0_10_7_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-sis-0.10.7.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-sis-0.10.7.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/xf86-video-sis-0.10.7-upstream_fixes-1.patch "

export Xorg_SiS_Driver_0_10_7_C24_packname="xf86-video-sis-0.10.7.tar.bz2"

export Xorg_SiS_Driver_0_10_7_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_3Dfx_Driver_1_4_5_C24(){

sed -e "/mibstore.h/d" -e "/miInitializeBackingStore/d" \
    -i src/tdfx_driver.c &&
./configure $XORG_CONFIG &&
make
make install
}

export Xorg_3Dfx_Driver_1_4_5_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-tdfx-1.4.5.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-tdfx-1.4.5.tar.bz2 "

export Xorg_3Dfx_Driver_1_4_5_C24_packname="xf86-video-tdfx-1.4.5.tar.bz2"

export Xorg_3Dfx_Driver_1_4_5_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_VESA_Driver_2_3_2_C24(){

sed -e "/mibstore.h/d" -e "/miInitializeBackingStore/d" \
    -e "s/MODE_QUERY < 0/function < MODE_QUERY/g" \
    -i src/vesa.c &&
./configure $XORG_CONFIG &&
make
make install
}

export Xorg_VESA_Driver_2_3_2_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-vesa-2.3.2.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-vesa-2.3.2.tar.bz2 "

export Xorg_VESA_Driver_2_3_2_C24_packname="xf86-video-vesa-2.3.2.tar.bz2"

export Xorg_VESA_Driver_2_3_2_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

Xorg_VMware_Driver_13_0_0_C24(){

sed -e "/mibstore.h/d" -e "/miInitializeBackingStore/d" \
    -i saa/saa_priv.h src/vmware.c vmwgfx/vmwgfx_driver.c &&
 ./configure $XORG_CONFIG &&
make
make install
}

export Xorg_VMware_Driver_13_0_0_C24_download="http://xorg.freedesktop.org/releases/individual/driver/xf86-video-vmware-13.0.0.tar.bz2 ftp://ftp.x.org/pub/individual/driver/xf86-video-vmware-13.0.0.tar.bz2 "

export Xorg_VMware_Driver_13_0_0_C24_packname="xf86-video-vmware-13.0.0.tar.bz2"

export Xorg_VMware_Driver_13_0_0_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

printproto_1_0_5_C24(){

./configure $XORG_CONFIG
make install
}

export printproto_1_0_5_C24_download="http://xorg.freedesktop.org/releases/individual/proto/printproto-1.0.5.tar.bz2 ftp://ftp.x.org/pub/individual/proto/printproto-1.0.5.tar.bz2 "

export printproto_1_0_5_C24_packname="printproto-1.0.5.tar.bz2"

libXp_1_0_1_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export libXp_1_0_1_C24_download="http://xorg.freedesktop.org/releases/individual/lib/libXp-1.0.1.tar.bz2 ftp://ftp.x.org/pub/individual/lib/libXp-1.0.1.tar.bz2 "

export libXp_1_0_1_C24_packname="libXp-1.0.1.tar.bz2"

export libXp_1_0_1_C24_required_or_recommended="printproto_1_0_5_C24 "

twm_1_0_7_C24(){

sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' \
    src/Makefile.in &&
./configure $XORG_CONFIG &&
make
make install
}

export twm_1_0_7_C24_download="http://xorg.freedesktop.org/releases/individual/app/twm-1.0.7.tar.bz2 ftp://ftp.x.org/pub/individual/app/twm-1.0.7.tar.bz2 "

export twm_1_0_7_C24_packname="twm-1.0.7.tar.bz2"

export twm_1_0_7_C24_required_or_recommended="Xorg_Server_1_14_0_C24 "

xterm_291_C24(){

sed -i '/v0/,+1s/new:/new:kb=^?:/' termcap &&
echo -e '\tkbs=\\177,' >>terminfo &&
TERMINFO=/usr/share/terminfo ./configure $XORG_CONFIG \
    --enable-luit --enable-wide-chars \
    --with-app-defaults=/etc/X11/app-defaults &&
make
make install &&
make install-ti
cat >> /etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true
EOF
}

export xterm_291_C24_download="ftp://invisible-island.net/xterm/xterm-291.tgz "

export xterm_291_C24_packname="xterm-291.tgz"

export xterm_291_C24_required_or_recommended="Xorg_Applications_C24 "

xclock_1_0_6_C24(){

./configure $XORG_CONFIG &&
make
make install
}

export xclock_1_0_6_C24_download="http://xorg.freedesktop.org/releases/individual/app/xclock-1.0.6.tar.bz2 ftp://ftp.x.org/pub/individual/app/xclock-1.0.6.tar.bz2 "

export xclock_1_0_6_C24_packname="xclock-1.0.6.tar.bz2"

export xclock_1_0_6_C24_required_or_recommended="Xorg_Libraries_C24 "

xinit_1_3_2_C24(){

./configure $XORG_CONFIG \
            --with-xinitdir=/etc/X11/app-defaults &&
make
make install
}

export xinit_1_3_2_C24_download="http://xorg.freedesktop.org/releases/individual/app/xinit-1.3.2.tar.bz2 ftp://ftp.x.org/pub/individual/app/xinit-1.3.2.tar.bz2 "

export xinit_1_3_2_C24_packname="xinit-1.3.2.tar.bz2"

export xinit_1_3_2_C24_required_or_recommended="xclock_1_0_6_C24 xterm_291_C24 "

Xorg_7_7_Testing_and_Configuration_C24(){

usermod -a -G video mao

DRI_PRIME=1 glxinfo | egrep "(OpenGL vendor|OpenGL renderer|OpenGL version)"
install -v -d -m755 /usr/share/fonts/dejavu &&
install -v -m644 *.ttf /usr/share/fonts/dejavu &&
fc-cache -v /usr/share/fonts/dejavu
cat > /etc/X11/xorg.conf.d/xkb-defaults.conf << "EOF"
Section "InputClass"
    Identifier "XKB Defaults"
    MatchIsKeyboard "yes"
    Option "XkbOptions" "terminate:ctrl_alt_bksp"
EOF
cat > /etc/X11/xorg.conf.d/videocard-0.conf << "EOF"
Section "Device"
    Identifier  "Videocard0"
    Driver      "radeon"
    VendorName  "Videocard vendor"
    BoardName   "ATI Radeon 7500"
    Option      "NoAccel" "true"
EndSection
EOF
cat > /etc/X11/xorg.conf.d/server-layout.conf << "EOF"
Section "ServerLayout"
    Identifier     "DefaultLayout"
    Screen      0  "Screen0" 0 0
    Screen      1  "Screen1" LeftOf "Screen0"
    Option         "Xinerama"
EndSection
EOF
}

export C24_XWindowSystemEnvironment="Introduction_to_Xorg_7_7_C24 util_macros_1_17_C24 Xorg_Protocol_Headers_C24 makedepend_1_0_4_C24 libXau_1_0_7_C24 libXdmcp_1_1_1_C24 xcb_proto_1_8_C24 libxcb_1_9_C24 Xorg_Libraries_C24 xcb_util_0_3_9_C24 xcb_util_image_0_3_9_C24 xcb_util_renderutil_0_3_8_C24 MesaLib_9_1_1_C24 xbitmaps_1_1_1_C24 Xorg_Applications_C24 xcursor_themes_1_0_3_C24 Xorg_Fonts_C24 XKeyboardConfig_2_8_C24 Xorg_Server_1_14_0_C24 Xorg_Drivers_C24 printproto_1_0_5_C24 libXp_1_0_1_C24 twm_1_0_7_C24 xterm_291_C24 xclock_1_0_6_C24 xinit_1_3_2_C24 Xorg_7_7_Testing_and_Configuration_C24 "
XWindowSystemEnvironment(){
Introduction_to_Xorg_7_7_C24
util_macros_1_17_C24
Xorg_Protocol_Headers_C24
makedepend_1_0_4_C24
libXau_1_0_7_C24
libXdmcp_1_1_1_C24
xcb_proto_1_8_C24
libxcb_1_9_C24
Xorg_Libraries_C24
xcb_util_0_3_9_C24
xcb_util_image_0_3_9_C24
xcb_util_renderutil_0_3_8_C24
MesaLib_9_1_1_C24
xbitmaps_1_1_1_C24
Xorg_Applications_C24
xcursor_themes_1_0_3_C24
Xorg_Fonts_C24
XKeyboardConfig_2_8_C24
Xorg_Server_1_14_0_C24
Xorg_Drivers_C24
printproto_1_0_5_C24
libXp_1_0_1_C24
twm_1_0_7_C24
xterm_291_C24
xclock_1_0_6_C24
xinit_1_3_2_C24
Xorg_7_7_Testing_and_Configuration_C24

}


agg_2_5_C25(){

sed -i 's:  -L@x_libraries@::' src/platform/X11/Makefile.am &&
sed -i '/^AM_C_PROTOTYPES/d' configure.in &&
bash autogen.sh --prefix=/usr --disable-static &&
make
make install
}

export agg_2_5_C25_download="http://www.antigrain.com/agg-2.5.tar.gz "

export agg_2_5_C25_packname="agg-2.5.tar.gz"

export agg_2_5_C25_required_or_recommended="pkg_config_0_28_C13 SDL_1_2_15_C38 Xorg_Libraries_C24 "

ATK_2_6_0_C25(){

./configure --prefix=/usr &&
make
make install
}

export ATK_2_6_0_C25_download="http://ftp.gnome.org/pub/gnome/sources/atk/2.6/atk-2.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/atk/2.6/atk-2.6.0.tar.xz "

export ATK_2_6_0_C25_packname="atk-2.6.0.tar.xz"

export ATK_2_6_0_C25_required_or_recommended="GLib_2_34_3_C9 "

Atkmm_2_22_6_C25(){

./configure --prefix=/usr &&
make
make install
}

export Atkmm_2_22_6_C25_download="http://ftp.gnome.org/pub/gnome/sources/atkmm/2.22/atkmm-2.22.6.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/atkmm/2.22/atkmm-2.22.6.tar.xz "

export Atkmm_2_22_6_C25_packname="atkmm-2.22.6.tar.xz"

export Atkmm_2_22_6_C25_required_or_recommended="ATK_2_6_0_C25 GLibmm_2_34_1_C9 "

at_spi2_core_2_6_3_C25(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/at-spi2-core &&
make
make install
}

export at_spi2_core_2_6_3_C25_download="http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.6/at-spi2-core-2.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.6/at-spi2-core-2.6.3.tar.xz "

export at_spi2_core_2_6_3_C25_packname="at-spi2-core-2.6.3.tar.xz"

export at_spi2_core_2_6_3_C25_required_or_recommended="D_Bus_1_6_8_C12 GLib_2_34_3_C9 Intltool_0_50_2_C11 Xorg_Libraries_C24 gobject_introspection_1_34_2_C9 "

at_spi2_atk_2_6_2_C25(){

./configure --prefix=/usr &&
make
make install
glib-compile-schemas /usr/share/glib-2.0/schemas
}

export at_spi2_atk_2_6_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.6/at-spi2-atk-2.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.6/at-spi2-atk-2.6.2.tar.xz "

export at_spi2_atk_2_6_2_C25_packname="at-spi2-atk-2.6.2.tar.xz"

export at_spi2_atk_2_6_2_C25_required_or_recommended="at_spi2_core_2_6_3_C25 ATK_2_6_0_C25 "

Cairo_1_12_14_C25(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Cairo_1_12_14_C25_download="http://cairographics.org/releases/cairo-1.12.14.tar.xz "

export Cairo_1_12_14_C25_packname="cairo-1.12.14.tar.xz"

export Cairo_1_12_14_C25_required_or_recommended="libpng_1_5_14_C10 GLib_2_34_3_C9 Pixman_0_28_2_C10 Fontconfig_2_10_2_C10 Xorg_Libraries_C24 "

Cairomm_1_10_0_C25(){

./configure --prefix=/usr &&
make
make install
}

export Cairomm_1_10_0_C25_download="http://cairographics.org/releases/cairomm-1.10.0.tar.gz "

export Cairomm_1_10_0_C25_packname="cairomm-1.10.0.tar.gz"

export Cairomm_1_10_0_C25_required_or_recommended="Cairo_1_12_14_C25 libsigc_2_2_11_C9 "

Cogl_1_12_2_C25(){

./configure --prefix=/usr &&
make
make install
}

export Cogl_1_12_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/cogl/1.12/cogl-1.12.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/cogl/1.12/cogl-1.12.2.tar.xz "

export Cogl_1_12_2_C25_packname="cogl-1.12.2.tar.xz"

export Cogl_1_12_2_C25_required_or_recommended="gdk_pixbuf_2_26_5_C25 MesaLib_9_1_1_C24 Pango_1_32_5_C25 gobject_introspection_1_34_2_C9 "

Clutter_1_12_2_C25(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export Clutter_1_12_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/clutter/1.12/clutter-1.12.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/clutter/1.12/clutter-1.12.2.tar.xz "

export Clutter_1_12_2_C25_packname="clutter-1.12.2.tar.xz"

export Clutter_1_12_2_C25_required_or_recommended="ATK_2_6_0_C25 Cogl_1_12_2_C25 JSON_GLib_0_15_2_C9 gobject_introspection_1_34_2_C9 "

clutter_gst_2_0_2_C25(){

./configure --prefix=/usr &&
make
make install
}

export clutter_gst_2_0_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/clutter-gst/2.0/clutter-gst-2.0.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/clutter-gst/2.0/clutter-gst-2.0.2.tar.xz "

export clutter_gst_2_0_2_C25_packname="clutter-gst-2.0.2.tar.xz"

export clutter_gst_2_0_2_C25_required_or_recommended="Clutter_1_12_2_C25 gst_plugins_base_1_0_6_C38 gobject_introspection_1_34_2_C9 "

clutter_gtk_1_4_2_C25(){

./configure --prefix=/usr &&
make
make install
}

export clutter_gtk_1_4_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/clutter-gtk/1.4/clutter-gtk-1.4.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/clutter-gtk/1.4/clutter-gtk-1.4.2.tar.xz "

export clutter_gtk_1_4_2_C25_packname="clutter-gtk-1.4.2.tar.xz"

export clutter_gtk_1_4_2_C25_required_or_recommended="Clutter_1_12_2_C25 GTK_3_6_4_C25 gobject_introspection_1_34_2_C9 "

colord_gtk_0_1_25_C25(){

./configure --prefix=/usr \
            --enable-vala \
            --disable-static &&
make
make install
}

export colord_gtk_0_1_25_C25_download="http://www.freedesktop.org/software/colord/releases/colord-gtk-0.1.25.tar.xz "

export colord_gtk_0_1_25_C25_packname="colord-gtk-0.1.25.tar.xz"

export colord_gtk_0_1_25_C25_required_or_recommended="Colord_0_1_31_C12 GTK_3_6_4_C25 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

Freeglut_2_8_0_C25(){

patch -Np1 -i ../freeglut-2.8.0-remove_smooth_opengl3_demo-1.patch &&
./configure --prefix=/usr --disable-static &&
make
make install
}

export Freeglut_2_8_0_C25_download="http://downloads.sourceforge.net/freeglut/freeglut-2.8.0.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/freeglut-2.8.0-remove_smooth_opengl3_demo-1.patch "

export Freeglut_2_8_0_C25_packname="freeglut-2.8.0.tar.gz"

export Freeglut_2_8_0_C25_required_or_recommended="MesaLib_9_1_1_C24 "

gdk_pixbuf_2_26_5_C25(){

./configure --prefix=/usr --with-x11 &&
make
make install
gdk-pixbuf-query-loaders --update-cache
}

export gdk_pixbuf_2_26_5_C25_download="http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/2.26/gdk-pixbuf-2.26.5.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/2.26/gdk-pixbuf-2.26.5.tar.xz "

export gdk_pixbuf_2_26_5_C25_packname="gdk-pixbuf-2.26.5.tar.xz"

export gdk_pixbuf_2_26_5_C25_required_or_recommended="GLib_2_34_3_C9 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 LibTIFF_4_0_3_C10 Xorg_Libraries_C24 "

GOffice_0_8_17_C25(){

sed -i 's#info (r, NULL#full&, 0#' goffice/utils/regutf8.c &&
./configure --prefix=/usr --disable-static &&
make
make install
}

export GOffice_0_8_17_C25_download="http://ftp.gnome.org/pub/gnome/sources/goffice/0.8/goffice-0.8.17.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/goffice/0.8/goffice-0.8.17.tar.bz2 "

export GOffice_0_8_17_C25_packname="goffice-0.8.17.tar.bz2"

export GOffice_0_8_17_C25_required_or_recommended="GConf_3_2_6_C30 GTK_2_24_17_C25 Intltool_0_50_2_C11 libgsf_1_14_26_C9 Which_2_20_and_Alternatives_C12 "

GOffice_0_10_1_C25(){

./configure --prefix=/usr &&
make
make install
}

export GOffice_0_10_1_C25_download="http://ftp.gnome.org/pub/gnome/sources/goffice/0.10/goffice-0.10.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/goffice/0.10/goffice-0.10.1.tar.xz "

export GOffice_0_10_1_C25_packname="goffice-0.10.1.tar.xz"

export GOffice_0_10_1_C25_required_or_recommended="GTK_3_6_4_C25 libgsf_1_14_26_C9 librsvg_2_36_4_C10 Which_2_20_and_Alternatives_C12 "

GTK_2_24_17_C25(){

sed -i 's#l \(gtk-.*\).sgml#& -o \1#' docs/{faq,tutorial}/Makefile.in &&
sed -i 's#.*@man_#man_#' docs/reference/gtk/Makefile.in               &&
./configure --prefix=/usr --sysconfdir=/etc                           &&
make
make install
gtk-query-immodules-2.0 > /etc/gtk-2.0/gtk.immodules
cat > ~/.gtkrc-2.0 << "EOF"
include "/usr/share/themes/Glider/gtk-2.0/gtkrc"
gtk-icon-theme-name = "hicolor"
EOF

cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF

}

export GTK_2_24_17_C25_download="http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.17.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.17.tar.xz "

export GTK_2_24_17_C25_packname="gtk+-2.24.17.tar.xz"

export GTK_2_24_17_C25_required_or_recommended="ATK_2_6_0_C25 Cairo_1_12_14_C25 gdk_pixbuf_2_26_5_C25 Pango_1_32_5_C25 Xorg_Libraries_C24 hicolor_icon_theme_0_12_C25 "

GTK_3_6_4_C25(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
rm tests/a11y/pickers.ui &&
make install
gtk-query-immodules-3.0 --update-cache
glib-compile-schemas /usr/share/glib-2.0/schemas
mkdir -p ~/.config/gtk-3.0 &&
cat > ~/.config/gtk-3.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Adwaita
gtk-fallback-icon-theme = gnome
EOF

cat > /etc/gtk-3.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Clearwaita
gtk-fallback-icon-theme = elementary
EOF

}

export GTK_3_6_4_C25_download="http://ftp.gnome.org/pub/gnome/sources/gtk+/3.6/gtk+-3.6.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtk+/3.6/gtk+-3.6.4.tar.xz "

export GTK_3_6_4_C25_packname="gtk+-3.6.4.tar.xz"

export GTK_3_6_4_C25_required_or_recommended="at_spi2_atk_2_6_2_C25 gdk_pixbuf_2_26_5_C25 Pango_1_32_5_C25 "

GTK_Engines_2_20_2_C25(){

./configure --prefix=/usr &&
make
make install
}

export GTK_Engines_2_20_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/gtk-engines/2.20/gtk-engines-2.20.2.tar.bz2 http://ftp.gnome.org/pub/gnome/sources/gtk-engines/2.20/gtk-engines-2.20.2.tar.bz2 "

export GTK_Engines_2_20_2_C25_packname="gtk-engines-2.20.2.tar.bz2"

export GTK_Engines_2_20_2_C25_required_or_recommended="GTK_2_24_17_C25 Intltool_0_50_2_C11 "

Gtkmm_2_24_2_C25(){

./configure --prefix=/usr &&
make
make install
}

export Gtkmm_2_24_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.2.tar.xz "

export Gtkmm_2_24_2_C25_packname="gtkmm-2.24.2.tar.xz"

export Gtkmm_2_24_2_C25_required_or_recommended="Atkmm_2_22_6_C25 GTK_2_24_17_C25 Pangomm_2_28_4_C25 "

Gtkmm_3_6_0_C25(){

./configure --prefix=/usr &&
make
make install
}

export Gtkmm_3_6_0_C25_download="http://ftp.gnome.org/pub/gnome/sources/gtkmm/3.6/gtkmm-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtkmm/3.6/gtkmm-3.6.0.tar.xz "

export Gtkmm_3_6_0_C25_packname="gtkmm-3.6.0.tar.xz"

export Gtkmm_3_6_0_C25_required_or_recommended="Atkmm_2_22_6_C25 GTK_3_6_4_C25 Pangomm_2_28_4_C25 "

gtk_vnc_0_5_2_C25(){

./configure --prefix=/usr \
            --with-gtk=3.0 \
            --enable-vala \
            --without-sasl &&
make
make install
}

export gtk_vnc_0_5_2_C25_download="http://ftp.gnome.org/pub/gnome/sources/gtk-vnc/0.5/gtk-vnc-0.5.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtk-vnc/0.5/gtk-vnc-0.5.2.tar.xz "

export gtk_vnc_0_5_2_C25_packname="gtk-vnc-0.5.2.tar.xz"

export gtk_vnc_0_5_2_C25_required_or_recommended="GTK_3_6_4_C25 GnuTLS_3_1_10_C4 Intltool_0_50_2_C11 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

hicolor_icon_theme_0_12_C25(){

./configure --prefix=/usr
make install
}

export hicolor_icon_theme_0_12_C25_download="http://icon-theme.freedesktop.org/releases/hicolor-icon-theme-0.12.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/hicolor-icon-theme-0.12.tar.gz "

export hicolor_icon_theme_0_12_C25_packname="hicolor-icon-theme-0.12.tar.gz"

libnotify_0_7_5_C25(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libnotify_0_7_5_C25_download="http://ftp.gnome.org/pub/gnome/sources/libnotify/0.7/libnotify-0.7.5.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libnotify/0.7/libnotify-0.7.5.tar.xz "

export libnotify_0_7_5_C25_packname="libnotify-0.7.5.tar.xz"

export libnotify_0_7_5_C25_required_or_recommended="GTK_3_6_4_C25 "

libxklavier_5_3_C25(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libxklavier_5_3_C25_download="http://ftp.gnome.org/pub/gnome/sources/libxklavier/5.3/libxklavier-5.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libxklavier/5.3/libxklavier-5.3.tar.xz "

export libxklavier_5_3_C25_packname="libxklavier-5.3.tar.xz"

export libxklavier_5_3_C25_required_or_recommended="GLib_2_34_3_C9 ISO_Codes_3_40_C9 libxml2_2_9_0_C9 Xorg_Libraries_C24 gobject_introspection_1_34_2_C9 "

notification_daemon_0_7_6_C25(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/notification-daemon &&
make
make install
}

export notification_daemon_0_7_6_C25_download="http://ftp.gnome.org/pub/gnome/sources/notification-daemon/0.7/notification-daemon-0.7.6.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/notification-daemon/0.7/notification-daemon-0.7.6.tar.xz "

export notification_daemon_0_7_6_C25_packname="notification-daemon-0.7.6.tar.xz"

export notification_daemon_0_7_6_C25_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 libcanberra_0_30_C38 GTK_3_6_4_C25 "

Pango_1_32_5_C25(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
pango-querymodules --update-cache
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-static &&
make
make install
}

export Pango_1_32_5_C25_download="http://ftp.gnome.org/pub/gnome/sources/pango/1.32/pango-1.32.5.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/pango/1.32/pango-1.32.5.tar.xz http://ftp.gnome.org/pub/gnome/sources/pangox-compat/0.0/pangox-compat-0.0.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/pangox-compat/0.0/pangox-compat-0.0.2.tar.xz "

export Pango_1_32_5_C25_packname="pango-1.32.5.tar.xz"

export Pango_1_32_5_C25_required_or_recommended="Cairo_1_12_14_C25 Harfbuzz_0_9_14_C10 Xorg_Libraries_C24 "

Pangomm_2_28_4_C25(){

./configure --prefix=/usr &&
make
make install
}

export Pangomm_2_28_4_C25_download="http://ftp.gnome.org/pub/gnome/sources/pangomm/2.28/pangomm-2.28.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/pangomm/2.28/pangomm-2.28.4.tar.xz "

export Pangomm_2_28_4_C25_packname="pangomm-2.28.4.tar.xz"

export Pangomm_2_28_4_C25_required_or_recommended="Cairomm_1_10_0_C25 GLibmm_2_34_1_C9 Pango_1_32_5_C25 "

Qt_4_8_4_C25(){

./configure -prefix /opt/qt-4.8.4  \
            -release               \
            -nomake examples       \
            -nomake demos          \
            -system-sqlite         \
            -no-nis                \
            -opensource            \
            -confirm-license &&
make
make install
ln -sfvfn qt-4.8.4 /opt/qt
cat > /etc/profile.d/qt.sh << EOF
# Begin /etc/profile.d/qt.sh

QTDIR=/usr

export QTDIR

# End /etc/profile.d/qt.sh
EOF

cat >> /etc/ld.so.conf << EOF
# Begin Qt addition

/opt/qt/lib

# End Qt addition
EOF
ldconfig

cat > /etc/profile.d/qt.sh << EOF
# Begin /etc/profile.d/qt.sh

QTDIR=/opt/qt

pathappend /opt/qt/bin           PATH
pathappend /opt/qt/lib/pkgconfig PKG_CONFIG_PATH

export QTDIR

# End /etc/profile.d/qt.sh
EOF

}

export Qt_4_8_4_C25_download="http://releases.qt-project.org/qt4/source/qt-everywhere-opensource-src-4.8.4.tar.gz "

export Qt_4_8_4_C25_packname="qt-everywhere-opensource-src-4.8.4.tar.gz"

export Qt_4_8_4_C25_required_or_recommended="XWindowSystemEnvironment D_Bus_1_6_8_C12 libjpeg_turbo_1_2_1_C10 libmng_1_0_10_C10 LibTIFF_4_0_3_C10 pkg_config_0_28_C13 "

shared_mime_info_1_1_C25(){

./configure --prefix=/usr &&
make
make install
}

export shared_mime_info_1_1_C25_download="http://freedesktop.org/~hadess/shared-mime-info-1.1.tar.xz "

export shared_mime_info_1_1_C25_packname="shared-mime-info-1.1.tar.xz"

export shared_mime_info_1_1_C25_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 libxml2_2_9_0_C9 "

startup_notification_0_12_C25(){

./configure --prefix=/usr &&
make
make install &&
install -v -m644 -D doc/startup-notification.txt \
    /usr/share/doc/startup-notification-0.12/startup-notification.txt
}

export startup_notification_0_12_C25_download="http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz "

export startup_notification_0_12_C25_packname="startup-notification-0.12.tar.gz"

export startup_notification_0_12_C25_required_or_recommended="Xorg_Libraries_C24 xcb_util_0_3_9_C24 "

WebKitGTK_1_10_2_C25(){

sed -i '/generate-gtkdoc --rebase/s:^:# :' GNUmakefile.in
./configure --prefix=/usr \
            --libexecdir=/usr/lib/WebKitGTK \
            --with-gstreamer=1.0 \
            --enable-introspection &&
make
make install
}

export WebKitGTK_1_10_2_C25_download="http://webkitgtk.org/releases/webkitgtk-1.10.2.tar.xz "

export WebKitGTK_1_10_2_C25_packname="webkitgtk-1.10.2.tar.xz"

export WebKitGTK_1_10_2_C25_required_or_recommended="Gperf_3_0_4_C11 gst_plugins_base_1_0_6_C38 GTK_3_6_4_C25 ICU_51_1_C9 libxslt_1_1_28_C9 libsoup_2_40_3_C17 MesaLib_9_1_1_C24 Ruby_1_9_3_p392_C13 SQLite_3_7_16_1_C22 Which_2_20_and_Alternatives_C12 GeoClue_0_12_0_C17 gobject_introspection_1_34_2_C9 "

Xulrunner_19_0_2_C25(){

cat > mozconfig << "EOF"
# If you have a multicore machine you can speed up the build by running
# several jobs at once by uncommenting the following line and setting the
# value to number of CPU cores:
#mk_add_options MOZ_MAKE_FLAGS="-j4"

# If you have installed DBus-Glib comment out this line:
ac_add_options --disable-dbus

# If you have installed wireless-tools comment out this line:
ac_add_options --disable-necko-wifi

# If you have installed libnotify comment out this line:
ac_add_options --disable-libnotify

# Uncomment these lines if you have installed optional dependencies:
#ac_add_options --enable-system-hunspell
#ac_add_options --enable-startup-notification

# If you have not installed Yasm then uncomment this line:
#ac_add_options --disable-webm

# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --enable-system-sqlite
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss

# It is recommended not to touch anything below this line
ac_add_options --prefix=/usr
ac_add_options --enable-application=xulrunner

ac_add_options --disable-crashreporter
ac_add_options --disable-installer
ac_add_options --disable-updater
ac_add_options --disable-debug
ac_add_options --disable-tests
ac_add_options --disable-mochitest

ac_add_options --enable-optimize
ac_add_options --enable-strip
ac_add_options --enable-install-strip

ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman

ac_add_options --enable-shared-js
ac_add_options --with-pthreads

ac_add_options --with-system-bz2
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/xulrunner-build-dir
EOF
make -f client.mk
make -C xulrunner-build-dir install &&

mkdir -pv /usr/lib/mozilla/plugins &&
rm -rf /usr/lib/xulrunner-19.0.2/plugins &&
ln -sfv ../mozilla/plugins /usr/lib/xulrunner-19.0.2 &&

chmod -v 755 /usr/lib/xulrunner-19.0.2/libxpcom.so \
             /usr/lib/xulrunner-devel-19.0.2/sdk/bin/xpcshell &&

for library in libmozalloc.so libmozjs.so libxpcom.so libxul.so; do
    ln -sfv ../../../xulrunner-19.0.2/$library \
            /usr/lib/xulrunner-devel-19.0.2/sdk/lib/$library
    ln -sfv xulrunner-19.0.2/$library /usr/lib/$library
done

ln -sfv ../xulrunner-devel-19.0.2/sdk/bin/run-mozilla.sh \
        /usr/lib/xulrunner-19.0.2
ln -sfv ../xulrunner-devel-19.0.2/sdk/bin/xpcshell \
        /usr/lib/xulrunner-19.0.2
}

export Xulrunner_19_0_2_C25_download="http://releases.mozilla.org/pub/mozilla.org/firefox/releases/19.0.2/source/firefox-19.0.2.source.tar.bz2 ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/19.0.2/source/firefox-19.0.2.source.tar.bz2 "

export Xulrunner_19_0_2_C25_packname="firefox-19.0.2.source.tar.bz2"

export Xulrunner_19_0_2_C25_required_or_recommended="alsa_lib_1_0_26_C38 GTK_2_24_17_C25 Zip_3_0_C12 UnZip_6_0_C12 libevent_2_0_21_C17 libvpx_v1_1_0_C38 NSPR_4_9_6_C9 NSS_3_14_3_C4 SQLite_3_7_16_1_C22 yasm_1_2_0_C13 "

export C25_XLibraries="agg_2_5_C25 ATK_2_6_0_C25 Atkmm_2_22_6_C25 at_spi2_core_2_6_3_C25 at_spi2_atk_2_6_2_C25 Cairo_1_12_14_C25 Cairomm_1_10_0_C25 Cogl_1_12_2_C25 Clutter_1_12_2_C25 clutter_gst_2_0_2_C25 clutter_gtk_1_4_2_C25 colord_gtk_0_1_25_C25 Freeglut_2_8_0_C25 gdk_pixbuf_2_26_5_C25 GOffice_0_8_17_C25 GOffice_0_10_1_C25 GTK_2_24_17_C25 GTK_3_6_4_C25 GTK_Engines_2_20_2_C25 Gtkmm_2_24_2_C25 Gtkmm_3_6_0_C25 gtk_vnc_0_5_2_C25 hicolor_icon_theme_0_12_C25 libnotify_0_7_5_C25 libxklavier_5_3_C25 notification_daemon_0_7_6_C25 Pango_1_32_5_C25 Pangomm_2_28_4_C25 Qt_4_8_4_C25 shared_mime_info_1_1_C25 startup_notification_0_12_C25 WebKitGTK_1_10_2_C25 Xulrunner_19_0_2_C25 "


Fluxbox_1_3_2_C26(){

./configure --prefix=/usr &&
make
make install
echo startfluxbox > ~/.xinitrc
cat > /usr/share/xsessions/fluxbox.desktop << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Fluxbox
Comment=This session logs you into Fluxbox
Exec=startfluxbox
Type=Application
EOF

mkdir -pv ~/.fluxbox &&
cp -v /usr/share/fluxbox/init ~/.fluxbox/init &&
cp -v /usr/share/fluxbox/keys ~/.fluxbox/keys
cd ~/.fluxbox &&
fluxbox-generate_menu
cp -v /usr/share/fluxbox/menu ~/.fluxbox/menu
cp /usr/share/fluxbox/styles/<theme> ~/.fluxbox/theme &&
sed -i 's,\(session.styleFile:\).*,\1 ~/.fluxbox/theme,' ~/.fluxbox/init &&
echo "background.pixmap: </path/to/nice/image.xpm>" >> ~/.fluxbox/theme
}

export Fluxbox_1_3_2_C26_download="http://downloads.sourceforge.net/fluxbox/fluxbox-1.3.2.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/fluxbox-1.3.2.tar. "

export Fluxbox_1_3_2_C26_packname="fluxbox-1.3.2.tar.bz2"

export Fluxbox_1_3_2_C26_required_or_recommended="XWindowSystemEnvironment "

IceWM_1_3_7_C26(){

sed -i '/^LIBS/s/\(.*\)/\1 -lfontconfig/' src/Makefile.in &&
sed -i 's/define deprecated/define ICEWM_deprecated/' src/base.h &&
./configure --prefix=/usr &&
make
make install &&
make install-docs &&
make install-man &&
make install-desktop
echo icewm-session > ~/.xinitrc
mkdir -pv ~/.icewm &&
cp -v /usr/share/icewm/keys ~/.icewm/keys &&
cp -v /usr/share/icewm/menu ~/.icewm/menu &&
cp -v /usr/share/icewm/preferences ~/.icewm/preferences &
cp -v /usr/share/icewm/toolbar ~/.icewm/toolbar &
cp -v /usr/share/icewm/winoptions ~/.icewm/winoptions
cat > ~/.icewm/menu << "EOF"
prog Urxvt xterm urxvt
prog GVolWheel /usr/share/pixmaps/gvolwheel/audio-volume-medium gvolwheel
separator
menufile General folder general
menufile Multimedia folder multimedia
menufile Tool_bar folder toolbar
EOF &&
>cat > ~/.icewm/general << "EOF"
prog Firefox firefox firefox
prog Epiphany /usr/share/icons/gnome/16x16/apps/web-browser epiphany
prog Midori /usr/share/icons/hicolor/24x24/apps/midori midori
separator
prog Gimp /usr/share/icons/hicolor/16x16/apps/gimp gimp
separator
prog Evince /usr/share/icons/hicolor/16x16/apps/evince evince
prog Epdfview /usr/share/epdfview/pixmaps/icon_epdfview-48 epdfview
EOF &&
>cat > ~/.icewm/multimedia << "EOF"
prog Audacious /usr/share/icons/hicolor/48x48/apps/audacious audacious
separator
prog Parole /usr/share/icons/hicolor/16x16/apps/parole parole
prog Totem /usr/share/icons/hicolor/16x16/apps/totem totem
prog Vlc /usr/share/icons/hicolor/16x16/apps/vlc vlc
prog Xine /usr/share/pixmaps/xine xine
EOF &&

cat > ~/.icewm/startup << "EOF"
rox -p Default &
EOF &&
chmod +x ~/.icewm/startup

}

export IceWM_1_3_7_C26_download="http://downloads.sourceforge.net/icewm/icewm-1.3.7.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/icewm-1.3.7.tar.gz "

export IceWM_1_3_7_C26_packname="icewm-1.3.7.tar.gz"

export IceWM_1_3_7_C26_required_or_recommended="XWindowSystemEnvironment gdk_pixbuf_2_26_5_C25 "

openbox_3_5_0_C26(){

export LIBRARY_PATH=$XORG_PREFIX/lib
./configure --prefix=/usr --sysconfdir=/etc --disable-static \
  --docdir=/usr/share/doc/openbox-3.5.0 &&
make
make install
cp -rf /etc/xdg/openbox ~/.config
ls -d /usr/share/themes/*/openbox-3 | sed 's#.*es/##;s#/o.*##'
echo openbox > ~/.xinitrc
cat > ~/.xinitrc << "HERE_DOC"
display -backdrop -window root /path/to/beautiful/picture.jpeg
exec openbox
HERE_DOC
cat > ~/.xinitrc << "HERE_DOC"
# make an array which lists the pictures:
picture_list=(~/.config/backgrounds/*)
# create a random integer between 0 and the number of pictures:
random_number=$(( ${RANDOM} % ${#picture_list[@]} ))
# display the chosen picture:
display -backdrop -window root "${picture_list[${random_number}]}"
exec openbox
HERE_DOC
cat > ~/.xinitrc << "HERE_DOC"
. /etc/profile
picture_list=(~/.config/backgrounds/*)
random_number=$(( ${RANDOM} % ${#picture_list[*]} ))
display -backdrop -window root "${picture_list[${random_number}]}"
numlockx
eval $(dbus-launch --auto-syntax --exit-with-session)
lxpanel &
exec openbox
HERE_DOC
}

export openbox_3_5_0_C26_download="http://openbox.org/dist/openbox/openbox-3.5.0.tar.gz "

export openbox_3_5_0_C26_packname="openbox-3.5.0.tar.gz"

export openbox_3_5_0_C26_required_or_recommended="XWindowSystemEnvironment Pango_1_32_5_C25 "

sawfish_1_9_1_C26(){

./configure --prefix=/usr --with-pango  &&
make
make install
cat >> ~/.xinitrc << "EOF"
exec sawfish
EOF

}

export sawfish_1_9_1_C26_download="http://download.tuxfamily.org/sawfish/sawfish-1.9.1.tar.xz "

export sawfish_1_9_1_C26_packname="sawfish-1.9.1.tar.xz"

export sawfish_1_9_1_C26_required_or_recommended="Rep_gtk_0_90_8_1_C11 Which_2_20_and_Alternatives_C12 GTK_2_24_17_C25 Pango_1_32_5_C25 "

export C26_WindowManagers="Introduction_C26 Fluxbox_1_3_2_C26 IceWM_1_3_7_C26 openbox_3_5_0_C26 sawfish_1_9_1_C26 Other_Window_Managers_C26 "


KDE_Pre_installation_Configuration_C27(){

export KDE_PREFIX=/usr
export KDE_PREFIX=/opt/kde
cat > /etc/profile.d/kde.sh << EOF
# Begin /etc/profile.d/kde.sh

KDE_PREFIX=/opt/kde
KDEDIR=$KDE_PREFIX

pathappend $KDE_PREFIX/bin             PATH
pathappend $KDE_PREFIX/lib/pkgconfig   PKG_CONFIG_PATH
pathappend $KDE_PREFIX/share/pkgconfig PKG_CONFIG_PATH
pathappend $KDE_PREFIX/share           XDG_DATA_DIRS
pathappend /etc/kde/xdg                XDG_CONFIG_DIRS

export KDE_PREFIX KDEDIR

# End /etc/profile.d/kde.sh
EOF


cat >> /etc/ld.so.conf << EOF
# Begin kde addition

/opt/kde/lib

# End kde addition
EOF

install -d $KDE_PREFIX/share &&
ln -sfvf /usr/share/dbus-1 $KDE_PREFIX/share &&
ln -sfvf /usr/share/polkit-1 $KDE_PREFIX/share
mkdir -pv /etc/dbus-1 &&
cat > /etc/dbus-1/system-local.conf << EOF
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <includedir>/etc/kde/dbus-1/system.d</includedir>

</busconfig>
EOF

mv /opt/kde{,-4.10.1} &&
ln -sfvf kde-4.10.1 /opt/kde
}

export C27_Introduction="Introduction_to_KDE_C27 KDE_Pre_installation_Configuration_C27 "


Automoc4_0_9_88_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR .. &&
make
make install
}

export Automoc4_0_9_88_C28_download="http://mirrors.isc.org/pub/kde/stable/automoc4/0.9.88/automoc4-0.9.88.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/automoc4/0.9.88/automoc4-0.9.88.tar.bz2 "

export Automoc4_0_9_88_C28_packname="automoc4-0.9.88.tar.bz2"

export Automoc4_0_9_88_C28_required_or_recommended="CMake_2_8_10_2_C13 Qt_4_8_4_C25 "

Phonon_4_6_0_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR \
      -DPHONON_INSTALL_QT_EXTENSIONS_INTO_SYSTEM_QT=TRUE \
      -DDBUS_INTERFACES_INSTALL_DIR=/usr/share/dbus-1/interfaces \
      .. &&
make
make install
}

export Phonon_4_6_0_C28_download="http://mirrors.isc.org/pub/kde/stable/phonon/4.6.0/src/phonon-4.6.0.tar.xz ftp://ftp.kde.org/pub/kde/stable/phonon/4.6.0/src/phonon-4.6.0.tar.xz "

export Phonon_4_6_0_C28_packname="phonon-4.6.0.tar.xz"

export Phonon_4_6_0_C28_required_or_recommended="Automoc4_0_9_88_C28 GLib_2_34_3_C9 "

Phonon_backend_gstreamer_4_6_3_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Phonon_backend_gstreamer_4_6_3_C28_download="http://mirrors.isc.org/pub/kde/stable/phonon/phonon-backend-gstreamer/4.6.3/src/phonon-backend-gstreamer-4.6.3.tar.xz ftp://ftp.kde.org/pub/kde/stable/phonon/phonon-backend-gstreamer/4.6.3/src/phonon-backend-gstreamer-4.6.3.tar.xz "

export Phonon_backend_gstreamer_4_6_3_C28_packname="phonon-backend-gstreamer-4.6.3.tar.xz"

export Phonon_backend_gstreamer_4_6_3_C28_required_or_recommended="Phonon_4_6_0_C28 GStreamer_0_10_36_C38 gst_plugins_base_0_10_36_C38 gst_plugins_good_0_10_31_C38 gst_plugins_bad_0_10_23_C38 gst_plugins_ugly_0_10_19_C38 "

Phonon_backend_vlc_0_6_2_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Phonon_backend_vlc_0_6_2_C28_download="http://mirrors.isc.org/pub/kde/stable/phonon/phonon-backend-vlc/0.6.2/phonon-backend-vlc-0.6.2.tar.xz ftp://ftp.kde.org/pub/kde/stable/phonon/phonon-backend-vlc/0.6.2/phonon-backend-vlc-0.6.2.tar.xz "

export Phonon_backend_vlc_0_6_2_C28_packname="phonon-backend-vlc-0.6.2.tar.xz"

export Phonon_backend_vlc_0_6_2_C28_required_or_recommended="Phonon_4_6_0_C28 VLC_2_0_5_C40 "

Akonadi_1_9_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_PREFIX_PATH=$QTDIR \
      -DCMAKE_BUILD_TYPE=Release \
      -DINSTALL_QSQLITE_IN_QT_PREFIX=TRUE \
      .. &&
make
make install
}

export Akonadi_1_9_1_C28_download="http://download.kde.org/stable/akonadi/src/akonadi-1.9.1.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/akonadi/src/akonadi-1.9.1.tar.bz2 "

export Akonadi_1_9_1_C28_packname="akonadi-1.9.1.tar.bz2"

export Akonadi_1_9_1_C28_required_or_recommended="shared_mime_info_1_1_C25 Boost_1_53_0_C9 Soprano_2_9_0_C23 SQLite_3_7_16_1_C22 MySQL_5_5_30_C22 "

Attica_0_4_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX .. &&
make
make install
}

export Attica_0_4_1_C28_download="http://mirrors.isc.org/pub/kde/stable/attica/attica-0.4.1.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/attica/attica-0.4.1.tar.bz2 "

export Attica_0_4_1_C28_packname="attica-0.4.1.tar.bz2"

export Attica_0_4_1_C28_required_or_recommended="Qt_4_8_4_C25 CMake_2_8_10_2_C13 "

QImageblitz_0_0_6_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX .. &&
make
make install
}

export QImageblitz_0_0_6_C28_download="http://mirrors.isc.org/pub/kde/stable/qimageblitz/qimageblitz-0.0.6.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/qimageblitz/qimageblitz-0.0.6.tar.bz2 "

export QImageblitz_0_0_6_C28_packname="qimageblitz-0.0.6.tar.bz2"

export QImageblitz_0_0_6_C28_required_or_recommended="Qt_4_8_4_C25 CMake_2_8_10_2_C13 "

Shared_desktop_ontologies_0_10_0_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX ..
make install
}

export Shared_desktop_ontologies_0_10_0_C28_download="http://downloads.sourceforge.net/oscaf/shared-desktop-ontologies-0.10.0.tar.bz2 "

export Shared_desktop_ontologies_0_10_0_C28_packname="shared-desktop-ontologies-0.10.0.tar.bz2"

export Shared_desktop_ontologies_0_10_0_C28_required_or_recommended="CMake_2_8_10_2_C13 "

Polkit_Qt_0_103_0_C28(){

mkdir build &&
cd build &&
CMAKE_PREFIX_PATH=$QTDIR \
      cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX .. &&
make
make install
}

export Polkit_Qt_0_103_0_C28_download="http://mirrors.isc.org/pub/kde/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2 "

export Polkit_Qt_0_103_0_C28_packname="polkit-qt-1-0.103.0.tar.bz2"

export Polkit_Qt_0_103_0_C28_required_or_recommended="Automoc4_0_9_88_C28 Polkit_0_110_C4 "

Oxygen_icons_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX ..
make install
}

export Oxygen_icons_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/oxygen-icons-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/oxygen-icons-4.10.1.tar.xz "

export Oxygen_icons_4_10_1_C28_packname="oxygen-icons-4.10.1.tar.xz"

export Oxygen_icons_4_10_1_C28_required_or_recommended="CMake_2_8_10_2_C13 "

Kdelibs_4_10_1_C28(){

sed -i "s@{SYSCONF_INSTALL_DIR}/xdg/menus@& RENAME kde-applications.menu@" \
        kded/CMakeLists.txt &&
sed -i "s@applications.menu@kde-&@" \
        kded/kbuildsycoca.cpp
mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DSYSCONF_INSTALL_DIR=/etc \
      -DCMAKE_BUILD_TYPE=Release \
      -DDOCBOOKXML_CURRENTDTD_DIR=/usr/share/xml/docbook/xml-dtd-4.5 \
      .. &&
make
make install
}

export Kdelibs_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kdelibs-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kdelibs-4.10.1.tar.xz "

export Kdelibs_4_10_1_C28_packname="kdelibs-4.10.1.tar.xz"

export Kdelibs_4_10_1_C28_required_or_recommended="Phonon_4_6_0_C28 Attica_0_4_1_C28 Soprano_2_9_0_C23 Strigi_0_7_8_C12 Qca_2_0_3_C9 libdbusmenu_qt_0_9_2_C9 docbook_xml_4_5_C45 docbook_xsl_1_77_1_C45 Shared_desktop_ontologies_0_10_0_C28 shared_mime_info_1_1_C25 Polkit_Qt_0_103_0_C28 libpng_1_5_14_C10 libjpeg_turbo_1_2_1_C10 giflib_4_1_6_C10 UPower_0_9_20_C12 UDisks_1_0_4_C12 "

Polkit_kde_agent_0_99_0_C28(){

patch -Np1 -i ../polkit-kde-agent-1-0.99.0-remember_password-1.patch &&
mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX .. &&
make
make install
}

export Polkit_kde_agent_0_99_0_C28_download="http://mirrors.isc.org/pub/kde/stable/apps/KDE4.x/admin/polkit-kde-agent-1-0.99.0.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/apps/KDE4.x/admin/polkit-kde-agent-1-0.99.0.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/polkit-kde-agent-1-0.99.0-remember_password-1.patch "

export Polkit_kde_agent_0_99_0_C28_packname="polkit-kde-agent-1-0.99.0.tar.bz2"

export Polkit_kde_agent_0_99_0_C28_required_or_recommended="Polkit_Qt_0_103_0_C28 Kdelibs_4_10_1_C28 "

Nepomuk_core_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Nepomuk_core_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/nepomuk-core-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/nepomuk-core-4.10.1.tar.xz "

export Nepomuk_core_4_10_1_C28_packname="nepomuk-core-4.10.1.tar.xz"

export Nepomuk_core_4_10_1_C28_required_or_recommended="Kdelibs_4_10_1_C28 Poppler_0_22_2_C10 Taglib_1_8_C38 Exiv2_0_23_C10 FFmpeg_1_2_C40 "

Nepomuk_widgets_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Nepomuk_widgets_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/nepomuk-widgets-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/nepomuk-widgets-4.10.1.tar.xz "

export Nepomuk_widgets_4_10_1_C28_packname="nepomuk-widgets-4.10.1.tar.xz"

export Nepomuk_widgets_4_10_1_C28_required_or_recommended="Nepomuk_core_4_10_1_C28 "

Kdepimlibs_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kdepimlibs_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kdepimlibs-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kdepimlibs-4.10.1.tar.xz "

export Kdepimlibs_4_10_1_C28_packname="kdepimlibs-4.10.1.tar.xz"

export Kdepimlibs_4_10_1_C28_required_or_recommended="Nepomuk_core_4_10_1_C28 libxslt_1_1_28_C9 GPGME_1_4_0_C4 libical_0_48_C9 Akonadi_1_9_1_C28 Cyrus_SASL_2_1_25_C4 Boost_1_53_0_C9 OpenLDAP_2_4_34_C23 http://qjson.sourceforge.net/ "

Kactivities_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kactivities_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kactivities-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kactivities-4.10.1.tar.xz "

export Kactivities_4_10_1_C28_packname="kactivities-4.10.1.tar.xz"

export Kactivities_4_10_1_C28_required_or_recommended="Kdelibs_4_10_1_C28 Nepomuk_core_4_10_1_C28 "

Kde_runtime_4_10_1_C28(){

patch -Np1 -i ../kde-runtime-4.10.1-rpc_fix-1.patch &&
mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DSYSCONF_INSTALL_DIR=/etc \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install &&
ln -s -v ../lib/kde4/libexec/kdesu $KDE_PREFIX/bin/kdesu
}

export Kde_runtime_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kde-runtime-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kde-runtime-4.10.1.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/kde-runtime-4.10.1-rpc_fix-1.patch "

export Kde_runtime_4_10_1_C28_packname="kde-runtime-4.10.1.tar.xz"

export Kde_runtime_4_10_1_C28_required_or_recommended="Kdelibs_4_10_1_C28 libtirpc_0_2_3_C17 Kactivities_4_10_1_C28 Kdepimlibs_4_10_1_C28 alsa_lib_1_0_26_C38 libjpeg_turbo_1_2_1_C10 Exiv2_0_23_C10 "

Kde_baseapps_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kde_baseapps_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kde-baseapps-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kde-baseapps-4.10.1.tar.xz "

export Kde_baseapps_4_10_1_C28_packname="kde-baseapps-4.10.1.tar.xz"

export Kde_baseapps_4_10_1_C28_required_or_recommended="Kdelibs_4_10_1_C28 Kactivities_4_10_1_C28 Nepomuk_widgets_4_10_1_C28 "

Kde_base_artwork_4_10_1_C28(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX ..
make install
}

export Kde_base_artwork_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kde-base-artwork-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kde-base-artwork-4.10.1.tar.xz "

export Kde_base_artwork_4_10_1_C28_packname="kde-base-artwork-4.10.1.tar.xz"

export Kde_base_artwork_4_10_1_C28_required_or_recommended="Kdelibs_4_10_1_C28 "

Kde_workspace_4_10_1_C28(){

groupadd -g 37 kdm &&
useradd -c "KDM Daemon Owner" -d /var/lib/kdm -g kdm \
        -u 37 -s /bin/false kdm &&
install -o kdm -g kdm -dm755 /var/lib/kdm
mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DSYSCONF_INSTALL_DIR=/etc \
      -DCMAKE_BUILD_TYPE=Release \
      -DINSTALL_PYTHON_FILES_IN_PYTHON_PREFIX=TRUE \
      .. &&
make
make install &&
mkdir -p /usr/share/xsessions &&
ln -sf $KDE_PREFIX/share/apps/kdm/sessions/kde-plasma.desktop \
       /usr/share/xsessions/kde-plasma.desktop
cat >> /etc/pam.d/kde << "EOF"
# Begin /etc/pam.d/kde

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde
EOF
cat > /etc/pam.d/kde-np << "EOF"
# Begin /etc/pam.d/kde-np

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde-np
EOF
cat > /etc/pam.d/kscreensaver << "EOF"
# Begin /etc/pam.d/kscreensaver

auth    include system-auth
account include system-account

# End /etc/pam.d/kscreensaver
EOF
}

export Kde_workspace_4_10_1_C28_download="http://download.kde.org/stable/4.10.1/src/kde-workspace-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kde-workspace-4.10.1.tar.xz "

export Kde_workspace_4_10_1_C28_packname="kde-workspace-4.10.1.tar.xz"

export Kde_workspace_4_10_1_C28_required_or_recommended="Kactivities_4_10_1_C28 QImageblitz_0_0_6_C28 xcb_util_image_0_3_9_C24 xcb_util_renderutil_0_3_8_C24 Kdepimlibs_4_10_1_C28 Nepomuk_core_4_10_1_C28 Boost_1_53_0_C9 FreeType_2_4_11_C10 PCI_Utils_3_1_10_C12 ConsoleKit_0_4_6_C4 "

Starting_KDE_C28(){

cat > ~/.xinitrc << EOF
# Begin .xinitrc

exec ck-launch-session dbus-launch --exit-with-session startkde

# End .xinitrc
EOF

cat >> /etc/inittab << EOF
kd:5:respawn:/opt/kde/bin/kdm
EOF

sed -i 's#id:3:initdefault:#id:5:initdefault:#' /etc/inittab
}

export C28_TheKDECore="Automoc4_0_9_88_C28 Phonon_4_6_0_C28 Phonon_backend_gstreamer_4_6_3_C28 Phonon_backend_vlc_0_6_2_C28 Akonadi_1_9_1_C28 Attica_0_4_1_C28 QImageblitz_0_0_6_C28 Shared_desktop_ontologies_0_10_0_C28 Polkit_Qt_0_103_0_C28 Oxygen_icons_4_10_1_C28 Kdelibs_4_10_1_C28 Polkit_kde_agent_0_99_0_C28 Nepomuk_core_4_10_1_C28 Nepomuk_widgets_4_10_1_C28 Kdepimlibs_4_10_1_C28 Kactivities_4_10_1_C28 Kde_runtime_4_10_1_C28 Kde_baseapps_4_10_1_C28 Kde_base_artwork_4_10_1_C28 Kde_workspace_4_10_1_C28 Starting_KDE_C28 "


Konsole_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Konsole_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/konsole-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/konsole-4.10.1.tar.xz "

export Konsole_4_10_1_C29_packname="konsole-4.10.1.tar.xz"

export Konsole_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 Kde_baseapps_4_10_1_C28 "

Kate_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DINSTALL_PYTHON_FILES_IN_PYTHON_PREFIX=TRUE \
      .. &&
make
make install
}

export Kate_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/kate-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kate-4.10.1.tar.xz "

export Kate_4_10_1_C29_packname="kate-4.10.1.tar.xz"

export Kate_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 Kactivities_4_10_1_C28 "

Ark_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Ark_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/ark-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/ark-4.10.1.tar.xz "

export Ark_4_10_1_C29_packname="ark-4.10.1.tar.xz"

export Ark_4_10_1_C29_required_or_recommended="Kde_baseapps_4_10_1_C28 libarchive_3_1_2_C12 "

Kdeadmin_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kdeadmin_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/kdeadmin-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kdeadmin-4.10.1.tar.xz "

export Kdeadmin_4_10_1_C29_packname="kdeadmin-4.10.1.tar.xz"

export Kdeadmin_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 Kdepimlibs_4_10_1_C28 "

Kmix_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kmix_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/kmix-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kmix-4.10.1.tar.xz "

export Kmix_4_10_1_C29_packname="kmix-4.10.1.tar.xz"

export Kmix_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 "

libkcddb_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export libkcddb_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/libkcddb-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/libkcddb-4.10.1.tar.xz "

export libkcddb_4_10_1_C29_packname="libkcddb-4.10.1.tar.xz"

export libkcddb_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 libmusicbrainz_5_0_1_C38 "

Kdepim_runtime_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kdepim_runtime_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/kdepim-runtime-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kdepim-runtime-4.10.1.tar.xz "

export Kdepim_runtime_4_10_1_C29_packname="kdepim-runtime-4.10.1.tar.xz"

export Kdepim_runtime_4_10_1_C29_required_or_recommended="Kdepimlibs_4_10_1_C28 "

Kdepim_4_10_1_C29(){

patch -Np1 -i ../kdepim-4.10.1-boost_fix-1.patch &&
mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DSYSCONF_INSTALL_DIR=/etc \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kdepim_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/kdepim-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kdepim-4.10.1.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/kdepim-4.10.1-boost_fix-1.patch "

export Kdepim_4_10_1_C29_packname="kdepim-4.10.1.tar.xz"

export Kdepim_4_10_1_C29_required_or_recommended="Kdepim_runtime_4_10_1_C29 Nepomuk_widgets_4_10_1_C28 Boost_1_53_0_C9 libassuan_2_1_0_C9 "

libkexiv2_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export libkexiv2_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/libkexiv2-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/libkexiv2-4.10.1.tar.xz "

export libkexiv2_4_10_1_C29_packname="libkexiv2-4.10.1.tar.xz"

export libkexiv2_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 Exiv2_0_23_C10 "

Kdeplasma_addons_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Kdeplasma_addons_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/kdeplasma-addons-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/kdeplasma-addons-4.10.1.tar.xz "

export Kdeplasma_addons_4_10_1_C29_packname="kdeplasma-addons-4.10.1.tar.xz"

export Kdeplasma_addons_4_10_1_C29_required_or_recommended="Kde_workspace_4_10_1_C28 Kdepimlibs_4_10_1_C28 "

Okular_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Okular_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/okular-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/okular-4.10.1.tar.xz "

export Okular_4_10_1_C29_packname="okular-4.10.1.tar.xz"

export Okular_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 Kactivities_4_10_1_C28 FreeType_2_4_11_C10 QImageblitz_0_0_6_C28 LibTIFF_4_0_3_C10 libjpeg_turbo_1_2_1_C10 Poppler_0_22_2_C10 "

Gwenview_4_10_1_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      .. &&
make
make install
}

export Gwenview_4_10_1_C29_download="http://download.kde.org/stable/4.10.1/src/gwenview-4.10.1.tar.xz ftp://ftp.kde.org/pub/kde/stable/4.10.1/src/gwenview-4.10.1.tar.xz "

export Gwenview_4_10_1_C29_packname="gwenview-4.10.1.tar.xz"

export Gwenview_4_10_1_C29_required_or_recommended="Kdelibs_4_10_1_C28 Kactivities_4_10_1_C28 Kde_baseapps_4_10_1_C28 Nepomuk_core_4_10_1_C28 libkexiv2_4_10_1_C29 libjpeg_turbo_1_2_1_C10 "

Further_KDE_packages_C29(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DSYSCONF_INSTALL_DIR=/etc/kde \
      .. &&
make
make install
}

export C29_KDEAdditionalPackages="Konsole_4_10_1_C29 Kate_4_10_1_C29 Ark_4_10_1_C29 Kdeadmin_4_10_1_C29 Kmix_4_10_1_C29 libkcddb_4_10_1_C29 Kdepim_runtime_4_10_1_C29 Kdepim_4_10_1_C29 libkexiv2_4_10_1_C29 Kdeplasma_addons_4_10_1_C29 Okular_4_10_1_C29 Gwenview_4_10_1_C29 Further_KDE_packages_C29 "


AccountsService_0_6_30_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/accountsservice \
            --disable-static &&
make
make install
}

export AccountsService_0_6_30_C30_download="http://www.freedesktop.org/software/accountsservice/accountsservice-0.6.30.tar.xz "

export AccountsService_0_6_30_C30_packname="accountsservice-0.6.30.tar.xz"

export AccountsService_0_6_30_C30_required_or_recommended="libxslt_1_1_28_C9 Polkit_0_110_C4 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

polkit_gnome_0_105_C30(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/polkit-gnome &&
make
make install
mkdir -p /etc/xdg/autostart &&
cat > /etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop << "EOF"
[Desktop Entry]
Name=PolicyKit Authentication Agent
Comment=PolicyKit Authentication Agent
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
Terminal=false
Type=Application
Categories=
NoDisplay=true
OnlyShowIn=GNOME;XFCE;Unity;
AutostartCondition=GNOME3 unless-session gnome
EOF

}

export polkit_gnome_0_105_C30_download="http://ftp.gnome.org/pub/gnome/sources/polkit-gnome/0.105/polkit-gnome-0.105.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/polkit-gnome/0.105/polkit-gnome-0.105.tar.xz "

export polkit_gnome_0_105_C30_packname="polkit-gnome-0.105.tar.xz"

export polkit_gnome_0_105_C30_required_or_recommended="GTK_3_6_4_C25 Polkit_0_110_C4 "

gnome_doc_utils_0_20_10_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_doc_utils_0_20_10_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-doc-utils/0.20/gnome-doc-utils-0.20.10.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-doc-utils/0.20/gnome-doc-utils-0.20.10.tar.xz "

export gnome_doc_utils_0_20_10_C30_packname="gnome-doc-utils-0.20.10.tar.xz"

export gnome_doc_utils_0_20_10_C30_required_or_recommended="Intltool_0_50_2_C11 libxslt_1_1_28_C9 Python_2_7_3_C13 libxml2_2_9_0_C9 Which_2_20_and_Alternatives_C12 Rarian_0_8_1_C11 "

yelp_xsl_3_6_1_C30(){

./configure --prefix=/usr &&
make
make install
}

export yelp_xsl_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/yelp-xsl/3.6/yelp-xsl-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/yelp-xsl/3.6/yelp-xsl-3.6.1.tar.xz "

export yelp_xsl_3_6_1_C30_packname="yelp-xsl-3.6.1.tar.xz"

export yelp_xsl_3_6_1_C30_required_or_recommended="libxslt_1_1_28_C9 Intltool_0_50_2_C11 Itstool_1_2_0_C45 "

libgnome_keyring_3_6_0_C30(){

./configure --prefix=/usr &&
make
make install
}

export libgnome_keyring_3_6_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/libgnome-keyring/3.6/libgnome-keyring-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgnome-keyring/3.6/libgnome-keyring-3.6.0.tar.xz "

export libgnome_keyring_3_6_0_C30_packname="libgnome-keyring-3.6.0.tar.xz"

export libgnome_keyring_3_6_0_C30_required_or_recommended="D_Bus_1_6_8_C12 GLib_2_34_3_C9 Intltool_0_50_2_C11 libgcrypt_1_5_1_C9 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

libsecret_0_14_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libsecret_0_14_C30_download="http://ftp.gnome.org/pub/gnome/sources/libsecret/0.14/libsecret-0.14.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libsecret/0.14/libsecret-0.14.tar.xz "

export libsecret_0_14_C30_packname="libsecret-0.14.tar.xz"

export libsecret_0_14_C30_required_or_recommended="GLib_2_34_3_C9 gobject_introspection_1_34_2_C9 libgcrypt_1_5_1_C9 Vala_0_18_1_C13 "

gsettings_desktop_schemas_3_6_1_C30(){

./configure --prefix=/usr &&
make
make install
glib-compile-schemas /usr/share/glib-2.0/schemas
}

export gsettings_desktop_schemas_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/gsettings-desktop-schemas/3.6/gsettings-desktop-schemas-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gsettings-desktop-schemas/3.6/gsettings-desktop-schemas-3.6.1.tar.xz "

export gsettings_desktop_schemas_3_6_1_C30_packname="gsettings-desktop-schemas-3.6.1.tar.xz"

export gsettings_desktop_schemas_3_6_1_C30_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 gobject_introspection_1_34_2_C9 "

DConf_0_14_1_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/dconf &&
make
make install
}

export DConf_0_14_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/dconf/0.14/dconf-0.14.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/dconf/0.14/dconf-0.14.1.tar.xz "

export DConf_0_14_1_C30_packname="dconf-0.14.1.tar.xz"

export DConf_0_14_1_C30_required_or_recommended="D_Bus_1_6_8_C12 GTK_3_6_4_C25 libxml2_2_9_0_C9 Vala_0_18_1_C13 "

GConf_3_2_6_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/GConf \
            --disable-orbit \
            --disable-static &&
make
make install &&
ln -s gconf.xml.defaults /etc/gconf/gconf.xml.system
}

export GConf_3_2_6_C30_download="http://ftp.gnome.org/pub/gnome/sources/GConf/3.2/GConf-3.2.6.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/GConf/3.2/GConf-3.2.6.tar.xz "

export GConf_3_2_6_C30_packname="GConf-3.2.6.tar.xz"

export GConf_3_2_6_C30_required_or_recommended="D_Bus_GLib_Bindings_C12 Intltool_0_50_2_C11 libxml2_2_9_0_C9 gobject_introspection_1_34_2_C9 GTK_3_6_4_C25 Polkit_0_110_C4 "

Gcr_3_6_2_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gnome-keyring &&
make
make install
}

export Gcr_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gcr/3.6/gcr-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gcr/3.6/gcr-3.6.2.tar.xz "

export Gcr_3_6_2_C30_packname="gcr-3.6.2.tar.xz"

export Gcr_3_6_2_C30_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 libgcrypt_1_5_1_C9 libtasn1_3_2_C9 p11_kit_0_15_2_C4 gobject_introspection_1_34_2_C9 "

libgee_0_6_7_C30(){

./configure --prefix=/usr &&
make
make install
}

export libgee_0_6_7_C30_download="http://ftp.gnome.org/pub/gnome/sources/libgee/0.6/libgee-0.6.7.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgee/0.6/libgee-0.6.7.tar.xz "

export libgee_0_6_7_C30_packname="libgee-0.6.7.tar.xz"

export libgee_0_6_7_C30_required_or_recommended="GLib_2_34_3_C9 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

libgweather_3_6_2_C30(){

./configure --prefix=/usr --enable-locations-compression &&
make
make install
}

export libgweather_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/libgweather/3.6/libgweather-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgweather/3.6/libgweather-3.6.2.tar.xz "

export libgweather_3_6_2_C30_packname="libgweather-3.6.2.tar.xz"

export libgweather_3_6_2_C30_required_or_recommended="GTK_3_6_4_C25 libsoup_2_40_3_C17 gobject_introspection_1_34_2_C9 "

libwnck_3_4_4_C30(){

./configure --prefix=/usr &&
make
make install
}

export libwnck_3_4_4_C30_download="http://ftp.gnome.org/pub/gnome/sources/libwnck/3.4/libwnck-3.4.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libwnck/3.4/libwnck-3.4.4.tar.xz "

export libwnck_3_4_4_C30_packname="libwnck-3.4.4.tar.xz"

export libwnck_3_4_4_C30_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 gobject_introspection_1_34_2_C9 startup_notification_0_12_C25 "

libgnomekbd_3_6_0_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libgnomekbd_3_6_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/libgnomekbd/3.6/libgnomekbd-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgnomekbd/3.6/libgnomekbd-3.6.0.tar.xz "

export libgnomekbd_3_6_0_C30_packname="libgnomekbd-3.6.0.tar.xz"

export libgnomekbd_3_6_0_C30_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 libxklavier_5_3_C25 gobject_introspection_1_34_2_C9 "

libgtop_2_28_4_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libgtop_2_28_4_C30_download="http://ftp.gnome.org/pub/gnome/sources/libgtop/2.28/libgtop-2.28.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgtop/2.28/libgtop-2.28.4.tar.xz "

export libgtop_2_28_4_C30_packname="libgtop-2.28.4.tar.xz"

export libgtop_2_28_4_C30_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 Xorg_Libraries_C24 gobject_introspection_1_34_2_C9 "

libwacom_0_6_1_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libwacom_0_6_1_C30_download="http://downloads.sourceforge.net/linuxwacom/libwacom-0.6.tar.bz2 "

export libwacom_0_6_1_C30_packname="libwacom-0.6.tar.bz2"

export libwacom_0_6_1_C30_required_or_recommended="Udev_Installed_LFS_Version_C12 "

gnome_online_accounts_3_6_2_C30(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/gnome-online-accounts \
            --disable-static &&
make
make install
}

export gnome_online_accounts_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-online-accounts/3.6/gnome-online-accounts-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-online-accounts/3.6/gnome-online-accounts-3.6.2.tar.xz "

export gnome_online_accounts_3_6_2_C30_packname="gnome-online-accounts-3.6.2.tar.xz"

export gnome_online_accounts_3_6_2_C30_required_or_recommended="Gcr_3_6_2_C30 libgnome_keyring_3_6_0_C30 libnotify_0_7_5_C25 librest_0_7_90_C17 libsecret_0_14_C30 JSON_GLib_0_15_2_C9 WebKitGTK_1_10_2_C25 gobject_introspection_1_34_2_C9 "

libgdata_0_13_2_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libgdata_0_13_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/libgdata/0.13/libgdata-0.13.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libgdata/0.13/libgdata-0.13.2.tar.xz "

export libgdata_0_13_2_C30_packname="libgdata-0.13.2.tar.xz"

export libgdata_0_13_2_C30_required_or_recommended="gnome_online_accounts_3_6_2_C30 libsoup_2_40_3_C17 liboauth_1_0_0_C4 gobject_introspection_1_34_2_C9 GTK_3_6_4_C25 "

evolution_data_server_3_6_4_C30(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/evolution-data-server \
            --enable-vala-bindings &&
make
make install
}

export evolution_data_server_3_6_4_C30_download="http://ftp.gnome.org/pub/gnome/sources/evolution-data-server/3.6/evolution-data-server-3.6.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/evolution-data-server/3.6/evolution-data-server-3.6.4.tar.xz "

export evolution_data_server_3_6_4_C30_packname="evolution-data-server-3.6.4.tar.xz"

export evolution_data_server_3_6_4_C30_required_or_recommended="Berkeley_DB_5_3_21_C22 gnome_online_accounts_3_6_2_C30 Gperf_3_0_4_C11 libgdata_0_13_2_C30 libical_0_48_C9 NSS_3_14_3_C4 libgweather_3_6_2_C30 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

libzeitgeist_0_3_18_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libzeitgeist_0_3_18_C30_download="https://launchpad.net/libzeitgeist/0.3/0.3.18/+download/libzeitgeist-0.3.18.tar.gz "

export libzeitgeist_0_3_18_C30_packname="libzeitgeist-0.3.18.tar.gz"

export libzeitgeist_0_3_18_C30_required_or_recommended="GLib_2_34_3_C9 "

Folks_0_8_0_C30(){

./configure --prefix=/usr --enable-vala &&
make
make install
}

export Folks_0_8_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/folks/0.8/folks-0.8.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/folks/0.8/folks-0.8.0.tar.xz "

export Folks_0_8_0_C30_packname="folks-0.8.0.tar.xz"

export Folks_0_8_0_C30_required_or_recommended="gobject_introspection_1_34_2_C9 Intltool_0_50_2_C11 libgee_0_6_7_C30 libzeitgeist_0_3_18_C30 telepathy_glib_0_20_1_C9 evolution_data_server_3_6_4_C30 Vala_0_18_1_C13 "

gnome_js_common_0_1_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_js_common_0_1_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-js-common/0.1/gnome-js-common-0.1.2.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/gnome-js-common/0.1/gnome-js-common-0.1.2.tar.bz2 "

export gnome_js_common_0_1_2_C30_packname="gnome-js-common-0.1.2.tar.bz2"

Gjs_1_34_0_C30(){

./configure --prefix=/usr &&
make
make install
}

export Gjs_1_34_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/gjs/1.34/gjs-1.34.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gjs/1.34/gjs-1.34.0.tar.xz "

export Gjs_1_34_0_C30_packname="gjs-1.34.0.tar.xz"

export Gjs_1_34_0_C30_required_or_recommended="Cairo_1_12_14_C25 D_Bus_GLib_Bindings_C12 gobject_introspection_1_34_2_C9 SpiderMonkey_1_0_0_C11 "

Seed_3_2_0_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Seed_3_2_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/seed/3.2/seed-3.2.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/seed/3.2/seed-3.2.0.tar.xz "

export Seed_3_2_0_C30_packname="seed-3.2.0.tar.xz"

export Seed_3_2_0_C30_required_or_recommended="gnome_js_common_0_1_2_C30 gobject_introspection_1_34_2_C9 WebKitGTK_1_10_2_C25 "

libpeas_1_6_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export libpeas_1_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/libpeas/1.6/libpeas-1.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libpeas/1.6/libpeas-1.6.2.tar.xz "

export libpeas_1_6_2_C30_packname="libpeas-1.6.2.tar.xz"

export libpeas_1_6_2_C30_required_or_recommended="gobject_introspection_1_34_2_C9 GTK_3_6_4_C25 Gjs_1_34_0_C30 PyGObject_3_4_2_C13 Seed_3_2_0_C30 "

gtksourceview_3_6_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export gtksourceview_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gtksourceview/3.6/gtksourceview-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gtksourceview/3.6/gtksourceview-3.6.2.tar.xz "

export gtksourceview_3_6_2_C30_packname="gtksourceview-3.6.2.tar.xz"

export gtksourceview_3_6_2_C30_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 gobject_introspection_1_34_2_C9 "

GtkHTML_4_6_4_C30(){

./configure --prefix=/usr &&
make
make install
}

export GtkHTML_4_6_4_C30_download="http://ftp.gnome.org/pub/gnome/sources/gtkhtml/4.6/gtkhtml-4.6.4.tar.xz http://ftp.gnome.org/pub/gnome/sources/gtkhtml/4.6/gtkhtml-4.6.4.tar.xz "

export GtkHTML_4_6_4_C30_packname="gtkhtml-4.6.4.tar.xz"

export GtkHTML_4_6_4_C30_required_or_recommended="enchant_1_6_0_C9 gnome_icon_theme_3_6_2_C30 gsettings_desktop_schemas_3_6_1_C30 GTK_3_6_4_C25 ISO_Codes_3_40_C9 libsoup_2_40_3_C17 "

totem_pl_parser_3_4_3_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export totem_pl_parser_3_4_3_C30_download="http://ftp.gnome.org/pub/gnome/sources/totem-pl-parser/3.4/totem-pl-parser-3.4.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/totem-pl-parser/3.4/totem-pl-parser-3.4.3.tar.xz "

export totem_pl_parser_3_4_3_C30_packname="totem-pl-parser-3.4.3.tar.xz"

export totem_pl_parser_3_4_3_C30_required_or_recommended="GMime_2_6_15_C9 Intltool_0_50_2_C11 libsoup_2_40_3_C17 gobject_introspection_1_34_2_C9 "

VTE_0_34_2_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/vte-2.90 \
            --enable-introspection \
            --disable-static &&
make
make install
}

export VTE_0_34_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/vte/0.34/vte-0.34.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/vte/0.34/vte-0.34.2.tar.xz "

export VTE_0_34_2_C30_packname="vte-0.34.2.tar.xz"

export VTE_0_34_2_C30_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 gobject_introspection_1_34_2_C9 "

gnome_backgrounds_3_6_1_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_backgrounds_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-backgrounds/3.6/gnome-backgrounds-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-backgrounds/3.6/gnome-backgrounds-3.6.1.tar.xz "

export gnome_backgrounds_3_6_1_C30_packname="gnome-backgrounds-3.6.1.tar.xz"

export gnome_backgrounds_3_6_1_C30_required_or_recommended="Intltool_0_50_2_C11 "

gnome_icon_theme_3_6_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_icon_theme_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme/3.6/gnome-icon-theme-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme/3.6/gnome-icon-theme-3.6.2.tar.xz "

export gnome_icon_theme_3_6_2_C30_packname="gnome-icon-theme-3.6.2.tar.xz"

export gnome_icon_theme_3_6_2_C30_required_or_recommended="GTK_3_6_4_C25 hicolor_icon_theme_0_12_C25 icon_naming_utils_0_8_90_C11 Intltool_0_50_2_C11 "

gnome_icon_theme_extras_3_6_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_icon_theme_extras_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-extras/3.6/gnome-icon-theme-extras-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-extras/3.6/gnome-icon-theme-extras-3.6.2.tar.xz "

export gnome_icon_theme_extras_3_6_2_C30_packname="gnome-icon-theme-extras-3.6.2.tar.xz"

export gnome_icon_theme_extras_3_6_2_C30_required_or_recommended="gnome_icon_theme_3_6_2_C30 "

gnome_icon_theme_symbolic_3_6_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_icon_theme_symbolic_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-symbolic/3.6/gnome-icon-theme-symbolic-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-symbolic/3.6/gnome-icon-theme-symbolic-3.6.2.tar.xz "

export gnome_icon_theme_symbolic_3_6_2_C30_packname="gnome-icon-theme-symbolic-3.6.2.tar.xz"

export gnome_icon_theme_symbolic_3_6_2_C30_required_or_recommended="GTK_3_6_4_C25 icon_naming_utils_0_8_90_C11 "

gnome_themes_standard_3_6_5_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_themes_standard_3_6_5_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-themes-standard/3.6/gnome-themes-standard-3.6.5.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-themes-standard/3.6/gnome-themes-standard-3.6.5.tar.xz "

export gnome_themes_standard_3_6_5_C30_packname="gnome-themes-standard-3.6.5.tar.xz"

export gnome_themes_standard_3_6_5_C30_required_or_recommended="GTK_2_24_17_C25 GTK_3_6_4_C25 Intltool_0_50_2_C11 librsvg_2_36_4_C10 "

gnome_video_effects_0_4_0_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_video_effects_0_4_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-video-effects/0.4/gnome-video-effects-0.4.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-video-effects/0.4/gnome-video-effects-0.4.0.tar.xz "

export gnome_video_effects_0_4_0_C30_packname="gnome-video-effects-0.4.0.tar.xz"

export gnome_video_effects_0_4_0_C30_required_or_recommended="Intltool_0_50_2_C11 "

gnome_desktop_3_6_2_C30(){

./configure --prefix=/usr --libexecdir=/usr/lib/gnome-desktop-3.0 &&
make
make install
}

export gnome_desktop_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-desktop/3.6/gnome-desktop-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-desktop/3.6/gnome-desktop-3.6.2.tar.xz "

export gnome_desktop_3_6_2_C30_packname="gnome-desktop-3.6.2.tar.xz"

export gnome_desktop_3_6_2_C30_required_or_recommended="gsettings_desktop_schemas_3_6_1_C30 GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 startup_notification_0_12_C25 "

gnome_keyring_3_6_3_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --with-pam-dir=/lib/security \
            --with-root-certs=/etc/ssl/certs &&
make
make install
}

export gnome_keyring_3_6_3_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-keyring/3.6/gnome-keyring-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-keyring/3.6/gnome-keyring-3.6.3.tar.xz "

export gnome_keyring_3_6_3_C30_packname="gnome-keyring-3.6.3.tar.xz"

export gnome_keyring_3_6_3_C30_required_or_recommended="D_Bus_1_6_8_C12 Gcr_3_6_2_C30 Linux_PAM_1_1_6_C4 "

gnome_menus_3_6_2_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-static &&
make
make install
}

export gnome_menus_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-menus/3.6/gnome-menus-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-menus/3.6/gnome-menus-3.6.2.tar.xz "

export gnome_menus_3_6_2_C30_packname="gnome-menus-3.6.2.tar.xz"

export gnome_menus_3_6_2_C30_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 gobject_introspection_1_34_2_C9 "

gnome_panel_3_6_2_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gnome-applets &&
make
make install
}

export gnome_panel_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-panel/3.6/gnome-panel-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-panel/3.6/gnome-panel-3.6.2.tar.xz "

export gnome_panel_3_6_2_C30_packname="gnome-panel-3.6.2.tar.xz"

export gnome_panel_3_6_2_C30_required_or_recommended="DConf_0_14_1_C30 GConf_3_2_6_C30 gnome_desktop_3_6_2_C30 gnome_menus_3_6_2_C30 libcanberra_0_30_C38 libgweather_3_6_2_C30 librsvg_2_36_4_C10 libwnck_3_4_4_C30 yelp_xsl_3_6_1_C30 evolution_data_server_3_6_4_C30 gobject_introspection_1_34_2_C9 NetworkManager_0_9_8_0_C16 telepathy_glib_0_20_1_C9 "

Gvfs_1_14_2_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gvfs \
            --disable-gphoto2 &&
make
make install
glib-compile-schemas /usr/share/glib-2.0/schemas
}

export Gvfs_1_14_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gvfs/1.14/gvfs-1.14.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gvfs/1.14/gvfs-1.14.2.tar.xz "

export Gvfs_1_14_2_C30_packname="gvfs-1.14.2.tar.xz"

export Gvfs_1_14_2_C30_required_or_recommended="D_Bus_1_6_8_C12 GLib_2_34_3_C9 Intltool_0_50_2_C11 GTK_3_6_4_C25 libsecret_0_14_C30 libsoup_2_40_3_C17 UDisks_2_1_0_C12 "

Nautilus_3_6_3_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/nautilus \
            --disable-nst-extension \
            --disable-packagekit \
            --disable-tracker &&
make
make install
}

export Nautilus_3_6_3_C30_download="http://ftp.gnome.org/pub/gnome/sources/nautilus/3.6/nautilus-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/nautilus/3.6/nautilus-3.6.3.tar.xz "

export Nautilus_3_6_3_C30_packname="nautilus-3.6.3.tar.xz"

export Nautilus_3_6_3_C30_required_or_recommended="gnome_desktop_3_6_2_C30 gobject_introspection_1_34_2_C9 Gvfs_1_14_2_C30 "

Nautilus_Sendto_3_6_1_C30(){

./configure --prefix=/usr &&
make
make install
}

export Nautilus_Sendto_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/nautilus-sendto/3.6/nautilus-sendto-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/nautilus-sendto/3.6/nautilus-sendto-3.6.1.tar.xz "

export Nautilus_Sendto_3_6_1_C30_packname="nautilus-sendto-3.6.1.tar.xz"

export Nautilus_Sendto_3_6_1_C30_required_or_recommended="Nautilus_3_6_3_C30 evolution_data_server_3_6_4_C30 "

gnome_screensaver_3_6_1_C30(){

sed -i 's|etc/pam\.d"|etc"|' data/Makefile.in &&
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gnome-screensaver \
            --with-pam-prefix=/etc &&
make
make install
cat > /etc/pam.d/gnome-screensaver << "EOF"
# Begin /etc/pam.d/gnome-screensaver

auth     include        system-auth
auth     optional       pam_gnome_keyring.so

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/gnome-screensaver
EOF
chmod -v 644 /etc/pam.d/gnome-screensaver

}

export gnome_screensaver_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-screensaver/3.6/gnome-screensaver-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-screensaver/3.6/gnome-screensaver-3.6.1.tar.xz "

export gnome_screensaver_3_6_1_C30_packname="gnome-screensaver-3.6.1.tar.xz"

export gnome_screensaver_3_6_1_C30_required_or_recommended="D_Bus_GLib_Bindings_C12 gnome_desktop_3_6_2_C30 Linux_PAM_1_1_6_C4 libgnomekbd_3_6_0_C30 "

gnome_power_manager_3_6_0_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_power_manager_3_6_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-power-manager/3.6/gnome-power-manager-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-power-manager/3.6/gnome-power-manager-3.6.0.tar.xz "

export gnome_power_manager_3_6_0_C30_packname="gnome-power-manager-3.6.0.tar.xz"

export gnome_power_manager_3_6_0_C30_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 UPower_0_9_20_C12 "

gnome_bluetooth_3_6_1_C30(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
cat > /lib/udev/rules.d/61-gnome-bluetooth.rules << "EOF"
# Get access to /dev/rfkill for users
# See https://bugzilla.redhat.com/show_bug.cgi?id=514798
#
# Updated for udev >= 154
# http://bugs.debian.org/582188
# https://bugzilla.redhat.com/show_bug.cgi?id=588660

ENV{ACL_MANAGE}=="0", GOTO="gnome_bluetooth_end"
ACTION!="add|change", GOTO="gnome_bluetooth_end"
KERNEL=="rfkill", TAG+="udev-acl"
LABEL="gnome_bluetooth_end"
EOF

}

export gnome_bluetooth_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-bluetooth/3.6/gnome-bluetooth-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-bluetooth/3.6/gnome-bluetooth-3.6.1.tar.xz "

export gnome_bluetooth_3_6_1_C30_packname="gnome-bluetooth-3.6.1.tar.xz"

export gnome_bluetooth_3_6_1_C30_required_or_recommended="libnotify_0_7_5_C25 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 Nautilus_Sendto_3_6_1_C30 "

gnome_user_share_3_0_4_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gnome-user-share  \
            --with-modules-path=/usr/lib/apache &&
make
make install
}

export gnome_user_share_3_0_4_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-user-share/3.0/gnome-user-share-3.0.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-user-share/3.0/gnome-user-share-3.0.4.tar.xz "

export gnome_user_share_3_0_4_C30_packname="gnome-user-share-3.0.4.tar.xz"

export gnome_user_share_3_0_4_C30_required_or_recommended="gnome_bluetooth_3_6_1_C30 libcanberra_0_30_C38 yelp_xsl_3_6_1_C30 mod_dnssd_0_6_C16 Nautilus_3_6_3_C30 "

gnome_settings_daemon_3_6_4_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gnome-settings-daemon \
            --disable-packagekit \
            --disable-static &&
make
make install
}

export gnome_settings_daemon_3_6_4_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-settings-daemon/3.6/gnome-settings-daemon-3.6.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-settings-daemon/3.6/gnome-settings-daemon-3.6.4.tar.xz "

export gnome_settings_daemon_3_6_4_C30_packname="gnome-settings-daemon-3.6.4.tar.xz"

export gnome_settings_daemon_3_6_4_C30_required_or_recommended="Colord_0_1_31_C12 gnome_desktop_3_6_2_C30 libcanberra_0_30_C38 libnotify_0_7_5_C25 libgnomekbd_3_6_0_C30 libwacom_0_6_1_C30 PulseAudio_3_0_C38 UPower_0_9_20_C12 Xorg_Wacom_Driver_0_20_0_C24 Cups_1_6_2_C42 IBus_1_5_1_C12 NSS_3_14_3_C4 "

gnome_control_center_3_6_3_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-static &&
make
make install
}

export gnome_control_center_3_6_3_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-control-center/3.6/gnome-control-center-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-control-center/3.6/gnome-control-center-3.6.3.tar.xz "

export gnome_control_center_3_6_3_C30_packname="gnome-control-center-3.6.3.tar.xz"

export gnome_control_center_3_6_3_C30_required_or_recommended="gnome_menus_3_6_2_C30 gnome_online_accounts_3_6_2_C30 gnome_settings_daemon_3_6_4_C30 ISO_Codes_3_40_C9 libgtop_2_28_4_C30 libpwquality_1_2_1_C4 MIT_Kerberos_V5_1_11_1_C4 AccountsService_0_6_30_C30 ConsoleKit_0_4_6_C4 Cups_1_6_2_C42 gnome_bluetooth_3_6_1_C30 IBus_1_5_1_C12 NetworkManager_0_9_8_0_C16 "

gnome_terminal_3_6_1_C30(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export gnome_terminal_3_6_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-terminal/3.6/gnome-terminal-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-terminal/3.6/gnome-terminal-3.6.1.tar.xz "

export gnome_terminal_3_6_1_C30_packname="gnome-terminal-3.6.1.tar.xz"

export gnome_terminal_3_6_1_C30_required_or_recommended="GConf_3_2_6_C30 gnome_doc_utils_0_20_10_C30 gsettings_desktop_schemas_3_6_1_C30 VTE_0_34_2_C30 yelp_xsl_3_6_1_C30 Rarian_0_8_1_C11 "

Zenity_3_6_0_C30(){

./configure --prefix=/usr &&
make
make install
}

export Zenity_3_6_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/zenity/3.6/zenity-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/zenity/3.6/zenity-3.6.0.tar.xz "

export Zenity_3_6_0_C30_packname="zenity-3.6.0.tar.xz"

export Zenity_3_6_0_C30_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 libnotify_0_7_5_C25 "

Metacity_2_34_13_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Metacity_2_34_13_C30_download="http://ftp.gnome.org/pub/gnome/sources/metacity/2.34/metacity-2.34.13.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/metacity/2.34/metacity-2.34.13.tar.xz "

export Metacity_2_34_13_C30_packname="metacity-2.34.13.tar.xz"

export Metacity_2_34_13_C30_required_or_recommended="GTK_2_24_17_C25 libcanberra_0_30_C38 yelp_xsl_3_6_1_C30 Zenity_3_6_0_C30 startup_notification_0_12_C25 notification_daemon_0_7_6_C25 polkit_gnome_0_105_C30 "

network_manager_applet_0_9_8_0_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/NetworkManager \
            --disable-migration \
            --disable-static &&
make
make install
}

export network_manager_applet_0_9_8_0_C30_download="http://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9/network-manager-applet-0.9.8.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9/network-manager-applet-0.9.8.0.tar.xz "

export network_manager_applet_0_9_8_0_C30_packname="network-manager-applet-0.9.8.0.tar.xz"

export network_manager_applet_0_9_8_0_C30_required_or_recommended="GTK_3_6_4_C25 ISO_Codes_3_40_C9 libgnome_keyring_3_6_0_C30 libnotify_0_7_5_C25 NetworkManager_0_9_8_0_C16 polkit_gnome_0_105_C30 gnome_bluetooth_3_6_1_C30 "

Caribou_0_4_4_2_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/caribou \
            --disable-gtk2-module \
            --disable-static &&
make
make install
}

export Caribou_0_4_4_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/caribou/0.4/caribou-0.4.4.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/caribou/0.4/caribou-0.4.4.2.tar.xz "

export Caribou_0_4_4_2_C30_packname="caribou-0.4.4.2.tar.xz"

export Caribou_0_4_4_2_C30_required_or_recommended="Clutter_1_12_2_C25 GTK_3_6_4_C25 libgee_0_6_7_C30 libxklavier_5_3_C25 PyGObject_3_4_2_C13 Vala_0_18_1_C13 "

Mutter_3_6_3_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Mutter_3_6_3_C30_download="http://ftp.gnome.org/pub/gnome/sources/mutter/3.6/mutter-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/mutter/3.6/mutter-3.6.3.tar.xz "

export Mutter_3_6_3_C30_packname="mutter-3.6.3.tar.xz"

export Mutter_3_6_3_C30_required_or_recommended="Clutter_1_12_2_C25 gsettings_desktop_schemas_3_6_1_C30 GTK_3_6_4_C25 Zenity_3_6_0_C30 libcanberra_0_30_C38 gobject_introspection_1_34_2_C9 startup_notification_0_12_C25 "

gnome_shell_3_6_3_1_C30(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/gnome-shell &&
make
make install
}

export gnome_shell_3_6_3_1_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-shell/3.6/gnome-shell-3.6.3.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-shell/3.6/gnome-shell-3.6.3.1.tar.xz "

export gnome_shell_3_6_3_1_C30_packname="gnome-shell-3.6.3.1.tar.xz"

export gnome_shell_3_6_3_1_C30_required_or_recommended="evolution_data_server_3_6_4_C30 Gcr_3_6_2_C30 Gjs_1_34_0_C30 gnome_menus_3_6_2_C30 gnome_settings_daemon_3_6_4_C30 gst_plugins_base_1_0_6_C38 JSON_GLib_0_15_2_C9 libcroco_0_6_8_C9 libgnome_keyring_3_6_0_C30 Mutter_3_6_3_C30 NetworkManager_0_9_8_0_C16 telepathy_logger_0_8_0_C9 gnome_bluetooth_3_6_1_C30 AccountsService_0_6_30_C30 Caribou_0_4_4_2_C30 DConf_0_14_1_C30 gnome_icon_theme_3_6_2_C30 gnome_icon_theme_symbolic_3_6_2_C30 telepathy_mission_control_5_14_0_C9 "

gnome_session_3_6_2_C30(){

./configure --prefix=/usr --libexecdir=/usr/lib/gnome-session &&
make
make install
cat >> ~/.xinitrc << "EOF"
exec ck-launch-session dbus-launch --exit-with-session gnome-session
EOF

}

export gnome_session_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-session/3.6/gnome-session-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-session/3.6/gnome-session-3.6.2.tar.xz "

export gnome_session_3_6_2_C30_packname="gnome-session-3.6.2.tar.xz"

export gnome_session_3_6_2_C30_required_or_recommended="GConf_3_2_6_C30 GTK_3_6_4_C25 JSON_GLib_0_15_2_C9 UPower_0_9_20_C12 ConsoleKit_0_4_6_C4 "

gnome_user_docs_3_6_2_C30(){

./configure --prefix=/usr &&
make
make install
}

export gnome_user_docs_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gnome-user-docs/3.6/gnome-user-docs-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-user-docs/3.6/gnome-user-docs-3.6.2.tar.xz "

export gnome_user_docs_3_6_2_C30_packname="gnome-user-docs-3.6.2.tar.xz"

export gnome_user_docs_3_6_2_C30_required_or_recommended="yelp_xsl_3_6_1_C30 "

Yelp_3_6_2_C30(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Yelp_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/yelp/3.6/yelp-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/yelp/3.6/yelp-3.6.2.tar.xz "

export Yelp_3_6_2_C30_packname="yelp-3.6.2.tar.xz"

export Yelp_3_6_2_C30_required_or_recommended="WebKitGTK_1_10_2_C25 yelp_xsl_3_6_1_C30 "

GDM_3_6_2_C30(){

groupadd -g 21 gdm &&
useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
        -g gdm -s /bin/false gdm &&
usermod -a -G audio gdm &&
usermod -a -G video gdm
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib/gdm \
            --with-initial-vt=7 \
            --with-at-spi-registryd-directory=/usr/lib/at-spi2-core \
            --with-authentication-agent-directory=/usr/lib/polkit-gnome \
            --with-check-accelerated-directory=/usr/lib/gnome-session \
            --with-consolekit-directory=/usr/lib/ConsoleKit \
            --disable-static &&
make
make install &&
chown -R -v gdm:gdm /var/lib/gdm /var/cache/gdm /var/log/gdm
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-gdm
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
sed -i 's/id:3:initdefault:/id:5:initdefault:/' \
    /etc/inittab
}

export GDM_3_6_2_C30_download="http://ftp.gnome.org/pub/gnome/sources/gdm/3.6/gdm-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gdm/3.6/gdm-3.6.2.tar.xz "

export GDM_3_6_2_C30_packname="gdm-3.6.2.tar.xz"

export GDM_3_6_2_C30_required_or_recommended="AccountsService_0_6_30_C30 DConf_0_14_1_C30 libcanberra_0_30_C38 Linux_PAM_1_1_6_C4 NSS_3_14_3_C4 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 ISO_Codes_3_40_C9 UPower_0_9_20_C12 ConsoleKit_0_4_6_C4 gnome_session_3_6_2_C30 gnome_shell_3_6_3_1_C30 "

export C30_GNOMECorePackages="dbus_python_1_1_1_C30 desktop_file_utils_0_21_C30 shared_mime_info_1_1_C30 AccountsService_0_6_30_C30 polkit_gnome_0_105_C30 gnome_doc_utils_0_20_10_C30 yelp_xsl_3_6_1_C30 libgnome_keyring_3_6_0_C30 libsecret_0_14_C30 gsettings_desktop_schemas_3_6_1_C30 DConf_0_14_1_C30 GConf_3_2_6_C30 Gcr_3_6_2_C30 libgee_0_6_7_C30 libgweather_3_6_2_C30 libwnck_3_4_4_C30 libgnomekbd_3_6_0_C30 libgtop_2_28_4_C30 libwacom_0_6_1_C30 gnome_online_accounts_3_6_2_C30 libgdata_0_13_2_C30 evolution_data_server_3_6_4_C30 libzeitgeist_0_3_18_C30 Folks_0_8_0_C30 gnome_js_common_0_1_2_C30 Gjs_1_34_0_C30 Seed_3_2_0_C30 libpeas_1_6_2_C30 gtksourceview_3_6_2_C30 GtkHTML_4_6_4_C30 totem_pl_parser_3_4_3_C30 VTE_0_34_2_C30 gnome_backgrounds_3_6_1_C30 gnome_icon_theme_3_6_2_C30 gnome_icon_theme_extras_3_6_2_C30 gnome_icon_theme_symbolic_3_6_2_C30 gnome_themes_standard_3_6_5_C30 gnome_video_effects_0_4_0_C30 gnome_desktop_3_6_2_C30 gnome_keyring_3_6_3_C30 gnome_menus_3_6_2_C30 gnome_panel_3_6_2_C30 Gvfs_1_14_2_C30 Nautilus_3_6_3_C30 Nautilus_Sendto_3_6_1_C30 gnome_screensaver_3_6_1_C30 gnome_power_manager_3_6_0_C30 gnome_bluetooth_3_6_1_C30 gnome_user_share_3_0_4_C30 gnome_settings_daemon_3_6_4_C30 gnome_control_center_3_6_3_C30 gnome_terminal_3_6_1_C30 Zenity_3_6_0_C30 Metacity_2_34_13_C30 network_manager_applet_0_9_8_0_C30 Caribou_0_4_4_2_C30 Mutter_3_6_3_C30 gnome_shell_3_6_3_1_C30 gnome_session_3_6_2_C30 gnome_user_docs_3_6_2_C30 Yelp_3_6_2_C30 GDM_3_6_2_C30 "


Aisleriot_3_6_2_C31(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib &&
make
make install
}

export Aisleriot_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/aisleriot/3.6/aisleriot-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/aisleriot/3.6/aisleriot-3.6.2.tar.xz "

export Aisleriot_3_6_2_C31_packname="aisleriot-3.6.2.tar.xz"

export Aisleriot_3_6_2_C31_required_or_recommended="GConf_3_2_6_C30 GTK_3_6_4_C25 Guile_2_0_7_C13 libcanberra_0_30_C38 librsvg_2_36_4_C10 yelp_xsl_3_6_1_C30 "

Alacarte_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export Alacarte_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/alacarte/3.6/alacarte-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/alacarte/3.6/alacarte-3.6.1.tar.xz "

export Alacarte_3_6_1_C31_packname="alacarte-3.6.1.tar.xz"

export Alacarte_3_6_1_C31_required_or_recommended="gnome_menus_3_6_2_C30 PyGObject_3_4_2_C13 "

Baobab_3_6_4_C31(){

./configure --prefix=/usr &&
make
make install
}

export Baobab_3_6_4_C31_download="http://ftp.gnome.org/pub/gnome/sources/baobab/3.6/baobab-3.6.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/baobab/3.6/baobab-3.6.4.tar.xz "

export Baobab_3_6_4_C31_packname="baobab-3.6.4.tar.xz"

export Baobab_3_6_4_C31_required_or_recommended="GTK_3_6_4_C25 Vala_0_18_1_C13 yelp_xsl_3_6_1_C30 "

Brasero_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export Brasero_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/brasero/3.6/brasero-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/brasero/3.6/brasero-3.6.1.tar.xz "

export Brasero_3_6_1_C31_packname="brasero-3.6.1.tar.xz"

export Brasero_3_6_1_C31_required_or_recommended="gst_plugins_base_1_0_6_C38 libcanberra_0_30_C38 libnotify_0_7_5_C25 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 libburn_1_2_8_C41 libisofs_1_2_8_C41 Nautilus_3_6_3_C30 totem_pl_parser_3_4_3_C30 dvd_rw_tools_7_1_C41 Gvfs_1_14_2_C30 "

Cheese_3_6_2_C31(){

./configure --prefix=/usr &&
make
make install
}

export Cheese_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/cheese/3.6/cheese-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/cheese/3.6/cheese-3.6.2.tar.xz "

export Cheese_3_6_2_C31_packname="cheese-3.6.2.tar.xz"

export Cheese_3_6_2_C31_required_or_recommended="clutter_gst_2_0_2_C25 clutter_gtk_1_4_2_C25 gnome_desktop_3_6_2_C30 gnome_video_effects_0_4_0_C30 gst_plugins_bad_1_0_6_C38 gst_plugins_good_1_0_6_C38 libgee_0_6_7_C30 libcanberra_0_30_C38 librsvg_2_36_4_C10 Udev_Installed_LFS_Version_C12 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 Nautilus_Sendto_3_6_1_C30 Vala_0_18_1_C13 "

Empathy_3_6_3_C31(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/empathy \
            --disable-static &&
make
make install
}

export Empathy_3_6_3_C31_download="http://ftp.gnome.org/pub/gnome/sources/empathy/3.6/empathy-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/empathy/3.6/empathy-3.6.3.tar.xz "

export Empathy_3_6_3_C31_packname="empathy-3.6.3.tar.xz"

export Empathy_3_6_3_C31_required_or_recommended="clutter_gst_2_0_2_C25 clutter_gtk_1_4_2_C25 evolution_data_server_3_6_4_C30 Folks_0_8_0_C30 libcanberra_0_30_C38 PulseAudio_3_0_C38 telepathy_farstream_0_6_0_C9 telepathy_logger_0_8_0_C9 telepathy_mission_control_5_14_0_C9 yelp_xsl_3_6_1_C30 enchant_1_6_0_C9 ISO_Codes_3_40_C9 Nautilus_Sendto_3_6_1_C30 Udev_Installed_LFS_Version_C12 "

EOG_3_6_2_C31(){

./configure --prefix=/usr &&
make
make install
}

export EOG_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/eog/3.6/eog-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/eog/3.6/eog-3.6.2.tar.xz "

export EOG_3_6_2_C31_packname="eog-3.6.2.tar.xz"

export EOG_3_6_2_C31_required_or_recommended="gnome_desktop_3_6_2_C30 gnome_icon_theme_3_6_2_C30 libpeas_1_6_2_C30 shared_mime_info_1_1_C25 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 librsvg_2_36_4_C10 "

Epiphany_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export Epiphany_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/epiphany/3.6/epiphany-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/epiphany/3.6/epiphany-3.6.1.tar.xz "

export Epiphany_3_6_1_C31_packname="epiphany-3.6.1.tar.xz"

export Epiphany_3_6_1_C31_required_or_recommended="Avahi_0_6_31_C16 Gcr_3_6_2_C30 gnome_desktop_3_6_2_C30 ISO_Codes_3_40_C9 libgnome_keyring_3_6_0_C30 libnotify_0_7_5_C25 WebKitGTK_1_10_2_C25 gobject_introspection_1_34_2_C9 NSS_3_14_3_C4 "

Epiphany_Extensions_3_6_0_C31(){

./configure --prefix=/usr &&
make
make install
}

export Epiphany_Extensions_3_6_0_C31_download="http://ftp.gnome.org/pub/gnome/sources/epiphany-extensions/3.6/epiphany-extensions-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/epiphany-extensions/3.6/epiphany-extensions-3.6.0.tar.xz "

export Epiphany_Extensions_3_6_0_C31_packname="epiphany-extensions-3.6.0.tar.xz"

export Epiphany_Extensions_3_6_0_C31_required_or_recommended="Epiphany_3_6_1_C31 gnome_doc_utils_0_20_10_C30 D_Bus_GLib_Bindings_C12 OpenSP_1_5_2_C44 Rarian_0_8_1_C11 "

Evince_3_6_1_C31(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/evince \
            --enable-introspection \
            --disable-static &&
make
make install
}

export Evince_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/evince/3.6/evince-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/evince/3.6/evince-3.6.1.tar.xz "

export Evince_3_6_1_C31_packname="evince-3.6.1.tar.xz"

export Evince_3_6_1_C31_required_or_recommended="gnome_icon_theme_3_6_2_C30 gsettings_desktop_schemas_3_6_1_C30 GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 libgnome_keyring_3_6_0_C30 Nautilus_3_6_3_C30 Poppler_0_22_2_C10 "

Evolution_3_6_4_C31(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib \
            --disable-pst-import &&
make
make install
}

export Evolution_3_6_4_C31_download="http://ftp.gnome.org/pub/gnome/sources/evolution/3.6/evolution-3.6.4.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/evolution/3.6/evolution-3.6.4.tar.xz "

export Evolution_3_6_4_C31_packname="evolution-3.6.4.tar.xz"

export Evolution_3_6_4_C31_required_or_recommended="evolution_data_server_3_6_4_C30 gnome_desktop_3_6_2_C30 gnome_icon_theme_3_6_2_C30 GtkHTML_4_6_4_C30 shared_mime_info_1_1_C25 GStreamer_1_0_6_C38 libcanberra_0_30_C38 libgweather_3_6_2_C30 "

File_Roller_3_6_3_C31(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib \
            --disable-packagekit \
            --disable-static &&
make
make install
}

export File_Roller_3_6_3_C31_download="http://ftp.gnome.org/pub/gnome/sources/file-roller/3.6/file-roller-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/file-roller/3.6/file-roller-3.6.3.tar.xz "

export File_Roller_3_6_3_C31_packname="file-roller-3.6.3.tar.xz"

export File_Roller_3_6_3_C31_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 JSON_GLib_0_15_2_C9 libarchive_3_1_2_C12 libnotify_0_7_5_C25 Nautilus_3_6_3_C30 "

Gcalctool_6_6_2_C31(){

./configure --prefix=/usr &&
make
make install
}

export Gcalctool_6_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/gcalctool/6.6/gcalctool-6.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gcalctool/6.6/gcalctool-6.6.2.tar.xz "

export Gcalctool_6_6_2_C31_packname="gcalctool-6.6.2.tar.xz"

export Gcalctool_6_6_2_C31_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 "

Gedit_3_6_2_C31(){

./configure --prefix=/usr --libexecdir=/usr/lib &&
make
make install
}

export Gedit_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/gedit/3.6/gedit-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gedit/3.6/gedit-3.6.2.tar.xz "

export Gedit_3_6_2_C31_packname="gedit-3.6.2.tar.xz"

export Gedit_3_6_2_C31_required_or_recommended="gsettings_desktop_schemas_3_6_1_C30 gtksourceview_3_6_2_C30 libpeas_1_6_2_C30 yelp_xsl_3_6_1_C30 enchant_1_6_0_C9 ISO_Codes_3_40_C9 libsoup_2_40_3_C17 libzeitgeist_0_3_18_C30 PyGObject_3_4_2_C13 "

gnome_color_manager_3_6_1_C31(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/gnome-color-manager \
            --disable-packagekit &&
make
make install
}

export gnome_color_manager_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-color-manager/3.6/gnome-color-manager-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-color-manager/3.6/gnome-color-manager-3.6.1.tar.xz "

export gnome_color_manager_3_6_1_C31_packname="gnome-color-manager-3.6.1.tar.xz"

export gnome_color_manager_3_6_1_C31_required_or_recommended="colord_gtk_0_1_25_C25 gnome_desktop_3_6_2_C30 Little_CMS_2_4_C10 libcanberra_0_30_C38 Exiv2_0_23_C10 libexif_0_6_21_C10 VTE_0_34_2_C30 "

gnome_contacts_3_6_2_C31(){

./configure --prefix=/usr --libexecdir=/usr/lib/gnome-contacts &&
make
make install
}

export gnome_contacts_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-contacts/3.6/gnome-contacts-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-contacts/3.6/gnome-contacts-3.6.2.tar.xz "

export gnome_contacts_3_6_2_C31_packname="gnome-contacts-3.6.2.tar.xz"

export gnome_contacts_3_6_2_C31_required_or_recommended="evolution_data_server_3_6_4_C30 Folks_0_8_0_C30 gnome_desktop_3_6_2_C30 gnome_online_accounts_3_6_2_C30 Vala_0_18_1_C13 telepathy_mission_control_5_14_0_C9 "

gnome_dictionary_3_6_0_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_dictionary_3_6_0_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-dictionary/3.6/gnome-dictionary-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-dictionary/3.6/gnome-dictionary-3.6.0.tar.xz "

export gnome_dictionary_3_6_0_C31_packname="gnome-dictionary-3.6.0.tar.xz"

export gnome_dictionary_3_6_0_C31_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 "

gnome_disk_utility_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_disk_utility_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-disk-utility/3.6/gnome-disk-utility-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-disk-utility/3.6/gnome-disk-utility-3.6.1.tar.xz "

export gnome_disk_utility_3_6_1_C31_packname="gnome-disk-utility-3.6.1.tar.xz"

export gnome_disk_utility_3_6_1_C31_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 libsecret_0_14_C30 libpwquality_1_2_1_C4 UDisks_2_1_0_C12 "

gnome_games_3_6_1_C31(){

install -v -m755 -d /var/games &&
groupadd -g 60 games &&
useradd -c "Games High Score Owner" -d /var/games \
        -g games -s /bin/false -u 60 games &&
chown -R games:games /var/games
./configure --prefix=/usr --localstatedir=/var &&
make
make install
}

export gnome_games_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-games/3.6/gnome-games-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-games/3.6/gnome-games-3.6.1.tar.xz "

export gnome_games_3_6_1_C31_packname="gnome-games-3.6.1.tar.xz"

export gnome_games_3_6_1_C31_required_or_recommended="clutter_gtk_1_4_2_C25 libcanberra_0_30_C38 librsvg_2_36_4_C10 PyGObject_3_4_2_C13 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

gnome_nettool_3_2_0_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_nettool_3_2_0_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-nettool/3.2/gnome-nettool-3.2.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-nettool/3.2/gnome-nettool-3.2.0.tar.xz "

export gnome_nettool_3_2_0_C31_packname="gnome-nettool-3.2.0.tar.xz"

export gnome_nettool_3_2_0_C31_required_or_recommended="gnome_doc_utils_0_20_10_C30 GTK_3_6_4_C25 libgtop_2_28_4_C30 Rarian_0_8_1_C11 "

gnome_screenshot_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_screenshot_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-screenshot/3.6/gnome-screenshot-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-screenshot/3.6/gnome-screenshot-3.6.1.tar.xz "

export gnome_screenshot_3_6_1_C31_packname="gnome-screenshot-3.6.1.tar.xz"

export gnome_screenshot_3_6_1_C31_required_or_recommended="GTK_3_6_4_C25 libcanberra_0_30_C38 "

gnome_search_tool_3_6_0_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_search_tool_3_6_0_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-search-tool/3.6/gnome-search-tool-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-search-tool/3.6/gnome-search-tool-3.6.0.tar.xz "

export gnome_search_tool_3_6_0_C31_packname="gnome-search-tool-3.6.0.tar.xz"

export gnome_search_tool_3_6_0_C31_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 "

gnome_system_log_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_system_log_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-system-log/3.6/gnome-system-log-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-system-log/3.6/gnome-system-log-3.6.1.tar.xz "

export gnome_system_log_3_6_1_C31_packname="gnome-system-log-3.6.1.tar.xz"

export gnome_system_log_3_6_1_C31_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 "

gnome_system_monitor_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_system_monitor_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-system-monitor/3.6/gnome-system-monitor-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-system-monitor/3.6/gnome-system-monitor-3.6.1.tar.xz "

export gnome_system_monitor_3_6_1_C31_packname="gnome-system-monitor-3.6.1.tar.xz"

export gnome_system_monitor_3_6_1_C31_required_or_recommended="gnome_icon_theme_3_6_2_C30 Gtkmm_3_6_0_C25 libgtop_2_28_4_C30 librsvg_2_36_4_C10 libwnck_3_4_4_C30 yelp_xsl_3_6_1_C30 "

gnome_tweak_tool_3_6_1_C31(){

./configure --prefix=/usr &&
make
make install
}

export gnome_tweak_tool_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gnome-tweak-tool/3.6/gnome-tweak-tool-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnome-tweak-tool/3.6/gnome-tweak-tool-3.6.1.tar.xz "

export gnome_tweak_tool_3_6_1_C31_packname="gnome-tweak-tool-3.6.1.tar.xz"

export gnome_tweak_tool_3_6_1_C31_required_or_recommended="GConf_3_2_6_C30 gsettings_desktop_schemas_3_6_1_C30 PyGObject_3_4_2_C13 "

Gucharmap_3_6_1_C31(){

./configure --prefix=/usr --enable-vala &&
make
make install
}

export Gucharmap_3_6_1_C31_download="http://ftp.gnome.org/pub/gnome/sources/gucharmap/3.6/gucharmap-3.6.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gucharmap/3.6/gucharmap-3.6.1.tar.xz "

export Gucharmap_3_6_1_C31_packname="gucharmap-3.6.1.tar.xz"

export Gucharmap_3_6_1_C31_required_or_recommended="GTK_3_6_4_C25 yelp_xsl_3_6_1_C30 gobject_introspection_1_34_2_C9 Vala_0_18_1_C13 "

Mousetweaks_3_6_0_C31(){

./configure --prefix=/usr &&
make
make install
}

export Mousetweaks_3_6_0_C31_download="http://ftp.gnome.org/pub/gnome/sources/mousetweaks/3.6/mousetweaks-3.6.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/mousetweaks/3.6/mousetweaks-3.6.0.tar.xz "

export Mousetweaks_3_6_0_C31_packname="mousetweaks-3.6.0.tar.xz"

export Mousetweaks_3_6_0_C31_required_or_recommended="gsettings_desktop_schemas_3_6_1_C30 GTK_3_6_4_C25 "

Orca_3_6_3_C31(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export Orca_3_6_3_C31_download="http://ftp.gnome.org/pub/gnome/sources/orca/3.6/orca-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/orca/3.6/orca-3.6.3.tar.xz "

export Orca_3_6_3_C31_packname="orca-3.6.3.tar.xz"

export Orca_3_6_3_C31_required_or_recommended="GTK_3_6_4_C25 PyGObject_3_4_2_C13 yelp_xsl_3_6_1_C30 "

Seahorse_3_6_3_C31(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Seahorse_3_6_3_C31_download="http://ftp.gnome.org/pub/gnome/sources/seahorse/3.6/seahorse-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/seahorse/3.6/seahorse-3.6.3.tar.xz "

export Seahorse_3_6_3_C31_packname="seahorse-3.6.3.tar.xz"

export Seahorse_3_6_3_C31_required_or_recommended="Gcr_3_6_2_C30 GPGME_1_4_0_C4 GnuPG_1_4_13_C4 libsecret_0_14_C30 yelp_xsl_3_6_1_C30 libsoup_2_40_3_C17 "

Sound_Juicer_3_4_0_C31(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export Sound_Juicer_3_4_0_C31_download="http://ftp.gnome.org/pub/gnome/sources/sound-juicer/3.4/sound-juicer-3.4.0.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/sound-juicer/3.4/sound-juicer-3.4.0.tar.xz "

export Sound_Juicer_3_4_0_C31_packname="sound-juicer-3.4.0.tar.xz"

export Sound_Juicer_3_4_0_C31_required_or_recommended="GConf_3_2_6_C30 gnome_doc_utils_0_20_10_C30 gst_plugins_base_0_10_36_C38 GTK_3_6_4_C25 libcanberra_0_30_C38 libmusicbrainz_3_0_3_C38 Rarian_0_8_1_C11 gst_plugins_good_0_10_31_C38 gst_plugins_ugly_0_10_19_C38 "

Totem_3_6_3_C31(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/totem \
            --disable-static &&
make
make install
}

export Totem_3_6_3_C31_download="http://ftp.gnome.org/pub/gnome/sources/totem/3.6/totem-3.6.3.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/totem/3.6/totem-3.6.3.tar.xz "

export Totem_3_6_3_C31_packname="totem-3.6.3.tar.xz"

export Totem_3_6_3_C31_required_or_recommended="clutter_gst_2_0_2_C25 clutter_gtk_1_4_2_C25 gnome_doc_utils_0_20_10_C30 gnome_icon_theme_3_6_2_C30 gst_plugins_bad_1_0_6_C38 gst_plugins_good_1_0_6_C38 libpeas_1_6_2_C30 totem_pl_parser_3_4_3_C30 D_Bus_GLib_Bindings_C12 gobject_introspection_1_34_2_C9 libzeitgeist_0_3_18_C30 Nautilus_3_6_3_C30 PyGObject_3_4_2_C13 Rarian_0_8_1_C11 Vala_0_18_1_C13 gst_libav_1_0_6_C38 gst_plugins_ugly_1_0_6_C38 libdvdcss_1_2_13_C38 "

Vinagre_3_6_2_C31(){

./configure --prefix=/usr &&
make
make install
}

export Vinagre_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/vinagre/3.6/vinagre-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/vinagre/3.6/vinagre-3.6.2.tar.xz "

export Vinagre_3_6_2_C31_packname="vinagre-3.6.2.tar.xz"

export Vinagre_3_6_2_C31_required_or_recommended="gnome_icon_theme_3_6_2_C30 gtk_vnc_0_5_2_C25 libsecret_0_14_C30 yelp_xsl_3_6_1_C30 "

Vino_3_6_2_C31(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/vino &&
make
make install
}

export Vino_3_6_2_C31_download="http://ftp.gnome.org/pub/gnome/sources/vino/3.6/vino-3.6.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/vino/3.6/vino-3.6.2.tar.xz "

export Vino_3_6_2_C31_packname="vino-3.6.2.tar.xz"

export Vino_3_6_2_C31_required_or_recommended="GTK_3_6_4_C25 Intltool_0_50_2_C11 libsoup_2_40_3_C17 libnotify_0_7_5_C25 libsecret_0_14_C30 NetworkManager_0_9_8_0_C16 telepathy_glib_0_20_1_C9 "

export C31_GNOMEApplications="Aisleriot_3_6_2_C31 Alacarte_3_6_1_C31 Baobab_3_6_4_C31 Brasero_3_6_1_C31 Cheese_3_6_2_C31 Empathy_3_6_3_C31 EOG_3_6_2_C31 Epiphany_3_6_1_C31 Epiphany_Extensions_3_6_0_C31 Evince_3_6_1_C31 Evolution_3_6_4_C31 File_Roller_3_6_3_C31 Gcalctool_6_6_2_C31 Gedit_3_6_2_C31 gnome_color_manager_3_6_1_C31 gnome_contacts_3_6_2_C31 gnome_dictionary_3_6_0_C31 gnome_disk_utility_3_6_1_C31 gnome_games_3_6_1_C31 gnome_nettool_3_2_0_C31 gnome_screenshot_3_6_1_C31 gnome_search_tool_3_6_0_C31 gnome_system_log_3_6_1_C31 gnome_system_monitor_3_6_1_C31 gnome_tweak_tool_3_6_1_C31 Gucharmap_3_6_1_C31 Mousetweaks_3_6_0_C31 Orca_3_6_3_C31 Seahorse_3_6_3_C31 Sound_Juicer_3_4_0_C31 Totem_3_6_3_C31 Vinagre_3_6_2_C31 Vino_3_6_2_C31 "


ORBit2_2_14_19_C32(){

./configure --prefix=/usr \
            --sysconfdir=/etc/gnome/2.30.2 &&
make
make install
}

export ORBit2_2_14_19_C32_download="http://ftp.gnome.org/pub/gnome/sources/ORBit2/2.14/ORBit2-2.14.19.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/ORBit2/2.14/ORBit2-2.14.19.tar.bz2 "

export ORBit2_2_14_19_C32_packname="ORBit2-2.14.19.tar.bz2"

export ORBit2_2_14_19_C32_required_or_recommended="LibIDL_0_8_14_C9 "

libbonobo_2_32_1_C32(){

ORBit_prefix=$(pkg-config --variable=prefix ORBit-2.0) &&

./configure --prefix=$ORBit_prefix                     \
            --sysconfdir=/etc/gnome/2.30.2           \
            --libexecdir=$ORBit_prefix/lib/bonobo-2.0  \
            --mandir=$ORBit_prefix/share/man           &&

unset ORBit_prefix                                     &&
make
make install
}

export libbonobo_2_32_1_C32_download="http://ftp.gnome.org/pub/gnome/sources/libbonobo/2.32/libbonobo-2.32.1.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libbonobo/2.32/libbonobo-2.32.1.tar.bz2 "

export libbonobo_2_32_1_C32_packname="libbonobo-2.32.1.tar.bz2"

export libbonobo_2_32_1_C32_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 libxml2_2_9_0_C9 ORBit2_2_14_19_C32 Popt_1_16_C9 "

gnome_mime_data_2_18_0_C32(){

ORBit_prefix=$(pkg-config --variable=prefix ORBit-2.0) &&

./configure --prefix=$ORBit_prefix            \
            --sysconfdir=/etc/gnome/2.30.2    \
            --mandir=$$ORBit_prefix/share/man &&
make
make install &&
install -v -m644 -D man/gnome-vfs-mime.5 \
                    $ORBit_prefix/share/man/man5/gnome-vfs-mime.5
}

export gnome_mime_data_2_18_0_C32_download="http://ftp.gnome.org/pub/gnome/sources/gnome-mime-data/2.18/gnome-mime-data-2.18.0.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/gnome-mime-data/2.18/gnome-mime-data-2.18.0.tar.bz2 "

export gnome_mime_data_2_18_0_C32_packname="gnome-mime-data-2.18.0.tar.bz2"

export gnome_mime_data_2_18_0_C32_required_or_recommended="XML_Parser_2_41_C13 "

gnome_vfs_2_24_4_C32(){

ORBit_prefix=$(pkg-config --variable=prefix ORBit-2.0)   &&

./configure --prefix=$ORBit_prefix                       \
            --sysconfdir=/etc/gnome/2.30.2               \
            --libexecdir=$ORBit_prefix/lib/gnome-vfs-2.0 &&
make
make install
}

export gnome_vfs_2_24_4_C32_download="http://ftp.gnome.org/pub/gnome/sources/gnome-vfs/2.24/gnome-vfs-2.24.4.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/gnome-vfs/2.24/gnome-vfs-2.24.4.tar.bz2 "

export gnome_vfs_2_24_4_C32_packname="gnome-vfs-2.24.4.tar.bz2"

export gnome_vfs_2_24_4_C32_required_or_recommended="D_Bus_GLib_Bindings_C12 GConf_3_2_6_C30 gnome_mime_data_2_18_0_C32 "

libgnome_2_32_1_C32(){

ORBit=$(pkg-config --variable=prefix ORBit-2.0) &&

./configure --prefix=$ORBit                \
            --sysconfdir=/etc/gnome/2.30.2 \
            --localstatedir=/var/lib       \
            --mandir=$ORBit/share/man &&
make
make install
}

export libgnome_2_32_1_C32_download="http://ftp.gnome.org/pub/gnome/sources/libgnome/2.32/libgnome-2.32.1.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libgnome/2.32/libgnome-2.32.1.tar.bz2 "

export libgnome_2_32_1_C32_packname="libgnome-2.32.1.tar.bz2"

export libgnome_2_32_1_C32_required_or_recommended="libbonobo_2_32_1_C32 gnome_vfs_2_24_4_C32 libcanberra_0_30_C38 "

libgnomecanvas_2_30_3_C32(){

./configure --prefix=$(pkg-config --variable=prefix ORBit-2.0) &&
make
make install
}

export libgnomecanvas_2_30_3_C32_download="http://ftp.gnome.org/pub/gnome/sources/libgnomecanvas/2.30/libgnomecanvas-2.30.3.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libgnomecanvas/2.30/libgnomecanvas-2.30.3.tar.bz2 "

export libgnomecanvas_2_30_3_C32_packname="libgnomecanvas-2.30.3.tar.bz2"

export libgnomecanvas_2_30_3_C32_required_or_recommended="GTK_2_24_17_C25 Intltool_0_50_2_C11 libart_lgpl_2_3_21_C10 "

LibBonoboUI_2_24_5_C32(){

./configure --prefix=$(pkg-config --variable=prefix ORBit-2.0) \
  --disable-static &&
make
make install &&

install -v -m755 -d $(pkg-config \
        --variable=prefix ORBit-2.0)/share/doc/libbonoboui-2.24.5 &&

install -v -m644 doc/*.{dtd,txt,xml,html} $(pkg-config \
        --variable=prefix ORBit-2.0)/share/doc/libbonoboui-2.24.5
echo export \
   LIBGLADE_MODULE_PATH=$(pkg-config --variable=prefix ORBit-2.0)/lib/libglade/2.0 \
   >> /etc/profile
}

export LibBonoboUI_2_24_5_C32_download="http://ftp.gnome.org/pub/gnome/sources/libbonoboui/2.24/libbonoboui-2.24.5.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libbonoboui/2.24/libbonoboui-2.24.5.tar.bz2 "

export LibBonoboUI_2_24_5_C32_packname="libbonoboui-2.24.5.tar.bz2"

export LibBonoboUI_2_24_5_C32_required_or_recommended="libglade_2_6_4_C9 libgnome_2_32_1_C32 libgnomecanvas_2_30_3_C32 "

libgnomeui_2_24_5_C32(){

./configure --prefix=$(pkg-config --variable=prefix ORBit-2.0) \
            --libexecdir=$(pkg-config \
            --variable=prefix ORBit-2.0)/lib/libgnomeui &&
make
make install
}

export libgnomeui_2_24_5_C32_download="http://ftp.gnome.org/pub/gnome/sources/libgnomeui/2.24/libgnomeui-2.24.5.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libgnomeui/2.24/libgnomeui-2.24.5.tar.bz2 "

export libgnomeui_2_24_5_C32_packname="libgnomeui-2.24.5.tar.bz2"

export libgnomeui_2_24_5_C32_required_or_recommended="LibBonoboUI_2_24_5_C32 libgnome_keyring_3_6_0_C30 Xorg_Libraries_C24 "

export C32_DeprecatedGNOMEPackages="ORBit2_2_14_19_C32 libbonobo_2_32_1_C32 gnome_mime_data_2_18_0_C32 gnome_vfs_2_24_4_C32 libgnome_2_32_1_C32 libgnomecanvas_2_30_3_C32 LibBonoboUI_2_24_5_C32 libgnomeui_2_24_5_C32 "


libxfce4util_4_10_0_C33(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libxfce4util_4_10_0_C33_download="http://archive.xfce.org/src/xfce/libxfce4util/4.10/libxfce4util-4.10.0.tar.bz2 "

export libxfce4util_4_10_0_C33_packname="libxfce4util-4.10.0.tar.bz2"

export libxfce4util_4_10_0_C33_required_or_recommended="GLib_2_34_3_C9 Intltool_0_50_2_C11 pkg_config_0_28_C13 "

Xfconf_4_10_0_C33(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Xfconf_4_10_0_C33_download="http://archive.xfce.org/src/xfce/xfconf/4.10/xfconf-4.10.0.tar.bz2 "

export Xfconf_4_10_0_C33_packname="xfconf-4.10.0.tar.bz2"

export Xfconf_4_10_0_C33_required_or_recommended="D_Bus_GLib_Bindings_C12 libxfce4util_4_10_0_C33 "

libxfce4ui_4_10_0_C33(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export libxfce4ui_4_10_0_C33_download="http://archive.xfce.org/src/xfce/libxfce4ui/4.10/libxfce4ui-4.10.0.tar.bz2 "

export libxfce4ui_4_10_0_C33_packname="libxfce4ui-4.10.0.tar.bz2"

export libxfce4ui_4_10_0_C33_required_or_recommended="GTK_2_24_17_C25 Xfconf_4_10_0_C33 startup_notification_0_12_C25 "

Exo_0_10_2_C33(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export Exo_0_10_2_C33_download="http://archive.xfce.org/src/xfce/exo/0.10/exo-0.10.2.tar.bz2 "

export Exo_0_10_2_C33_packname="exo-0.10.2.tar.bz2"

export Exo_0_10_2_C33_required_or_recommended="libxfce4ui_4_10_0_C33 libxfce4util_4_10_0_C33 URI_1_60_C13 "

Garcon_0_2_0_C33(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-static &&
make
make install
}

export Garcon_0_2_0_C33_download="http://archive.xfce.org/src/xfce/garcon/0.2/garcon-0.2.0.tar.bz2 "

export Garcon_0_2_0_C33_packname="garcon-0.2.0.tar.bz2"

export Garcon_0_2_0_C33_required_or_recommended="libxfce4util_4_10_0_C33 "

gtk_xfce_engine_3_0_1_C33(){

./configure --prefix=/usr &&
make
make install
}

export gtk_xfce_engine_3_0_1_C33_download="http://archive.xfce.org/src/xfce/gtk-xfce-engine/3.0/gtk-xfce-engine-3.0.1.tar.bz2 "

export gtk_xfce_engine_3_0_1_C33_packname="gtk-xfce-engine-3.0.1.tar.bz2"

export gtk_xfce_engine_3_0_1_C33_required_or_recommended="GTK_2_24_17_C25 GTK_3_6_4_C25 "

libwnck_2_30_7_C33(){

./configure --prefix=/usr \
            --disable-static \
            --program-suffix=-1 &&
make GETTEXT_PACKAGE=libwnck-1
make GETTEXT_PACKAGE=libwnck-1 install
}

export libwnck_2_30_7_C33_download="http://ftp.gnome.org/pub/gnome/sources/libwnck/2.30/libwnck-2.30.7.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/libwnck/2.30/libwnck-2.30.7.tar.xz "

export libwnck_2_30_7_C33_packname="libwnck-2.30.7.tar.xz"

export libwnck_2_30_7_C33_required_or_recommended="GTK_2_24_17_C25 Intltool_0_50_2_C11 startup_notification_0_12_C25 "

libxfcegui4_4_10_0_C33(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libxfcegui4_4_10_0_C33_download="http://archive.xfce.org/src/xfce/libxfcegui4/4.10/libxfcegui4-4.10.0.tar.bz2 "

export libxfcegui4_4_10_0_C33_packname="libxfcegui4-4.10.0.tar.bz2"

export libxfcegui4_4_10_0_C33_required_or_recommended="libglade_2_6_4_C9 libxfce4util_4_10_0_C33 "

xfce4_panel_4_10_0_C33(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/xfce4-panel-4.10.0 \
            --disable-static &&
make
make install
}

export xfce4_panel_4_10_0_C33_download="http://archive.xfce.org/src/xfce/xfce4-panel/4.10/xfce4-panel-4.10.0.tar.bz2 "

export xfce4_panel_4_10_0_C33_packname="xfce4-panel-4.10.0.tar.bz2"

export xfce4_panel_4_10_0_C33_required_or_recommended="Exo_0_10_2_C33 Garcon_0_2_0_C33 libwnck_2_30_7_C33 libxfce4ui_4_10_0_C33 "

Thunar_1_6_2_C33(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/Thunar-1.6.2 &&
make
make install
}

export Thunar_1_6_2_C33_download="http://archive.xfce.org/src/xfce/thunar/1.6/Thunar-1.6.2.tar.bz2 "

export Thunar_1_6_2_C33_packname="Thunar-1.6.2.tar.bz2"

export Thunar_1_6_2_C33_required_or_recommended="Exo_0_10_2_C33 libxfce4ui_4_10_0_C33 libnotify_0_7_5_C25 startup_notification_0_12_C25 Udev_Installed_LFS_Version_C12 xfce4_panel_4_10_0_C33 "

thunar_volman_0_8_0_C33(){

./configure --prefix=/usr &&
make
make install
}

export thunar_volman_0_8_0_C33_download="http://archive.xfce.org/src/xfce/thunar-volman/0.8/thunar-volman-0.8.0.tar.bz2 "

export thunar_volman_0_8_0_C33_packname="thunar-volman-0.8.0.tar.bz2"

export thunar_volman_0_8_0_C33_required_or_recommended="Exo_0_10_2_C33 libxfce4ui_4_10_0_C33 Udev_Installed_LFS_Version_C12 libnotify_0_7_5_C25 startup_notification_0_12_C25 "

Tumbler_0_1_27_C33(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export Tumbler_0_1_27_C33_download="http://archive.xfce.org/src/xfce/tumbler/0.1/tumbler-0.1.27.tar.bz2 "

export Tumbler_0_1_27_C33_packname="tumbler-0.1.27.tar.bz2"

export Tumbler_0_1_27_C33_required_or_recommended="D_Bus_GLib_Bindings_C12 Intltool_0_50_2_C11 "

xfce4_appfinder_4_10_0_C33(){

./configure --prefix=/usr &&
make
make install
}

export xfce4_appfinder_4_10_0_C33_download="http://archive.xfce.org/src/xfce/xfce4-appfinder/4.10/xfce4-appfinder-4.10.0.tar.bz2 "

export xfce4_appfinder_4_10_0_C33_packname="xfce4-appfinder-4.10.0.tar.bz2"

export xfce4_appfinder_4_10_0_C33_required_or_recommended="Garcon_0_2_0_C33 libxfce4ui_4_10_0_C33 "

xfce4_power_manager_1_2_0_C33(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make docdir=/usr/share/doc/xfce4-power-manager-1.2.0 \
     imagesdir=/usr/share/doc/xfce4-power-manager-1.2.0/images install
}

export xfce4_power_manager_1_2_0_C33_download="http://archive.xfce.org/src/xfce/xfce4-power-manager/1.2/xfce4-power-manager-1.2.0.tar.bz2 "

export xfce4_power_manager_1_2_0_C33_packname="xfce4-power-manager-1.2.0.tar.bz2"

export xfce4_power_manager_1_2_0_C33_required_or_recommended="libnotify_0_7_5_C25 UPower_0_9_20_C12 xfce4_panel_4_10_0_C33 "

xfce4_settings_4_10_0_C33(){

./configure --prefix=/usr --sysconfdir=/etc &&
make
make install
}

export xfce4_settings_4_10_0_C33_download="http://archive.xfce.org/src/xfce/xfce4-settings/4.10/xfce4-settings-4.10.0.tar.bz2 "

export xfce4_settings_4_10_0_C33_packname="xfce4-settings-4.10.0.tar.bz2"

export xfce4_settings_4_10_0_C33_required_or_recommended="Exo_0_10_2_C33 libxfce4ui_4_10_0_C33 libnotify_0_7_5_C25 libxklavier_5_3_C25 "

Xfdesktop_4_10_2_C33(){

./configure --prefix=/usr &&
make
make install
}

export Xfdesktop_4_10_2_C33_download="http://archive.xfce.org/src/xfce/xfdesktop/4.10/xfdesktop-4.10.2.tar.bz2 "

export Xfdesktop_4_10_2_C33_packname="xfdesktop-4.10.2.tar.bz2"

export Xfdesktop_4_10_2_C33_required_or_recommended="Exo_0_10_2_C33 libwnck_2_30_7_C33 libxfce4ui_4_10_0_C33 libnotify_0_7_5_C25 startup_notification_0_12_C25 Thunar_1_6_2_C33 "

Xfwm4_4_10_0_C33(){

./configure --prefix=/usr &&
make
make install
}

export Xfwm4_4_10_0_C33_download="http://archive.xfce.org/src/xfce/xfwm4/4.10/xfwm4-4.10.0.tar.bz2 "

export Xfwm4_4_10_0_C33_packname="xfwm4-4.10.0.tar.bz2"

export Xfwm4_4_10_0_C33_required_or_recommended="libwnck_2_30_7_C33 libxfce4ui_4_10_0_C33 libxfce4util_4_10_0_C33 startup_notification_0_12_C25 "

xfce4_session_4_10_0_C33(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/xfce4-session-4.10.0 \
            --disable-static &&
make
make install
echo USERNAME ${HOSTNAME} = NOPASSWD: /usr/lib/xfce4/session/xfsm-shutdown-helper \
     >> /etc/sudoers

}

export xfce4_session_4_10_0_C33_download="http://archive.xfce.org/src/xfce/xfce4-session/4.10/xfce4-session-4.10.0.tar.bz2 "

export xfce4_session_4_10_0_C33_packname="xfce4-session-4.10.0.tar.bz2"

export xfce4_session_4_10_0_C33_required_or_recommended="libwnck_2_30_7_C33 libxfce4ui_4_10_0_C33 Which_2_20_and_Alternatives_C12 "

export C33_XfceDesktop="libxfce4util_4_10_0_C33 Xfconf_4_10_0_C33 libxfce4ui_4_10_0_C33 Exo_0_10_2_C33 Garcon_0_2_0_C33 gtk_xfce_engine_3_0_1_C33 libwnck_2_30_7_C33 libxfcegui4_4_10_0_C33 xfce4_panel_4_10_0_C33 Thunar_1_6_2_C33 thunar_volman_0_8_0_C33 Tumbler_0_1_27_C33 xfce4_appfinder_4_10_0_C33 xfce4_power_manager_1_2_0_C33 xfce4_settings_4_10_0_C33 Xfdesktop_4_10_2_C33 Xfwm4_4_10_0_C33 xfce4_session_4_10_0_C33 "


Midori_0_4_9_C34(){

./configure --prefix=/usr --docdir=/usr/share/doc/midori-0.4.9 &&
make
make install
}

export Midori_0_4_9_C34_download="http://archive.xfce.org/src/apps/midori/0.4/midori-0.4.9.tar.bz2 "

export Midori_0_4_9_C34_packname="midori-0.4.9.tar.bz2"

export Midori_0_4_9_C34_required_or_recommended="WebKitGTK_1_10_2_C25 WebKitGTK_1_10_2_C25 Vala_0_18_1_C13 libnotify_0_7_5_C25 librsvg_2_36_4_C10 "

Parole_0_5_0_C34(){

./configure --prefix=/usr &&
make
make install
}

export Parole_0_5_0_C34_download="http://archive.xfce.org/src/apps/parole/0.5/parole-0.5.0.tar.bz2 "

export Parole_0_5_0_C34_packname="parole-0.5.0.tar.bz2"

export Parole_0_5_0_C34_required_or_recommended="gst_plugins_base_0_10_36_C38 libxfce4ui_4_10_0_C33 libnotify_0_7_5_C25 Taglib_1_8_C38 "

gtksourceview_2_10_5_C34(){

./configure --prefix=/usr &&
make
make install
}

export gtksourceview_2_10_5_C34_download="http://ftp.gnome.org/pub/gnome/sources/gtksourceview/2.10/gtksourceview-2.10.5.tar.gz ftp://ftp.gnome.org/pub/gnome/sources/gtksourceview/2.10/gtksourceview-2.10.5.tar.gz "

export gtksourceview_2_10_5_C34_packname="gtksourceview-2.10.5.tar.gz"

export gtksourceview_2_10_5_C34_required_or_recommended="GTK_2_24_17_C25 Intltool_0_50_2_C11 "

Mousepad_0_3_0_C34(){

./configure --prefix=/usr &&
make
make install
}

export Mousepad_0_3_0_C34_download="http://archive.xfce.org/src/apps/mousepad/0.3/mousepad-0.3.0.tar.bz2 "

export Mousepad_0_3_0_C34_packname="mousepad-0.3.0.tar.bz2"

export Mousepad_0_3_0_C34_required_or_recommended="D_Bus_GLib_Bindings_C12 gtksourceview_2_10_5_C34 "

Vte_0_28_2_C34(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib/vte \
            --disable-static  &&
make
make install
}

export Vte_0_28_2_C34_download="http://ftp.gnome.org/pub/gnome/sources/vte/0.28/vte-0.28.2.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/vte/0.28/vte-0.28.2.tar.xz "

export Vte_0_28_2_C34_packname="vte-0.28.2.tar.xz"

export Vte_0_28_2_C34_required_or_recommended="GTK_2_24_17_C25 Intltool_0_50_2_C11 "

xfce4_terminal_0_6_1_C34(){

./configure --prefix=/usr &&
make
make install
}

export xfce4_terminal_0_6_1_C34_download="http://archive.xfce.org/src/apps/xfce4-terminal/0.6/xfce4-terminal-0.6.1.tar.bz2 "

export xfce4_terminal_0_6_1_C34_packname="xfce4-terminal-0.6.1.tar.bz2"

export xfce4_terminal_0_6_1_C34_required_or_recommended="libxfce4ui_4_10_0_C33 Vte_0_28_2_C34 "

Xfburn_0_4_3_C34(){

sed -i '/<glib.h>/a#include <glib-object.h>' xfburn/xfburn-settings.h &&
./configure --prefix=/usr --disable-static &&
make
make install
}

export Xfburn_0_4_3_C34_download="http://archive.xfce.org/src/apps/xfburn/0.4/xfburn-0.4.3.tar.bz2 "

export Xfburn_0_4_3_C34_packname="xfburn-0.4.3.tar.bz2"

export Xfburn_0_4_3_C34_required_or_recommended="Exo_0_10_2_C33 libxfcegui4_4_10_0_C33 libisoburn_1_2_8_C41 "

Ristretto_0_6_3_C34(){

./configure --prefix=/usr &&
make
make install
}

export Ristretto_0_6_3_C34_download="http://archive.xfce.org/src/apps/ristretto/0.6/ristretto-0.6.3.tar.bz2 "

export Ristretto_0_6_3_C34_packname="ristretto-0.6.3.tar.bz2"

export Ristretto_0_6_3_C34_required_or_recommended="libexif_0_6_21_C10 libxfce4ui_4_10_0_C33 "

libunique_1_1_6_C34(){

patch -Np1 -i ../libunique-1.1.6-upstream_fixes-1.patch &&
autoreconf -fi &&
./configure --prefix=/usr  \
            --disable-dbus \
            --disable-static &&
make
make install
}

export libunique_1_1_6_C34_download="http://ftp.gnome.org/pub/gnome/sources/libunique/1.1/libunique-1.1.6.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/libunique/1.1/libunique-1.1.6.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/libunique-1.1.6-upstream_fixes-1.patch "

export libunique_1_1_6_C34_packname="libunique-1.1.6.tar.bz2"

export libunique_1_1_6_C34_required_or_recommended="GTK_2_24_17_C25 "

xfce4_mixer_4_10_0_C34(){

./configure --prefix=/usr &&
make
make install
}

export xfce4_mixer_4_10_0_C34_download="http://archive.xfce.org/src/apps/xfce4-mixer/4.10/xfce4-mixer-4.10.0.tar.bz2 "

export xfce4_mixer_4_10_0_C34_packname="xfce4-mixer-4.10.0.tar.bz2"

export xfce4_mixer_4_10_0_C34_required_or_recommended="gst_plugins_base_0_10_36_C38 libunique_1_1_6_C34 xfce4_panel_4_10_0_C33 "

xfce4_notifyd_0_2_2_C34(){

./configure --prefix=/usr &&
make
make install
notify-send -i info Information "Hi ${USER}, This is a Test"
}

export xfce4_notifyd_0_2_2_C34_download="http://archive.xfce.org/src/apps/xfce4-notifyd/0.2/xfce4-notifyd-0.2.2.tar.bz2 "

export xfce4_notifyd_0_2_2_C34_packname="xfce4-notifyd-0.2.2.tar.bz2"

export xfce4_notifyd_0_2_2_C34_required_or_recommended="libxfce4ui_4_10_0_C33 "

export C34_XfceApplications="Midori_0_4_9_C34 Parole_0_5_0_C34 gtksourceview_2_10_5_C34 Mousepad_0_3_0_C34 Vte_0_28_2_C34 xfce4_terminal_0_6_1_C34 Xfburn_0_4_3_C34 Ristretto_0_6_3_C34 libunique_1_1_6_C34 xfce4_mixer_4_10_0_C34 xfce4_notifyd_0_2_2_C34 "


AbiWord_2_9_4_C35(){

./configure --prefix=/usr &&
make
make install
tar -xf ../abiword-docs-2.9.4.tar.gz &&
cd abiword-docs-2.9.4 &&
./configure --prefix=/usr &&
make
make install
ls /usr/share/abiword-2.9/templates
install -v -m750 -d ~/.AbiSuite/templates &&
install -v -m640    /usr/share/abiword-2.9/templates/normal.awt-<lang> \
                    ~/.AbiSuite/templates/normal.awt

}

export AbiWord_2_9_4_C35_download="http://www.abisource.com/downloads/abiword/2.9.4/source/abiword-2.9.4.tar.gz http://www.abisource.com/downloads/abiword/2.9.4/source/abiword-docs-2.9.4.tar.gz "

export AbiWord_2_9_4_C35_packname="abiword-2.9.4.tar.gz"

export AbiWord_2_9_4_C35_required_or_recommended="Boost_1_53_0_C9 FriBidi_0_19_5_C10 GOffice_0_10_1_C25 wv_1_2_9_C9 enchant_1_6_0_C9 "

Gnumeric_1_12_1_C35(){

sed -e "s@zz-application/zz-winassoc-xls;@@" -i gnumeric.desktop.in &&
./configure --prefix=/usr &&
make
make install
}

export Gnumeric_1_12_1_C35_download="http://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.1.tar.xz "

export Gnumeric_1_12_1_C35_packname="gnumeric-1.12.1.tar.xz"

export Gnumeric_1_12_1_C35_required_or_recommended="GOffice_0_10_1_C25 "

GnuCash_2_4_11_C35(){

patch -Np1 -i ../gnucash-2.4.11-guile-2_fixes-1.patch &&

./configure --prefix=/usr           \
            --sysconfdir=/etc/gnome \
            --disable-dbi           \
            --with-html-engine=webkit &&
make
make doc
make -C src/doc/design html pdf ps
make install
./configure --prefix=/usr &&
make
make -C guide html &&
make -C guide pdf
make install
mkdir -p                           /usr/share/doc/gnucash-2.4.1 &&
cp -v -R guide/C/gnucash-guide/*   /usr/share/doc/gnucash-2.4.1 &&
cp -v    guide/C/gnucash-guide.pdf /usr/share/doc/gnucash-2.4.1
}

export GnuCash_2_4_11_C35_download="http://downloads.sourceforge.net/gnucash/gnucash-2.4.11.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/gnucash-2.4.11-guile-2_fixes-1.patch http://downloads.sourceforge.net/gnucash/gnucash-docs-2.4.1.tar.gz "

export GnuCash_2_4_11_C35_packname="gnucash-2.4.11.tar.bz2"

export GnuCash_2_4_11_C35_required_or_recommended="Guile_2_0_7_C13 libgnomeui_2_24_5_C32 gnome_vfs_2_24_4_C32 SLIB_3b3_C9 GOffice_0_8_17_C25 WebKitGTK_1_10_2_C25 "

LibreOffice_4_0_1_C35(){

tar -xf libreoffice-4.0.1.2.tar.xz --no-overwrite-dir &&
cd libreoffice-4.0.1.2
install -dm755 src &&

tar -xvf ../libreoffice-dictionaries-4.0.1.2.tar.xz --no-overwrite-dir --strip-components=1 &&
tar -xvf ../libreoffice-help-4.0.1.2.tar.xz --no-overwrite-dir --strip-components=1 &&

ln -sfv ../../libreoffice-dictionaries-4.0.1.2.tar.xz src/ &&
ln -sfv ../../libreoffice-help-4.0.1.2.tar.xz src/
tar -xvf ../libreoffice-translations-4.0.1.2.tar.xz --no-overwrite-dir --strip-components=1 &&
ln -sfv ../../libreoffice-translations-4.0.1.2.tar.xz src/
sed -e "/gzip -f/d"   \
    -e "s|.1.gz|.1|g" \
    -i bin/distro-install-desktop-integration &&
sed -e "/distro-install-file-lists/d" -i Makefile.top &&
./autogen.sh --prefix=/usr              \
             --sysconfdir=/etc          \
             --with-vendor="BLFS"       \
             --with-lang=""             \
             --with-alloc=system        \
             --without-java             \
             --disable-gconf            \
             --disable-odk              \
             --disable-postgresql-sdbc  \
             --enable-python=system     \
             --with-system-cairo        \
             --with-system-curl         \
             --with-system-expat        \
             --with-system-icu          \
             --with-system-jpeg         \
             --with-system-lcms2        \
             --with-system-libpng       \
             --with-system-libxml       \
             --with-system-mesa-headers \
             --with-system-neon         \
             --with-system-nss          \
             --with-system-odbc         \
             --with-system-openldap     \
             --with-system-openssl      \
             --with-system-poppler      \
             --with-system-redland      \
             --with-system-zlib         \
             --with-parallelism=$(getconf _NPROCESSORS_ONLN)
make build
make distro-pack-install
}

export LibreOffice_4_0_1_C35_download="http://download.documentfoundation.org/libreoffice/src/4.0.1/libreoffice-4.0.1.2.tar.xz http://download.documentfoundation.org/libreoffice/src/4.0.1/libreoffice-dictionaries-4.0.1.2.tar.xz http://download.documentfoundation.org/libreoffice/src/4.0.1/libreoffice-help-4.0.1.2.tar.xz http://download.documentfoundation.org/libreoffice/src/4.0.1/libreoffice-translations-4.0.1.2.tar.xz "

export LibreOffice_4_0_1_C35_packname="libreoffice-4.0.1.2.tar.xz"

export LibreOffice_4_0_1_C35_required_or_recommended="Cups_1_6_2_C42 Gperf_3_0_4_C11 GTK_2_24_17_C25 Archive_Zip_1_30_C13 XML_Parser_2_41_C13 UnZip_6_0_C12 Wget_1_14_C15 Which_2_20_and_Alternatives_C12 Zip_3_0_C12 cURL_7_29_0_C17 D_Bus_1_6_8_C12 Expat_2_1_0_C9 gst_plugins_base_0_10_36_C38 ICU_51_1_C9 Little_CMS_2_4_C10 librsvg_2_36_4_C10 libxml2_2_9_0_C9 libxslt_1_1_28_C9 MesaLib_9_1_1_C24 neon_0_29_6_C17 NSS_3_14_3_C4 OpenLDAP_2_4_34_C23 OpenSSL_1_0_1e_C4 Poppler_0_22_2_C10 Python_3_3_0_C13 Redland_1_0_16_C12 unixODBC_2_3_1_C11 "

export C35_OfficePrograms="AbiWord_2_9_4_C35 Gnumeric_1_12_1_C35 GnuCash_2_4_11_C35 LibreOffice_4_0_1_C35 "


SeaMonkey_2_13_2_C36(){

cat > mozconfig << EOF
# If you have a multicore machine you can speed up the build by running
# several jobs at once, but if you have a single core, delete this line:
mk_add_options MOZ_MAKE_FLAGS="-j$(getconf _NPROCESSORS_ONLN)"

# If you have installed Yasm delete this option:
ac_add_options --disable-webm

# If you have installed DBus-Glib delete this option:
ac_add_options --disable-dbus

# If you have installed wireless-tools delete this option:
ac_add_options --disable-necko-wifi

# If you have installed libnotify delete this option:
ac_add_options --disable-libnotify

# Uncomment these if you have installed them:
# ac_add_options --enable-startup-notification
# ac_add_options --enable-system-hunspell
# ac_add_options --enable-system-sqlite
# ac_add_options --with-system-libevent
# ac_add_options --with-system-libvpx
# ac_add_options --with-system-nspr
# ac_add_options --with-system-nss

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/moz-build-dir
ac_add_options --disable-crashreporter
ac_add_options --disable-debug
ac_add_options --disable-debug-symbols
ac_add_options --disable-installer
ac_add_options --disable-static
ac_add_options --disable-tests
ac_add_options --disable-updater
ac_add_options --enable-application=suite
ac_add_options --enable-shared
ac_add_options --enable-system-ffi
ac_add_options --prefix=/usr
ac_add_options --with-pthreads
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib
EOF
make -f client.mk &&
make -C moz-build-dir/suite/installer
rm -rf    /usr/lib/seamonkey-2.13.2 &&
mkdir -pv /usr/lib/seamonkey-2.13.2 &&

tar -xf moz-build-dir/mozilla/dist/seamonkey-2.13.2.en-US.linux-$(uname -m).tar.bz2 \
  -C /usr/lib/seamonkey-2.13.2 --strip-components=1  &&

ln -sfv ../lib/seamonkey-2.13.2/seamonkey /usr/bin   &&

mkdir -pv /usr/lib/mozilla/plugins                   &&
ln -sfv ../mozilla/plugins /usr/lib/seamonkey-2.13.2 &&

cp -v moz-build-dir/mozilla/dist/man/man1/seamonkey.1 /usr/share/man/man1
rm -rf   /usr/include/npapi &&
mkdir -pv /usr/include/npapi &&
cp -v mozilla/dom/plugins/base/*.h /usr/include/npapi
make -C moz-build-dir install
mkdir -pv /usr/share/{applications,pixmaps}              &&

cat > /usr/share/applications/seamonkey.desktop << "EOF"
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=SeaMonkey
Comment=The Mozilla Suite
Icon=seamonkey
Exec=seamonkey
Categories=Network;GTK;Application;Email;Browser;WebBrowser;News;
StartupNotify=true
Terminal=false
EOF

ln -sfv /usr/lib/seamonkey-2.13.2/chrome/icons/default/seamonkey.png \
        /usr/share/pixmaps
}

export SeaMonkey_2_13_2_C36_download="http://ftp.mozilla.org/pub/mozilla.org/seamonkey/releases/2.13.2/source/seamonkey-2.13.2.source.tar.bz2 ftp://ftp.mozilla.org/pub/mozilla.org/seamonkey/releases/2.13.2/source/seamonkey-2.13.2.source.tar.bz2 "

export SeaMonkey_2_13_2_C36_packname="seamonkey-2.13.2.source.tar.bz2"

export SeaMonkey_2_13_2_C36_required_or_recommended="alsa_lib_1_0_26_C38 GTK_2_24_17_C25 Zip_3_0_C12 UnZip_6_0_C12 yasm_1_2_0_C13 "

Firefox_19_0_2_C36(){

cat > mozconfig << "EOF"
# If you have a multicore machine you can speed up the build by running
# several jobs at once by uncommenting the following line and setting the
# value to number of CPU cores:
#mk_add_options MOZ_MAKE_FLAGS="-j4"

# If you have installed DBus-Glib comment out this line:
ac_add_options --disable-dbus

# If you have installed wireless-tools comment out this line:
ac_add_options --disable-necko-wifi

# If you have installed libnotify comment out this line:
ac_add_options --disable-libnotify

# Uncomment these lines if you have installed optional dependencies:
#ac_add_options --enable-system-hunspell
#ac_add_options --enable-startup-notification

# If you have not installed Yasm then uncomment this line:
#ac_add_options --disable-webm

# If you have installed xulrunner uncomment following two lines:
#ac_add_options --with-system-libxul
#ac_add_options --with-libxul-sdk=\$(pkg-config --variable=sdkdir libxul)

# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --enable-system-sqlite
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss

# It is recommended not to touch anything below this line
ac_add_options --prefix=/usr
ac_add_options --enable-application=browser

ac_add_options --disable-crashreporter
ac_add_options --disable-installer
ac_add_options --disable-updater
ac_add_options --disable-debug
ac_add_options --disable-tests

ac_add_options --enable-optimize
ac_add_options --enable-strip
ac_add_options --enable-install-strip

ac_add_options --enable-gio
ac_add_options --enable-official-branding
ac_add_options --enable-safe-browsing
ac_add_options --enable-url-classifier

ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman

ac_add_options --with-pthreads

ac_add_options --with-system-bz2
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/firefox-build-dir
EOF
sed -i 's# ""##' browser/base/Makefile.in &&
make -f client.mk
make -C firefox-build-dir/browser/installer
rm -rf /usr/lib/firefox-19.0.2 &&
mkdir -pv /usr/lib/firefox-19.0.2 &&

tar -xvf firefox-build-dir/dist/firefox-19.0.2.en-US.linux-$(uname -m).tar.bz2 \
    -C /usr/lib/firefox-19.0.2 --strip-components=1 &&
chown -R -v root:root /usr/lib/firefox-19.0.2 &&
chmod -v 755 /usr/lib/firefox-19.0.2/libxpcom.so &&

ln -sfv ../lib/firefox-19.0.2/firefox /usr/bin &&

mkdir -pv /usr/lib/mozilla/plugins &&
ln -sfv ../mozilla/plugins /usr/lib/firefox-19.0.2
make -C firefox-build-dir install &&
rm -v /usr/bin/firefox &&

cat > /usr/bin/firefox << "EOF"
#!/bin/bash
/usr/lib/xulrunner-19.0.2/xulrunner /usr/lib/firefox-19.0.2/application.ini "${@}"
EOF

chmod -v 755 /usr/bin/firefox &&
mkdir -pv /usr/lib/mozilla/plugins &&
ln -sfv ../mozilla/plugins /usr/lib/firefox-19.0.2
rm -rf /usr/include/npapi &&
mkdir -pv /usr/include/npapi &&
cp -v dom/plugins/base/*.h /usr/include/npapi
mkdir -pv /usr/share/applications &&
mkdir -pv /usr/share/pixmaps &&

cat > /usr/share/applications/firefox.desktop << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Firefox Web Browser
Comment=Browse the World Wide Web
GenericName=Web Browser
Exec=firefox %u
Terminal=false
Type=Application
Icon=firefox
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=application/xhtml+xml;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

ln -sfv /usr/lib/firefox-19.0.2/icons/mozicon128.png \
        /usr/share/pixmaps/firefox.png
}

export Firefox_19_0_2_C36_download="http://releases.mozilla.org/pub/mozilla.org/firefox/releases/19.0.2/source/firefox-19.0.2.source.tar.bz2 ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/19.0.2/source/firefox-19.0.2.source.tar.bz2 "

export Firefox_19_0_2_C36_packname="firefox-19.0.2.source.tar.bz2"

export Firefox_19_0_2_C36_required_or_recommended="alsa_lib_1_0_26_C38 GTK_2_24_17_C25 Zip_3_0_C12 UnZip_6_0_C12 libevent_2_0_21_C17 libvpx_v1_1_0_C38 NSPR_4_9_6_C9 NSS_3_14_3_C4 SQLite_3_7_16_1_C22 yasm_1_2_0_C13 "

export C36_GraphicalWebBrowsers="SeaMonkey_2_13_2_C36 Firefox_19_0_2_C36 "


Balsa_2_4_12_C37(){

./configure --prefix=/usr            \
            --sysconfdir=/etc/gnome  \
            --localstatedir=/var/lib \
            --with-rubrica           \
            --without-html-widget    \
            --without-esmtp          \
            --without-libnotify      \
            --without-nm             \
            --without-gtkspell       \
            ENABLE_SK_FALSE='#'  &&
make
make install
}

export Balsa_2_4_12_C37_download="http://pawsa.fedorapeople.org/balsa/balsa-2.4.12.tar.bz2 "

export Balsa_2_4_12_C37_packname="balsa-2.4.12.tar.bz2"

export Balsa_2_4_12_C37_required_or_recommended="libgnomeui_2_24_5_C32 Rarian_0_8_1_C11 GMime_2_6_15_C9 Aspell_0_60_6_1_C9 libESMTP_1_0_6_C9 PCRE_8_32_C9 "

Blueman_1_23_C37(){

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/blueman \
            --disable-static &&
make
make install
}

export Blueman_1_23_C37_download="http://download.tuxfamily.org/blueman/blueman-1.23.tar.gz "

export Blueman_1_23_C37_packname="blueman-1.23.tar.gz"

export Blueman_1_23_C37_required_or_recommended="BlueZ_4_101_C12 D_Bus_Python_Bindings_C12 GTK_2_24_17_C25 Notify_Python_0_1_1_C13 PyGTK_2_24_0_C13 GTK_2_24_17_C25 Pyrex_0_9_9_C13 startup_notification_0_12_C25 Polkit_0_110_C4 obex_data_server_0_4_6_C12 polkit_gnome_0_105_C30 "

Ekiga_4_0_1_C37(){

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-eds     \
            --disable-gdu     \
            --disable-ldap    \
            --disable-scrollkeeper &&
make
make install
}

export Ekiga_4_0_1_C37_download="http://ftp.gnome.org/pub/gnome/sources/ekiga/4.0/ekiga-4.0.1.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/ekiga/4.0/ekiga-4.0.1.tar.xz "

export Ekiga_4_0_1_C37_packname="ekiga-4.0.1.tar.xz"

export Ekiga_4_0_1_C37_required_or_recommended="Boost_1_53_0_C9 D_Bus_GLib_Bindings_C12 gnome_icon_theme_3_6_2_C30 GTK_2_24_17_C25 Opal_3_10_10_C38 GConf_3_2_6_C30 libnotify_0_7_5_C25 "

Gimp_2_8_4_C37(){

./configure --prefix=/usr --sysconfdir=/etc --without-gvfs &&
make
make install
ALL_LINGUAS="da de el en en_GB es fi fr hr it ja ko lt nl nn pl ru sl sv zh_CN" \
./configure --prefix=/usr &&
xzcat ../gimp-help-2.8.0-build_fixes-1.patch.xz \
 | patch -p1 &&
./autogen.sh --prefix=/usr &&
make
make install &&
chown -R root:root /usr/share/gimp/2.0/help
gtk-update-icon-cache &&
update-desktop-database
echo '(web-browser "<browser> %s")' >> /etc/gimp/2.0/gimprc

}

export Gimp_2_8_4_C37_download="http://artfiles.org/gimp.org/gimp/v2.8/gimp-2.8.4.tar.bz2 ftp://ftp.gimp.org/pub/gimp/v2.8/gimp-2.8.4.tar.bz2 ftp://gimp.org/pub/gimp/help/gimp-help-2.8.0.tar.bz2 ftp://anduin.linuxfromscratch.org/other/gimp-help-2.8.0-build_fixes-1.patch.xz "

export Gimp_2_8_4_C37_packname="gimp-2.8.4.tar.bz2"

export Gimp_2_8_4_C37_required_or_recommended="gegl_0_2_0_C10 GTK_2_24_17_C25 Intltool_0_50_2_C11 PyGTK_2_24_0_C13 "

gnash_0_8_10_C37(){

patch -Np1 -i ../gnash-0.8.10-CVE-2012-1175-1.patch &&
sed -i '/^LIBS/s/\(.*\)/\1 -lboost_system/' \
  gui/Makefile.in utilities/Makefile.in &&
./configure --prefix=/usr --sysconfdir=/etc               \
  --with-npapi-incl=/usr/include/npapi --enable-media=gst \
  --with-npapi-plugindir=/usr/lib/mozilla/plugins         &&
make
make install &&
make install-plugin
}

export gnash_0_8_10_C37_download="http://ftp.gnu.org/pub/gnu/gnash/0.8.10/gnash-0.8.10.tar.bz2 ftp://ftp.gnu.org/pub/gnu/gnash/0.8.10/gnash-0.8.10.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/gnash-0.8.10-CVE-2012-1175-1.patch "

export gnash_0_8_10_C37_packname="gnash-0.8.10.tar.bz2"

export gnash_0_8_10_C37_required_or_recommended="agg_2_5_C25 Boost_1_53_0_C9 gst_ffmpeg_0_10_13_C38 Firefox_19_0_2_C36 GConf_3_2_6_C30 giflib_4_1_6_C10 "

Gparted_0_14_1_C37(){

./configure --prefix=/usr --disable-doc &&
make
make install
}

export Gparted_0_14_1_C37_download="http://downloads.sourceforge.net/gparted/gparted-0.14.1.tar.bz2 "

export Gparted_0_14_1_C37_packname="gparted-0.14.1.tar.bz2"

export Gparted_0_14_1_C37_required_or_recommended="Gtkmm_2_24_2_C25 Intltool_0_50_2_C11 parted_3_1_C5 "

IcedTea_Web_1_3_C37(){

./configure --prefix=${JAVA_HOME}/jre    \
            --with-jdk-home=${JAVA_HOME} \
            --disable-docs               \
            --mandir=${JAVA_HOME}/man &&
make
make install
ln -s ${JAVA_HOME}/jre/lib/<arch>/IcedTeaPlugin.so \
    /usr/lib/mozilla/plugins/

}

export IcedTea_Web_1_3_C37_download="http://icedtea.classpath.org/download/source/icedtea-web-1.3.tar.gz "

export IcedTea_Web_1_3_C37_packname="icedtea-web-1.3.tar.gz"

export IcedTea_Web_1_3_C37_required_or_recommended="OpenJDK_1_7_0_9_C13 Xulrunner_19_0_2_C25 "

Inkscape_0_48_4_C37(){

export LIBRARY_PATH=$XORG_PREFIX/lib
./configure --prefix=/usr &&
make &&
unset LIBRARY_PATH
make install
gtk-update-icon-cache &&
update-desktop-database
}

export Inkscape_0_48_4_C37_download="http://downloads.sourceforge.net/inkscape/inkscape-0.48.4.tar.bz2 "

export Inkscape_0_48_4_C37_packname="inkscape-0.48.4.tar.bz2"

export Inkscape_0_48_4_C37_required_or_recommended="Boost_1_53_0_C9 GC_7_2d_C13 Gsl_1_15_C9 Gtkmm_2_24_2_C25 Little_CMS_1_19_C10 "

Pidgin_2_10_7_C37(){

./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --disable-avahi     \
            --disable-dbus      \
            --disable-gtkspell  \
            --disable-gstreamer \
            --disable-meanwhile \
            --disable-idn       \
            --disable-nm        \
            --disable-vv        \
            --disable-tcl &&
make
make install &&
mkdir -pv /usr/share/doc/pidgin-2.10.7 &&
cp -v README doc/gtkrc-2.0 /usr/share/doc/pidgin-2.10.7
mkdir -pv /usr/share/doc/pidgin-2.10.7/api &&
cp -v doc/html/* /usr/share/doc/pidgin-2.10.7/api
}

export Pidgin_2_10_7_C37_download="http://downloads.sourceforge.net/pidgin/pidgin-2.10.7.tar.bz2 "

export Pidgin_2_10_7_C37_packname="pidgin-2.10.7.tar.bz2"

export Pidgin_2_10_7_C37_required_or_recommended="GTK_2_24_17_C25 XML_Parser_2_41_C13 libgcrypt_1_5_1_C9 GnuTLS_3_1_10_C4 "

Rox_Filer_2_11_C37(){

cd ROX-Filer                                                        &&
sed -i 's:g_strdup(getenv("APP_DIR")):"/usr/share/rox":' src/main.c &&

mkdir build                      &&
pushd build                      &&
../src/configure LIBS="-lm -ldl" &&
make                             &&
popd
mkdir -p /usr/share/rox                              &&
cp -av Help Messages Options.xml ROX images style.css .DirIcon /usr/share/rox &&

cp -av ../rox.1 /usr/share/man/man1                  &&
cp -v  ROX-Filer /usr/bin/rox                        &&
chown -Rv root:root /usr/bin/rox /usr/share/rox      &&

cd /usr/share/rox/ROX/MIME                           &&
ln -sfv text-x-{diff,patch}.png                       &&
ln -sfv application-x-font-{afm,type1}.png            &&
ln -sfv application-xml{,-dtd}.png                    &&
ln -sfv application-xml{,-external-parsed-entity}.png &&
ln -sfv application-{,rdf+}xml.png                    &&
ln -sfv application-x{ml,-xbel}.png                   &&
ln -sfv application-{x-shell,java}script.png          &&
ln -sfv application-x-{bzip,xz}-compressed-tar.png    &&
ln -sfv application-x-{bzip,lzma}-compressed-tar.png  &&
ln -sfv application-x-{bzip-compressed-tar,lzo}.png   &&
ln -sfv application-x-{bzip,xz}.png                   &&
ln -sfv application-x-{gzip,lzma}.png                 &&
ln -sfv application-{msword,rtf}.png
cat > /path/to/hostname/AppRun << "HERE_DOC"
#!/bin/bash

MOUNT_PATH="${0%/*}"
HOST=${MOUNT_PATH##*/}
export MOUNT_PATH HOST
sshfs -o nonempty ${HOST}:/ ${MOUNT_PATH}
rox -x ${MOUNT_PATH}
HERE_DOC

chmod 755 /path/to/hostname/AppRun
cat > /usr/bin/myumount << "HERE_DOC" &&
#!/bin/bash
sync
if mount | grep "${@}" | grep -q fuse
then fusermount -u "${@}"
else umount "${@}"
fi
HERE_DOC

chmod 755 /usr/bin/myumount
ln -s ../rox/.DirIcon /usr/share/pixmaps/rox.png &&
mkdir -p /usr/share/applications &&

cat > /usr/share/applications/rox.desktop << "HERE_DOC"
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Rox
Comment=The Rox File Manager
Icon=rox
Exec=rox
Categories=GTK;Utility;Application;System;Core;
StartupNotify=true
Terminal=false
HERE_DOC
}

export Rox_Filer_2_11_C37_download="http://downloads.sourceforge.net/rox/rox-filer-2.11.tar.bz2 "

export Rox_Filer_2_11_C37_packname="rox-filer-2.11.tar.bz2"

export Rox_Filer_2_11_C37_required_or_recommended="libglade_2_6_4_C9 shared_mime_info_1_1_C25 "

Thunderbird_17_0_4_C37(){

cat > mozconfig << "EOF"
# If you have a multicore machine you can speed up the build by running
# several jobs at once by uncommenting the following line and setting the
# value to number of CPU cores:
#mk_add_options MOZ_MAKE_FLAGS="-j4"

# If you have installed DBus-Glib comment out this line:
ac_add_options --disable-dbus

# If you have installed wireless-tools comment out this line:
ac_add_options --disable-necko-wifi

# If you have installed libnotify comment out this line:
ac_add_options --disable-libnotify

# Uncomment these lines if you have installed optional dependencies:
#ac_add_options --enable-system-hunspell
#ac_add_options --enable-startup-notification

# If you have not installed Yasm then uncomment this line:
#ac_add_options --disable-webm

# If you want to compile the Mozilla Calendar, uncomment this line:
#ac_add_options --enable-calendar

# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --enable-system-sqlite
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss

# It is recommended not to touch anything below this line
ac_add_options --prefix=/usr

ac_add_options --disable-crashreporter
ac_add_options --disable-installer
ac_add_options --disable-updater
ac_add_options --disable-debug
ac_add_options --disable-tests

ac_add_options --enable-optimize
ac_add_options --enable-strip
ac_add_options --enable-install-strip

ac_add_options --enable-gio
ac_add_options --enable-official-branding
ac_add_options --enable-safe-browsing
ac_add_options --enable-url-classifier

ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman

ac_add_options --with-pthreads

ac_add_options --with-system-bz2
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/thunderbuild
EOF
make -f client.mk &&
make -C thunderbuild/mail/installer
mkdir -pv /usr/lib/thunderbird-17.0.4 &&
tar -xvf thunderbuild/mozilla/dist/thunderbird-17.0.4.en-US.linux-$(uname -m).tar.bz2 \
    -C /usr/lib/thunderbird-17.0.4 --strip-components=1 &&
ln -sfv ../lib/thunderbird-17.0.4/thunderbird /usr/bin
make -C thunderbuild install
mkdir -pv /usr/share/applications &&
mkdir -pv /usr/share/pixmaps &&

cat > /usr/share/applications/thunderbird.desktop << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Thunderbird Mail
Comment=Send and receive mail with Thunderbird
GenericName=Mail Client
Exec=thunderbird %u
Terminal=false
Type=Application
Icon=thunderbird
Categories=Application;Network;Email;
MimeType=application/xhtml+xml;text/xml;application/xhtml+xml;application/xml;application/rss+xml;x-scheme-handler/mailto;
StartupNotify=true
EOF

ln -sfv /usr/lib/thunderbird-17.0.4/chrome/icons/default/default256.png \
        /usr/share/pixmaps/thunderbird.png
}

export Thunderbird_17_0_4_C37_download="http://releases.mozilla.org/pub/mozilla.org/thunderbird/releases/17.0.4/source/thunderbird-17.0.4.source.tar.bz2 ftp://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/17.0.4/source/thunderbird-17.0.4.source.tar.bz2 "

export Thunderbird_17_0_4_C37_packname="thunderbird-17.0.4.source.tar.bz2"

export Thunderbird_17_0_4_C37_required_or_recommended="alsa_lib_1_0_26_C38 GTK_2_24_17_C25 Zip_3_0_C12 UnZip_6_0_C12 libevent_2_0_21_C17 libvpx_v1_1_0_C38 NSPR_4_9_6_C9 NSS_3_14_3_C4 SQLite_3_7_16_1_C22 yasm_1_2_0_C13 "

Transmission_2_77_C37(){

./configure --prefix=/usr &&
make
pushd qt &&
qmake qtr.pro &&
make &&
popd
make install
INSTALL_ROOT=/usr make -C qt install &&
install -m644 qt/transmission-qt.desktop /usr/share/applications/transmission-qt.desktop &&
install -m644 qt/icons/transmission.png /usr/share/pixmaps/transmission-qt.png
}

export Transmission_2_77_C37_download="http://download.transmissionbt.com/files/transmission-2.77.tar.xz "

export Transmission_2_77_C37_packname="transmission-2.77.tar.xz"

export Transmission_2_77_C37_required_or_recommended="OpenSSL_1_0_1e_C4 cURL_7_29_0_C17 libevent_2_0_21_C17 Intltool_0_50_2_C11 GTK_3_6_4_C25 "

XChat_2_8_8_C37(){

patch -Np1 -i ../xchat-2.8.8-glib-2.31-1.patch &&
LIBS+="-lgmodule-2.0" ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --enable-shm &&
make
make install &&
install -v -m755 -d /usr/share/doc/xchat-2.8.8 &&
install -v -m644    README faq.html \
                    /usr/share/doc/xchat-2.8.8
}

export XChat_2_8_8_C37_download="http://www.xchat.org/files/source/2.8/xchat-2.8.8.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xchat-2.8.8.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/xchat-2.8.8-glib-2.31-1.patch "

export XChat_2_8_8_C37_packname="xchat-2.8.8.tar.bz2"

export XChat_2_8_8_C37_required_or_recommended="GLib_2_34_3_C9 GTK_2_24_17_C25 "

xdg_utils_1_1_0_rc1_C37(){

./configure --prefix=/usr --mandir=/usr/share/man
make install
}

export xdg_utils_1_1_0_rc1_C37_download="http://portland.freedesktop.org/download/xdg-utils-1.1.0-rc1.tar.gz "

export xdg_utils_1_1_0_rc1_C37_packname="xdg-utils-1.1.0-rc1.tar.gz"

export C37_OtherXbasedPrograms="Balsa_2_4_12_C37 Blueman_1_23_C37 Ekiga_4_0_1_C37 Gimp_2_8_4_C37 gnash_0_8_10_C37 Gparted_0_14_1_C37 IcedTea_Web_1_3_C37 Inkscape_0_48_4_C37 Pidgin_2_10_7_C37 Rox_Filer_2_11_C37 Thunderbird_17_0_4_C37 Transmission_2_77_C37 XChat_2_8_8_C37 xdg_utils_1_1_0_rc1_C37 "


alsa_lib_1_0_26_C38(){

./configure &&
make
make install
make doc
install -v -d -m755 /usr/share/doc/alsa-lib-1.0.26/html &&
install -v -m644 doc/doxygen/html/* /usr/share/doc/alsa-1.0.26/html
}

export alsa_lib_1_0_26_C38_download="ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.26.tar.bz2 "

export alsa_lib_1_0_26_C38_packname="alsa-lib-1.0.26.tar.bz2"

alsa_plugins_1_0_26_C38(){

patch -Np1 -i ../alsa-plugins-1.0.26-ffmpeg-1.patch &&
./configure &&
make
make install
}

export alsa_plugins_1_0_26_C38_download="ftp://ftp.alsa-project.org/pub/plugins/alsa-plugins-1.0.26.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/alsa-plugins-1.0.26-ffmpeg-1.patch "

export alsa_plugins_1_0_26_C38_packname="alsa-plugins-1.0.26.tar.bz2"

export alsa_plugins_1_0_26_C38_required_or_recommended="alsa_lib_1_0_26_C38 "

alsa_utils_1_0_26_C38(){

patch -Np1 -i ../alsa-utils-1.0.26-no_xmlto-1.patch
./configure --without-systemdsystemunitdir &&
make
make install
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-alsa
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
touch /var/lib/alsa/asound.state &&
alsactl store
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
usermod -a -G audio mao

}

export alsa_utils_1_0_26_C38_download="ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.26.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/alsa-utils-1.0.26-no_xmlto-1.patch "

export alsa_utils_1_0_26_C38_packname="alsa-utils-1.0.26.tar.bz2"

export alsa_utils_1_0_26_C38_required_or_recommended="alsa_lib_1_0_26_C38 "

alsa_tools_1_0_25_C38(){

./configure --prefix=/usr &&
make
make install
}

export alsa_tools_1_0_25_C38_download="ftp://ftp.alsa-project.org/pub/tools/alsa-tools-1.0.25.tar.bz2 "

export alsa_tools_1_0_25_C38_packname="alsa-tools-1.0.25.tar.bz2"

export alsa_tools_1_0_25_C38_required_or_recommended="alsa_lib_1_0_26_C38 "

alsa_firmware_1_0_25_C38(){

./configure --prefix=/usr &&
make
make install
}

export alsa_firmware_1_0_25_C38_download="ftp://ftp.alsa-project.org/pub/firmware/alsa-firmware-1.0.25.tar.bz2 "

export alsa_firmware_1_0_25_C38_packname="alsa-firmware-1.0.25.tar.bz2"

export alsa_firmware_1_0_25_C38_required_or_recommended="alsa_tools_1_0_25_C38 "

ALSA_OSS_1_0_25_C38(){

./configure &&
make
make install
}

export ALSA_OSS_1_0_25_C38_download="ftp://ftp.alsa-project.org/pub/oss-lib/alsa-oss-1.0.25.tar.bz2 "

export ALSA_OSS_1_0_25_C38_packname="alsa-oss-1.0.25.tar.bz2"

export ALSA_OSS_1_0_25_C38_required_or_recommended="alsa_lib_1_0_26_C38 "

AudioFile_0_3_6_C38(){

./configure --prefix=/usr &&
make
make install
}

export AudioFile_0_3_6_C38_download="http://ftp.gnome.org/pub/gnome/sources/audiofile/0.3/audiofile-0.3.6.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/audiofile/0.3/audiofile-0.3.6.tar.xz "

export AudioFile_0_3_6_C38_packname="audiofile-0.3.6.tar.xz"

export AudioFile_0_3_6_C38_required_or_recommended="alsa_lib_1_0_26_C38 FLAC_1_2_1_C38 "

EsounD_0_2_41_C38(){

LIBS=-lm ./configure --prefix=/usr --sysconfdir=/etc &&
make
make install docdir=/usr/share/doc/esound-0.2.41
chown -R root:root /usr/share/doc/esound-0.2.41/*
}

export EsounD_0_2_41_C38_download="http://ftp.gnome.org/pub/gnome/sources/esound/0.2/esound-0.2.41.tar.bz2 ftp://ftp.gnome.org/pub/gnome/sources/esound/0.2/esound-0.2.41.tar.bz2 "

export EsounD_0_2_41_C38_packname="esound-0.2.41.tar.bz2"

export EsounD_0_2_41_C38_required_or_recommended="AudioFile_0_3_6_C38 "

FAAC_1_28_C38(){

patch -Np1 -i ../faac-1.28-glibc_fixes-1.patch &&
sed -i -e '/obj-type/d' -e '/Long Term/d' frontend/main.c &&
./configure --prefix=/usr &&
make
./frontend/faac -o Front_Left.mp4 /usr/share/sounds/alsa/Front_Left.wav
faad Front_Left.mp4
aplay Front_Left.wav
make install
}

export FAAC_1_28_C38_download="http://downloads.sourceforge.net/faac/faac-1.28.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/faac-1.28.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/faac-1.28-glibc_fixes-1.patch "

export FAAC_1_28_C38_packname="faac-1.28.tar.gz"

FAAD2_2_7_C38(){

./configure --prefix=/usr &&
make
./frontend/faad -o sample.wav ../sample.aac
aplay sample.wav
make install
}

export FAAD2_2_7_C38_download="http://downloads.sourceforge.net/faac/faad2-2.7.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/faad2-2.7.tar.gz http://www.nch.com.au/acm/sample.aac "

export FAAD2_2_7_C38_packname="faad2-2.7.tar.gz"

Farstream_0_2_2_C38(){

./configure --prefix=/usr &&
make
make install
}

export Farstream_0_2_2_C38_download="http://freedesktop.org/software/farstream/releases/farstream/farstream-0.2.2.tar.gz "

export Farstream_0_2_2_C38_packname="farstream-0.2.2.tar.gz"

export Farstream_0_2_2_C38_required_or_recommended="gst_plugins_base_1_0_6_C38 libnice_0_1_3_C17 gobject_introspection_1_34_2_C9 gst_plugins_bad_1_0_6_C38 gst_plugins_good_1_0_6_C38 "

FLAC_1_2_1_C38(){

sed -i 's/#include <stdio.h>/&\n#include <string.h>/' \
    examples/cpp/encode/file/main.cpp &&

./configure --prefix=/usr \
            --mandir=/usr/share/man \
            --disable-thorough-tests &&
make
make install
}

export FLAC_1_2_1_C38_download="http://downloads.sourceforge.net/flac/flac-1.2.1.tar.gz "

export FLAC_1_2_1_C38_packname="flac-1.2.1.tar.gz"

GStreamer_0_10_36_C38(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib \
            --disable-static &&
make
make install &&
install -v -m755 -d /usr/share/doc/gstreamer-0.10/design &&
install -v -m644 docs/design/*.txt \
                    /usr/share/doc/gstreamer-0.10/design &&

if [ -d /usr/share/doc/gstreamer-0.10/faq/html ]; then
    chown -R -R root:root \
        /usr/share/doc/gstreamer-0.10/*/html
fi
gst-launch -v fakesrc num_buffers=5 ! fakesink
}

export GStreamer_0_10_36_C38_download="http://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10/gstreamer-0.10.36.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10/gstreamer-0.10.36.tar.xz "

export GStreamer_0_10_36_C38_packname="gstreamer-0.10.36.tar.xz"

export GStreamer_0_10_36_C38_required_or_recommended="GLib_2_34_3_C9 libxml2_2_9_0_C9 "

gst_plugins_base_0_10_36_C38(){

./configure --prefix=/usr &&
make
make install
}

export gst_plugins_base_0_10_36_C38_download="http://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10/gst-plugins-base-0.10.36.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10/gst-plugins-base-0.10.36.tar.xz "

export gst_plugins_base_0_10_36_C38_packname="gst-plugins-base-0.10.36.tar.xz"

export gst_plugins_base_0_10_36_C38_required_or_recommended="GStreamer_0_10_36_C38 Pango_1_32_5_C25 alsa_lib_1_0_26_C38 libogg_1_3_0_C38 libtheora_1_1_1_C38 libvorbis_1_3_3_C38 Udev_Installed_LFS_Version_C12 Xorg_Libraries_C24 "

gst_plugins_good_0_10_31_C38(){

sed -i -e '/input:/d' sys/v4l2/gstv4l2bufferpool.c &&
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --with-gtk=3.0 &&
make
make install
make -C docs/plugins install-data
}

export gst_plugins_good_0_10_31_C38_download="http://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10/gst-plugins-good-0.10.31.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10/gst-plugins-good-0.10.31.tar.xz "

export gst_plugins_good_0_10_31_C38_packname="gst-plugins-good-0.10.31.tar.xz"

export gst_plugins_good_0_10_31_C38_required_or_recommended="gst_plugins_base_0_10_36_C38 Cairo_1_12_14_C25 FLAC_1_2_1_C38 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 Xorg_Libraries_C24 "

gst_plugins_bad_0_10_23_C38(){

./configure --prefix=/usr --with-gtk=3.0 --disable-examples &&
make
make install
}

export gst_plugins_bad_0_10_23_C38_download="http://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-0.10.23.tar.xz "

export gst_plugins_bad_0_10_23_C38_packname="gst-plugins-bad-0.10.23.tar.xz"

export gst_plugins_bad_0_10_23_C38_required_or_recommended="gst_plugins_base_0_10_36_C38 FAAC_1_28_C38 libpng_1_5_14_C10 libvpx_v1_1_0_C38 OpenSSL_1_0_1e_C4 XviD_1_3_2_C38 "

gst_plugins_ugly_0_10_19_C38(){

patch -Np1 -i ../gst-plugins-ugly-0.10.19-libcdio_fixes-1.patch &&
./configure --prefix=/usr &&
make
make install
make -C docs/plugins install-data
}

export gst_plugins_ugly_0_10_19_C38_download="http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-0.10.19.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/gst-plugins-ugly-0.10.19-libcdio_fixes-1.patch "

export gst_plugins_ugly_0_10_19_C38_packname="gst-plugins-ugly-0.10.19.tar.xz"

export gst_plugins_ugly_0_10_19_C38_required_or_recommended="gst_plugins_base_0_10_36_C38 LAME_3_99_5_C39 Libdvdnav_4_2_0_C38 Libdvdread_4_2_0_C38 "

gst_ffmpeg_0_10_13_C38(){

patch -p1 < ../gst-ffmpeg-0.10.13-gcc-4.7-1.patch &&
./configure --prefix=/usr &&
make
make install
}

export gst_ffmpeg_0_10_13_C38_download="http://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.13.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/gst-ffmpeg-0.10.13-gcc-4.7-1.patch "

export gst_ffmpeg_0_10_13_C38_packname="gst-ffmpeg-0.10.13.tar.bz2"

export gst_ffmpeg_0_10_13_C38_required_or_recommended="gst_plugins_base_0_10_36_C38 yasm_1_2_0_C13 "

GStreamer_1_0_6_C38(){

./configure --prefix=/usr \
            --libexecdir=/usr/lib \
            --with-package-name="GStreamer 1.0.6 BLFS" \
            --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
make
make install
}

export GStreamer_1_0_6_C38_download="http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.0.6.tar.xz "

export GStreamer_1_0_6_C38_packname="gstreamer-1.0.6.tar.xz"

export GStreamer_1_0_6_C38_required_or_recommended="GLib_2_34_3_C9 gobject_introspection_1_34_2_C9 "

gst_plugins_base_1_0_6_C38(){

./configure --prefix=/usr \
            --with-package-name="GStreamer Base Plugins 1.0.6 BLFS" \
            --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
make
make install
}

export gst_plugins_base_1_0_6_C38_download="http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.0.6.tar.xz "

export gst_plugins_base_1_0_6_C38_packname="gst-plugins-base-1.0.6.tar.xz"

export gst_plugins_base_1_0_6_C38_required_or_recommended="GStreamer_1_0_6_C38 libxml2_2_9_0_C9 alsa_lib_1_0_26_C38 gobject_introspection_1_34_2_C9 ISO_Codes_3_40_C9 libogg_1_3_0_C38 libtheora_1_1_1_C38 libvorbis_1_3_3_C38 Pango_1_32_5_C25 Xorg_Libraries_C24 "

gst_plugins_good_1_0_6_C38(){

./configure --prefix=/usr \
            --with-package-name="GStreamer Good Plugins 1.0.6 BLFS" \
            --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/"  &&
make
make install
}

export gst_plugins_good_1_0_6_C38_download="http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.0.6.tar.xz "

export gst_plugins_good_1_0_6_C38_packname="gst-plugins-good-1.0.6.tar.xz"

export gst_plugins_good_1_0_6_C38_required_or_recommended="gst_plugins_base_1_0_6_C38 Cairo_1_12_14_C25 FLAC_1_2_1_C38 gdk_pixbuf_2_26_5_C25 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 libsoup_2_40_3_C17 libvpx_v1_1_0_C38 Xorg_Libraries_C24 "

gst_plugins_bad_1_0_6_C38(){

./configure --prefix=/usr \
            --with-package-name="GStreamer Bad Plugins 1.0.6 BLFS" \
            --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
make
make install
}

export gst_plugins_bad_1_0_6_C38_download="http://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.0.6.tar.xz "

export gst_plugins_bad_1_0_6_C38_packname="gst-plugins-bad-1.0.6.tar.xz"

export gst_plugins_bad_1_0_6_C38_required_or_recommended="gst_plugins_base_1_0_6_C38 Libdvdread_4_2_0_C38 Libdvdnav_4_2_0_C38 SoundTouch_1_7_1_C38 "

gst_plugins_ugly_1_0_6_C38(){

./configure --prefix=/usr \
            --with-package-name="GStreamer Ugly Plugins 1.0.6 BLFS" \
            --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
make
make install
}

export gst_plugins_ugly_1_0_6_C38_download="http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.0.6.tar.xz "

export gst_plugins_ugly_1_0_6_C38_packname="gst-plugins-ugly-1.0.6.tar.xz"

export gst_plugins_ugly_1_0_6_C38_required_or_recommended="gst_plugins_base_1_0_6_C38 LAME_3_99_5_C39 Libdvdread_4_2_0_C38 "

gst_libav_1_0_6_C38(){

./configure --prefix=/usr \
            --with-package-name="GStreamer Libav Plugins 1.0.6 BLFS" \
            --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
make
make install
}

export gst_libav_1_0_6_C38_download="http://gstreamer.freedesktop.org/src/gst-libav/gst-libav-1.0.6.tar.xz "

export gst_libav_1_0_6_C38_packname="gst-libav-1.0.6.tar.xz"

export gst_libav_1_0_6_C38_required_or_recommended="gst_plugins_base_1_0_6_C38 yasm_1_2_0_C13 "

Liba52_0_7_4_C38(){

./configure --prefix=/usr \
            --mandir=/usr/share/man \
            --enable-shared \
            --disable-static \
           CFLAGS="-g -O2 $([ $(uname -m) = x86_64 ] && echo -fPIC)" &&
make
make install &&
cp liba52/a52_internal.h /usr/include/a52dec &&
install -v -m644 -D doc/liba52.txt \
    /usr/share/doc/liba52-0.7.4/liba52.txt
}

export Liba52_0_7_4_C38_download="http://liba52.sourceforge.net/files/a52dec-0.7.4.tar.gz "

export Liba52_0_7_4_C38_packname="a52dec-0.7.4.tar.gz"

Libao_1_1_0_C38(){

./configure --prefix=/usr &&
make
make install &&
install -v -m644 README /usr/share/doc/libao-1.1.0
}

export Libao_1_1_0_C38_download="http://downloads.xiph.org/releases/ao/libao-1.1.0.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libao-1.1.0.tar.gz "

export Libao_1_1_0_C38_packname="libao-1.1.0.tar.gz"

libcanberra_0_30_C38(){

./configure --prefix=/usr --disable-oss &&
make
make docdir=/usr/share/doc/libcanberra/0.30 install
}

export libcanberra_0_30_C38_download="http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz "

export libcanberra_0_30_C38_packname="libcanberra-0.30.tar.xz"

export libcanberra_0_30_C38_required_or_recommended="libvorbis_1_3_3_C38 alsa_lib_1_0_26_C38 GStreamer_1_0_6_C38 GTK_3_6_4_C25 "

libdiscid_0_3_2_C38(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libdiscid_0_3_2_C38_download="http://ftp.musicbrainz.org/pub/musicbrainz/libdiscid/libdiscid-0.3.2.tar.gz "

export libdiscid_0_3_2_C38_packname="libdiscid-0.3.2.tar.gz"

libdvdcss_1_2_13_C38(){

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libdvdcss-1.2.13 &&
make
make install
}

export libdvdcss_1_2_13_C38_download="http://www.videolan.org/pub/libdvdcss/1.2.13/libdvdcss-1.2.13.tar.bz2 "

export libdvdcss_1_2_13_C38_packname="libdvdcss-1.2.13.tar.bz2"

Libdvdread_4_2_0_C38(){

./autogen.sh --prefix=/usr &&
make
make install
}

export Libdvdread_4_2_0_C38_download="http://dvdnav.mplayerhq.hu/releases/libdvdread-4.2.0.tar.bz2 "

export Libdvdread_4_2_0_C38_packname="libdvdread-4.2.0.tar.bz2"

Libdvdnav_4_2_0_C38(){

./autogen.sh --prefix=/usr &&
make
make install
}

export Libdvdnav_4_2_0_C38_download="http://dvdnav.mplayerhq.hu/releases/libdvdnav-4.2.0.tar.bz2 "

export Libdvdnav_4_2_0_C38_packname="libdvdnav-4.2.0.tar.bz2"

export Libdvdnav_4_2_0_C38_required_or_recommended="Libdvdread_4_2_0_C38 "

Libdv_1_0_0_C38(){

./configure --prefix=/usr \
            --disable-xv \
            --disable-static &&
make
make install &&
install -v -m755 -d      /usr/share/doc/libdv-1.0.0 &&
install -v -m644 README* /usr/share/doc/libdv-1.0.0
}

export Libdv_1_0_0_C38_download="http://downloads.sourceforge.net/libdv/libdv-1.0.0.tar.gz "

export Libdv_1_0_0_C38_packname="libdv-1.0.0.tar.gz"

libmad_0_15_1b_C38(){

sed -i '/-fforce-mem/d' configure &&
./configure --prefix=/usr &&
make
make install
cat > /usr/lib/pkgconfig/mad.pc << "EOF"
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: mad
Description: MPEG audio decoder
Requires:
Version: 0.15.1b
Libs: -L${libdir} -lmad
Cflags: -I${includedir}
EOF

}

export libmad_0_15_1b_C38_download="http://downloads.sourceforge.net/mad/libmad-0.15.1b.tar.gz ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz "

export libmad_0_15_1b_C38_packname="libmad-0.15.1b.tar.gz"

libmpeg2_0_5_1_C38(){

sed -i 's/static const/static/' libmpeg2/idct_mmx.c &&
./configure --prefix=/usr                           &&
make
make install &&
install -v -m755 -d /usr/share/doc/mpeg2dec-0.5.1 &&
install -v -m644 README doc/libmpeg2.txt \
                    /usr/share/doc/mpeg2dec-0.5.1
}

export libmpeg2_0_5_1_C38_download="http://libmpeg2.sourceforge.net/files/libmpeg2-0.5.1.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libmpeg2-0.5.1.tar.gz "

export libmpeg2_0_5_1_C38_packname="libmpeg2-0.5.1.tar.gz"

libMPEG3_1_8_C38(){

patch -Np1 -i ../libmpeg3-1.8-makefile_fixes-2.patch &&
make
make install
}

export libMPEG3_1_8_C38_download="http://downloads.sourceforge.net/heroines/libmpeg3-1.8-src.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/libmpeg3-1.8-makefile_fixes-2.patch "

export libMPEG3_1_8_C38_packname="libmpeg3-1.8-src.tar.bz2"

export libMPEG3_1_8_C38_required_or_recommended="Liba52_0_7_4_C38 NASM_2_10_07_C13 "

libmusicbrainz_2_1_5_C38(){

patch -Np1 -i ../libmusicbrainz-2.1.5-missing-includes-1.patch &&
./configure --prefix=/usr &&
make
(cd python && python setup.py build)
make install &&
install -v -m644 -D docs/mb_howto.txt \
    /usr/share/doc/libmusicbrainz-2.1.5/mb_howto.txt
(cd python && python setup.py install)
}

export libmusicbrainz_2_1_5_C38_download="http://ftp.musicbrainz.org/pub/musicbrainz/libmusicbrainz-2.1.5.tar.gz ftp://ftp.musicbrainz.org/pub/musicbrainz/libmusicbrainz-2.1.5.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/libmusicbrainz-2.1.5-missing-includes-1.patch "

export libmusicbrainz_2_1_5_C38_packname="libmusicbrainz-2.1.5.tar.gz"

libmusicbrainz_3_0_3_C38(){

cmake -DCMAKE_INSTALL_PREFIX=/usr . &&
make
make install
}

export libmusicbrainz_3_0_3_C38_download="http://ftp.musicbrainz.org/pub/musicbrainz/libmusicbrainz-3.0.3.tar.gz "

export libmusicbrainz_3_0_3_C38_packname="libmusicbrainz-3.0.3.tar.gz"

export libmusicbrainz_3_0_3_C38_required_or_recommended="CMake_2_8_10_2_C13 libdiscid_0_3_2_C38 neon_0_29_6_C17 "

libmusicbrainz_5_0_1_C38(){

patch -Np1 -i ../libmusicbrainz-5.0.1-build_system-1.patch &&
mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr .. &&
make
make install
}

export libmusicbrainz_5_0_1_C38_download="https://github.com/downloads/metabrainz/libmusicbrainz/libmusicbrainz-5.0.1.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/libmusicbrainz-5.0.1-build_system-1.patch "

export libmusicbrainz_5_0_1_C38_packname="libmusicbrainz-5.0.1.tar.gz"

export libmusicbrainz_5_0_1_C38_required_or_recommended="CMake_2_8_10_2_C13 neon_0_29_6_C17 "

libogg_1_3_0_C38(){

./configure --prefix=/usr &&
make
make install
}

export libogg_1_3_0_C38_download="http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.xz "

export libogg_1_3_0_C38_packname="libogg-1.3.0.tar.xz"

libquicktime_1_2_4_C38(){

./configure --prefix=/usr \
            --docdir=/usr/share/doc/libquicktime-1.2.4 \
            --enable-gpl \
            --without-doxygen &&
make
make install &&
install -v -m755 -d /usr/share/doc/libquicktime-1.2.4 &&
install -v -m644    README doc/{*.txt,*.html,mainpage.incl} \
                    /usr/share/doc/libquicktime-1.2.4
}

export libquicktime_1_2_4_C38_download="http://downloads.sourceforge.net/libquicktime/libquicktime-1.2.4.tar.gz "

export libquicktime_1_2_4_C38_packname="libquicktime-1.2.4.tar.gz"

libsamplerate_0_1_8_C38(){

./configure --prefix=/usr &&
make
make install
}

export libsamplerate_0_1_8_C38_download="http://www.mega-nerd.com/SRC/libsamplerate-0.1.8.tar.gz "

export libsamplerate_0_1_8_C38_packname="libsamplerate-0.1.8.tar.gz"

libsndfile_1_0_25_C38(){

./configure --prefix=/usr &&
make
make htmldocdir=/usr/share/doc/libsndfile-1.0.25 install
}

export libsndfile_1_0_25_C38_download="http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz "

export libsndfile_1_0_25_C38_packname="libsndfile-1.0.25.tar.gz"

libtheora_1_1_1_C38(){

./configure --prefix=/usr &&
make
make install
cd examples/.libs &&
for E in *; do
install -v -m755 $E /usr/bin/theora_${E}; done
}

export libtheora_1_1_1_C38_download="http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2 "

export libtheora_1_1_1_C38_packname="libtheora-1.1.1.tar.bz2"

export libtheora_1_1_1_C38_required_or_recommended="libogg_1_3_0_C38 libvorbis_1_3_3_C38 "

libvorbis_1_3_3_C38(){

./configure --prefix=/usr --disable-static &&
make
make install &&
install -v -m644 doc/Vorbis* /usr/share/doc/libvorbis-1.3.3
}

export libvorbis_1_3_3_C38_download="http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.xz "

export libvorbis_1_3_3_C38_packname="libvorbis-1.3.3.tar.xz"

export libvorbis_1_3_3_C38_required_or_recommended="libogg_1_3_0_C38 "

libvpx_v1_1_0_C38(){

mkdir ../libvpx-build &&
cd ../libvpx-build &&
../libvpx-v1.1.0/configure --prefix=/usr \
                           --enable-shared \
                           --disable-static &&
make
make install
}

export libvpx_v1_1_0_C38_download="http://webm.googlecode.com/files/libvpx-v1.1.0.tar.bz2 "

export libvpx_v1_1_0_C38_packname="libvpx-v1.1.0.tar.bz2"

export libvpx_v1_1_0_C38_required_or_recommended="yasm_1_2_0_C13 NASM_2_10_07_C13 Which_2_20_and_Alternatives_C12 "

Opal_3_10_10_C38(){

patch -Np1 -i ../opal-3.10.10-ffmpeg-1.patch &&
./configure --prefix=/usr &&
make
make install &&
chmod -v 644 /usr/lib/libopal_s.a
}

export Opal_3_10_10_C38_download="http://ftp.gnome.org/pub/gnome/sources/opal/3.10/opal-3.10.10.tar.xz ftp://ftp.gnome.org/pub/gnome/sources/opal/3.10/opal-3.10.10.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/opal-3.10.10-ffmpeg-1.patch "

export Opal_3_10_10_C38_packname="opal-3.10.10.tar.xz"

export Opal_3_10_10_C38_required_or_recommended="Ptlib_2_10_10_C9 "

PulseAudio_3_0_C38(){

groupadd -g 58 pulse &&
groupadd -g 59 pulse-access &&
useradd -c "Pulseaudio User" -d /var/run/pulse -g pulse \
        -s /bin/false -u 58 pulse &&
usermod -a -G audio pulse
find . -name "Makefile.in" | xargs sed -i "s|(libdir)/@PACKAGE@|(libdir)/pulse|" &&
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib \
            --with-module-dir=/usr/lib/pulse/modules &&
make
make install
}

export PulseAudio_3_0_C38_download="http://freedesktop.org/software/pulseaudio/releases/pulseaudio-3.0.tar.xz "

export PulseAudio_3_0_C38_packname="pulseaudio-3.0.tar.xz"

export PulseAudio_3_0_C38_required_or_recommended="Intltool_0_50_2_C11 JSON_C_0_10_C9 libsndfile_1_0_25_C38 pkg_config_0_28_C13 alsa_lib_1_0_26_C38 D_Bus_1_6_8_C12 libcap2_2_22_C4 OpenSSL_1_0_1e_C4 Speex_1_2rc1_C38 Xorg_Libraries_C24 "

SDL_1_2_15_C38(){

./configure --prefix=/usr &&
make
make install &&

install -v -m755 -d /usr/share/doc/SDL-1.2.15/html &&
install -v -m644    docs/html/*.html \
                    /usr/share/doc/SDL-1.2.15/html
cd test &&
./configure &&
make
}

export SDL_1_2_15_C38_download="http://www.libsdl.org/release/SDL-1.2.15.tar.gz "

export SDL_1_2_15_C38_packname="SDL-1.2.15.tar.gz"

SoundTouch_1_7_1_C38(){

./bootstrap &&
./configure --prefix=/usr &&
make
make pkgdocdir=/usr/share/doc/soundtouch-1.7.1 install 
}

export SoundTouch_1_7_1_C38_download="http://www.surina.net/soundtouch/soundtouch-1.7.1.tar.gz "

export SoundTouch_1_7_1_C38_packname="soundtouch-1.7.1.tar.gz"

Speex_1_2rc1_C38(){

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/speex-1.2rc1 &&
make
make install
}

export Speex_1_2rc1_C38_download="http://downloads.us.xiph.org/releases/speex/speex-1.2rc1.tar.gz "

export Speex_1_2rc1_C38_packname="speex-1.2rc1.tar.gz"

export Speex_1_2rc1_C38_required_or_recommended="libogg_1_3_0_C38 "

Taglib_1_8_C38(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release  \
      .. &&
make
make install
}

export Taglib_1_8_C38_download="https://github.com/downloads/taglib/taglib/taglib-1.8.tar.gz "

export Taglib_1_8_C38_packname="taglib-1.8.tar.gz"

export Taglib_1_8_C38_required_or_recommended="CMake_2_8_10_2_C13 "

xine_lib_1_2_2_C38(){

./configure --prefix=/usr \
            --disable-vcd \
            --docdir=/usr/share/doc/xine-lib-1.2.2 &&
make
doxygen doc/Doxyfile
make install
install -v -m755 -d /usr/share/doc/xine-lib-1.2.2/api &&
install -v -m644    doc/api/* \
                    /usr/share/doc/xine-lib-1.2.2/api
}

export xine_lib_1_2_2_C38_download="http://downloads.sourceforge.net/xine/xine-lib-1.2.2.tar.xz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xine-lib-1.2.2.tar.xz "

export xine_lib_1_2_2_C38_packname="xine-lib-1.2.2.tar.xz"

export xine_lib_1_2_2_C38_required_or_recommended="XWindowSystemEnvironment FFmpeg_1_2_C40 ALSA_1_0_26_C38 PulseAudio_3_0_C38 "

XviD_1_3_2_C38(){

cd build/generic &&
./configure --prefix=/usr &&
make
make install &&

chmod -v 755 /usr/lib/libxvidcore.so.4.3 &&
ln -v -sf libxvidcore.so.4.3 /usr/lib/libxvidcore.so.4 &&
ln -v -sf libxvidcore.so.4   /usr/lib/libxvidcore.so   &&

install -v -m755 -d /usr/share/doc/xvidcore-1.3.2/examples &&
install -v -m644 ../../doc/* /usr/share/doc/xvidcore-1.3.2 &&
install -v -m644 ../../examples/* \
    /usr/share/doc/xvidcore-1.3.2/examples
}

export XviD_1_3_2_C38_download="http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz "

export XviD_1_3_2_C38_packname="xvidcore-1.3.2.tar.gz"

export C38_MultimediaLibrariesandDrivers="ALSA_1_0_26_C38 alsa_lib_1_0_26_C38 alsa_plugins_1_0_26_C38 alsa_utils_1_0_26_C38 alsa_tools_1_0_25_C38 alsa_firmware_1_0_25_C38 ALSA_OSS_1_0_25_C38 AudioFile_0_3_6_C38 EsounD_0_2_41_C38 FAAC_1_28_C38 FAAD2_2_7_C38 Farstream_0_2_2_C38 FLAC_1_2_1_C38 GStreamer_0_10_36_C38 gst_plugins_base_0_10_36_C38 gst_plugins_good_0_10_31_C38 gst_plugins_bad_0_10_23_C38 gst_plugins_ugly_0_10_19_C38 gst_ffmpeg_0_10_13_C38 GStreamer_1_0_6_C38 gst_plugins_base_1_0_6_C38 gst_plugins_good_1_0_6_C38 gst_plugins_bad_1_0_6_C38 gst_plugins_ugly_1_0_6_C38 gst_libav_1_0_6_C38 Liba52_0_7_4_C38 Libao_1_1_0_C38 libcanberra_0_30_C38 libdiscid_0_3_2_C38 libdvdcss_1_2_13_C38 Libdvdread_4_2_0_C38 Libdvdnav_4_2_0_C38 Libdv_1_0_0_C38 libmad_0_15_1b_C38 libmpeg2_0_5_1_C38 libMPEG3_1_8_C38 libmusicbrainz_2_1_5_C38 libmusicbrainz_3_0_3_C38 libmusicbrainz_5_0_1_C38 libogg_1_3_0_C38 libquicktime_1_2_4_C38 libsamplerate_0_1_8_C38 libsndfile_1_0_25_C38 libtheora_1_1_1_C38 libvorbis_1_3_3_C38 libvpx_v1_1_0_C38 Opal_3_10_10_C38 PulseAudio_3_0_C38 SDL_1_2_15_C38 SoundTouch_1_7_1_C38 Speex_1_2rc1_C38 Taglib_1_8_C38 xine_lib_1_2_2_C38 XviD_1_3_2_C38 "


Mpg123_1_15_1_C39(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export Mpg123_1_15_1_C39_download="http://downloads.sourceforge.net/mpg123/mpg123-1.15.1.tar.bz2 "

export Mpg123_1_15_1_C39_packname="mpg123-1.15.1.tar.bz2"

export Mpg123_1_15_1_C39_required_or_recommended="alsa_lib_1_0_26_C38 "

vorbis_tools_1_4_0_C39(){

./configure --prefix=/usr \
            --enable-vcut \
            --without-curl &&
make
make install
}

export vorbis_tools_1_4_0_C39_download="http://downloads.xiph.org/releases/vorbis/vorbis-tools-1.4.0.tar.gz "

export vorbis_tools_1_4_0_C39_packname="vorbis-tools-1.4.0.tar.gz"

export vorbis_tools_1_4_0_C39_required_or_recommended="libvorbis_1_3_3_C38 "

LAME_3_99_5_C39(){

./configure --prefix=/usr --enable-mp3rtp --disable-static &&
make
make pkghtmldir=/usr/share/doc/lame-3.99.5 install
}

export LAME_3_99_5_C39_download="http://downloads.sourceforge.net/lame/lame-3.99.5.tar.gz "

export LAME_3_99_5_C39_packname="lame-3.99.5.tar.gz"

CDParanoia_III_10_2_C39(){

patch -Np1 -i ../cdparanoia-III-10.2-gcc_fixes-1.patch &&
./configure --prefix=/usr &&
make
make install &&
chmod -v 755 /usr/lib/libcdda_*.so.0.10.2
}

export CDParanoia_III_10_2_C39_download="http://downloads.xiph.org/releases/cdparanoia/cdparanoia-III-10.2.src.tgz http://www.linuxfromscratch.org/patches/blfs/svn/cdparanoia-III-10.2-gcc_fixes-1.patch "

export CDParanoia_III_10_2_C39_packname="cdparanoia-III-10.2.src.tgz"

FreeTTS_1_2_2_C39(){

unzip -q freetts-1.2.2-src.zip -x META-INF/* &&
unzip -q freetts-1.2.2-tst.zip -x META-INF/*
sed -i 's/value="src/value="./' build.xml &&
cd lib      &&
sh jsapi.sh &&
cd ..       &&
ant
ant junit &&
cd tests &&
sh regression.sh &&
cd ..

install -v -m755 -d /opt/freetts-1.2.2/{lib,docs/{audio,images}} &&
install -v -m644 lib/*.jar /opt/freetts-1.2.2/lib                &&
install -v -m644 *.txt RELEASE_NOTES docs/*.{pdf,html,txt,sx{w,d}} \
                               /opt/freetts-1.2.2/docs           &&
install -v -m644 docs/audio/*  /opt/freetts-1.2.2/docs/audio     &&
install -v -m644 docs/images/* /opt/freetts-1.2.2/docs/images    &&
cp -v -R javadoc               /opt/freetts-1.2.2                &&
ln -v -s freetts-1.2.2 /opt/freetts
cp -v -R bin    /opt/freetts-1.2.2        &&
install -v -m644 speech.properties $JAVA_HOME/jre/lib &&
cp -v -R tools  /opt/freetts-1.2.2        &&
cp -v -R mbrola /opt/freetts-1.2.2        &&
cp -v -R demo   /opt/freetts-1.2.2
java -jar /opt/freetts/lib/freetts.jar \
    -text "This is a test of the FreeTTS speech synthesis system"
java -jar /opt/freetts/lib/freetts.jar -streaming \
    -text "This is a test of the FreeTTS speech synthesis system"
}

export FreeTTS_1_2_2_C39_download="http://downloads.sourceforge.net/freetts/freetts-1.2.2-src.zip http://downloads.sourceforge.net/freetts/freetts-1.2.2-tst.zip "

export FreeTTS_1_2_2_C39_packname="freetts-1.2.2-src.zip"

export FreeTTS_1_2_2_C39_required_or_recommended="apache_ant_1_8_4_C12 Sharutils_4_13_3_C11 "

Audacious_3_3_3_C39(){

TPUT=/bin/true ./configure --prefix=/usr &&
make
make install
install -v -m755 -d /usr/share/doc/audacious-3.3.3/api &&
install -v -m644    doc/html/* \
                    /usr/share/doc/audacious-3.3.3/api
export LIBRARY_PATH=$XORG_PREFIX/lib
patch -Np1 -i ../audacious-plugins-3.3.3-libcdio_v0.90_fixes-1.patch &&
TPUT=/bin/true ./configure --prefix=/usr &&
make
make install
gtk-update-icon-cache &&
update-desktop-database
}

export Audacious_3_3_3_C39_download="http://distfiles.audacious-media-player.org/audacious-3.3.3.tar.bz2 http://distfiles.audacious-media-player.org/audacious-plugins-3.3.3.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/audacious-plugins-3.3.3-libcdio_v0.90_fixes-1.patch "

export Audacious_3_3_3_C39_packname="audacious-3.3.3.tar.bz2"

export Audacious_3_3_3_C39_required_or_recommended="GTK_3_6_4_C25 libxml2_2_9_0_C9 "

Amarok_2_7_0_C39(){

mkdir build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DCMAKE_BUILD_TYPE=Release         \
      .. &&
make
make install
}

export Amarok_2_7_0_C39_download="http://download.kde.org/stable/amarok/2.7.0/src/amarok-2.7.0.tar.bz2 ftp://ftp.kde.org/pub/kde/stable/amarok/2.7.0/src/amarok-2.7.0.tar.bz2 "

export Amarok_2_7_0_C39_packname="amarok-2.7.0.tar.bz2"

export Amarok_2_7_0_C39_required_or_recommended="Kdelibs_4_10_1_C28 MySQL_5_5_30_C22 Taglib_1_8_C38 FFmpeg_1_2_C40 Nepomuk_core_4_10_1_C28 "

gvolwheel_1_0_C39(){

sed -i 's%doc/gvolwheel%share/doc/gvolwheel-1.0%' Makefile.in &&
./configure --prefix=/usr --enable-oss &&
make
make install
}

export gvolwheel_1_0_C39_download="http://sourceforge.net/projects/gvolwheel/files/gvolwheel-1.0.tar.gz gvolwheel.html "

export gvolwheel_1_0_C39_packname="gvolwheel-1.0.tar.gz"

export gvolwheel_1_0_C39_required_or_recommended="alsa_utils_1_0_26_C38 GTK_3_6_4_C25 Intltool_0_50_2_C11 XML_Parser_2_41_C13 "

export C39_AudioUtilities="Mpg123_1_15_1_C39 vorbis_tools_1_4_0_C39 LAME_3_99_5_C39 CDParanoia_III_10_2_C39 FreeTTS_1_2_2_C39 Audacious_3_3_3_C39 Amarok_2_7_0_C39 gvolwheel_1_0_C39 "


FFmpeg_1_2_C40(){

export LIBRARY_PATH=$XORG_PREFIX/lib
sed -i 's/-lflite"/-lflite -lasound"/' configure &&
./configure --prefix=/usr        \
            --enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --disable-static     \
            --enable-shared      \
            --enable-x11grab     \
            --enable-libfaac     \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopenjpeg \
            --enable-libpulse    \
            --enable-libspeex    \
            --enable-libtheora   \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libxvid     \
            --enable-openssl     \
            --disable-debug      &&
make &&
gcc tools/qt-faststart.c -o tools/qt-faststart &&
unset LIBRARY_PATH
pushd doc &&
for DOCNAME in `basename -s .html *.html`
do
    texi2pdf -b $DOCNAME.texi &&
    texi2dvi -b $DOCNAME.texi &&
    dvips -o    $DOCNAME.ps   \
                $DOCNAME.dvi
done                          &&
popd                          &&
unset DOCNAME
make install &&
install -v -m755    tools/qt-faststart /usr/bin &&
install -v -m755 -d /usr/share/doc/ffmpeg-1.2 &&
install -v -m644    doc/*.txt \
                    /usr/share/doc/ffmpeg-1.2
install -v -m644 doc/*.html \
                 /usr/share/doc/ffmpeg-1.2
install -v -m755 -d /usr/share/doc/ffmpeg-1.2/api &&
install -v -m644    doc/doxy/html/* \
                    /usr/share/doc/ffmpeg-1.2/api
}

export FFmpeg_1_2_C40_download="http://ffmpeg.org/releases/ffmpeg-1.2.tar.bz2 "

export FFmpeg_1_2_C40_packname="ffmpeg-1.2.tar.bz2"

export FFmpeg_1_2_C40_required_or_recommended="FAAC_1_28_C38 FreeType_2_4_11_C10 LAME_3_99_5_C39 OpenJPEG_1_5_1_C10 PulseAudio_3_0_C38 Speex_1_2rc1_C38 libtheora_1_1_1_C38 libvorbis_1_3_3_C38 libvpx_v1_1_0_C38 XviD_1_3_2_C38 OpenSSL_1_0_1e_C4 SDL_1_2_15_C38 Xorg_Libraries_C24 yasm_1_2_0_C13 "

export Introduction_to_MPlayer_C40_download="http://www.mplayerhq.hu/MPlayer/releases/MPlayer-1.1.tar.xz ftp://ftp.mplayerhq.hu/MPlayer/releases/MPlayer-1.1.tar.xz http://www.mplayerhq.hu/MPlayer/skins/Clearlooks-1.5.tar.bz2 ftp://ftp.mplayerhq.hu/MPlayer/skins/Clearlooks-1.5.tar.bz2  "

export Introduction_to_MPlayer_C40_packname="MPlayer-1.1.tar.xz"

export Introduction_to_MPlayer_C40_required_or_recommended="yasm_1_2_0_C13 GTK_2_24_17_C25 "

Installation_of_MPlayer_C40(){

./configure --prefix=/usr            \
            --confdir=/etc/mplayer   \
            --enable-dynamic-plugins \
            --enable-menu            \
            --enable-gui             &&
make
make doc
make install
install -v -m755 -d /usr/share/doc/mplayer-1.1 &&
install -v -m644    DOCS/HTML/en/* \
                    /usr/share/doc/mplayer-1.1
install -v -m644 etc/codecs.conf /etc/mplayer
install -v -m644 etc/*.conf /etc/mplayer
gtk-update-icon-cache &&
update-desktop-database
tar -xvf ../Clearlooks-1.5.tar.bz2 \
       -C /usr/share/mplayer/skins &&
ln -sfv Clearlooks /usr/share/mplayer/skins/default
}

Transcode_1_1_7_C40(){

sed -i 's|doc/transcode|&-$(PACKAGE_VERSION)|' \
       $(find . -name Makefile.in -exec grep -l 'docsdir =' {} \;) &&
patch -Np1 -i ../transcode-1.1.7-ffmpeg-2.patch &&
./configure --prefix=/usr \
            --enable-alsa \
            --enable-libmpeg2 &&
make
make install
}

export Transcode_1_1_7_C40_download="https://bitbucket.org/france/transcode-tcforge/downloads/transcode-1.1.7.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/transcode-1.1.7.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/transcode-1.1.7-ffmpeg-2.patch "

export Transcode_1_1_7_C40_packname="transcode-1.1.7.tar.bz2"

export Transcode_1_1_7_C40_required_or_recommended="FFmpeg_1_2_C40 alsa_lib_1_0_26_C38 LAME_3_99_5_C39 libmpeg2_0_5_1_C38 Xorg_Libraries_C24 "

VLC_2_0_5_C40(){

patch -Np1 -i ../vlc-2.0.5-opencv_fixes-1.patch &&
sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac &&
./bootstrap &&
sed -e "s@LDFLAGS_sid)@& -L/usr/lib/sidplay/builders@g" \
    -i modules/demux/Makefile.in &&

./configure --prefix=/usr --disable-lua &&
make
make docdir=/usr/share/doc/vlc-2.0.5 install
gtk-update-icon-cache &&
update-desktop-database
}

export VLC_2_0_5_C40_download="http://download.videolan.org/pub/videolan/vlc/2.0.5/vlc-2.0.5.tar.xz ftp://ftp.videolan.org/pub/videolan/vlc/2.0.5/vlc-2.0.5.tar.xz http://www.linuxfromscratch.org/patches/blfs/svn/vlc-2.0.5-opencv_fixes-1.patch "

export VLC_2_0_5_C40_packname="vlc-2.0.5.tar.xz"

export VLC_2_0_5_C40_required_or_recommended="D_Bus_1_6_8_C12 alsa_lib_1_0_26_C38 FFmpeg_1_2_C40 GnuTLS_3_1_10_C4 Liba52_0_7_4_C38 libgcrypt_1_5_1_C9 libmad_0_15_1b_C38 Qt_4_8_4_C25 "

xine_ui_0_99_7_C40(){

./configure --prefix=/usr &&
make
make docsdir=/usr/share/doc/xine-ui-0.99.7 install
gtk-update-icon-cache &&
update-desktop-database
}

export xine_ui_0_99_7_C40_download="http://downloads.sourceforge.net/xine/xine-ui-0.99.7.tar.xz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xine-ui-0.99.7.tar.xz "

export xine_ui_0_99_7_C40_packname="xine-ui-0.99.7.tar.xz"

export xine_ui_0_99_7_C40_required_or_recommended="xine_lib_1_2_2_C38 shared_mime_info_1_1_C25 "

export C40_VideoUtilities="FFmpeg_1_2_C40 MPlayer_1_1_C40 Transcode_1_1_7_C40 VLC_2_0_5_C40 xine_ui_0_99_7_C40 "


Cdrdao_1_2_3_C41(){

sed -i '/ioctl/a #include <sys/stat.h>' dao/ScsiIf-linux.cc &&
./configure --prefix=/usr --mandir=/usr/share/man &&
make
make install &&
install -v -m755 -d /usr/share/doc/cdrdao-1.2.3 &&
install -v -m644 README /usr/share/doc/cdrdao-1.2.3
}

export Cdrdao_1_2_3_C41_download="http://downloads.sourceforge.net/cdrdao/cdrdao-1.2.3.tar.bz2 "

export Cdrdao_1_2_3_C41_packname="cdrdao-1.2.3.tar.bz2"

export Cdrdao_1_2_3_C41_required_or_recommended="Libao_1_1_0_C38 libvorbis_1_3_3_C38 libmad_0_15_1b_C38 LAME_3_99_5_C39 "

dvd_rw_tools_7_1_C41(){

sed -i '/stdlib/a #include <limits.h>' transport.hxx &&
sed -i 's#mkisofs"#xorrisofs"#' growisofs.c &&
sed -i 's#mkisofs#xorrisofs#;s#MKISOFS#XORRISOFS#' growisofs.1 &&
make all rpl8 btcflash
make prefix=/usr install &&
install -v -m644 -D index.html \
    /usr/share/doc/dvd+rw-tools-7.1/index.html
}

export dvd_rw_tools_7_1_C41_download="http://fy.chalmers.se/~appro/linux/DVD+RW/tools/dvd+rw-tools-7.1.tar.gz "

export dvd_rw_tools_7_1_C41_packname="dvd+rw-tools-7.1.tar.gz"

K3b_2_0_2_C41(){

patch -Np1 -i ../k3b-2.0.2-ffmpeg_fix-2.patch &&

mkdir build &&
cd    build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX \
      -DSYSCONF_INSTALL_DIR=/etc/kde     \
      ..  &&
make
make install
}

export K3b_2_0_2_C41_download="http://downloads.sourceforge.net/k3b/k3b-2.0.2.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/k3b-2.0.2-ffmpeg_fix-2.patch "

export K3b_2_0_2_C41_packname="k3b-2.0.2.tar.bz2"

export K3b_2_0_2_C41_required_or_recommended="Kde_runtime_4_10_1_C28 libkcddb_4_10_1_C29 libsamplerate_0_1_8_C38 FFmpeg_1_2_C40 Libdvdread_4_2_0_C38 libjpeg_turbo_1_2_1_C10 Taglib_1_8_C38 "

libburn_1_2_8_C41(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libburn_1_2_8_C41_download="http://files.libburnia-project.org/releases/libburn-1.2.8.tar.gz "

export libburn_1_2_8_C41_packname="libburn-1.2.8.tar.gz"

libisoburn_1_2_8_C41(){

./configure --prefix=/usr --disable-static &&
make
doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libisoburn-1.2.8 &&
install -v -m644 doc/html/* /usr/share/doc/libisoburn-1.2.8
}

export libisoburn_1_2_8_C41_download="http://files.libburnia-project.org/releases/libisoburn-1.2.8.tar.gz "

export libisoburn_1_2_8_C41_packname="libisoburn-1.2.8.tar.gz"

export libisoburn_1_2_8_C41_required_or_recommended="libburn_1_2_8_C41 libisofs_1_2_8_C41 "

libisofs_1_2_8_C41(){

./configure --prefix=/usr --disable-static &&
make
make install
}

export libisofs_1_2_8_C41_download="http://files.libburnia-project.org/releases/libisofs-1.2.8.tar.gz "

export libisofs_1_2_8_C41_packname="libisofs-1.2.8.tar.gz"

export C41_CDDVDWritingUtilities="Cdrdao_1_2_3_C41 dvd_rw_tools_7_1_C41 K3b_2_0_2_C41 libburn_1_2_8_C41 libisoburn_1_2_8_C41 libisofs_1_2_8_C41 "


Cups_1_6_2_C42(){

useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp
groupadd -g 19 lpadmin
usermod -a -G lpadmin mao

sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in
patch -Np1 -i ../cups-1.6.2-blfs-1.patch &&
aclocal -I config-scripts &&
autoconf -I config-scripts &&
./configure --libdir=/usr/lib \
            --with-rcdir=/tmp/cupsinit \
            --with-docdir=/usr/share/cups/doc \
            --with-system-groups=lpadmin &&
make
make install &&
rm -rf /tmp/cupsinit &&
ln -sfv ../cups/doc /usr/share/doc/cups-1.6.2
echo "ServerName /var/run/cups/cups.sock" > /etc/cups/client.conf
rm -rf /usr/share/cups/banners &&
rm -rf /usr/share/cups/data/testprint
gtk-update-icon-cache
exec 1>&3
time pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"
exec 3>&1
make install-cups
}

export Cups_1_6_2_C42_download="http://ftp.easysw.com/pub/cups/1.6.2/cups-1.6.2-source.tar.bz2 ftp://ftp.easysw.com/pub/cups/1.6.2/cups-1.6.2-source.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/cups-1.6.2-blfs-1.patch "

export Cups_1_6_2_C42_packname="cups-1.6.2-source.tar.bz2"

export Cups_1_6_2_C42_required_or_recommended="Colord_0_1_31_C12 D_Bus_1_6_8_C12 libusb_1_0_9_C9 "

cups_filters_1_0_31_C42(){

./configure --prefix=/usr                               \
            --sysconfdir=/etc                           \
            --docdir=/usr/share/doc/cups-filters-1.0.31 \
            --without-rcdir                             \
            --with-gs-path=/usr/bin/gs                  \
            --with-pdftops-path=/usr/bin/gs             \
            --disable-avahi                             \
            --disable-static                            &&
make
make install
}

export cups_filters_1_0_31_C42_download="http://www.openprinting.org/download/cups-filters/cups-filters-1.0.31.tar.xz "

export cups_filters_1_0_31_C42_packname="cups-filters-1.0.31.tar.xz"

export cups_filters_1_0_31_C42_required_or_recommended="Cups_1_6_2_C42 IJS_0_35_C10 Little_CMS_2_4_C10 Poppler_0_22_2_C10 Qpdf_4_0_1_C10 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 LibTIFF_4_0_3_C10 "

ghostscript_9_06_C42(){

rm -rf expat freetype jpeg lcms2 libpng tiff
rm -rf jasper lcms zlib &&
./configure --prefix=/usr --enable-dynamic --with-system-libtiff LIBS=-lz &&
make
make so
bin/gs -Ilib -dBATCH examples/tiger.eps
make install
make soinstall &&
install -v -m644 base/*.h /usr/include/ghostscript &&
ln -v -s ghostscript /usr/include/ps
ln -sfv ../ghostscript/9.06/doc /usr/share/doc/ghostscript-9.06
tar -xvf ../<font-tarball> -C /usr/share/ghostscript --no-same-owner

}

export ghostscript_9_06_C42_download="http://downloads.ghostscript.com/public/ghostscript-9.06.tar.bz2 http://downloads.sourceforge.net/gs-fonts/ghostscript-fonts-std-8.11.tar.gz http://downloads.sourceforge.net/gs-fonts/gnu-gs-fonts-other-6.0.tar.gz "

export ghostscript_9_06_C42_packname="ghostscript-9.06.tar.bz2"

export ghostscript_9_06_C42_required_or_recommended="Expat_2_1_0_C9 FreeType_2_4_11_C10 libjpeg_turbo_1_2_1_C10 libpng_1_5_14_C10 LibTIFF_4_0_3_C10 Little_CMS_2_4_C10 "

Gutenprint_5_2_9_C42(){

sed -i 's|$(PACKAGE)/doc|doc/$(PACKAGE)-$(VERSION)|' \
       {,doc/,doc/developer/}Makefile.in &&
./configure --prefix=/usr --disable-static &&
make
make install &&
install -v -m755 -d /usr/share/doc/gutenprint-5.2.9/api/gutenprint{,ui2} &&
install -v -m644    doc/gutenprint/html/* \
                    /usr/share/doc/gutenprint-5.2.9/api/gutenprint &&
install -v -m644    doc/gutenprintui2/html/* \
                    /usr/share/doc/gutenprint-5.2.9/api/gutenprintui2
/etc/rc.d/init.d/cups restart
}

export Gutenprint_5_2_9_C42_download="http://downloads.sourceforge.net/gimp-print/gutenprint-5.2.9.tar.bz2 "

export Gutenprint_5_2_9_C42_packname="gutenprint-5.2.9.tar.bz2"

export Gutenprint_5_2_9_C42_required_or_recommended="Cups_1_6_2_C42 Gimp_2_8_4_C37 "

export C42_Printing="Cups_1_6_2_C42 cups_filters_1_0_31_C42 ghostscript_9_06_C42 Gutenprint_5_2_9_C42 "


export Introduction_to_SANE_C43_download="ftp://ftp2.sane-project.org/pub/sane/sane-backends-1.0.23.tar.gz http://alioth.debian.org/download.php/1140/sane-frontends-1.0.14.tar.gz ftp://ftp2.sane-project.org/pub/sane/sane-frontends-1.0.14/sane-frontends-1.0.14.tar.gz "

export Introduction_to_SANE_C43_packname="sane-backends-1.0.23.tar.gz"

Installation_of_SANE_C43(){

groupadd -g 70 scanner
su $(whoami)
./configure --prefix=/usr                                    \
            --sysconfdir=/etc                                \
            --localstatedir=/var                             \
            --with-docdir=/usr/share/doc/sane-backend-1.0.23 \
            --with-group=scanner                             &&
make                                                         &&
make install                                         &&
install -m 644 -v tools/udev/libsane.rules           \
                  /etc/udev/rules.d/65-scanner.rules &&
chgrp -v scanner  /var/lock/sane
sed -i -e "/SANE_CAP_ALWAYS_SETTABLE/d" src/gtkglue.c &&
./configure --prefix=/usr &&
make
make install &&
install -v -m644 doc/sane.png xscanimage-icon-48x48-2.png \
    /usr/share/sane
ln -v -s ../../../../bin/xscanimage /usr/lib/gimp/2.0/plug-ins
}

XSane_0_998_C43(){

sed -i -e 's/netscape/xdg-open/'                   src/xsane.h      &&
sed -i -e 's/png_ptr->jmpbuf/png_jmpbuf(png_ptr)/' src/xsane-save.c &&
./configure --prefix=/usr                                           &&
make
make xsanedocdir=/usr/share/doc/xsane-0.998 install &&
ln -v -s ../../doc/xsane-0.998 /usr/share/sane/xsane/doc &&
ln -v -s <browser> /usr/bin/netscape
ln -v -s /usr/bin/xsane /usr/lib/gimp/2.0/plug-ins/
}

export XSane_0_998_C43_download="ftp://ftp2.sane-project.org/pub/sane/xsane/xsane-0.998.tar.gz "

export XSane_0_998_C43_packname="xsane-0.998.tar.gz"

export XSane_0_998_C43_required_or_recommended="GTK_2_24_17_C25 SANE_1_0_23_C43 "

export C43_Scanning="SANE_1_0_23_C43 XSane_0_998_C43 "


sgml_common_0_6_3_C44(){

patch -Np1 -i ../sgml-common-0.6.3-manpage-1.patch &&
autoreconf -f -i
./configure --prefix=/usr --sysconfdir=/etc &&
make
make install &&
install-catalog --add /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&
install-catalog --add /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat
install-catalog --remove /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&
install-catalog --remove /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat
}

export sgml_common_0_6_3_C44_download="ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/sgml-common-0.6.3.tgz http://www.linuxfromscratch.org/patches/blfs/svn/sgml-common-0.6.3-manpage-1.patch "

export sgml_common_0_6_3_C44_packname="sgml-common-0.6.3.tgz"

docbook_3_1_C44(){

sed -i -e '/ISO 8879/d' \
    -e 's|DTDDECL "-//OASIS//DTD DocBook V3.1//EN"|SGMLDECL|g' \
    docbook.cat
install -v -d -m755 /usr/share/sgml/docbook/sgml-dtd-3.1 &&
chown -R root:root . &&
install -v docbook.cat /usr/share/sgml/docbook/sgml-dtd-3.1/catalog &&
cp -v -af *.dtd *.mod *.dcl /usr/share/sgml/docbook/sgml-dtd-3.1 &&
install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat \
    /usr/share/sgml/docbook/sgml-dtd-3.1/catalog &&
install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat \
    /etc/sgml/sgml-docbook.cat
cat >> /usr/share/sgml/docbook/sgml-dtd-3.1/catalog << "EOF"
  -- Begin Single Major Version catalog changes --

PUBLIC "-//Davenport//DTD DocBook V3.0//EN" "docbook.dtd"

  -- End Single Major Version catalog changes --
EOF

}

export docbook_3_1_C44_download="http://www.docbook.org/sgml/3.1/docbk31.zip ftp://ftp.kde.org/pub/kde/devel/docbook/SOURCES/docbk31.zip "

export docbook_3_1_C44_packname="docbk31.zip"

export docbook_3_1_C44_required_or_recommended="sgml_common_0_6_3_C44 UnZip_6_0_C12 "

docbook_4_5_C44(){

sed -i -e '/ISO 8879/d' \
    -e '/gml/d' docbook.cat
install -v -d /usr/share/sgml/docbook/sgml-dtd-4.5 &&
chown -R root:root . &&
install -v docbook.cat /usr/share/sgml/docbook/sgml-dtd-4.5/catalog &&
cp -v -af *.dtd *.mod *.dcl /usr/share/sgml/docbook/sgml-dtd-4.5 &&
install-catalog --add /etc/sgml/sgml-docbook-dtd-4.5.cat \
    /usr/share/sgml/docbook/sgml-dtd-4.5/catalog &&
install-catalog --add /etc/sgml/sgml-docbook-dtd-4.5.cat \
    /etc/sgml/sgml-docbook.cat
cat >> /usr/share/sgml/docbook/sgml-dtd-4.5/catalog << "EOF"
  -- Begin Single Major Version catalog changes --

PUBLIC "-//OASIS//DTD DocBook V4.4//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.3//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.2//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.1//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.0//EN" "docbook.dtd"

  -- End Single Major Version catalog changes --
EOF

}

export docbook_4_5_C44_download="http://www.docbook.org/sgml/4.5/docbook-4.5.zip "

export docbook_4_5_C44_packname="docbook-4.5.zip"

export docbook_4_5_C44_required_or_recommended="sgml_common_0_6_3_C44 UnZip_6_0_C12 "

OpenSP_1_5_2_C44(){

sed -i 's/32,/253,/' lib/Syntax.cxx &&
sed -i 's/LITLEN          240 /LITLEN          8092/' \
    unicode/{gensyntax.pl,unicode.syn} &&
./configure --prefix=/usr                              \
            --disable-static                           \
            --disable-doc-build                        \
            --enable-default-catalog=/etc/sgml/catalog \
            --enable-http                              \
            --enable-default-search-path=/usr/share/sgml &&
make pkgdatadir=/usr/share/sgml/OpenSP-1.5.2
make pkgdatadir=/usr/share/sgml/OpenSP-1.5.2 install &&
ln -v -sf onsgmls /usr/bin/nsgmls &&
ln -v -sf osgmlnorm /usr/bin/sgmlnorm &&
ln -v -sf ospam /usr/bin/spam &&
ln -v -sf ospcat /usr/bin/spcat &&
ln -v -sf ospent /usr/bin/spent &&
ln -v -sf osx /usr/bin/sx &&
ln -v -sf osx /usr/bin/sgml2xml &&
ln -v -sf libosp.so /usr/lib/libsp.so
}

export OpenSP_1_5_2_C44_download="http://downloads.sourceforge.net/openjade/OpenSP-1.5.2.tar.gz "

export OpenSP_1_5_2_C44_packname="OpenSP-1.5.2.tar.gz"

export OpenSP_1_5_2_C44_required_or_recommended="sgml_common_0_6_3_C44 "

OpenJade_1_3_2_C44(){

patch -Np1 -i ../openjade-1.3.2-gcc_4.6-1.patch
sed -i -e '/getopts/{N;s#&G#g#;s#do .getopts.pl.;##;}' \
       -e '/use POSIX/ause Getopt::Std;' msggen.pl
./configure --prefix=/usr                                \
            --enable-http                                \
            --disable-static                             \
            --enable-default-catalog=/etc/sgml/catalog   \
            --enable-default-search-path=/usr/share/sgml \
            --datadir=/usr/share/sgml/openjade-1.3.2   &&
make
make install                                                   &&
make install-man                                               &&
ln -v -sf openjade /usr/bin/jade                               &&
ln -v -sf libogrove.so /usr/lib/libgrove.so                    &&
ln -v -sf libospgrove.so /usr/lib/libspgrove.so                &&
ln -v -sf libostyle.so /usr/lib/libstyle.so                    &&

install -v -m644 dsssl/catalog /usr/share/sgml/openjade-1.3.2/ &&

install -v -m644 dsssl/*.{dtd,dsl,sgm}              \
    /usr/share/sgml/openjade-1.3.2                             &&

install-catalog --add /etc/sgml/openjade-1.3.2.cat  \
    /usr/share/sgml/openjade-1.3.2/catalog                     &&

install-catalog --add /etc/sgml/sgml-docbook.cat    \
    /etc/sgml/openjade-1.3.2.cat
echo "SYSTEM \"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd\" \
    \"/usr/share/xml/docbook/xml-dtd-4.5/docbookx.dtd\"" >> \
    /usr/share/sgml/openjade-1.3.2/catalog
}

export OpenJade_1_3_2_C44_download="http://downloads.sourceforge.net/openjade/openjade-1.3.2.tar.gz ftp://ftp.freestandards.org/pub/lsb/app-battery/packages/openjade-1.3.2.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/openjade-1.3.2-gcc_4.6-1.patch "

export OpenJade_1_3_2_C44_packname="openjade-1.3.2.tar.gz"

export OpenJade_1_3_2_C44_required_or_recommended="OpenSP_1_5_2_C44 "

docbook_dsssl_1_79_C44(){

tar -xf ../docbook-dsssl-doc-1.79.tar.bz2 --strip-components=1
install -v -m755 bin/collateindex.pl /usr/bin                      &&
install -v -m644 bin/collateindex.pl.1 /usr/share/man/man1         &&
install -v -d -m755 /usr/share/sgml/docbook/dsssl-stylesheets-1.79 &&
cp -v -R * /usr/share/sgml/docbook/dsssl-stylesheets-1.79          &&

install-catalog --add /etc/sgml/dsssl-docbook-stylesheets.cat \
    /usr/share/sgml/docbook/dsssl-stylesheets-1.79/catalog         &&

install-catalog --add /etc/sgml/dsssl-docbook-stylesheets.cat \
    /usr/share/sgml/docbook/dsssl-stylesheets-1.79/common/catalog  &&

install-catalog --add /etc/sgml/sgml-docbook.cat              \
    /etc/sgml/dsssl-docbook-stylesheets.cat
cd /usr/share/sgml/docbook/dsssl-stylesheets-1.79/doc/testdata
openjade -t rtf -d jtest.dsl jtest.sgm
onsgmls -sv test.sgm
openjade -t rtf \
    -d /usr/share/sgml/docbook/dsssl-stylesheets-1.79/print/docbook.dsl \
    test.sgm
openjade -t sgml \
    -d /usr/share/sgml/docbook/dsssl-stylesheets-1.79/html/docbook.dsl \
    test.sgm
rm jtest.rtf test.rtf c1.htm
}

export docbook_dsssl_1_79_C44_download="http://downloads.sourceforge.net/docbook/docbook-dsssl-1.79.tar.bz2 ftp://mirror.ovh.net/gentoo-distfiles/distfiles/docbook-dsssl-1.79.tar.bz2 http://downloads.sourceforge.net/docbook/docbook-dsssl-doc-1.79.tar.bz2 "

export docbook_dsssl_1_79_C44_packname="docbook-dsssl-1.79.tar.bz2"

export docbook_dsssl_1_79_C44_required_or_recommended="sgml_common_0_6_3_C44 docbook_3_1_C44 docbook_4_5_C44 OpenSP_1_5_2_C44 OpenJade_1_3_2_C44 "

DocBook_utils_0_6_14_C44(){

patch -Np1 -i ../docbook-utils-0.6.14-grep_fix-1.patch &&
sed -i 's:/html::' doc/HTML/Makefile.in                &&
./configure --prefix=/usr                              &&
make
make install
for doctype in html ps dvi man pdf rtf tex texi txt
do
    ln -s docbook2$doctype /usr/bin/db2$doctype
done
}

export DocBook_utils_0_6_14_C44_download="http://sources-redhat.mirrors.redwire.net/docbook-tools/new-trials/SOURCES/docbook-utils-0.6.14.tar.gz ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/docbook-utils-0.6.14.tar.gz http://www.linuxfromscratch.org/patches/blfs/svn/docbook-utils-0.6.14-grep_fix-1.patch "

export DocBook_utils_0_6_14_C44_packname="docbook-utils-0.6.14.tar.gz"

export DocBook_utils_0_6_14_C44_required_or_recommended="texlive_20120701_C47 docbook_dsssl_1_79_C44 docbook_3_1_C44 "

export C44_StandardGeneralizedMarkupLanguageSGML="sgml_common_0_6_3_C44 docbook_3_1_C44 docbook_4_5_C44 OpenSP_1_5_2_C44 OpenJade_1_3_2_C44 docbook_dsssl_1_79_C44 DocBook_utils_0_6_14_C44 "


docbook_xml_4_5_C45(){

install -v -d -m755 /usr/share/xml/docbook/xml-dtd-4.5 &&
install -v -d -m755 /etc/xml &&
chown -R root:root . &&
cp -v -af docbook.cat *.dtd ent/ *.mod \
    /usr/share/xml/docbook/xml-dtd-4.5
if [ ! -e /etc/xml/docbook ]; then
    xmlcatalog --noout --create /etc/xml/docbook
fi &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V4.5//EN" \
    "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
if [ ! -e /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi &&
xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
for DTDVERSION in 4.1.2 4.2 4.3 4.4
do
  xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V$DTDVERSION//EN" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd" \
    /etc/xml/docbook
  xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
  xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
  xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
  xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
done
}

export docbook_xml_4_5_C45_download="http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip ftp://mirror.ovh.net/gentoo-distfiles/distfiles/docbook-xml-4.5.zip "

export docbook_xml_4_5_C45_packname="docbook-xml-4.5.zip"

export docbook_xml_4_5_C45_required_or_recommended="libxml2_2_9_0_C9 UnZip_6_0_C12 "

docbook_xsl_1_77_1_C45(){

tar -xf ../docbook-xsl-doc-1.77.1.tar.bz2 --strip-components=1
install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-1.77.1 &&

cp -v -R VERSION common eclipse epub extensions fo highlighting html \
         htmlhelp images javahelp lib manpages params profiling \
         roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 \
    /usr/share/xml/docbook/xsl-stylesheets-1.77.1 &&

ln -s VERSION /usr/share/xml/docbook/xsl-stylesheets-1.77.1/VERSION.xsl &&

install -v -m644 -D README \
                    /usr/share/doc/docbook-xsl-1.77.1/README.txt &&
install -v -m644    RELEASE-NOTES* NEWS* \
                    /usr/share/doc/docbook-xsl-1.77.1
cp -v -R doc/* /usr/share/doc/docbook-xsl-1.77.1
if [ ! -d /etc/xml ]; then install -v -m755 -d /etc/xml; fi &&
if [ ! -f /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi &&

xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/1.77.1" \
           "/usr/share/xml/docbook/xsl-stylesheets-1.77.1" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/1.77.1" \
           "/usr/share/xml/docbook/xsl-stylesheets-1.77.1" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-1.77.1" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-1.77.1" \
    /etc/xml/catalog
xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/<version>" \
           "/usr/share/xml/docbook/xsl-stylesheets-<version>" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/<version>" \
           "/usr/share/xml/docbook/xsl-stylesheets-<version>" \
    /etc/xml/catalog

}

export docbook_xsl_1_77_1_C45_download="http://downloads.sourceforge.net/docbook/docbook-xsl-1.77.1.tar.bz2 http://downloads.sourceforge.net/docbook/docbook-xsl-doc-1.77.1.tar.bz2 "

export docbook_xsl_1_77_1_C45_packname="docbook-xsl-1.77.1.tar.bz2"

export docbook_xsl_1_77_1_C45_required_or_recommended="libxml2_2_9_0_C9 "

Itstool_1_2_0_C45(){

./configure --prefix=/usr &&
make
make install
}

export Itstool_1_2_0_C45_download="http://files.itstool.org/itstool/itstool-1.2.0.tar.bz2 "

export Itstool_1_2_0_C45_packname="itstool-1.2.0.tar.bz2"

export Itstool_1_2_0_C45_required_or_recommended="docbook_xml_4_5_C45 docbook_xsl_1_77_1_C45 Python_2_7_3_C13 "

xmlto_0_0_25_C45(){

./configure --prefix=/usr &&
make
make install
}

export xmlto_0_0_25_C45_download="https://fedorahosted.org/releases/x/m/xmlto/xmlto-0.0.25.tar.bz2 "

export xmlto_0_0_25_C45_packname="xmlto-0.0.25.tar.bz2"

export xmlto_0_0_25_C45_required_or_recommended="docbook_xml_4_5_C45 docbook_xsl_1_77_1_C45 libxslt_1_1_28_C9 "

export C45_ExtensibleMarkupLanguageXML="docbook_xml_4_5_C45 docbook_xsl_1_77_1_C45 Itstool_1_2_0_C45 xmlto_0_0_25_C45 "


a2ps_4_14_C46(){

autoconf &&
sed -i "s/GPERF --version |/& head -n 1 |/" configure &&
sed -i "s|/usr/local/share|/usr/share|" configure &&
./configure --prefix=/usr \
    --sysconfdir=/etc/a2ps \
    --enable-shared \
    --with-medium=letter &&
make
make install
tar -xf ../i18n-fonts-0.1.tar.bz2 &&
cp -v i18n-fonts-0.1/fonts/* /usr/share/a2ps/fonts &&
cp -v i18n-fonts-0.1/afm/* /usr/share/a2ps/afm &&
cd /usr/share/a2ps/afm &&
./make_fonts_map.sh &&
mv fonts.map.new fonts.map
}

export a2ps_4_14_C46_download="http://ftp.gnu.org/gnu/a2ps/a2ps-4.14.tar.gz ftp://ftp.gnu.org/gnu/a2ps/a2ps-4.14.tar.gz http://anduin.linuxfromscratch.org/sources/BLFS/conglomeration/i18n-fonts//i18n-fonts-0.1.tar.bz2 "

export a2ps_4_14_C46_packname="a2ps-4.14.tar.gz"

export a2ps_4_14_C46_required_or_recommended="Gperf_3_0_4_C11 PSUtils_p17_C46 Cups_1_6_2_C42 "

Enscript_1_6_6_C46(){

./configure --prefix=/usr              \
            --sysconfdir=/etc/enscript \
            --localstatedir=/var       \
            --with-media=Letter &&
make &&

pushd docs &&
texi2html enscript.texi &&
makeinfo --plaintext -o enscript.txt enscript.texi &&
popd
make install &&

install -v -m755 -d /usr/share/doc/enscript-1.6.6 &&
install -v -m644    README* *.txt docs/*.{html,txt} \
                    /usr/share/doc/enscript-1.6.6
install -v -m644 docs/*.{dvi,pdf,ps} \
                 /usr/share/doc/enscript-1.6.6
}

export Enscript_1_6_6_C46_download="http://ftp.gnu.org/gnu/enscript/enscript-1.6.6.tar.gz ftp://mirror.ovh.net/gentoo-distfiles/distfiles/enscript-1.6.6.tar.gz "

export Enscript_1_6_6_C46_packname="enscript-1.6.6.tar.gz"

PSUtils_p17_C46(){

sed 's@/usr/local@/usr@g' Makefile.unix > Makefile &&
make
make install

}

export PSUtils_p17_C46_download="ftp://ftp.knackered.org/pub/psutils/psutils-p17.tar.gz "

export PSUtils_p17_C46_packname="psutils-p17.tar.gz"

ePDFView_0_1_8_C46(){

patch -Np1 -i ../epdfview-0.1.8-fixes-1.patch &&
./configure --prefix=/usr &&
make
make install
}

export ePDFView_0_1_8_C46_download="http://trac.emma-soft.com/epdfview/chrome/site/releases/epdfview-0.1.8.tar.bz2 http://www.linuxfromscratch.org/patches/blfs/svn/epdfview-0.1.8-fixes-1.patch "

export ePDFView_0_1_8_C46_packname="epdfview-0.1.8.tar.bz2"

export ePDFView_0_1_8_C46_required_or_recommended="Poppler_0_22_2_C10 GTK_2_24_17_C25 "

export Introduction_to_fop_C46_download="http://archive.apache.org/dist/xmlgraphics/fop/source/fop-1.1-src.tar.gz http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-i586.tar.gz http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz "

export Introduction_to_fop_C46_packname="fop-1.1-src.tar.gz"

export Introduction_to_fop_C46_required_or_recommended="Introduction_to_Xorg_7_7_C24 apache_ant_1_8_4_C12 "

Installation_of_fop_C46(){

case `uname -m` in
  i?86)
    tar -xf ../jai-1_1_3-lib-linux-i586.tar.gz
    cp -v jai-1_1_3/lib/{jai*,mlibwrapper_jai.jar} $JAVA_HOME/jre/lib/ext/
    cp -v jai-1_1_3/lib/libmlib_jai.so             $JAVA_HOME/jre/lib/i386/
    ;;

  x86_64)
    tar -xf ../jai-1_1_3-lib-linux-amd64.tar.gz
    cp -v jai-1_1_3/lib/{jai*,mlibwrapper_jai.jar} $JAVA_HOME/jre/lib/ext/
    cp -v jai-1_1_3/lib/libmlib_jai.so             $JAVA_HOME/jre/lib/amd64/
    ;;
esac
ant compile &&
ant jar-main &&
ant javadocs &&
mv build/javadocs .
ant docs
install -v -d -m755                                     /opt/fop-1.1 &&
cp -v  KEYS LICENSE NOTICE README                       /opt/fop-1.1 &&
cp -va build conf examples fop* javadocs lib status.xml /opt/fop-1.1 &&

ln -v -sf fop-1.1 /opt/fop
}

Configuring_fop_C46(){

cat > ~/.foprc << "EOF"
FOP_OPTS="-Xmx<RAM_Installed>m"
FOP_HOME="/opt/fop"
EOF

}

paps_0_6_8_C46(){

./configure --prefix=/usr &&
make
make install &&
install -v -m755 -d                 /usr/share/doc/paps-0.6.8 &&
install -v -m644 doxygen-doc/html/* /usr/share/doc/paps-0.6.8
}

export paps_0_6_8_C46_download="http://downloads.sourceforge.net/paps/paps-0.6.8.tar.gz "

export paps_0_6_8_C46_packname="paps-0.6.8.tar.gz"

export paps_0_6_8_C46_required_or_recommended="Pango_1_32_5_C25 "

export C46_PostScript="a2ps_4_14_C46 Enscript_1_6_6_C46 PSUtils_p17_C46 ePDFView_0_1_8_C46 fop_1_1_C46 paps_0_6_8_C46 "


texlive_20120701_C47(){

tar -xf install-tl-unx.tar.gz &&
cd install-tl-20111204 
TEXLIVE_INSTALL_PREFIX=/opt/texlive ./install-tl
cat >> /etc/profile.d/extrapaths.sh << "EOF"
pathappend /usr/share/man                   MANPATH
pathappend /opt/texlive/2012/texmf/doc/man  MANPATH
pathappend /usr/share/info                  INFOPATH
pathappend /opt/texlive/2012/texmf/doc/info INFOPATH
pathappend /opt/texlive/2012/bin/x86_64-linux
EOF
./configure --prefix=/usr                  \
            --disable-native-texlive-build \
            --enable-build-in-source-tree  \
            --without-luatex               \
            --enable-mktextex-default      \
            --with-banner-add=" - BLFS"    &&
make
make DESTDIR=$PWD/texlive-tmp install
find texlive-tmp/usr/bin -type f -exec cp -v {} /opt/texlive/2011/bin/x86_64-linux \;
}

export texlive_20120701_C47_download="ftp://tug.org/texlive/historic/2012/texlive-20120701-source.tar.xz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz "

export texlive_20120701_C47_packname="texlive-20120701-source.tar.xz"

export C47_Typesetting="texlive_20120701_C47 "


export BLFSCHAPTERS="C0_Preface C1_WelcometoBLFS C2_ImportantInformation C3_AfterLFSConfigurationIssues C4_Security C5_FileSystemsandDiskManagement C6_Editors C7_Shells C8_Virtualization C9_GeneralLibraries C10_GraphicsandFontLibraries C11_GeneralUtilities C12_SystemUtilities C13_Programming C14_ConnectingtoaNetwork C15_NetworkingPrograms C16_NetworkingUtilities C17_NetworkingLibraries C18_TextWebBrowsers C19_MailNewsClients C20_MajorServers C21_MailServerSoftware C22_Databases C23_OtherServerSoftware C24_XWindowSystemEnvironment C25_XLibraries C26_WindowManagers C27_Introduction C28_TheKDECore C29_KDEAdditionalPackages C30_GNOMECorePackages C31_GNOMEApplications C32_DeprecatedGNOMEPackages C33_XfceDesktop C34_XfceApplications C35_OfficePrograms C36_GraphicalWebBrowsers C37_OtherXbasedPrograms C38_MultimediaLibrariesandDrivers C39_AudioUtilities C40_VideoUtilities C41_CDDVDWritingUtilities C42_Printing C43_Scanning C44_StandardGeneralizedMarkupLanguageSGML C45_ExtensibleMarkupLanguageXML C46_PostScript C47_Typesetting "
