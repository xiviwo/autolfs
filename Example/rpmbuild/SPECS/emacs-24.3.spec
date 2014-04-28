%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Emacs package contains an extensible, customizable, self-documenting real-time display editor. 
Name:       emacs
Version:    24.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/pub/gnu/emacs/emacs-24.3.tar.xz
Source1:    ftp://ftp.gnu.org/pub/gnu/emacs/emacs-24.3.tar.xz
URL:        http://ftp.gnu.org/pub/gnu/emacs
%description
 The Emacs package contains an extensible, customizable, self-documenting real-time display editor. 
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
./configure --prefix=/usr --with-gif=no --localstatedir=/var  &&
make bootstrap %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/emacs/24.3
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/icons/hicolor
make install && DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -v -R root:root /usr/share/emacs/24.3

gtk-update-icon-cache -qf /usr/share/icons/hicolor
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog