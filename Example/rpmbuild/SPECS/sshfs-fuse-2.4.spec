%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Sshfs Fuse package contains a filesystem client based on the SSH File Transfer Protocol. This is useful for mounting a remote computer that you have ssh access to as a local filesystem. This allows you to drag and drop files or run shell commands on the remote files as if they were on your local computer. 
Name:       sshfs-fuse
Version:    2.4
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  fuse
Requires:  glib
Requires:  openssh
Source0:    http://downloads.sourceforge.net/fuse/sshfs-fuse-2.4.tar.gz
URL:        http://downloads.sourceforge.net/fuse
%description
 The Sshfs Fuse package contains a filesystem client based on the SSH File Transfer Protocol. This is useful for mounting a remote computer that you have ssh access to as a local filesystem. This allows you to drag and drop files or run shell commands on the remote files as if they were on your local computer. 
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
./configure --prefix=/usr 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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