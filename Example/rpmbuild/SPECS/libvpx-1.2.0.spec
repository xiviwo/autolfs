%define dist BLFS
Summary:     This package provides the reference implementation of the vp8 Codec from the WebM project, used in most current html5 video. 
Name:       libvpx
Version:    1.2.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  yasm
Requires:  nasm
Requires:  which
Source0:    http://webm.googlecode.com/files/libvpx-v1.2.0.tar.bz2
URL:        http://webm.googlecode.com/files
%description
 This package provides the reference implementation of the vp8 Codec from the WebM project, used in most current html5 video. 
%pre
%prep
rm -rf %_builddir/%{name}-%{version}
mkdir -pv %_builddir/%{name}-%{version} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{name}-%{version}
	;;
	*tar)
	tar xf %SOURCE0 -C %{name}-%{version} 
	;;
	*)
	tar xf %SOURCE0 -C %{name}-%{version}  --strip-components 1
	;;
esac

%build
cd %_builddir/%{name}-%{version}
mkdir -pv ../libvpx-build &&
cd ../libvpx-build &&
../libvpx-v1.2.0/configure --prefix=/usr \
                           --enable-shared \
                           --disable-static &&
make %{?_smp_mflags} 

%install
cd %_builddir/%{name}-%{version}
rm -rf ${RPM_BUILD_ROOT}
cd ../libvpx-build

make install DESTDIR=$RPM_BUILD_ROOT 

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