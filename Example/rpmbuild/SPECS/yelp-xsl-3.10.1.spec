%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Yelp XSL package contains XSL stylesheets that are used by the Yelp help browser to format Docbook and Mallard documents. 
Name:       yelp-xsl
Version:    3.10.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxslt
Requires:  intltool
Requires:  itstool
Source0:    http://ftp.gnome.org/pub/gnome/sources/yelp-xsl/3.10/yelp-xsl-3.10.1.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/yelp-xsl/3.10/yelp-xsl-3.10.1.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/yelp-xsl/3.10
%description
 The Yelp XSL package contains XSL stylesheets that are used by the Yelp help browser to format Docbook and Mallard documents. 
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
./configure --prefix=/usr &&
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