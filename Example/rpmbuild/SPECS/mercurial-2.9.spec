%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Mercurial is a distributed source control management tool similar to Git and Bazaar. Mercurial is written in Python and is used by projects such as Mozilla and Vim. 
Name:       mercurial
Version:    2.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Source0:    http://mercurial.selenic.com/release/mercurial-2.9.tar.gz
URL:        http://mercurial.selenic.com/release
%description
 Mercurial is a distributed source control management tool similar to Git and Bazaar. Mercurial is written in Python and is used by projects such as Mozilla and Vim. 
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
make build %{?_smp_mflags} 

make doc %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/mercurial
make PREFIX=${RPM_BUILD_ROOT}/usr install-bin DESTDIR=${RPM_BUILD_ROOT} 

install -v -d -m755 ${RPM_BUILD_ROOT}/etc/mercurial &&

cat > /etc/mercurial/hgrc << "EOF"
[web]
cacerts = /etc/ssl/ca-bundle.crt
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> ~/.hgrc << "EOF"

[ui]

username = <user_name> <your@mail>

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog