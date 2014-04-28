%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The rsync package contains the rsync utility. This is useful for synchronizing large file archives over a network. 
Name:       rsync
Version:    3.1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  popt
Source0:    http://samba.org/ftp/rsync/src/rsync-3.1.0.tar.gz
Source1:    ftp://ftp.samba.org/pub/rsync/src/rsync-3.1.0.tar.gz
URL:        http://samba.org/ftp/rsync/src
%description
 The rsync package contains the rsync utility. This is useful for synchronizing large file archives over a network. 
%pre
groupadd -g 48 rsyncd  || :

useradd -c "rsyncd Daemon" -d /home/rsync -g rsyncd -s /bin/false -u 48 rsyncd || :
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
./configure --prefix=/usr --without-included-zlib &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/rsyncd.conf << "EOF"
# This is a basic rsync configuration file
# It exports a single module without user authentication.
motd file = /home/rsync/welcome.msg
use chroot = yes
[localhost]
    path = /home/rsync
    comment = Default rsync module
    read only = yes
    list = yes
    uid = rsyncd
    gid = rsyncd
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-rsyncd DESTDIR=${RPM_BUILD_ROOT} 


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