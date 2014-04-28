%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Readline package is a set of libraries that offers command-line editing and history capabilities. 
Name:       readline
Version:    6.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz

URL:        http://ftp.gnu.org/gnu/readline
%description
 The Readline package is a set of libraries that offers command-line editing and history capabilities. 
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
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
patch -Np1 -i %_sourcedir/readline-6.2-fixes-2.patch
./configure --prefix=/usr
make SHLIB_LIBS=-lncurses %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/readline-6.2
make install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/lib{readline,history}.so.* ${RPM_BUILD_ROOT}/lib

ln -sfv ../../lib/$(readlink ${RPM_BUILD_ROOT}/usr/lib/libreadline.so) ${RPM_BUILD_ROOT}/usr/lib/libreadline.so

ln -sfv ../../lib/$(readlink ${RPM_BUILD_ROOT}/usr/lib/libhistory.so ) ${RPM_BUILD_ROOT}/usr/lib/libhistory.so

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/readline-6.2

install -v -m644 doc/*.{ps,pdf,html,dvi} ${RPM_BUILD_ROOT}/usr/share/doc/readline-6.2


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