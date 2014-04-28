%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Ncurses package contains libraries for terminal-independent handling of character screens. 
Name:       ncurses
Version:    5.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz

URL:        http://ftp.gnu.org/gnu/ncurses
%description
 The Ncurses package contains libraries for terminal-independent handling of character screens. 
%pre
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
./configure --prefix=/usr --mandir=/usr/share/man --with-shared --without-debug --enable-pc-files --enable-widec
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/pkgconfig
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/ncurses-5.9
make install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libncursesw.so.5* ${RPM_BUILD_ROOT}/lib

ln -sfv ../../lib/$(readlink ${RPM_BUILD_ROOT}/usr/lib/libncursesw.so) ${RPM_BUILD_ROOT}/usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
    rm -vf                    ${RPM_BUILD_ROOT}/usr/lib/lib${lib}.so

    echo "INPUT(-l${lib}w)" > ${RPM_BUILD_ROOT}/usr/lib/lib${lib}.so

    ln -sfv lib${lib}w.a      ${RPM_BUILD_ROOT}/usr/lib/lib${lib}.a

    ln -sfv ${lib}w.pc        ${RPM_BUILD_ROOT}/usr/lib/pkgconfig/${lib}.pc

done
ln -sfv libncurses++w.a ${RPM_BUILD_ROOT}/usr/lib/libncurses++.a

rm -vf                     ${RPM_BUILD_ROOT}/usr/lib/libcursesw.so

echo "INPUT(-lncursesw)" > ${RPM_BUILD_ROOT}/usr/lib/libcursesw.so

ln -sfv libncurses.so      ${RPM_BUILD_ROOT}/usr/lib/libcurses.so

ln -sfv libncursesw.a      ${RPM_BUILD_ROOT}/usr/lib/libcursesw.a

ln -sfv libncurses.a       ${RPM_BUILD_ROOT}/usr/lib/libcurses.a

mkdir -pv       ${RPM_BUILD_ROOT}/usr/share/doc/ncurses-5.9

cp -v -R doc/* ${RPM_BUILD_ROOT}/usr/share/doc/ncurses-5.9


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog