%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Dash is a POSIX compliant shell. It can be installed as /bin/sh or as the default shell for either root or a second user with a userid of 0. It depends on fewer libraries than the Bash shell and is therefore less likely to be affected by an upgrade problem or disk failure. Dash is also useful for checking that a script is completely compatible with POSIX syntax. 
Name:       dash
Version:    0.5.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.7.tar.gz
URL:        http://gondor.apana.org.au/~herbert/dash/files
%description
 Dash is a POSIX compliant shell. It can be installed as /bin/sh or as the default shell for either root or a second user with a userid of 0. It depends on fewer libraries than the Bash shell and is therefore less likely to be affected by an upgrade problem or disk failure. Dash is also useful for checking that a script is completely compatible with POSIX syntax. 
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
./configure --bindir=/bin --mandir=/usr/share/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

ln -svf dash ${RPM_BUILD_ROOT}/bin/sh


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/shells << "EOF"

/bin/dash

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog