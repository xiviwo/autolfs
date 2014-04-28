%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The IcedTea-Web package contains both a Java browser plugin, and a new webstart implementation, licensed under GPLV3. 
Name:       icedtea-web
Version:    1.4.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  npapi-sdk
Requires:  openjdk
Requires:  xulrunner
Source0:    http://icedtea.classpath.org/download/source/icedtea-web-1.4.2.tar.gz
URL:        http://icedtea.classpath.org/download/source
%description
 The IcedTea-Web package contains both a Java browser plugin, and a new webstart implementation, licensed under GPLV3. 
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
./configure --prefix=${JAVA_HOME}/jre --with-jdk-home=${JAVA_HOME} --disable-docs --mandir=${JAVA_HOME}/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/opt/jdk
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins/
make install && DESTDIR=${RPM_BUILD_ROOT} 

mandb -c ${RPM_BUILD_ROOT}/opt/jdk/man

ln -svf ${JAVA_HOME}/jre/lib/IcedTeaPlugin.so ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins/


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