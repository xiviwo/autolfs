%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Linux PAM package contains Pluggable Authentication Modules used to enable the local system administrator to choose how applications authenticate users. 
Name:       linux-pam
Version:    1.1.7
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://linux-pam.org/library/Linux-PAM-1.1.7.tar.bz2
Source1:    http://linux-pam.org/documentation/Linux-PAM-1.1.7-docs.tar.bz2
URL:        http://linux-pam.org/library
%description
 The Linux PAM package contains Pluggable Authentication Modules used to enable the local system administrator to choose how applications authenticate users. 
%pre
install -v -m755 -d /etc/pam.d 
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
tar -xf  %_sourcedir/Linux-PAM-1.1.7-docs.tar.bz2 --strip-components=1
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/Linux-PAM-1.1.7 --disable-nis 
make %{?_smp_mflags} 
cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF
rm -rfv /etc/pam.d

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/sbin
make install  DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 4755 /sbin/unix_chkpwd
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog