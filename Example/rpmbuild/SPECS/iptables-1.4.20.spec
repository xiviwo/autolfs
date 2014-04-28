%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The next part of this chapter deals with firewalls. The principal firewall tool for Linux is Iptables. You will need to install Iptables if you intend on using any form of a firewall. 
Name:       iptables
Version:    1.4.20
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.netfilter.org/projects/iptables/files/iptables-1.4.20.tar.bz2
Source1:    ftp://ftp.netfilter.org/pub/iptables/iptables-1.4.20.tar.bz2
URL:        http://www.netfilter.org/projects/iptables/files
%description
 The next part of this chapter deals with firewalls. The principal firewall tool for Linux is Iptables. You will need to install Iptables if you intend on using any form of a firewall. 
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
./configure --prefix=/usr --exec-prefix= --bindir=/usr/bin --with-xtlibdir=/lib/xtables --with-pkgconfigdir=/usr/lib/pkgconfig --enable-libipq --enable-devel 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/etc
make install  DESTDIR=${RPM_BUILD_ROOT} 

ln -sfv ../../sbin/xtables-multi ${RPM_BUILD_ROOT}/usr/bin/iptables-xml 

for file in libip4tc libip6tc libipq libiptc libxtables
do
  ln -sfv ../../lib/`readlink ${RPM_BUILD_ROOT}/lib/${file}.so` ${RPM_BUILD_ROOT}/usr/lib/${file}.so 

  rm -v ${RPM_BUILD_ROOT}/lib/${file}.so 

  mv -v ${RPM_BUILD_ROOT}/lib/${file}.la ${RPM_BUILD_ROOT}/usr/lib 

  sed -i "s@libdir='@&/usr@g" ${RPM_BUILD_ROOT}/usr/lib/${file}.la

done
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-iptables DESTDIR=${RPM_BUILD_ROOT} 


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