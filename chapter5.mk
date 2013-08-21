LFS=/mnt/lfs
SOURCES=$(LFS)/sources
ConstructingaTemporarySystem : General-Compilation-Instructions Binutils-2-23-2-Pass-1 GCC-4-8-1-Pass-1 Linux-3-9-6-API-Headers Glibc-2-17 Libstdc-4-8-1 Binutils-2-23-2-Pass-2 GCC-4-8-1-Pass-2 Tcl-8-6-0 Expect-5-45 DejaGNU-1-5-1 Check-0-9-10 Ncurses-5-9 Bash-4-2 Bzip2-1-0-6 Coreutils-8-21 Diffutils-3-3 File-5-14 Findutils-4-4-2 Gawk-4-1-0 Gettext-0-18-2-1 Grep-2-14 Gzip-1-6 M4-1-4-16 Make-3-82 Patch-2-7-1 Perl-5-18-0 Sed-4-2-2 Tar-1-26 Texinfo-5-1 Xz-5-0-4 Stripping Changing-Ownership 
General-Compilation-Instructions:
	echo $(LFS)

Binutils-2-23-2-Pass-1:
	cd $(SOURCES) && rm -rf binutils-2.23.2
	cd $(SOURCES) && rm -rf binutils-build
	cd $(SOURCES) && mkdir -pv binutils-2.23.2
	cd $(SOURCES) && tar xvf binutils-2.23.2.tar.bz2 -C binutils-2.23.2  --strip-components 1
	cd $(SOURCES)/binutils-2.23.2/ && sed -i -e 's/@colophon/@@colophon/' \
	-e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
	cd $(SOURCES)/binutils-2.23.2/ && mkdir -pv ../binutils-build
	cd $(SOURCES)/binutils-2.23.2/ && cd ../binutils-build
	cd $(SOURCES)/binutils-build/ && ../binutils-2.23.2/configure   \
	--prefix=/tools            \
	--with-sysroot=$(LFS)        \
	--with-lib-path=/tools/lib \
	--target=$(LFS_TGT)          \
	--disable-nls              \
	--disable-werror
	cd $(SOURCES)/binutils-build/ && make
	case $(uname -m) in
	x86_64) mkdir -pv /tools/lib && ln -sv lib /tools/lib64 ;;
	esac
	cd $(SOURCES)/binutils-build/ && make install

GCC-4-8-1-Pass-1:
	cd $(SOURCES) && rm -rf gcc-4.8.1
	cd $(SOURCES) && rm -rf gcc-build
	cd $(SOURCES) && mkdir -pv gcc-4.8.1
	cd $(SOURCES) && tar xvf gcc-4.8.1.tar.bz2 -C gcc-4.8.1  --strip-components 1
	cd $(SOURCES)/gcc-4.8.1/ && tar -Jxf ../mpfr-3.1.2.tar.xz
	cd $(SOURCES)/gcc-4.8.1/ && mv -v mpfr-3.1.2 mpfr
	cd $(SOURCES)/gcc-4.8.1/ && tar -Jxf ../gmp-5.1.2.tar.xz
	cd $(SOURCES)/gcc-4.8.1/ && mv -v gmp-5.1.2 gmp
	cd $(SOURCES)/gcc-4.8.1/ && tar -zxf ../mpc-1.0.1.tar.gz
	cd $(SOURCES)/gcc-4.8.1/ && mv -v mpc-1.0.1 mpc
	cd $(SOURCES)/gcc-4.8.1/ && for file in \
	$(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
	do
	cp -uv $(file){,.orig}
	sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
	-e 's@/usr@/tools@g' $(file).orig > $(file)
	echo '
	#undef STANDARD_STARTFILE_PREFIX_1
	#undef STANDARD_STARTFILE_PREFIX_2
	#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
	#define STANDARD_STARTFILE_PREFIX_2 ""' >> $(file)
	touch $(file).orig
	done
	cd $(SOURCES)/gcc-4.8.1/ && sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure
	cd $(SOURCES)/gcc-4.8.1/ && mkdir -pv ../gcc-build
	cd $(SOURCES)/gcc-4.8.1/ && cd ../gcc-build
	cd $(SOURCES)/gcc-build/ && ../gcc-4.8.1/configure                               \
	--target=$(LFS_TGT)                                \
	--prefix=/tools                                  \
	--with-sysroot=$(LFS)                              \
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
	cd $(SOURCES)/gcc-build/ && make
	cd $(SOURCES)/gcc-build/ && make install
	cd $(SOURCES)/gcc-build/ && ln -sv libgcc.a `$(LFS_TGT-gcc) -print-libgcc-file-name | sed 's/libgcc/&_eh/'`

Linux-3-9-6-API-Headers:
	cd $(SOURCES) && rm -rf linux-3.9.6
	cd $(SOURCES) && rm -rf linux-build
	cd $(SOURCES) && mkdir -pv linux-3.9.6
	cd $(SOURCES) && tar xvf linux-3.9.6.tar.xz -C linux-3.9.6  --strip-components 1
	cd $(SOURCES)/linux-3.9.6/ && make mrproper
	cd $(SOURCES)/linux-3.9.6/ && make headers_check
	cd $(SOURCES)/linux-3.9.6/ && make INSTALL_HDR_PATH=dest headers_install
	cd $(SOURCES)/linux-3.9.6/ && cp -rv dest/include/* /tools/include

Glibc-2-17:
	cd $(SOURCES) && rm -rf glibc-2.17
	cd $(SOURCES) && rm -rf glibc-build
	cd $(SOURCES) && mkdir -pv glibc-2.17
	cd $(SOURCES) && tar xvf glibc-2.17.tar.xz -C glibc-2.17  --strip-components 1
	cd $(SOURCES)/glibc-2.17/ && if [ ! -r /usr/include/rpc/types.h ]; then
	su -c 'mkdir -p /usr/include/rpc'
	su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
	fi
	cd $(SOURCES)/glibc-2.17/ && mkdir -pv ../glibc-build
	cd $(SOURCES)/glibc-2.17/ && cd ../glibc-build
	cd $(SOURCES)/glibc-build/ && ../glibc-2.17/configure                             \
	--prefix=/tools                               \
	--host=$(LFS_TGT)                               \
	--build=$(../glibc-2.17/scripts/config.guess) \
	--disable-profile                             \
	--enable-kernel=2.6.25                        \
	--with-headers=/tools/include                 \
	libc_cv_forced_unwind=yes                     \
	libc_cv_ctors_header=yes                      \
	libc_cv_c_cleanup=yes
	cd $(SOURCES)/glibc-build/ && make
	cd $(SOURCES)/glibc-build/ && make install

Libstdc-4-8-1:
	cd $(SOURCES)/libstdc-4.8.1/ && mkdir -pv ../gcc-build
	cd $(SOURCES)/libstdc-4.8.1/ && cd ../gcc-build
	cd $(SOURCES)/libstdc-build/ && ../gcc-4.8.1/libstdc++-v3/configure \
	--host=$(LFS_TGT)                      \
	--prefix=/tools                      \
	--disable-multilib                   \
	--disable-shared                     \
	--disable-nls                        \
	--disable-libstdcxx-threads          \
	--disable-libstdcxx-pch              \
	--with-gxx-include-dir=/tools/$(LFS_TGT)/include/c++/4.8.1
	cd $(SOURCES)/libstdc-build/ && make
	cd $(SOURCES)/libstdc-build/ && make install

Binutils-2-23-2-Pass-2:
	cd $(SOURCES) && rm -rf binutils-2.23.2
	cd $(SOURCES) && rm -rf binutils-build
	cd $(SOURCES) && mkdir -pv binutils-2.23.2
	cd $(SOURCES) && tar xvf binutils-2.23.2.tar.bz2 -C binutils-2.23.2  --strip-components 1
	cd $(SOURCES)/binutils-2.23.2/ && sed -i -e 's/@colophon/@@colophon/' \
	-e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
	cd $(SOURCES)/binutils-2.23.2/ && mkdir -pv ../binutils-build
	cd $(SOURCES)/binutils-2.23.2/ && cd ../binutils-build
	cd $(SOURCES)/binutils-build/ && CC=$(LFS_TGT-gcc)                \
	AR=$(LFS_TGT-ar)                 \
	RANLIB=$(LFS_TGT-ranlib)         \
	../binutils-2.23.2/configure   \
	--prefix=/tools            \
	--disable-nls              \
	--with-lib-path=/tools/lib \
	--with-sysroot
	cd $(SOURCES)/binutils-build/ && make
	cd $(SOURCES)/binutils-build/ && make install
	cd $(SOURCES)/binutils-build/ && make -C ld clean
	cd $(SOURCES)/binutils-build/ && make -C ld LIB_PATH=/usr/lib:/lib
	cd $(SOURCES)/binutils-build/ && cp -v ld/ld-new /tools/bin

GCC-4-8-1-Pass-2:
	cd $(SOURCES) && rm -rf gcc-4.8.1
	cd $(SOURCES) && rm -rf gcc-build
	cd $(SOURCES) && mkdir -pv gcc-4.8.1
	cd $(SOURCES) && tar xvf gcc-4.8.1.tar.bz2 -C gcc-4.8.1  --strip-components 1
	cd $(SOURCES)/gcc-4.8.1/ && cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
	`dirname $($(LFS_TGT-gcc) -print-libgcc-file-name)`/include-fixed/limits.h
	cd $(SOURCES)/gcc-4.8.1/ && cp -v gcc/Makefile.in{,.tmp}
	cd $(SOURCES)/gcc-4.8.1/ && sed 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in.tmp \
	> gcc/Makefile.in
	cd $(SOURCES)/gcc-4.8.1/ && for file in \
	$(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
	do
	cp -uv $(file){,.orig}
	sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
	-e 's@/usr@/tools@g' $(file).orig > $(file)
	echo '
	#undef STANDARD_STARTFILE_PREFIX_1
	#undef STANDARD_STARTFILE_PREFIX_2
	#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
	#define STANDARD_STARTFILE_PREFIX_2 ""' >> $(file)
	touch $(file).orig
	done
	cd $(SOURCES)/gcc-4.8.1/ && tar -Jxf ../mpfr-3.1.2.tar.xz
	cd $(SOURCES)/gcc-4.8.1/ && mv -v mpfr-3.1.2 mpfr
	cd $(SOURCES)/gcc-4.8.1/ && tar -Jxf ../gmp-5.1.2.tar.xz
	cd $(SOURCES)/gcc-4.8.1/ && mv -v gmp-5.1.2 gmp
	cd $(SOURCES)/gcc-4.8.1/ && tar -zxf ../mpc-1.0.1.tar.gz
	cd $(SOURCES)/gcc-4.8.1/ && mv -v mpc-1.0.1 mpc
	cd $(SOURCES)/gcc-4.8.1/ && mkdir -pv ../gcc-build
	cd $(SOURCES)/gcc-4.8.1/ && cd ../gcc-build
	cd $(SOURCES)/gcc-build/ && CC=$(LFS_TGT-gcc)                                      \
	CXX=$(LFS_TGT-g)++                                     \
	AR=$(LFS_TGT-ar)                                       \
	RANLIB=$(LFS_TGT-ranlib)                               \
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
	cd $(SOURCES)/gcc-build/ && make
	cd $(SOURCES)/gcc-build/ && make install
	cd $(SOURCES)/gcc-build/ && ln -sv gcc /tools/bin/cc

Tcl-8-6-0:
	cd $(SOURCES) && rm -rf tcl-8.6.0
	cd $(SOURCES) && rm -rf tcl-build
	cd $(SOURCES) && mkdir -pv tcl-8.6.0
	cd $(SOURCES) && tar xvf tcl8.6.0-src.tar.gz -C tcl-8.6.0  --strip-components 1
	cd $(SOURCES)/tcl-8.6.0/ && sed -i s/500/5000/ generic/regc_nfa.c
	cd $(SOURCES)/tcl-8.6.0/ && cd unix
	cd $(SOURCES)/tcl-8.6.0/ && ./configure --prefix=/tools
	cd $(SOURCES)/tcl-8.6.0/ && make
	cd $(SOURCES)/tcl-8.6.0/ && make install
	cd $(SOURCES)/tcl-8.6.0/ && chmod -v u+w /tools/lib/libtcl8.6.so
	cd $(SOURCES)/tcl-8.6.0/ && make install-private-headers
	cd $(SOURCES)/tcl-8.6.0/ && ln -sv tclsh8.6 /tools/bin/tclsh

Expect-5-45:
	cd $(SOURCES) && rm -rf expect-5.45
	cd $(SOURCES) && rm -rf expect-build
	cd $(SOURCES) && mkdir -pv expect-5.45
	cd $(SOURCES) && tar xvf expect5.45.tar.gz -C expect-5.45  --strip-components 1
	cd $(SOURCES)/expect-5.45/ && cp -v configure{,.orig}
	cd $(SOURCES)/expect-5.45/ && sed 's:/usr/local/bin:/bin:' configure.orig > configure
	cd $(SOURCES)/expect-5.45/ && ./configure --prefix=/tools --with-tcl=/tools/lib \
	--with-tclinclude=/tools/include
	cd $(SOURCES)/expect-5.45/ && make
	cd $(SOURCES)/expect-5.45/ && make SCRIPTS="" install

DejaGNU-1-5-1:
	cd $(SOURCES) && rm -rf dejagnu-1.5.1
	cd $(SOURCES) && rm -rf dejagnu-build
	cd $(SOURCES) && mkdir -pv dejagnu-1.5.1
	cd $(SOURCES) && tar xvf dejagnu-1.5.1.tar.gz -C dejagnu-1.5.1  --strip-components 1
	cd $(SOURCES)/dejagnu-1.5.1/ && ./configure --prefix=/tools
	cd $(SOURCES)/dejagnu-1.5.1/ && make install

Check-0-9-10:
	cd $(SOURCES) && rm -rf check-0.9.10
	cd $(SOURCES) && rm -rf check-build
	cd $(SOURCES) && mkdir -pv check-0.9.10
	cd $(SOURCES) && tar xvf check-0.9.10.tar.gz -C check-0.9.10  --strip-components 1
	cd $(SOURCES)/check-0.9.10/ && ./configure --prefix=/tools
	cd $(SOURCES)/check-0.9.10/ && make
	cd $(SOURCES)/check-0.9.10/ && make install

Ncurses-5-9:
	cd $(SOURCES) && rm -rf ncurses-5.9
	cd $(SOURCES) && rm -rf ncurses-build
	cd $(SOURCES) && mkdir -pv ncurses-5.9
	cd $(SOURCES) && tar xvf ncurses-5.9.tar.gz -C ncurses-5.9  --strip-components 1
	cd $(SOURCES)/ncurses-5.9/ && ./configure --prefix=/tools --with-shared \
	--without-debug --without-ada --enable-overwrite
	cd $(SOURCES)/ncurses-5.9/ && make
	cd $(SOURCES)/ncurses-5.9/ && make install

Bash-4-2:
	cd $(SOURCES) && rm -rf bash-4.2
	cd $(SOURCES) && rm -rf bash-build
	cd $(SOURCES) && mkdir -pv bash-4.2
	cd $(SOURCES) && tar xvf bash-4.2.tar.gz -C bash-4.2  --strip-components 1
	cd $(SOURCES)/bash-4.2/ && patch -Np1 -i ../bash-4.2-fixes-12.patch
	cd $(SOURCES)/bash-4.2/ && ./configure --prefix=/tools --without-bash-malloc
	cd $(SOURCES)/bash-4.2/ && make
	cd $(SOURCES)/bash-4.2/ && make install
	cd $(SOURCES)/bash-4.2/ && ln -sv bash /tools/bin/sh

Bzip2-1-0-6:
	cd $(SOURCES) && rm -rf bzip2-1.0.6
	cd $(SOURCES) && rm -rf bzip2-build
	cd $(SOURCES) && mkdir -pv bzip2-1.0.6
	cd $(SOURCES) && tar xvf bzip2-1.0.6.tar.gz -C bzip2-1.0.6  --strip-components 1
	cd $(SOURCES)/bzip2-1.0.6/ && make
	cd $(SOURCES)/bzip2-1.0.6/ && make PREFIX=/tools install

Coreutils-8-21:
	cd $(SOURCES) && rm -rf coreutils-8.21
	cd $(SOURCES) && rm -rf coreutils-build
	cd $(SOURCES) && mkdir -pv coreutils-8.21
	cd $(SOURCES) && tar xvf coreutils-8.21.tar.xz -C coreutils-8.21  --strip-components 1
	cd $(SOURCES)/coreutils-8.21/ && ./configure --prefix=/tools --enable-install-program=hostname
	cd $(SOURCES)/coreutils-8.21/ && make
	cd $(SOURCES)/coreutils-8.21/ && make install

Diffutils-3-3:
	cd $(SOURCES) && rm -rf diffutils-3.3
	cd $(SOURCES) && rm -rf diffutils-build
	cd $(SOURCES) && mkdir -pv diffutils-3.3
	cd $(SOURCES) && tar xvf diffutils-3.3.tar.xz -C diffutils-3.3  --strip-components 1
	cd $(SOURCES)/diffutils-3.3/ && ./configure --prefix=/tools
	cd $(SOURCES)/diffutils-3.3/ && make
	cd $(SOURCES)/diffutils-3.3/ && make install

File-5-14:
	cd $(SOURCES) && rm -rf file-5.14
	cd $(SOURCES) && rm -rf file-build
	cd $(SOURCES) && mkdir -pv file-5.14
	cd $(SOURCES) && tar xvf file-5.14.tar.gz -C file-5.14  --strip-components 1
	cd $(SOURCES)/file-5.14/ && ./configure --prefix=/tools
	cd $(SOURCES)/file-5.14/ && make
	cd $(SOURCES)/file-5.14/ && make install

Findutils-4-4-2:
	cd $(SOURCES) && rm -rf findutils-4.4.2
	cd $(SOURCES) && rm -rf findutils-build
	cd $(SOURCES) && mkdir -pv findutils-4.4.2
	cd $(SOURCES) && tar xvf findutils-4.4.2.tar.gz -C findutils-4.4.2  --strip-components 1
	cd $(SOURCES)/findutils-4.4.2/ && ./configure --prefix=/tools
	cd $(SOURCES)/findutils-4.4.2/ && make
	cd $(SOURCES)/findutils-4.4.2/ && make install

Gawk-4-1-0:
	cd $(SOURCES) && rm -rf gawk-4.1.0
	cd $(SOURCES) && rm -rf gawk-build
	cd $(SOURCES) && mkdir -pv gawk-4.1.0
	cd $(SOURCES) && tar xvf gawk-4.1.0.tar.xz -C gawk-4.1.0  --strip-components 1
	cd $(SOURCES)/gawk-4.1.0/ && ./configure --prefix=/tools
	cd $(SOURCES)/gawk-4.1.0/ && make
	cd $(SOURCES)/gawk-4.1.0/ && make install

Gettext-0-18-2-1:
	cd $(SOURCES) && rm -rf gettext-0.18.2.1
	cd $(SOURCES) && rm -rf gettext-build
	cd $(SOURCES) && mkdir -pv gettext-0.18.2.1
	cd $(SOURCES) && tar xvf gettext-0.18.2.1.tar.gz -C gettext-0.18.2.1  --strip-components 1
	cd $(SOURCES)/gettext-0.18.2.1/ && cd gettext-tools
	cd $(SOURCES)/gettext-0.18.2.1/ && EMACS="no" ./configure --prefix=/tools --disable-shared
	cd $(SOURCES)/gettext-0.18.2.1/ && make -C gnulib-lib
	cd $(SOURCES)/gettext-0.18.2.1/ && make -C src msgfmt
	cd $(SOURCES)/gettext-0.18.2.1/ && cp -v src/msgfmt /tools/bin

Grep-2-14:
	cd $(SOURCES) && rm -rf grep-2.14
	cd $(SOURCES) && rm -rf grep-build
	cd $(SOURCES) && mkdir -pv grep-2.14
	cd $(SOURCES) && tar xvf grep-2.14.tar.xz -C grep-2.14  --strip-components 1
	cd $(SOURCES)/grep-2.14/ && ./configure --prefix=/tools
	cd $(SOURCES)/grep-2.14/ && make
	cd $(SOURCES)/grep-2.14/ && make install

Gzip-1-6:
	cd $(SOURCES) && rm -rf gzip-1.6
	cd $(SOURCES) && rm -rf gzip-build
	cd $(SOURCES) && mkdir -pv gzip-1.6
	cd $(SOURCES) && tar xvf gzip-1.6.tar.xz -C gzip-1.6  --strip-components 1
	cd $(SOURCES)/gzip-1.6/ && ./configure --prefix=/tools
	cd $(SOURCES)/gzip-1.6/ && make
	cd $(SOURCES)/gzip-1.6/ && make install

M4-1-4-16:
	cd $(SOURCES) && rm -rf m4-1.4.16
	cd $(SOURCES) && rm -rf m4-build
	cd $(SOURCES) && mkdir -pv m4-1.4.16
	cd $(SOURCES) && tar xvf m4-1.4.16.tar.bz2 -C m4-1.4.16  --strip-components 1
	cd $(SOURCES)/m4-1.4.16/ && sed -i -e '/gets is a/d' lib/stdio.in.h
	cd $(SOURCES)/m4-1.4.16/ && ./configure --prefix=/tools
	cd $(SOURCES)/m4-1.4.16/ && make
	cd $(SOURCES)/m4-1.4.16/ && make install

Make-3-82:
	cd $(SOURCES) && rm -rf make-3.82
	cd $(SOURCES) && rm -rf make-build
	cd $(SOURCES) && mkdir -pv make-3.82
	cd $(SOURCES) && tar xvf make-3.82.tar.bz2 -C make-3.82  --strip-components 1
	cd $(SOURCES)/make-3.82/ && ./configure --prefix=/tools
	cd $(SOURCES)/make-3.82/ && make
	cd $(SOURCES)/make-3.82/ && make install

Patch-2-7-1:
	cd $(SOURCES) && rm -rf patch-2.7.1
	cd $(SOURCES) && rm -rf patch-build
	cd $(SOURCES) && mkdir -pv patch-2.7.1
	cd $(SOURCES) && tar xvf patch-2.7.1.tar.xz -C patch-2.7.1  --strip-components 1
	cd $(SOURCES)/patch-2.7.1/ && ./configure --prefix=/tools
	cd $(SOURCES)/patch-2.7.1/ && make
	cd $(SOURCES)/patch-2.7.1/ && make install

Perl-5-18-0:
	cd $(SOURCES) && rm -rf perl-5.18.0
	cd $(SOURCES) && rm -rf perl-build
	cd $(SOURCES) && mkdir -pv perl-5.18.0
	cd $(SOURCES) && tar xvf perl-5.18.0.tar.bz2 -C perl-5.18.0  --strip-components 1
	cd $(SOURCES)/perl-5.18.0/ && patch -Np1 -i ../perl-5.18.0-libc-1.patch
	cd $(SOURCES)/perl-5.18.0/ && sh Configure -des -Dprefix=/tools
	cd $(SOURCES)/perl-5.18.0/ && make
	cd $(SOURCES)/perl-5.18.0/ && cp -v perl cpan/podlators/pod2man /tools/bin
	cd $(SOURCES)/perl-5.18.0/ && mkdir -pv /tools/lib/perl5/5.18.0
	cd $(SOURCES)/perl-5.18.0/ && cp -Rv lib/* /tools/lib/perl5/5.18.0

Sed-4-2-2:
	cd $(SOURCES) && rm -rf sed-4.2.2
	cd $(SOURCES) && rm -rf sed-build
	cd $(SOURCES) && mkdir -pv sed-4.2.2
	cd $(SOURCES) && tar xvf sed-4.2.2.tar.bz2 -C sed-4.2.2  --strip-components 1
	cd $(SOURCES)/sed-4.2.2/ && ./configure --prefix=/tools
	cd $(SOURCES)/sed-4.2.2/ && make
	cd $(SOURCES)/sed-4.2.2/ && make install

Tar-1-26:
	cd $(SOURCES) && rm -rf tar-1.26
	cd $(SOURCES) && rm -rf tar-build
	cd $(SOURCES) && mkdir -pv tar-1.26
	cd $(SOURCES) && tar xvf tar-1.26.tar.bz2 -C tar-1.26  --strip-components 1
	cd $(SOURCES)/tar-1.26/ && sed -i -e '/gets is a/d' gnu/stdio.in.h
	cd $(SOURCES)/tar-1.26/ && ./configure --prefix=/tools
	cd $(SOURCES)/tar-1.26/ && make
	cd $(SOURCES)/tar-1.26/ && make install

Texinfo-5-1:
	cd $(SOURCES) && rm -rf texinfo-5.1
	cd $(SOURCES) && rm -rf texinfo-build
	cd $(SOURCES) && mkdir -pv texinfo-5.1
	cd $(SOURCES) && tar xvf texinfo-5.1.tar.xz -C texinfo-5.1  --strip-components 1
	cd $(SOURCES)/texinfo-5.1/ && ./configure --prefix=/tools
	cd $(SOURCES)/texinfo-5.1/ && make
	cd $(SOURCES)/texinfo-5.1/ && make install

Xz-5-0-4:
	cd $(SOURCES) && rm -rf xz-5.0.4
	cd $(SOURCES) && rm -rf xz-build
	cd $(SOURCES) && mkdir -pv xz-5.0.4
	cd $(SOURCES) && tar xvf xz-5.0.4.tar.xz -C xz-5.0.4  --strip-components 1
	cd $(SOURCES)/xz-5.0.4/ && ./configure --prefix=/tools
	cd $(SOURCES)/xz-5.0.4/ && make
	cd $(SOURCES)/xz-5.0.4/ && make install

Stripping:
	strip --strip-debug /tools/lib/*
	strip --strip-unneeded /tools/{,s}bin/*
	rm -rf /tools/{,share}/{info,man,doc}

Changing-Ownership:
	chown -R root:root $(LFS)/tools
