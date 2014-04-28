%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Screen is a terminal multiplexor that runs several separate processes, typically interactive shells, on a single physical character-based terminal. Each virtual terminal emulates a DEC VT100 plus several ANSI X3.64 and ISO 2022 functions and also provides configurable input and output translation, serial port support, configurable logging, multi-user support, and many character encodings, including UTF-8. Screen sessions can be detached and resumed later on a different terminal. 
Name:       screen
Version:    4.0.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz
URL:        http://ftp.gnu.org/gnu/screen
%description
 Screen is a terminal multiplexor that runs several separate processes, typically interactive shells, on a single physical character-based terminal. Each virtual terminal emulates a DEC VT100 plus several ANSI X3.64 and ISO 2022 functions and also provides configurable input and output translation, serial port support, configurable logging, multi-user support, and many character encodings, including UTF-8. Screen sessions can be detached and resumed later on a different terminal. 
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
./configure --prefix=/usr --infodir=/usr/share/info --mandir=/usr/share/man --with-socket-dir=/var/run/screen --with-pty-group=5 --with-sys-screenrc=/etc/screenrc &&
sed -i -e "s%/usr/local/etc/screenrc%/etc/screenrc%" {etc,doc}/* &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -m 644 etc/etcscreenrc ${RPM_BUILD_ROOT}/etc/screenrc


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