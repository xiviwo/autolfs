LFS=/mnt/lfs
SOURCES=$(LFS)/sources
InstallingBasicSystemSoftware : Preparing-Virtual-Kernel-File-Systems Package-Management Entering-the-Chroot-Environment Creating-Directories Creating-Essential-Files-and-Symlinks Linux-3-9-6-API-Headers Man-pages-3-51 Glibc-2-17 Adjusting-the-Toolchain Zlib-1-2-8 File-5-14 Binutils-2-23-2 GMP-5-1-2 MPFR-3-1-2 MPC-1-0-1 GCC-4-8-1 Sed-4-2-2 Bzip2-1-0-6 Pkg-config-0-28 Ncurses-5-9 Shadow-4-1-5-1 Util-linux-2-23-1 Psmisc-22-20 Procps-ng-3-3-8 E2fsprogs-1-42-7 Coreutils-8-21 Iana-Etc-2-30 M4-1-4-16 Bison-2-7-1 Grep-2-14 Readline-6-2 Bash-4-2 Bc-1-06-95 Libtool-2-4-2 GDBM-1-10 Inetutils-1-9-1 Perl-5-18-0 Autoconf-2-69 Automake-1-13-4 Diffutils-3-3 Gawk-4-1-0 Findutils-4-4-2 Flex-2-5-37 Gettext-0-18-2-1 Groff-1-22-2 Xz-5-0-4 GRUB-2-00 Less-458 Gzip-1-6 IPRoute2-3-9-0 Kbd-1-15-5 Kmod-13 Libpipeline-1-2-4 Make-3-82 Man-DB-2-6-3 Patch-2-7-1 Sysklogd-1-5 Sysvinit-2-88dsf Tar-1-26 Texinfo-5-1 Udev-204-Extracted-from-systemd-204- Vim-7-3 Stripping-Again Cleaning-Up 
Preparing-Virtual-Kernel-File-Systems:
	mkdir -pv $(LFS)/{dev,proc,sys}
	mknod -m 600 $(LFS)/dev/console c 5 1
	mknod -m 666 $(LFS)/dev/null c 1 3
	mount -v --bind /dev $(LFS)/dev
	mount -vt devpts devpts $(LFS)/dev/pts
	mount -vt proc proc $(LFS)/proc
	mount -vt sysfs sysfs $(LFS)/sys
	cd $(SOURCES)/preparing-/ && if [ -h $(LFS)/dev/shm ]; then
	link=$(readlink $(LFS)/dev/shm)
	mkdir -p $(LFS)/$(link)
	mount -vt tmpfs shm $(LFS)/$(link)
	unset link
	else
	mount -vt tmpfs shm $(LFS)/dev/shm
	fi

Package-Management:
	make
	make install
	./configure --prefix=/usr
	make

Entering-the-Chroot-Environment:
	cd $(SOURCES)/entering-/ && chroot "$(LFS)" /tools/bin/env -i \
	HOME=/root                  \
	TERM="$(TERM)"                \
	PS1='\u:\w\$ '              \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \

Creating-Directories:
	mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib,mnt,opt,run}
	mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
	mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
	mkdir -pv  /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	cd $(SOURCES)/creating-/ && for dir in /usr /usr/local; do
	ln -sv share/{man,doc,info} $(dir)
	done
	case $(uname -m) in
	x86_64) ln -sv lib /lib64 && ln -sv lib /usr/lib64 ;;
	esac
	mkdir -pv /var/{log,mail,spool}
	ln -sv /run /var/run
	ln -sv /run/lock /var/lock
	mkdir -pv /var/{opt,cache,lib/{misc,locate},local}

Creating-Essential-Files-and-Symlinks:
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

Linux-3-9-6-API-Headers:
	cd $(SOURCES) && rm -rf linux-3.9.6
	cd $(SOURCES) && rm -rf linux-build
	cd $(SOURCES) && mkdir -pv linux-3.9.6
	cd $(SOURCES) && tar xvf linux-3.9.6.tar.xz -C linux-3.9.6  --strip-components 1
	cd $(SOURCES)/linux-3.9.6/ && make mrproper
	cd $(SOURCES)/linux-3.9.6/ && make headers_check
	cd $(SOURCES)/linux-3.9.6/ && make INSTALL_HDR_PATH=dest headers_install
	find dest/include \( -name .install -o -name ..install.cmd \) -delete
	cd $(SOURCES)/linux-3.9.6/ && cp -rv dest/include/* /usr/include

Man-pages-3-51:
	cd $(SOURCES) && rm -rf man-pages-3.51
	cd $(SOURCES) && rm -rf man-pages-build
	cd $(SOURCES) && mkdir -pv man-pages-3.51
	cd $(SOURCES) && tar xvf man-pages-3.51.tar.xz -C man-pages-3.51  --strip-components 1
	cd $(SOURCES)/man-pages-3.51/ && make install

Glibc-2-17:
	cd $(SOURCES) && rm -rf glibc-2.17
	cd $(SOURCES) && rm -rf glibc-build
	cd $(SOURCES) && mkdir -pv glibc-2.17
	cd $(SOURCES) && tar xvf glibc-2.17.tar.xz -C glibc-2.17  --strip-components 1
	cd $(SOURCES)/glibc-2.17/ && mkdir -pv ../glibc-build
	cd $(SOURCES)/glibc-2.17/ && cd ../glibc-build
	cd $(SOURCES)/glibc-build/ && ../glibc-2.17/configure    \
	--prefix=/usr          \
	--disable-profile      \
	--enable-kernel=2.6.25 \
	--libexecdir=/usr/lib/glibc
	cd $(SOURCES)/glibc-build/ && make
	cd $(SOURCES)/glibc-build/ && touch /etc/ld.so.conf
	cd $(SOURCES)/glibc-build/ && make install
	cd $(SOURCES)/glibc-build/ && cp -v ../glibc-2.17/sunrpc/rpc/*.h /usr/include/rpc
	cd $(SOURCES)/glibc-build/ && cp -v ../glibc-2.17/sunrpc/rpcsvc/*.h /usr/include/rpcsvc
	cd $(SOURCES)/glibc-build/ && cp -v ../glibc-2.17/nis/rpcsvc/*.h /usr/include/rpcsvc
	cd $(SOURCES)/glibc-build/ && mkdir -pv /usr/lib/locale
	cd $(SOURCES)/glibc-build/ && make localedata/install-locales
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
	cd $(SOURCES)/glibc-build/ && tar -xf ../tzdata2013c.tar.gz
	cd $(SOURCES)/glibc-build/ && ZONEINFO=/usr/share/zoneinfo
	cd $(SOURCES)/glibc-build/ && mkdir -pv $(ZONEINFO)/{posix,right}
	cd $(SOURCES)/glibc-build/ && for tz in etcetera southamerica northamerica europe africa antarctica  \
	asia australasia backward pacificnew solar87 solar88 solar89 \
	systemv; do
	zic -L /dev/null   -d $(ZONEINFO)       -y "sh yearistype.sh" ${tz}
	zic -L /dev/null   -d $(ZONEINFO)/posix -y "sh yearistype.sh" ${tz}
	zic -L leapseconds -d $(ZONEINFO)/right -y "sh yearistype.sh" ${tz}
	done
	cd $(SOURCES)/glibc-build/ && cp -v zone.tab iso3166.tab $(ZONEINFO)
	cd $(SOURCES)/glibc-build/ && zic -d $(ZONEINFO) -p America/New_York
	cd $(SOURCES)/glibc-build/ && unset ZONEINFO
	cd $(SOURCES)/glibc-build/ && cp -v --remove-destination /usr/share/zoneinfo/	<xxx> \
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
	cd $(SOURCES)/glibc-build/ && mkdir -pv /etc/ld.so.conf.d

Adjusting-the-Toolchain:
	mv -v /tools/bin/{ld,ld-old}
	mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
	mv -v /tools/bin/{ld-new,ld}
	ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld
	cd $(SOURCES)/adjusting-/ && gcc -dumpspecs | sed -e 's@/tools@@g'                   \
	-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
	-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
	`dirname $(gcc --print-libgcc-file-name)`/specs

Zlib-1-2-8:
	cd $(SOURCES) && rm -rf zlib-1.2.8
	cd $(SOURCES) && rm -rf zlib-build
	cd $(SOURCES) && mkdir -pv zlib-1.2.8
	cd $(SOURCES) && tar xvf zlib-1.2.8.tar.xz -C zlib-1.2.8  --strip-components 1
	cd $(SOURCES)/zlib-1.2.8/ && ./configure --prefix=/usr
	cd $(SOURCES)/zlib-1.2.8/ && make
	cd $(SOURCES)/zlib-1.2.8/ && make install
	cd $(SOURCES)/zlib-1.2.8/ && mv -v /usr/lib/libz.so.* /lib
	cd $(SOURCES)/zlib-1.2.8/ && ln -sfv ../../lib/libz.so.1.2.8 /usr/lib/libz.so

File-5-14:
	cd $(SOURCES) && rm -rf file-5.14
	cd $(SOURCES) && rm -rf file-build
	cd $(SOURCES) && mkdir -pv file-5.14
	cd $(SOURCES) && tar xvf file-5.14.tar.gz -C file-5.14  --strip-components 1
	cd $(SOURCES)/file-5.14/ && ./configure --prefix=/usr
	cd $(SOURCES)/file-5.14/ && make
	cd $(SOURCES)/file-5.14/ && make install

Binutils-2-23-2:
	cd $(SOURCES) && rm -rf binutils-2.23.2
	cd $(SOURCES) && rm -rf binutils-build
	cd $(SOURCES) && mkdir -pv binutils-2.23.2
	cd $(SOURCES) && tar xvf binutils-2.23.2.tar.bz2 -C binutils-2.23.2  --strip-components 1
	cd $(SOURCES)/binutils-2.23.2/ && rm -fv etc/standards.info
	cd $(SOURCES)/binutils-2.23.2/ && sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in
	cd $(SOURCES)/binutils-2.23.2/ && sed -i -e 's/@colophon/@@colophon/' \
	-e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
	cd $(SOURCES)/binutils-2.23.2/ && mkdir -pv ../binutils-build
	cd $(SOURCES)/binutils-2.23.2/ && cd ../binutils-build
	cd $(SOURCES)/binutils-build/ && ../binutils-2.23.2/configure --prefix=/usr --enable-shared
	cd $(SOURCES)/binutils-build/ && make tooldir=/usr
	cd $(SOURCES)/binutils-build/ && make tooldir=/usr install
	cd $(SOURCES)/binutils-build/ && cp -v ../binutils-2.23.2/include/libiberty.h /usr/include

GMP-5-1-2:
	cd $(SOURCES) && rm -rf gmp-5.1.2
	cd $(SOURCES) && rm -rf gmp-build
	cd $(SOURCES) && mkdir -pv gmp-5.1.2
	cd $(SOURCES) && tar xvf gmp-5.1.2.tar.xz -C gmp-5.1.2  --strip-components 1
	cd $(SOURCES)/gmp-5.1.2/ && ABI=64 
./configure --prefix=/usr --enable-cxx
	cd $(SOURCES)/gmp-5.1.2/ && make
	cd $(SOURCES)/gmp-5.1.2/ && make install
	cd $(SOURCES)/gmp-5.1.2/ && mkdir -pv /usr/share/doc/gmp-5.1.2
	cd $(SOURCES)/gmp-5.1.2/ && cp    -v doc/{isa_abi_headache,configuration} doc/*.html \
	/usr/share/doc/gmp-5.1.2

MPFR-3-1-2:
	cd $(SOURCES) && rm -rf mpfr-3.1.2
	cd $(SOURCES) && rm -rf mpfr-build
	cd $(SOURCES) && mkdir -pv mpfr-3.1.2
	cd $(SOURCES) && tar xvf mpfr-3.1.2.tar.xz -C mpfr-3.1.2  --strip-components 1
	cd $(SOURCES)/mpfr-3.1.2/ && ./configure  --prefix=/usr        \
	--enable-thread-safe \
	--docdir=/usr/share/doc/mpfr-3.1.2
	cd $(SOURCES)/mpfr-3.1.2/ && make
	cd $(SOURCES)/mpfr-3.1.2/ && make install
	cd $(SOURCES)/mpfr-3.1.2/ && make html
	cd $(SOURCES)/mpfr-3.1.2/ && make install-html

MPC-1-0-1:
	cd $(SOURCES) && rm -rf mpc-1.0.1
	cd $(SOURCES) && rm -rf mpc-build
	cd $(SOURCES) && mkdir -pv mpc-1.0.1
	cd $(SOURCES) && tar xvf mpc-1.0.1.tar.gz -C mpc-1.0.1  --strip-components 1
	cd $(SOURCES)/mpc-1.0.1/ && ./configure --prefix=/usr
	cd $(SOURCES)/mpc-1.0.1/ && make
	cd $(SOURCES)/mpc-1.0.1/ && make install

GCC-4-8-1:
	cd $(SOURCES) && rm -rf gcc-4.8.1
	cd $(SOURCES) && rm -rf gcc-build
	cd $(SOURCES) && mkdir -pv gcc-4.8.1
	cd $(SOURCES) && tar xvf gcc-4.8.1.tar.bz2 -C gcc-4.8.1  --strip-components 1
	case `uname -m` in
	i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
	esac
	cd $(SOURCES)/gcc-4.8.1/ && sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	cd $(SOURCES)/gcc-4.8.1/ && sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in
	cd $(SOURCES)/gcc-4.8.1/ && mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}
	cd $(SOURCES)/gcc-4.8.1/ && mkdir -pv ../gcc-build
	cd $(SOURCES)/gcc-4.8.1/ && cd ../gcc-build
	cd $(SOURCES)/gcc-build/ && ../gcc-4.8.1/configure --prefix=/usr               \
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
	cd $(SOURCES)/gcc-build/ && make
	cd $(SOURCES)/gcc-build/ && make install
	cd $(SOURCES)/gcc-build/ && ln -sv ../usr/bin/cpp /lib
	cd $(SOURCES)/gcc-build/ && ln -sv gcc /usr/bin/cc
	cd $(SOURCES)/gcc-build/ && mkdir -pv /usr/share/gdb/auto-load/usr/lib
	cd $(SOURCES)/gcc-build/ && mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

Sed-4-2-2:
	cd $(SOURCES) && rm -rf sed-4.2.2
	cd $(SOURCES) && rm -rf sed-build
	cd $(SOURCES) && mkdir -pv sed-4.2.2
	cd $(SOURCES) && tar xvf sed-4.2.2.tar.bz2 -C sed-4.2.2  --strip-components 1
	cd $(SOURCES)/sed-4.2.2/ && ./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2
	cd $(SOURCES)/sed-4.2.2/ && make
	cd $(SOURCES)/sed-4.2.2/ && make html
	cd $(SOURCES)/sed-4.2.2/ && make install
	cd $(SOURCES)/sed-4.2.2/ && make -C doc install-html

Bzip2-1-0-6:
	cd $(SOURCES) && rm -rf bzip2-1.0.6
	cd $(SOURCES) && rm -rf bzip2-build
	cd $(SOURCES) && mkdir -pv bzip2-1.0.6
	cd $(SOURCES) && tar xvf bzip2-1.0.6.tar.gz -C bzip2-1.0.6  --strip-components 1
	cd $(SOURCES)/bzip2-1.0.6/ && patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
	cd $(SOURCES)/bzip2-1.0.6/ && sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	cd $(SOURCES)/bzip2-1.0.6/ && sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	cd $(SOURCES)/bzip2-1.0.6/ && make -f Makefile-libbz2_so
	cd $(SOURCES)/bzip2-1.0.6/ && make clean
	cd $(SOURCES)/bzip2-1.0.6/ && make
	cd $(SOURCES)/bzip2-1.0.6/ && make PREFIX=/usr install
	cd $(SOURCES)/bzip2-1.0.6/ && cp -v bzip2-shared /bin/bzip2
	cd $(SOURCES)/bzip2-1.0.6/ && cp -av libbz2.so* /lib
	cd $(SOURCES)/bzip2-1.0.6/ && ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
	cd $(SOURCES)/bzip2-1.0.6/ && rm -v /usr/bin/{bunzip2,bzcat,bzip2}
	cd $(SOURCES)/bzip2-1.0.6/ && ln -sv bzip2 /bin/bunzip2
	cd $(SOURCES)/bzip2-1.0.6/ && ln -sv bzip2 /bin/bzcat

Pkg-config-0-28:
	cd $(SOURCES) && rm -rf pkg-config-0.28
	cd $(SOURCES) && rm -rf pkg-config-build
	cd $(SOURCES) && mkdir -pv pkg-config-0.28
	cd $(SOURCES) && tar xvf pkg-config-0.28.tar.gz -C pkg-config-0.28  --strip-components 1
	cd $(SOURCES)/pkg-config-0.28/ && ./configure --prefix=/usr         \
	--with-internal-glib  \
	--disable-host-tool   \
	--docdir=/usr/share/doc/pkg-config-0.28
	cd $(SOURCES)/pkg-config-0.28/ && make
	cd $(SOURCES)/pkg-config-0.28/ && make install

Ncurses-5-9:
	cd $(SOURCES) && rm -rf ncurses-5.9
	cd $(SOURCES) && rm -rf ncurses-build
	cd $(SOURCES) && mkdir -pv ncurses-5.9
	cd $(SOURCES) && tar xvf ncurses-5.9.tar.gz -C ncurses-5.9  --strip-components 1
	cd $(SOURCES)/ncurses-5.9/ && ./configure --prefix=/usr           \
	--mandir=/usr/share/man \
	--with-shared           \
	--without-debug         \
	--enable-pc-files       \
	--enable-widec
	cd $(SOURCES)/ncurses-5.9/ && make
	cd $(SOURCES)/ncurses-5.9/ && make install
	cd $(SOURCES)/ncurses-5.9/ && mv -v /usr/lib/libncursesw.so.5* /lib
	cd $(SOURCES)/ncurses-5.9/ && ln -sfv ../../lib/libncursesw.so.5 /usr/lib/libncursesw.so
	cd $(SOURCES)/ncurses-5.9/ && for lib in ncurses form panel menu ; do
	rm -vf                    /usr/lib/lib${lib}.so
	echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
	ln -sfv lib${lib}w.a      /usr/lib/lib${lib}.a
	ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
	done
	cd $(SOURCES)/ncurses-5.9/ && ln -sfv libncurses++w.a /usr/lib/libncurses++.a
	cd $(SOURCES)/ncurses-5.9/ && rm -vf                     /usr/lib/libcursesw.so
	cd $(SOURCES)/ncurses-5.9/ && echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	cd $(SOURCES)/ncurses-5.9/ && ln -sfv libncurses.so      /usr/lib/libcurses.so
	cd $(SOURCES)/ncurses-5.9/ && ln -sfv libncursesw.a      /usr/lib/libcursesw.a
	cd $(SOURCES)/ncurses-5.9/ && ln -sfv libncurses.a       /usr/lib/libcurses.a
	cd $(SOURCES)/ncurses-5.9/ && mkdir -pv       /usr/share/doc/ncurses-5.9
	cd $(SOURCES)/ncurses-5.9/ && cp -v -R doc/* /usr/share/doc/ncurses-5.9
	cd $(SOURCES)/ncurses-5.9/ && make distclean
	cd $(SOURCES)/ncurses-5.9/ && ./configure --prefix=/usr    \
	--with-shared    \
	--without-normal \
	--without-debug  \
	--without-cxx-binding
	make sources libs
	cp -av lib/lib*.so.5* /usr/lib

Shadow-4-1-5-1:
	cd $(SOURCES) && rm -rf shadow-4.1.5.1
	cd $(SOURCES) && rm -rf shadow-build
	cd $(SOURCES) && mkdir -pv shadow-4.1.5.1
	cd $(SOURCES) && tar xvf shadow-4.1.5.1.tar.bz2 -C shadow-4.1.5.1  --strip-components 1
	cd $(SOURCES)/shadow-4.1.5.1/ && sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
	cd $(SOURCES)/shadow-4.1.5.1/ && sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
	-e 's@/var/spool/mail@/var/mail@' etc/login.defs
	cd $(SOURCES)/shadow-4.1.5.1/ && sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' \
	etc/login.defs
	cd $(SOURCES)/shadow-4.1.5.1/ && ./configure --sysconfdir=/etc --with-libpam=no
	cd $(SOURCES)/shadow-4.1.5.1/ && make
	cd $(SOURCES)/shadow-4.1.5.1/ && make install
	cd $(SOURCES)/shadow-4.1.5.1/ && mv -v /usr/bin/passwd /bin
	cd $(SOURCES)/shadow-4.1.5.1/ && pwconv
	cd $(SOURCES)/shadow-4.1.5.1/ && grpconv
	cd $(SOURCES)/shadow-4.1.5.1/ && sed -i 's/yes/no/' /etc/default/useradd
	cd $(SOURCES)/shadow-4.1.5.1/ && echo 'root:ping' | chpasswd

Util-linux-2-23-1:
	cd $(SOURCES) && rm -rf util-linux-2.23.1
	cd $(SOURCES) && rm -rf util-linux-build
	cd $(SOURCES) && mkdir -pv util-linux-2.23.1
	cd $(SOURCES) && tar xvf util-linux-2.23.1.tar.xz -C util-linux-2.23.1  --strip-components 1
	cd $(SOURCES)/util-linux-2.23.1/ && sed -i -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
	$(grep -rl '/etc/adjtime' .)
	mkdir -pv /var/lib/hwclock
	cd $(SOURCES)/util-linux-2.23.1/ && ./configure --disable-su --disable-sulogin --disable-login
	cd $(SOURCES)/util-linux-2.23.1/ && make
	cd $(SOURCES)/util-linux-2.23.1/ && bash tests/run.sh --srcdir=$(PWD) --builddir=$(PWD)
	cd $(SOURCES)/util-linux-2.23.1/ && make install

Psmisc-22-20:
	cd $(SOURCES) && rm -rf psmisc-22.20
	cd $(SOURCES) && rm -rf psmisc-build
	cd $(SOURCES) && mkdir -pv psmisc-22.20
	cd $(SOURCES) && tar xvf psmisc-22.20.tar.gz -C psmisc-22.20  --strip-components 1
	cd $(SOURCES)/psmisc-22.20/ && ./configure --prefix=/usr
	cd $(SOURCES)/psmisc-22.20/ && make
	cd $(SOURCES)/psmisc-22.20/ && make install
	cd $(SOURCES)/psmisc-22.20/ && mv -v /usr/bin/fuser   /bin
	cd $(SOURCES)/psmisc-22.20/ && mv -v /usr/bin/killall /bin

Procps-ng-3-3-8:
	cd $(SOURCES) && rm -rf procps-ng-3.3.8
	cd $(SOURCES) && rm -rf procps-ng-build
	cd $(SOURCES) && mkdir -pv procps-ng-3.3.8
	cd $(SOURCES) && tar xvf procps-ng-3.3.8.tar.xz -C procps-ng-3.3.8  --strip-components 1
	cd $(SOURCES)/procps-ng-3.3.8/ && ./configure --prefix=/usr                           \
	--exec-prefix=                          \
	--libdir=/usr/lib                       \
	--docdir=/usr/share/doc/procps-ng-3.3.8 \
	--disable-static                        \
	--disable-skill                         \
	--disable-kill
	cd $(SOURCES)/procps-ng-3.3.8/ && make
	cd $(SOURCES)/procps-ng-3.3.8/ && sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
	cd $(SOURCES)/procps-ng-3.3.8/ && make install
	cd $(SOURCES)/procps-ng-3.3.8/ && mv -v /usr/lib/libprocps.so.* /lib
	cd $(SOURCES)/procps-ng-3.3.8/ && ln -sfv ../../lib/libprocps.so.1.1.2 /usr/lib/libprocps.so

E2fsprogs-1-42-7:
	cd $(SOURCES) && rm -rf e2fsprogs-1.42.7
	cd $(SOURCES) && rm -rf e2fsprogs-build
	cd $(SOURCES) && mkdir -pv e2fsprogs-1.42.7
	cd $(SOURCES) && tar xvf e2fsprogs-1.42.7.tar.gz -C e2fsprogs-1.42.7  --strip-components 1
	cd $(SOURCES)/e2fsprogs-1.42.7/ && mkdir -pv build
	cd $(SOURCES)/e2fsprogs-1.42.7/ && cd build
	cd $(SOURCES)/e2fsprogs-1.42.7/ && ../configure --prefix=/usr         \
	--with-root-prefix="" \
	--enable-elf-shlibs   \
	--disable-libblkid    \
	--disable-libuuid     \
	--disable-uuidd       \
	--disable-fsck
	cd $(SOURCES)/e2fsprogs-1.42.7/ && make
	cd $(SOURCES)/e2fsprogs-1.42.7/ && make install
	cd $(SOURCES)/e2fsprogs-1.42.7/ && make install-libs
	cd $(SOURCES)/e2fsprogs-1.42.7/ && chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
	cd $(SOURCES)/e2fsprogs-1.42.7/ && gunzip -v /usr/share/info/libext2fs.info.gz
	cd $(SOURCES)/e2fsprogs-1.42.7/ && install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
	cd $(SOURCES)/e2fsprogs-1.42.7/ && makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
	cd $(SOURCES)/e2fsprogs-1.42.7/ && install -v -m644 doc/com_err.info /usr/share/info
	cd $(SOURCES)/e2fsprogs-1.42.7/ && install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

Coreutils-8-21:
	cd $(SOURCES) && rm -rf coreutils-8.21
	cd $(SOURCES) && rm -rf coreutils-build
	cd $(SOURCES) && mkdir -pv coreutils-8.21
	cd $(SOURCES) && tar xvf coreutils-8.21.tar.xz -C coreutils-8.21  --strip-components 1
	cd $(SOURCES)/coreutils-8.21/ && patch -Np1 -i ../coreutils-8.21-i18n-1.patch
	cd $(SOURCES)/coreutils-8.21/ && FORCE_UNSAFE_CONFIGURE=1 ./configure \
	--prefix=/usr         \
	--libexecdir=/usr/lib \
	--enable-no-install-program=kill,uptime
	cd $(SOURCES)/coreutils-8.21/ && make
	cd $(SOURCES)/coreutils-8.21/ && make install
	cd $(SOURCES)/coreutils-8.21/ && mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
	cd $(SOURCES)/coreutils-8.21/ && mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
	cd $(SOURCES)/coreutils-8.21/ && mv -v /usr/bin/{rmdir,stty,sync,true,uname,test,[} /bin
	cd $(SOURCES)/coreutils-8.21/ && mv -v /usr/bin/chroot /usr/sbin
	cd $(SOURCES)/coreutils-8.21/ && mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	cd $(SOURCES)/coreutils-8.21/ && sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
	cd $(SOURCES)/coreutils-8.21/ && mv -v /usr/bin/{head,sleep,nice} /bin

Iana-Etc-2-30:
	cd $(SOURCES) && rm -rf iana-etc-2.30
	cd $(SOURCES) && rm -rf iana-etc-build
	cd $(SOURCES) && mkdir -pv iana-etc-2.30
	cd $(SOURCES) && tar xvf iana-etc-2.30.tar.bz2 -C iana-etc-2.30  --strip-components 1
	cd $(SOURCES)/iana-etc-2.30/ && make
	cd $(SOURCES)/iana-etc-2.30/ && make install

M4-1-4-16:
	cd $(SOURCES) && rm -rf m4-1.4.16
	cd $(SOURCES) && rm -rf m4-build
	cd $(SOURCES) && mkdir -pv m4-1.4.16
	cd $(SOURCES) && tar xvf m4-1.4.16.tar.bz2 -C m4-1.4.16  --strip-components 1
	cd $(SOURCES)/m4-1.4.16/ && sed -i -e '/gets is a/d' lib/stdio.in.h
	cd $(SOURCES)/m4-1.4.16/ && ./configure --prefix=/usr
	cd $(SOURCES)/m4-1.4.16/ && make
	cd $(SOURCES)/m4-1.4.16/ && sed -i -e '41s/ENOENT/& || errno == EINVAL/' tests/test-readlink.h
	cd $(SOURCES)/m4-1.4.16/ && make install

Bison-2-7-1:
	cd $(SOURCES) && rm -rf bison-2.7.1
	cd $(SOURCES) && rm -rf bison-build
	cd $(SOURCES) && mkdir -pv bison-2.7.1
	cd $(SOURCES) && tar xvf bison-2.7.1.tar.xz -C bison-2.7.1  --strip-components 1
	cd $(SOURCES)/bison-2.7.1/ && ./configure --prefix=/usr
	cd $(SOURCES)/bison-2.7.1/ && echo '#define YYENABLE_NLS 1' >> lib/config.h
	cd $(SOURCES)/bison-2.7.1/ && make
	cd $(SOURCES)/bison-2.7.1/ && make install

Grep-2-14:
	cd $(SOURCES) && rm -rf grep-2.14
	cd $(SOURCES) && rm -rf grep-build
	cd $(SOURCES) && mkdir -pv grep-2.14
	cd $(SOURCES) && tar xvf grep-2.14.tar.xz -C grep-2.14  --strip-components 1
	cd $(SOURCES)/grep-2.14/ && ./configure --prefix=/usr --bindir=/bin
	cd $(SOURCES)/grep-2.14/ && make
	cd $(SOURCES)/grep-2.14/ && make install

Readline-6-2:
	cd $(SOURCES) && rm -rf readline-6.2
	cd $(SOURCES) && rm -rf readline-build
	cd $(SOURCES) && mkdir -pv readline-6.2
	cd $(SOURCES) && tar xvf readline-6.2.tar.gz -C readline-6.2  --strip-components 1
	cd $(SOURCES)/readline-6.2/ && sed -i '/MV.*old/d' Makefile.in
	cd $(SOURCES)/readline-6.2/ && sed -i '/{OLDSUFF}/c:' support/shlib-install
	cd $(SOURCES)/readline-6.2/ && patch -Np1 -i ../readline-6.2-fixes-1.patch
	cd $(SOURCES)/readline-6.2/ && ./configure --prefix=/usr --libdir=/lib
	cd $(SOURCES)/readline-6.2/ && make SHLIB_LIBS=-lncurses
	cd $(SOURCES)/readline-6.2/ && make install
	cd $(SOURCES)/readline-6.2/ && mv -v /lib/lib{readline,history}.a /usr/lib
	cd $(SOURCES)/readline-6.2/ && rm -v /lib/lib{readline,history}.so
	cd $(SOURCES)/readline-6.2/ && ln -sfv ../../lib/libreadline.so.6 /usr/lib/libreadline.so
	cd $(SOURCES)/readline-6.2/ && ln -sfv ../../lib/libhistory.so.6 /usr/lib/libhistory.so
	cd $(SOURCES)/readline-6.2/ && mkdir   -v       /usr/share/doc/readline-6.2
	cd $(SOURCES)/readline-6.2/ && install -v -m644 doc/*.{ps,pdf,html,dvi} \
	/usr/share/doc/readline-6.2

Bash-4-2:
	cd $(SOURCES) && rm -rf bash-4.2
	cd $(SOURCES) && rm -rf bash-build
	cd $(SOURCES) && mkdir -pv bash-4.2
	cd $(SOURCES) && tar xvf bash-4.2.tar.gz -C bash-4.2  --strip-components 1
	cd $(SOURCES)/bash-4.2/ && patch -Np1 -i ../bash-4.2-fixes-12.patch
	cd $(SOURCES)/bash-4.2/ && ./configure --prefix=/usr                     \
	--bindir=/bin                     \
	--htmldir=/usr/share/doc/bash-4.2 \
	--without-bash-malloc             \
	--with-installed-readline
	cd $(SOURCES)/bash-4.2/ && make
	cd $(SOURCES)/bash-4.2/ && make install

Bc-1-06-95:
	cd $(SOURCES) && rm -rf bc-1.06.95
	cd $(SOURCES) && rm -rf bc-build
	cd $(SOURCES) && mkdir -pv bc-1.06.95
	cd $(SOURCES) && tar xvf bc-1.06.95.tar.bz2 -C bc-1.06.95  --strip-components 1
	cd $(SOURCES)/bc-1.06.95/ && ./configure --prefix=/usr --with-readline
	cd $(SOURCES)/bc-1.06.95/ && make
	cd $(SOURCES)/bc-1.06.95/ && echo "quit" | ./bc/bc -l Test/checklib.b
	cd $(SOURCES)/bc-1.06.95/ && make install

Libtool-2-4-2:
	cd $(SOURCES) && rm -rf libtool-2.4.2
	cd $(SOURCES) && rm -rf libtool-build
	cd $(SOURCES) && mkdir -pv libtool-2.4.2
	cd $(SOURCES) && tar xvf libtool-2.4.2.tar.gz -C libtool-2.4.2  --strip-components 1
	cd $(SOURCES)/libtool-2.4.2/ && ./configure --prefix=/usr
	cd $(SOURCES)/libtool-2.4.2/ && make
	cd $(SOURCES)/libtool-2.4.2/ && make install

GDBM-1-10:
	cd $(SOURCES) && rm -rf gdbm-1.10
	cd $(SOURCES) && rm -rf gdbm-build
	cd $(SOURCES) && mkdir -pv gdbm-1.10
	cd $(SOURCES) && tar xvf gdbm-1.10.tar.gz -C gdbm-1.10  --strip-components 1
	cd $(SOURCES)/gdbm-1.10/ && ./configure --prefix=/usr --enable-libgdbm-compat
	cd $(SOURCES)/gdbm-1.10/ && make
	cd $(SOURCES)/gdbm-1.10/ && make install

Inetutils-1-9-1:
	cd $(SOURCES) && rm -rf inetutils-1.9.1
	cd $(SOURCES) && rm -rf inetutils-build
	cd $(SOURCES) && mkdir -pv inetutils-1.9.1
	cd $(SOURCES) && tar xvf inetutils-1.9.1.tar.gz -C inetutils-1.9.1  --strip-components 1
	cd $(SOURCES)/inetutils-1.9.1/ && sed -i -e '/gets is a/d' lib/stdio.in.h
	cd $(SOURCES)/inetutils-1.9.1/ && ./configure --prefix=/usr  \
	--libexecdir=/usr/sbin \
	--localstatedir=/var   \
	--disable-ifconfig     \
	--disable-logger       \
	--disable-syslogd      \
	--disable-whois        \
	--disable-servers
	cd $(SOURCES)/inetutils-1.9.1/ && make
	cd $(SOURCES)/inetutils-1.9.1/ && make install
	cd $(SOURCES)/inetutils-1.9.1/ && mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin

Perl-5-18-0:
	cd $(SOURCES) && rm -rf perl-5.18.0
	cd $(SOURCES) && rm -rf perl-build
	cd $(SOURCES) && mkdir -pv perl-5.18.0
	cd $(SOURCES) && tar xvf perl-5.18.0.tar.bz2 -C perl-5.18.0  --strip-components 1
	cd $(SOURCES)/perl-5.18.0/ && echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
	cd $(SOURCES)/perl-5.18.0/ && sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|"           \
	-e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" \
	-e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|"         \
	cpan/Compress-Raw-Zlib/config.in
	cd $(SOURCES)/perl-5.18.0/ && sh Configure -des -Dprefix=/usr                 \
	-Dvendorprefix=/usr           \
	-Dman1dir=/usr/share/man/man1 \
	-Dman3dir=/usr/share/man/man3 \
	-Dpager="/usr/bin/less -isR"  \
	-Duseshrplib
	cd $(SOURCES)/perl-5.18.0/ && make
	cd $(SOURCES)/perl-5.18.0/ && make install

Autoconf-2-69:
	cd $(SOURCES) && rm -rf autoconf-2.69
	cd $(SOURCES) && rm -rf autoconf-build
	cd $(SOURCES) && mkdir -pv autoconf-2.69
	cd $(SOURCES) && tar xvf autoconf-2.69.tar.xz -C autoconf-2.69  --strip-components 1
	cd $(SOURCES)/autoconf-2.69/ && ./configure --prefix=/usr
	cd $(SOURCES)/autoconf-2.69/ && make
	cd $(SOURCES)/autoconf-2.69/ && make install

Automake-1-13-4:
	cd $(SOURCES) && rm -rf automake-1.13.4
	cd $(SOURCES) && rm -rf automake-build
	cd $(SOURCES) && mkdir -pv automake-1.13.4
	cd $(SOURCES) && tar xvf automake-1.13.4.tar.xz -C automake-1.13.4  --strip-components 1
	cd $(SOURCES)/automake-1.13.4/ && ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.13.4
	cd $(SOURCES)/automake-1.13.4/ && make
	cd $(SOURCES)/automake-1.13.4/ && make install

Diffutils-3-3:
	cd $(SOURCES) && rm -rf diffutils-3.3
	cd $(SOURCES) && rm -rf diffutils-build
	cd $(SOURCES) && mkdir -pv diffutils-3.3
	cd $(SOURCES) && tar xvf diffutils-3.3.tar.xz -C diffutils-3.3  --strip-components 1
	cd $(SOURCES)/diffutils-3.3/ && ./configure --prefix=/usr
	cd $(SOURCES)/diffutils-3.3/ && make
	cd $(SOURCES)/diffutils-3.3/ && make install

Gawk-4-1-0:
	cd $(SOURCES) && rm -rf gawk-4.1.0
	cd $(SOURCES) && rm -rf gawk-build
	cd $(SOURCES) && mkdir -pv gawk-4.1.0
	cd $(SOURCES) && tar xvf gawk-4.1.0.tar.xz -C gawk-4.1.0  --strip-components 1
	cd $(SOURCES)/gawk-4.1.0/ && ./configure --prefix=/usr --libexecdir=/usr/lib
	cd $(SOURCES)/gawk-4.1.0/ && make
	cd $(SOURCES)/gawk-4.1.0/ && make install
	cd $(SOURCES)/gawk-4.1.0/ && mkdir -pv /usr/share/doc/gawk-4.1.0
	cd $(SOURCES)/gawk-4.1.0/ && cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.0

Findutils-4-4-2:
	cd $(SOURCES) && rm -rf findutils-4.4.2
	cd $(SOURCES) && rm -rf findutils-build
	cd $(SOURCES) && mkdir -pv findutils-4.4.2
	cd $(SOURCES) && tar xvf findutils-4.4.2.tar.gz -C findutils-4.4.2  --strip-components 1
	cd $(SOURCES)/findutils-4.4.2/ && ./configure --prefix=/usr                   \
	--libexecdir=/usr/lib/findutils \
	--localstatedir=/var/lib/locate
	cd $(SOURCES)/findutils-4.4.2/ && make
	cd $(SOURCES)/findutils-4.4.2/ && make install
	cd $(SOURCES)/findutils-4.4.2/ && mv -v /usr/bin/find /bin
	cd $(SOURCES)/findutils-4.4.2/ && sed -i 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb

Flex-2-5-37:
	cd $(SOURCES) && rm -rf flex-2.5.37
	cd $(SOURCES) && rm -rf flex-build
	cd $(SOURCES) && mkdir -pv flex-2.5.37
	cd $(SOURCES) && tar xvf flex-2.5.37.tar.bz2 -C flex-2.5.37  --strip-components 1
	cd $(SOURCES)/flex-2.5.37/ && patch -Np1 -i ../flex-2.5.37-bison-2.6.1-1.patch
	cd $(SOURCES)/flex-2.5.37/ && ./configure --prefix=/usr             \
	--docdir=/usr/share/doc/flex-2.5.37
	cd $(SOURCES)/flex-2.5.37/ && make
	cd $(SOURCES)/flex-2.5.37/ && make install
	cd $(SOURCES)/flex-2.5.37/ && ln -sv libfl.a /usr/lib/libl.a
	cat > /usr/bin/lex << "EOF"
	#!/bin/sh
	# Begin /usr/bin/lex
	exec /usr/bin/flex -l "$@"
	# End /usr/bin/lex
	EOF
	cd $(SOURCES)/flex-2.5.37/ && chmod -v 755 /usr/bin/lex

Gettext-0-18-2-1:
	cd $(SOURCES) && rm -rf gettext-0.18.2.1
	cd $(SOURCES) && rm -rf gettext-build
	cd $(SOURCES) && mkdir -pv gettext-0.18.2.1
	cd $(SOURCES) && tar xvf gettext-0.18.2.1.tar.gz -C gettext-0.18.2.1  --strip-components 1
	cd $(SOURCES)/gettext-0.18.2.1/ && ./configure --prefix=/usr \
	--docdir=/usr/share/doc/gettext-0.18.2.1
	cd $(SOURCES)/gettext-0.18.2.1/ && make
	cd $(SOURCES)/gettext-0.18.2.1/ && make install

Groff-1-22-2:
	cd $(SOURCES) && rm -rf groff-1.22.2
	cd $(SOURCES) && rm -rf groff-build
	cd $(SOURCES) && mkdir -pv groff-1.22.2
	cd $(SOURCES) && tar xvf groff-1.22.2.tar.gz -C groff-1.22.2  --strip-components 1
	cd $(SOURCES)/groff-1.22.2/ && PAGE=	<paper_size> ./configure --prefix=/usr
	cd $(SOURCES)/groff-1.22.2/ && make
	cd $(SOURCES)/groff-1.22.2/ && mkdir -p /usr/share/doc/groff-1.22/pdf
	cd $(SOURCES)/groff-1.22.2/ && make install
	cd $(SOURCES)/groff-1.22.2/ && ln -sv eqn /usr/bin/geqn
	cd $(SOURCES)/groff-1.22.2/ && ln -sv tbl /usr/bin/gtbl

Xz-5-0-4:
	cd $(SOURCES) && rm -rf xz-5.0.4
	cd $(SOURCES) && rm -rf xz-build
	cd $(SOURCES) && mkdir -pv xz-5.0.4
	cd $(SOURCES) && tar xvf xz-5.0.4.tar.xz -C xz-5.0.4  --strip-components 1
	cd $(SOURCES)/xz-5.0.4/ && ./configure --prefix=/usr --libdir=/lib --docdir=/usr/share/doc/xz-5.0.4
	cd $(SOURCES)/xz-5.0.4/ && make
	cd $(SOURCES)/xz-5.0.4/ && make pkgconfigdir=/usr/lib/pkgconfig install

GRUB-2-00:
	cd $(SOURCES) && rm -rf grub-2.00
	cd $(SOURCES) && rm -rf grub-build
	cd $(SOURCES) && mkdir -pv grub-2.00
	cd $(SOURCES) && tar xvf grub-2.00.tar.xz -C grub-2.00  --strip-components 1
	cd $(SOURCES)/grub-2.00/ && sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h
	cd $(SOURCES)/grub-2.00/ && ./configure --prefix=/usr          \
	--sysconfdir=/etc      \
	--disable-grub-emu-usb \
	--disable-efiemu       \
	--disable-werror
	cd $(SOURCES)/grub-2.00/ && make
	cd $(SOURCES)/grub-2.00/ && make install

Less-458:
	cd $(SOURCES) && rm -rf less-458
	cd $(SOURCES) && rm -rf less-build
	cd $(SOURCES) && mkdir -pv less-458
	cd $(SOURCES) && tar xvf less-458.tar.gz -C less-458  --strip-components 1
	cd $(SOURCES)/less-458/ && ./configure --prefix=/usr --sysconfdir=/etc
	cd $(SOURCES)/less-458/ && make
	cd $(SOURCES)/less-458/ && make install

Gzip-1-6:
	cd $(SOURCES) && rm -rf gzip-1.6
	cd $(SOURCES) && rm -rf gzip-build
	cd $(SOURCES) && mkdir -pv gzip-1.6
	cd $(SOURCES) && tar xvf gzip-1.6.tar.xz -C gzip-1.6  --strip-components 1
	cd $(SOURCES)/gzip-1.6/ && ./configure --prefix=/usr --bindir=/bin
	cd $(SOURCES)/gzip-1.6/ && make
	cd $(SOURCES)/gzip-1.6/ && make install
	cd $(SOURCES)/gzip-1.6/ && mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
	cd $(SOURCES)/gzip-1.6/ && mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin

IPRoute2-3-9-0:
	cd $(SOURCES) && rm -rf iproute2-3.9.0
	cd $(SOURCES) && rm -rf iproute2-build
	cd $(SOURCES) && mkdir -pv iproute2-3.9.0
	cd $(SOURCES) && tar xvf iproute2-3.9.0.tar.xz -C iproute2-3.9.0  --strip-components 1
	cd $(SOURCES)/iproute2-3.9.0/ && sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
	cd $(SOURCES)/iproute2-3.9.0/ && sed -i /ARPD/d Makefile
	cd $(SOURCES)/iproute2-3.9.0/ && sed -i 's/arpd.8//' man/man8/Makefile
	cd $(SOURCES)/iproute2-3.9.0/ && sed -i 's/-Werror//' Makefile
	cd $(SOURCES)/iproute2-3.9.0/ && make DESTDIR=
	cd $(SOURCES)/iproute2-3.9.0/ && make DESTDIR=              \
	MANDIR=/usr/share/man \
	DOCDIR=/usr/share/doc/iproute2-3.9.0 install

Kbd-1-15-5:
	cd $(SOURCES) && rm -rf kbd-1.15.5
	cd $(SOURCES) && rm -rf kbd-build
	cd $(SOURCES) && mkdir -pv kbd-1.15.5
	cd $(SOURCES) && tar xvf kbd-1.15.5.tar.gz -C kbd-1.15.5  --strip-components 1
	cd $(SOURCES)/kbd-1.15.5/ && patch -Np1 -i ../kbd-1.15.5-backspace-1.patch
	cd $(SOURCES)/kbd-1.15.5/ && sed -i -e '326 s/if/while/' src/loadkeys.analyze.l
	cd $(SOURCES)/kbd-1.15.5/ && sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
	cd $(SOURCES)/kbd-1.15.5/ && sed -i 's/resizecons.8 //' man/man8/Makefile.in
	cd $(SOURCES)/kbd-1.15.5/ && ./configure --prefix=/usr --disable-vlock
	cd $(SOURCES)/kbd-1.15.5/ && make
	cd $(SOURCES)/kbd-1.15.5/ && make install
	cd $(SOURCES)/kbd-1.15.5/ && mkdir -pv       /usr/share/doc/kbd-1.15.5
	cd $(SOURCES)/kbd-1.15.5/ && cp -R -v doc/* /usr/share/doc/kbd-1.15.5

Kmod-13:
	cd $(SOURCES) && rm -rf kmod-13
	cd $(SOURCES) && rm -rf kmod-build
	cd $(SOURCES) && mkdir -pv kmod-13
	cd $(SOURCES) && tar xvf kmod-13.tar.xz -C kmod-13  --strip-components 1
	cd $(SOURCES)/kmod-13/ && ./configure --prefix=/usr       \
	--bindir=/bin       \
	--libdir=/lib       \
	--sysconfdir=/etc   \
	--disable-manpages  \
	--with-xz           \
	--with-zlib
	cd $(SOURCES)/kmod-13/ && make
	cd $(SOURCES)/kmod-13/ && make pkgconfigdir=/usr/lib/pkgconfig install
	cd $(SOURCES)/kmod-13/ && for target in depmod insmod modinfo modprobe rmmod; do
	ln -sv ../bin/kmod /sbin/$(target)
	done
	cd $(SOURCES)/kmod-13/ && ln -sv kmod /bin/lsmod

Libpipeline-1-2-4:
	cd $(SOURCES) && rm -rf libpipeline-1.2.4
	cd $(SOURCES) && rm -rf libpipeline-build
	cd $(SOURCES) && mkdir -pv libpipeline-1.2.4
	cd $(SOURCES) && tar xvf libpipeline-1.2.4.tar.gz -C libpipeline-1.2.4  --strip-components 1
	cd $(SOURCES)/libpipeline-1.2.4/ && PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr
	cd $(SOURCES)/libpipeline-1.2.4/ && make
	cd $(SOURCES)/libpipeline-1.2.4/ && make install

Make-3-82:
	cd $(SOURCES) && rm -rf make-3.82
	cd $(SOURCES) && rm -rf make-build
	cd $(SOURCES) && mkdir -pv make-3.82
	cd $(SOURCES) && tar xvf make-3.82.tar.bz2 -C make-3.82  --strip-components 1
	cd $(SOURCES)/make-3.82/ && patch -Np1 -i ../make-3.82-upstream_fixes-3.patch
	cd $(SOURCES)/make-3.82/ && ./configure --prefix=/usr
	cd $(SOURCES)/make-3.82/ && make
	cd $(SOURCES)/make-3.82/ && make install

Man-DB-2-6-3:
	cd $(SOURCES) && rm -rf man-db-2.6.3
	cd $(SOURCES) && rm -rf man-db-build
	cd $(SOURCES) && mkdir -pv man-db-2.6.3
	cd $(SOURCES) && tar xvf man-db-2.6.3.tar.xz -C man-db-2.6.3  --strip-components 1
	cd $(SOURCES)/man-db-2.6.3/ && ./configure --prefix=/usr                        \
	--libexecdir=/usr/lib                \
	--docdir=/usr/share/doc/man-db-2.6.3 \
	--sysconfdir=/etc                    \
	--disable-setuid                     \
	--with-browser=/usr/bin/lynx         \
	--with-vgrind=/usr/bin/vgrind        \
	--with-grap=/usr/bin/grap
	cd $(SOURCES)/man-db-2.6.3/ && make
	cd $(SOURCES)/man-db-2.6.3/ && make install

Patch-2-7-1:
	cd $(SOURCES) && rm -rf patch-2.7.1
	cd $(SOURCES) && rm -rf patch-build
	cd $(SOURCES) && mkdir -pv patch-2.7.1
	cd $(SOURCES) && tar xvf patch-2.7.1.tar.xz -C patch-2.7.1  --strip-components 1
	cd $(SOURCES)/patch-2.7.1/ && ./configure --prefix=/usr
	cd $(SOURCES)/patch-2.7.1/ && make
	cd $(SOURCES)/patch-2.7.1/ && make install

Sysklogd-1-5:
	cd $(SOURCES) && rm -rf sysklogd-1.5
	cd $(SOURCES) && rm -rf sysklogd-build
	cd $(SOURCES) && mkdir -pv sysklogd-1.5
	cd $(SOURCES) && tar xvf sysklogd-1.5.tar.gz -C sysklogd-1.5  --strip-components 1
	cd $(SOURCES)/sysklogd-1.5/ && make
	cd $(SOURCES)/sysklogd-1.5/ && make BINDIR=/sbin install
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

Sysvinit-2-88dsf:
	cd $(SOURCES) && rm -rf sysvinit-2.88
	cd $(SOURCES) && rm -rf sysvinit-build
	cd $(SOURCES) && mkdir -pv sysvinit-2.88
	cd $(SOURCES) && tar xvf sysvinit-2.88dsf.tar.bz2 -C sysvinit-2.88  --strip-components 1
	cd $(SOURCES)/sysvinit-2.88/ && sed -i 's@Sending processes@& configured via /etc/inittab@g' src/init.c
	cd $(SOURCES)/sysvinit-2.88/ && sed -i -e '/utmpdump/d' \
	-e '/mountpoint/d' src/Makefile
	cd $(SOURCES)/sysvinit-2.88/ && make -C src
	cd $(SOURCES)/sysvinit-2.88/ && make -C src install

Tar-1-26:
	cd $(SOURCES) && rm -rf tar-1.26
	cd $(SOURCES) && rm -rf tar-build
	cd $(SOURCES) && mkdir -pv tar-1.26
	cd $(SOURCES) && tar xvf tar-1.26.tar.bz2 -C tar-1.26  --strip-components 1
	cd $(SOURCES)/tar-1.26/ && sed -i -e '/gets is a/d' gnu/stdio.in.h
	cd $(SOURCES)/tar-1.26/ && FORCE_UNSAFE_CONFIGURE=1  \
	./configure --prefix=/usr \
	--bindir=/bin \
	--libexecdir=/usr/sbin
	cd $(SOURCES)/tar-1.26/ && make
	cd $(SOURCES)/tar-1.26/ && make install
	cd $(SOURCES)/tar-1.26/ && make -C doc install-html docdir=/usr/share/doc/tar-1.26

Texinfo-5-1:
	cd $(SOURCES) && rm -rf texinfo-5.1
	cd $(SOURCES) && rm -rf texinfo-build
	cd $(SOURCES) && mkdir -pv texinfo-5.1
	cd $(SOURCES) && tar xvf texinfo-5.1.tar.xz -C texinfo-5.1  --strip-components 1
	cd $(SOURCES)/texinfo-5.1/ && ./configure --prefix=/usr
	cd $(SOURCES)/texinfo-5.1/ && make
	cd $(SOURCES)/texinfo-5.1/ && make install
	cd $(SOURCES)/texinfo-5.1/ && make TEXMF=/usr/share/texmf install-tex
	cd $(SOURCES)/texinfo-5.1/ && cd /usr/share/info
	cd $(SOURCES)/texinfo-5.1/ && rm -v dir
	cd $(SOURCES)/texinfo-5.1/ && for f in *
	do install-info $(f) dir 2>/dev/null
	done

Udev-204-Extracted-from-systemd-204-:
	cd $(SOURCES) && rm -rf udev-204
	cd $(SOURCES) && rm -rf udev-build
	cd $(SOURCES) && mkdir -pv udev-204
	cd $(SOURCES) && tar xvf udev-lfs-204-1.tar.bz2 -C udev-204  --strip-components 1
	cd $(SOURCES)/udev-204/ && tar -xvf ../udev-lfs-204-1.tar.bz2
	cd $(SOURCES)/udev-204/ && make -f udev-lfs-204-1/Makefile.lfs
	cd $(SOURCES)/udev-204/ && make -f udev-lfs-204-1/Makefile.lfs install
	cd $(SOURCES)/udev-204/ && sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-197-2/init-net-rules.sh
build/udevadm hwdb --update
	cd $(SOURCES)/udev-204/ && bash udev-lfs-204-1/init-net-rules.sh

Vim-7-3:
	cd $(SOURCES) && rm -rf vim-7.3
	cd $(SOURCES) && rm -rf vim-build
	cd $(SOURCES) && mkdir -pv vim-7.3
	cd $(SOURCES) && tar xvf vim-7.3.tar.bz2 -C vim-7.3  --strip-components 1
	cd $(SOURCES)/vim-7.3/ && echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
	cd $(SOURCES)/vim-7.3/ && ./configure --prefix=/usr --enable-multibyte
	cd $(SOURCES)/vim-7.3/ && make
	cd $(SOURCES)/vim-7.3/ && make install
	cd $(SOURCES)/vim-7.3/ && ln -sv vim /usr/bin/vi
	cd $(SOURCES)/vim-7.3/ && for L in  /usr/share/man/{,*/}man1/vim.1; do
	ln -sv vim.1 $(dirname $(L))/vi.1
	done
	cd $(SOURCES)/vim-7.3/ && ln -sv ../vim/vim73/doc /usr/share/doc/vim-7.3
	cat > /etc/vimrc << "EOF"
	" Begin /etc/vimrc
	set nocompatible
	set backspace=2
	syntax on
	cd $(SOURCES)/vim-7.3/ && if (&term == "iterm") || (&term == "putty")
	set background=dark
	endif
	" End /etc/vimrc
	EOF

Stripping-Again:
	logout
	cd $(SOURCES)/stripping-/ && chroot $(LFS) /tools/bin/env -i \
	HOME=/root TERM=$(TERM) PS1='\u:\w\$ ' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin \
	/tools/bin/find /{,usr/}{bin,lib,sbin} -type f \
	-exec /tools/bin/strip --strip-debug '{}' ';'

Cleaning-Up:
	cd $(SOURCES)/cleaning-/ && chroot "$(LFS)" /usr/bin/env -i \
	HOME=/root TERM="$(TERM)" PS1='\u:\w\$ ' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin \
	/bin/bash --login
