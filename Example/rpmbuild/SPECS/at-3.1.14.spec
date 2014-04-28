%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The at package provide delayed job execution and batch processing. It is required for Linux Standards Base (LSB) conformance. 
Name:       at
Version:    3.1.14
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  chapter
Source0:    http://ftp.de.debian.org/debian/pool/main/a/at/at_3.1.14.orig.tar.gz
Source1:    ftp://ftp.de.debian.org/debian/pool/main/a/at/at_3.1.14.orig.tar.gz
URL:        http://ftp.de.debian.org/debian/pool/main/a/at
%description
 The at package provide delayed job execution and batch processing. It is required for Linux Standards Base (LSB) conformance. 
%pre
groupadd -g 17 atd                                                   || :

useradd -d /dev/null -c "atd daemon" -g atd -s /bin/false -u 17 atd  || :
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
mkdir -pv -p /var/spool/cron
./configure --docdir=/usr/share/doc/at-3.1.14 --with-daemon_username=atd --with-daemon_groupname=atd SENDMAIL=/usr/sbin/sendmail &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-atd DESTDIR=${RPM_BUILD_ROOT} 


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