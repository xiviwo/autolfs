%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The OpenSSH package contains ssh clients and the sshd daemon. This is useful for encrypting authentication and subsequent traffic over a network. The ssh and scp commands are secure implementions of telnet and rcp respectively. 
Name:       openssh
Version:    6.5p1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Source0:    http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz
Source1:    ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz
URL:        http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable
%description
 The OpenSSH package contains ssh clients and the sshd daemon. This is useful for encrypting authentication and subsequent traffic over a network. The ssh and scp commands are secure implementions of telnet and rcp respectively. 
%pre
install -v -m700 -d /var/lib/sshd &&

chown   -v root:sys /var/lib/sshd &&

groupadd -g 50 sshd  || :

useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd || :
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
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-privsep-path=/var/lib/sshd &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/pam.d
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/ssh
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
make install                                  && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 contrib/ssh-copy-id ${RPM_BUILD_ROOT}/usr/bin &&

install -v -m644 contrib/ssh-copy-id.1 ${RPM_BUILD_ROOT}/usr/share/man/man1 &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/openssh-6.5p1           &&

install -v -m644 INSTALL LICENCE OVERVIEW README* ${RPM_BUILD_ROOT}/usr/share/doc/openssh-6.5p1

sed 's@d/login@d/sshd@g' ${RPM_BUILD_ROOT}/etc/pam.d/login > ${RPM_BUILD_ROOT}/etc/pam.d/sshd &&

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-sshd DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

ssh-keygen &&

public_key="$(cat ~/.ssh/id_rsa.pub)" &&

ssh REMOTE_HOSTNAME "echo ${public_key} >> ~/.ssh/authorized_keys" &&

unset public_key

echo "PasswordAuthentication no" >> /etc/ssh/sshd_config &&

echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config

chmod 644 /etc/pam.d/sshd &&

echo "UsePAM yes" >> /etc/ssh/sshd_config
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog