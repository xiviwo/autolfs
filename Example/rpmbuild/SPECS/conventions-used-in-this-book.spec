export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    conventions-used-in-this-book
Name:       conventions-used-in-this-book
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/introduction/conventions.html
%description
conventions-used-in-this-book
%pre
%prep
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


./configure --prefix=${RPM_BUILD_ROOT}/usr
cat > $LFS/etc/group << "EOF"
root:x:0:
bin:x:1:
......
EOF

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog