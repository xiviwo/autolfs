
Preparing_Virtual_Kernel_File_Systems:
	
mkdir -v $LFS/{dev,proc,sys}	
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

6_3_2_Package_Management_Techniques_C6:
	
./configure --prefix=/usr/pkg/libfoo/1.1
make
make install	
./configure --prefix=/usr
make
make DESTDIR=/usr/pkg/libfoo/1.1 install

Entering_the_Chroot_Environment:
	
chroot "$LFS" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

Creating_Directories:
	
mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib,mnt,opt,run}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
for dir in /usr /usr/local; do
  ln -sv share/{man,doc,info} $dir
done
case $(uname -m) in
 x86_64) ln -sv lib /lib64 && ln -sv lib /usr/lib64 ;;
esac
mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{misc,locate},local}

Creating_Essential_Files_and_Symlinks:
	
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
	
exec /tools/bin/bash --login +h	
touch /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

Linux_3_9_6_API_Headers:
	
make mrproper	
make headers_check
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
	
cp -rv dest/include/* /usr/include

Man_pages_3_51:
	
make install

Glibc_2_17:
	
mkdir -v ../glibc-build
cd ../glibc-build	
../glibc-2.17/configure    \
    --prefix=/usr          \
    --disable-profile      \
    --enable-kernel=2.6.25 \
    --libexecdir=/usr/lib/glibc	
make	
make -k check 2>&1 | tee glibc-check-log
grep Error glibc-check-log	
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
tzselect	
cp -v --remove-destination /usr/share/zoneinfo/	<xxx> \
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


Adjusting_the_Toolchain:
	
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld	
gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
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

Zlib_1_2_8:
	
./configure --prefix=/usr	
make	
make check	
make install	
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/libz.so.1.2.8 /usr/lib/libz.so

File_5_14:
	
./configure --prefix=/usr	
make	
make check	
make install

Binutils_2_23_2:
	
expect -c "spawn ls"	
rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in	
sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo	
mkdir -v ../binutils-build
cd ../binutils-build	
../binutils-2.23.2/configure --prefix=/usr --enable-shared	
make tooldir=/usr	
make check	
make tooldir=/usr install	
cp -v ../binutils-2.23.2/include/libiberty.h /usr/include

GMP_5_1_2:
	
	ABI=32 ./configure ...
	
./configure --prefix=/usr --enable-cxx	
make	
make check 2>&1 | tee gmp-check-log	
awk '/tests passed/{total+=$2} ; END{print total}' gmp-check-log	
make install	
mkdir -v /usr/share/doc/gmp-5.1.2
cp    -v doc/{isa_abi_headache,configuration} doc/*.html \
         /usr/share/doc/gmp-5.1.2

MPFR_3_1_2:
	
./configure  --prefix=/usr        \
             --enable-thread-safe \
             --docdir=/usr/share/doc/mpfr-3.1.2	
make	
make check	
make install	
make html
	
make install-html

MPC_1_0_1:
	
./configure --prefix=/usr	
make	
make check	
make install

GCC_4_8_1:
	
case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac	
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in	
sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in 
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}	
mkdir -v ../gcc-build
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
ulimit -s 32768	
make -k check	
../gcc-4.8.1/contrib/test_summary	
make install	
ln -sv ../usr/bin/cpp /lib	
ln -sv gcc /usr/bin/cc	
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

Sed_4_2_2:
	
./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2	
make	
make html	
make check	
make install	
make -C doc install-html

Bzip2_1_0_6:
	
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

Pkg_config_0_28:
	
./configure --prefix=/usr         \
            --with-internal-glib  \
            --disable-host-tool   \
            --docdir=/usr/share/doc/pkg-config-0.28	
make	
make check	
make install

Ncurses_5_9:
	
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
mkdir -v       /usr/share/doc/ncurses-5.9
cp -v -R doc/* /usr/share/doc/ncurses-5.9	
make distclean
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding
make sources libs
cp -av lib/lib*.so.5* /usr/lib

Shadow_4_1_5_1:
	
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
passwd root

Util_linux_2_23_1:
	
sed -i -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
     $(grep -rl '/etc/adjtime' .)

mkdir -pv /var/lib/hwclock	
./configure --disable-su --disable-sulogin --disable-login	
make	
bash tests/run.sh --srcdir=$PWD --builddir=$PWD	
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make check"	
make install

Psmisc_22_20:
	
./configure --prefix=/usr	
make	
make install	
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin

Procps_ng_3_3_8:
	
./configure --prefix=/usr                           \
            --exec-prefix=                          \
            --libdir=/usr/lib                       \
            --docdir=/usr/share/doc/procps-ng-3.3.8 \
            --disable-static                        \
            --disable-skill                         \
            --disable-kill	
make	
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp

make check	
make install	
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/libprocps.so.1.1.2 /usr/lib/libprocps.so

E2fsprogs_1_42_7:
	
mkdir -v build
cd build	
../configure --prefix=/usr         \
             --with-root-prefix="" \
             --enable-elf-shlibs   \
             --disable-libblkid    \
             --disable-libuuid     \
             --disable-uuidd       \
             --disable-fsck	
make	
make check	
make install	
make install-libs	
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a	
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info	
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

Coreutils_8_21:
	
patch -Np1 -i ../coreutils-8.21-i18n-1.patch	
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr         \
            --libexecdir=/usr/lib \
            --enable-no-install-program=kill,uptime	
make	
make NON_ROOT_USERNAME=nobody check-root	
echo "dummy:x:1000:nobody" >> /etc/group	
chown -Rv nobody . 	
su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"	
sed -i '/dummy/d' /etc/group	
make install	
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname,test,[} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8	
mv -v /usr/bin/{head,sleep,nice} /bin

Iana_Etc_2_30:
	
make	
make install

M4_1_4_16:
	
sed -i -e '/gets is a/d' lib/stdio.in.h	
./configure --prefix=/usr	
make	
sed -i -e '41s/ENOENT/& || errno == EINVAL/' tests/test-readlink.h
make check	
make install

Bison_2_7_1:
	
./configure --prefix=/usr	
echo '#define YYENABLE_NLS 1' >> lib/config.h	
make	
make check	
make install

Grep_2_14:
	
./configure --prefix=/usr --bindir=/bin	
make	
make check	
make install

Readline_6_2:
	
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

Bash_4_2:
	
patch -Np1 -i ../bash-4.2-fixes-12.patch	
./configure --prefix=/usr                     \
            --bindir=/bin                     \
            --htmldir=/usr/share/doc/bash-4.2 \
            --without-bash-malloc             \
            --with-installed-readline	
make	
chown -Rv nobody .	
su nobody -s /bin/bash -c "PATH=$PATH make tests"	
make install	
exec /bin/bash --login +h

Bc_1_06_95:
	
./configure --prefix=/usr --with-readline	
make	
echo "quit" | ./bc/bc -l Test/checklib.b	
make install

Libtool_2_4_2:
	
./configure --prefix=/usr	
make	
make check	
make install

GDBM_1_10:
	
./configure --prefix=/usr --enable-libgdbm-compat	
make	
make check	
make install

Inetutils_1_9_1:
	
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
make check	
make install	
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin

Perl_5_18_0:
	
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
make -k test	
make install

Autoconf_2_69:
	
./configure --prefix=/usr	
make	
make check	
make install

Automake_1_13_4:
	
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.13.4	
make	
make check	
make install

Diffutils_3_3:
	
./configure --prefix=/usr	
make	
make check	
make install

Gawk_4_1_0:
	
./configure --prefix=/usr --libexecdir=/usr/lib	
make	
make check	
make install	
mkdir -v /usr/share/doc/gawk-4.1.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.0

Findutils_4_4_2:
	
./configure --prefix=/usr                   \
            --libexecdir=/usr/lib/findutils \
            --localstatedir=/var/lib/locate	
make	
make check	
make install	
mv -v /usr/bin/find /bin
sed -i 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb

Flex_2_5_37:
	
patch -Np1 -i ../flex-2.5.37-bison-2.6.1-1.patch	
./configure --prefix=/usr             \
            --docdir=/usr/share/doc/flex-2.5.37	
make	
make check	
make install	
ln -sv libfl.a /usr/lib/libl.a	
cat > /usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex

exec /usr/bin/flex -l "$@"

# End /usr/bin/lex
EOF
chmod -v 755 /usr/bin/lex


Gettext_0_18_2_1:
	
./configure --prefix=/usr \
            --docdir=/usr/share/doc/gettext-0.18.2.1	
make	
make check	
make install

Groff_1_22_2:
	
PAGE=	<paper_size> ./configure --prefix=/usr
	
make	
mkdir -p /usr/share/doc/groff-1.22/pdf
make install	
ln -sv eqn /usr/bin/geqn
ln -sv tbl /usr/bin/gtbl

Xz_5_0_4:
	
./configure --prefix=/usr --libdir=/lib --docdir=/usr/share/doc/xz-5.0.4	
make	
make check	
make pkgconfigdir=/usr/lib/pkgconfig install

GRUB_2_00:
	
sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h	
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-grub-emu-usb \
            --disable-efiemu       \
            --disable-werror	
make	
make install

Less_458:
	
./configure --prefix=/usr --sysconfdir=/etc	
make	
make install

Gzip_1_6:
	
./configure --prefix=/usr --bindir=/bin	
make	
make check	
make install	
mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin

IPRoute2_3_9_0:
	
sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile	
sed -i 's/-Werror//' Makefile	
make DESTDIR=	
make DESTDIR=              \
     MANDIR=/usr/share/man \
     DOCDIR=/usr/share/doc/iproute2-3.9.0 install

Kbd_1_15_5:
	
patch -Np1 -i ../kbd-1.15.5-backspace-1.patch	
sed -i -e '326 s/if/while/' src/loadkeys.analyze.l	
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' man/man8/Makefile.in	
./configure --prefix=/usr --disable-vlock	
make	
make install	
mkdir -v       /usr/share/doc/kbd-1.15.5
cp -R -v doc/* /usr/share/doc/kbd-1.15.5

Kmod_13:
	
./configure --prefix=/usr       \
            --bindir=/bin       \
            --libdir=/lib       \
            --sysconfdir=/etc   \
            --disable-manpages  \
            --with-xz           \
            --with-zlib	
make	
make check	
make pkgconfigdir=/usr/lib/pkgconfig install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sv ../bin/kmod /sbin/$target
done

ln -sv kmod /bin/lsmod

Libpipeline_1_2_4:
	
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr	
make	
make check	
make install

Make_3_82:
	
patch -Np1 -i ../make-3.82-upstream_fixes-3.patch	
./configure --prefix=/usr	
make	
make check	
make install

Man_DB_2_6_3:
	
./configure --prefix=/usr                        \
            --libexecdir=/usr/lib                \
            --docdir=/usr/share/doc/man-db-2.6.3 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap	
make	
make check	
make install

Patch_2_7_1:
	
./configure --prefix=/usr	
make	
make check	
make install

Sysklogd_1_5:
	
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


Sysvinit_2_88dsf:
	
sed -i 's@Sending processes@& configured via /etc/inittab@g' src/init.c	
sed -i -e '/utmpdump/d' \
       -e '/mountpoint/d' src/Makefile	
make -C src	
make -C src install

Tar_1_26:
	
sed -i -e '/gets is a/d' gnu/stdio.in.h	
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin \
            --libexecdir=/usr/sbin	
make	
make check	
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.26

Texinfo_5_1:
	
./configure --prefix=/usr	
make	
make check	
make install	
make TEXMF=/usr/share/texmf install-tex	
cd /usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done

Udev_204_Extracted_from_systemd_204_:
	
tar -xvf ../udev-lfs-204-1.tar.bz2	
make -f udev-lfs-204-1/Makefile.lfs	
make -f udev-lfs-204-1/Makefile.lfs install	
build/udevadm hwdb --update	
bash udev-lfs-204-1/init-net-rules.sh

Vim_7_3:
	
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h	
./configure --prefix=/usr --enable-multibyte	
make	
make test	
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
	
vim -c ':options'

Stripping_Again:
	
logout	
chroot $LFS /tools/bin/env -i \
    HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /tools/bin/bash --login	
/tools/bin/find /{,usr/}{bin,lib,sbin} -type f \
  -exec /tools/bin/strip --strip-debug '{}' ';'

Cleaning_Up:
	
chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login
InstallingBasicSystemSoftware : Preparing_Virtual_Kernel_File_Systems Package_Management Entering_the_Chroot_Environment Creating_Directories Creating_Essential_Files_and_Symlinks Linux_3_9_6_API_Headers Man_pages_3_51 Glibc_2_17 Adjusting_the_Toolchain Zlib_1_2_8 File_5_14 Binutils_2_23_2 GMP_5_1_2 MPFR_3_1_2 MPC_1_0_1 GCC_4_8_1 Sed_4_2_2 Bzip2_1_0_6 Pkg_config_0_28 Ncurses_5_9 Shadow_4_1_5_1 Util_linux_2_23_1 Psmisc_22_20 Procps_ng_3_3_8 E2fsprogs_1_42_7 Coreutils_8_21 Iana_Etc_2_30 M4_1_4_16 Bison_2_7_1 Grep_2_14 Readline_6_2 Bash_4_2 Bc_1_06_95 Libtool_2_4_2 GDBM_1_10 Inetutils_1_9_1 Perl_5_18_0 Autoconf_2_69 Automake_1_13_4 Diffutils_3_3 Gawk_4_1_0 Findutils_4_4_2 Flex_2_5_37 Gettext_0_18_2_1 Groff_1_22_2 Xz_5_0_4 GRUB_2_00 Less_458 Gzip_1_6 IPRoute2_3_9_0 Kbd_1_15_5 Kmod_13 Libpipeline_1_2_4 Make_3_82 Man_DB_2_6_3 Patch_2_7_1 Sysklogd_1_5 Sysvinit_2_88dsf Tar_1_26 Texinfo_5_1 Udev_204_Extracted_from_systemd_204_ Vim_7_3 Stripping_Again Cleaning_Up 