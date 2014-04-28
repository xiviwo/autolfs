%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Apache HTTPD package contains an open-source HTTP server. It is useful for creating local intranet web sites or running huge web serving operations. 
Name:       apache
Version:    2.4.6
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  apr-util
Requires:  openssl
Source0:    http://archive.apache.org/dist/httpd/httpd-2.4.6.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/httpd-2.4.6-blfs_layout-1.patch
URL:        http://archive.apache.org/dist/httpd
%description
 The Apache HTTPD package contains an open-source HTTP server. It is useful for creating local intranet web sites or running huge web serving operations. 
%pre
groupadd -g 25 apache

useradd -c "Apache Server" -d /srv/www -g apache -s /bin/false -u 25 apache
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
patch -Np1 -i %_sourcedir/httpd-2.4.6-blfs_layout-1.patch 
./configure --enable-layout=BLFS --enable-mods-shared="all cgi" --enable-mpms-shared=all --with-apr=/usr/bin/apr-1-config --with-apr-util=/usr/bin/apu-1-config --enable-suexec=shared --with-suexec-bin=/usr/lib/httpd/suexec --with-suexec-docroot=/srv/www --with-suexec-caller=apache --with-suexec-userdir=public_html --with-suexec-logfile=/var/log/httpd/suexec.log --with-suexec-uidmin=100 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/httpd
mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
mkdir -pv ${RPM_BUILD_ROOT}/srv
mkdir -pv ${RPM_BUILD_ROOT}/etc
make install                                  DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/sbin/suexec ${RPM_BUILD_ROOT}/usr/lib/httpd/suexec 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-httpd DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chgrp apache           /usr/lib/httpd/suexec 

chmod 4754             /usr/lib/httpd/suexec 

chown -v -R apache:apache /srv/www
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog