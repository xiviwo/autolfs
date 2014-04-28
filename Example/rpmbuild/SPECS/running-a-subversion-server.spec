%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This section will describe how to set up, administer and secure a Subversion server. 
Name:       running-a-subversion-server
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/general/svnserver.html
%description
 This section will describe how to set up, administer and secure a Subversion server. 
%pre
groupadd -g 56 svn  || :

useradd -c "SVN Owner" -d /home/svn -m -g svn -s /bin/false -u 56 svn || :

groupadd -g 57 svntest  || :

usermod -G svntest -a svn || :

install -v -m 0755 -d /srv/svn &&

install -v -m 0755 -o svn -g svn -d /srv/svn/repositories &&

chown -R svn:svntest /srv/svn/repositories/svntest    &&

usermod -G svn,svntest -a mao || :
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
mv /usr/bin/svn /usr/bin/svn.orig &&
mv /usr/bin/svnserve /usr/bin/svnserve.orig &&
cat >> /usr/bin/svn << "EOF"
#!/bin/sh
umask 002
/usr/bin/svn.orig "$@"
EOF
cat >> /usr/bin/svnserve << "EOF"
#!/bin/sh
umask 002
/usr/bin/svnserve.orig "$@"
EOF
chmod 0755 /usr/bin/svn{,serve}
svnadmin create --fs-type fsfs /srv/svn/repositories/svntest
svn import -m "Initial import." </path/to/source/tree> file:///srv/svn/repositories/svntest
chmod -R g+w         /srv/svn/repositories/svntest    &&
chmod g+s            /srv/svn/repositories/svntest/db &&
svnlook tree /srv/svn/repositories/svntest/
cp /srv/svn/repositories/svntest/conf/svnserve.conf /srv/svn/repositories/svntest/conf/svnserve.conf.default &&
cat > /srv/svn/repositories/svntest/conf/svnserve.conf << "EOF"
[general]
anon-access = read
auth-access = write
EOF
mkdir -pv /etc
mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ${SOURCES}/blfs-boot-scripts


make install-svn DESTDIR=${RPM_BUILD_ROOT} 


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