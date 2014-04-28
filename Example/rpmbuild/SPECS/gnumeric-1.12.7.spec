%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gnumeric package contains a spreadsheet program which is useful for mathematical analysis. 
Name:       gnumeric
Version:    1.12.7
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  goffice
Requires:  rarian
Source0:    http://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.7.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.7.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12
%description
 The Gnumeric package contains a spreadsheet program which is useful for mathematical analysis. 
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
sed -e "s@zz-application/zz-winassoc-xls;@@" -i gnumeric.desktop.in 
./configure --prefix=/usr 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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