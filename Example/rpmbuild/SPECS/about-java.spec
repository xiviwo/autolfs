%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    about-java
Name:       about-java
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  atk
Requires:  cairo
Requires:  cups
Requires:  gdk-pixbuf
Requires:  giflib
Requires:  gtk
Requires:  little-cms
Requires:  pulseaudio
Requires:  xorg-libraries
Source0:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/OpenJDK-1.7.0.51-i686-bin.tar.xz
Source1:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/OpenJDK-1.7.0.51-x86_64-bin.tar.xz
URL:        http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51
%description
about-java
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

mkdir -pv ${RPM_BUILD_ROOT}/opt
install -vdm755 ${RPM_BUILD_ROOT}/opt/OpenJDK-1.7.0.51-bin &&

mv -v * ${RPM_BUILD_ROOT}/opt/OpenJDK-1.7.0.51-bin         &&

export CLASSPATH=.:/usr/share/java &&
export PATH="$PATH:/opt/OpenJDK-1.7.0.51-bin/bin"

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R root:root /opt/OpenJDK-1.7.0.51-bin
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog