%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Apache Ant package is a Java-based build tool. In theory, it is kind of like make, but without make's wrinkles. Ant is different. Instead of a model that is extended with shell-based commands, Ant is extended using Java classes. Instead of writing shell commands, the configuration files are XML-based, calling out a target tree that executes various tasks. Each task is run by an object that implements a particular task interface. 
Name:       apache-ant
Version:    1.9.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  installing-a-binary-jdk
Requires:  glib
Requires:  junit
Source0:    http://archive.apache.org/dist/ant/source/apache-ant-1.9.3-src.tar.bz2
URL:        http://archive.apache.org/dist/ant/source
%description
 The Apache Ant package is a Java-based build tool. In theory, it is kind of like make, but without make's wrinkles. Ant is different. Instead of a model that is extended with shell-based commands, Ant is extended using Java classes. Instead of writing shell commands, the configuration files are XML-based, calling out a target tree that executes various tasks. Each task is run by an object that implements a particular task interface. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/java
mkdir -pv ${RPM_BUILD_ROOT}/opt
sed -i 's/jars,test-jar/jars/' build.xml
cp -v ${RPM_BUILD_ROOT}/usr/share/java/junit-4.11.jar lib/optional

./build.sh -Ddist.dir=${RPM_BUILD_ROOT}/opt/ant-1.9.3 dist &&
ln -v -sfn ant-1.9.3 ${RPM_BUILD_ROOT}/opt/ant


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