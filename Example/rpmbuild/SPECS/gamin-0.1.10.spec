%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gamin package contains a File Alteration Monitor which is useful for notifying applications of changes to the file system. Gamin is compatible with FAM. 
Name:       gamin
Version:    0.1.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Source0:    http://www.gnome.org/~veillard/gamin/sources/gamin-0.1.10.tar.gz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/gamin-0.1.10.tar.gz
URL:        http://www.gnome.org/~veillard/gamin/sources
%description
 The Gamin package contains a File Alteration Monitor which is useful for notifying applications of changes to the file system. Gamin is compatible with FAM. 
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
sed -i 's/G_CONST_RETURN/const/' server/gam_{node,subscription}.{c,h} 
./configure --prefix=/usr --libexecdir=/usr/sbin --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/gamin-0.1.10 

install -v -m644 doc/*.{html,fig,gif,txt} ${RPM_BUILD_ROOT}/usr/share/doc/gamin-0.1.10


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