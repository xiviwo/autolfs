%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Itstool extracts messages from XML files and outputs PO template files, then merges translations from MO files to create translated XML files. It determines what to translate and how to chunk it into messages using the W3C Internationalization Tag Set (ITS). 
Name:       itstool
Version:    1.2.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  docbook-xml
Requires:  docbook-xsl
Requires:  python
Source0:    http://files.itstool.org/itstool/itstool-1.2.0.tar.bz2
URL:        http://files.itstool.org/itstool
%description
 Itstool extracts messages from XML files and outputs PO template files, then merges translations from MO files to create translated XML files. It determines what to translate and how to chunk it into messages using the W3C Internationalization Tag Set (ITS). 
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