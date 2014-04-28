%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The JUnit package contains a simple, open source framework to write and run repeatable tests. It is an instance of the xUnit architecture for unit testing frameworks. JUnit features include assertions for testing expected results, test fixtures for sharing common test data, and test runners for running tests. 
Name:       junit
Version:    4.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  apache-ant
Requires:  unzip
Source0:    https://launchpad.net/debian/+archive/primary/+files/junit4_4.11.orig.tar.gz
Source1:    http://anduin.linuxfromscratch.org/sources/other/junit-4.11.jar
Source2:    http://hamcrest.googlecode.com/files/hamcrest-1.3.tgz
URL:        https://launchpad.net/debian/+archive/primary/+files
%description
 The JUnit package contains a simple, open source framework to write and run repeatable tests. It is an instance of the xUnit architecture for unit testing frameworks. JUnit features include assertions for testing expected results, test fixtures for sharing common test data, and test runners for running tests. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/java
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/java &&

cp -v junit-4.11.jar ${RPM_BUILD_ROOT}/usr/share/java

tar -xf  %_sourcedir/hamcrest-1.3.tgz                              &&
cp -v hamcrest-1.3/hamcrest-core-1.3{,-sources}.jar lib/ &&
ant dist
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/{doc,java}/junit-4.11 &&

cp -v -R junit*/javadoc/*             ${RPM_BUILD_ROOT}/usr/share/doc/junit-4.11  &&

cp -v junit*/junit*.jar               ${RPM_BUILD_ROOT}/usr/share/java/junit-4.11 &&

cp -v hamcrest-1.3/hamcrest-core*.jar ${RPM_BUILD_ROOT}/usr/share/java/junit-4.11

export CLASSPATH=$CLASSPATH:/usr/share/java/junit-4.11

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R root:root .                                 &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog