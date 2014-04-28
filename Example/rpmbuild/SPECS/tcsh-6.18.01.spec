%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Tcsh package contains “an enhanced but completely compatible version of the Berkeley Unix C shell (csh)”. This is useful as an alternative shell for those who prefer C syntax to that of the bash shell, and also because some programs require the C shell in order to perform installation tasks. 
Name:       tcsh
Version:    6.18.01
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.sfr-fresh.com/unix/misc/tcsh-6.18.01.tar.gz
Source1:    ftp://ftp.astron.com/pub/tcsh/tcsh-6.18.01.tar.gz
URL:        http://www.sfr-fresh.com/unix/misc
%description
 The Tcsh package contains “an enhanced but completely compatible version of the Berkeley Unix C shell (csh)”. This is useful as an alternative shell for those who prefer C syntax to that of the bash shell, and also because some programs require the C shell in order to perform installation tasks. 
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
sed -i -e 's|\$\*|#&|' -e 's|fR/g|&m|' tcsh.man2html &&
./configure --prefix=/usr --bindir=/bin &&
make && %{?_smp_mflags} 

sh ./tcsh.man2html

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/tcsh-6.18.01
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/tcsh-6.18.01/html
mkdir -pv ${RPM_BUILD_ROOT}/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
make install install.man && DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf tcsh   ${RPM_BUILD_ROOT}/bin/csh &&

ln -v -sf tcsh.1 ${RPM_BUILD_ROOT}/usr/share/man/man1/csh.1 &&

install -v -m755 -d          ${RPM_BUILD_ROOT}/usr/share/doc/tcsh-6.18.01/html &&

install -v -m644 tcsh.html/* ${RPM_BUILD_ROOT}/usr/share/doc/tcsh-6.18.01/html &&

install -v -m644 FAQ         ${RPM_BUILD_ROOT}/usr/share/doc/tcsh-6.18.01


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/shells << "EOF"

/bin/tcsh

/bin/csh

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog