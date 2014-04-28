%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Intltool is an internationalization tool used for extracting translatable strings from source files, collecting the extracted strings with messages from traditional source files (<source directory>/<package>/po) and merging the translations into .xml, .desktop and .oaf files. 
Name:       intltool
Version:    0.50.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  xml-parser
Source0:    http://launchpad.net/intltool/trunk/0.50.2/+download/intltool-0.50.2.tar.gz
URL:        http://launchpad.net/intltool/trunk/0.50.2/+download
%description
 The Intltool is an internationalization tool used for extracting translatable strings from source files, collecting the extracted strings with messages from traditional source files (<source directory>/<package>/po) and merging the translations into .xml, .desktop and .oaf files. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/intltool-0.50.2
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 -D doc/I18N-HOWTO ${RPM_BUILD_ROOT}/usr/share/doc/intltool-0.50.2/I18N-HOWTO


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