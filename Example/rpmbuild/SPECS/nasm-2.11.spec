%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     NASM (Netwide Assembler) is an 80x86 assembler designed for portability and modularity. It includes a disassembler as well. 
Name:       nasm
Version:    2.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.nasm.us/pub/nasm/releasebuilds/2.11/nasm-2.11.tar.xz
Source1:    http://www.nasm.us/pub/nasm/releasebuilds/2.11/nasm-2.11-xdoc.tar.xz
URL:        http://www.nasm.us/pub/nasm/releasebuilds/2.11
%description
 NASM (Netwide Assembler) is an 80x86 assembler designed for portability and modularity. It includes a disassembler as well. 
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
tar -xf  %_sourcedir/nasm-2.11-xdoc.tar.xz --strip-components=1
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/info
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/nasm-2.11/html
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/nasm-2.11
make install DESTDIR=${RPM_BUILD_ROOT} 

install -m755 -d         ${RPM_BUILD_ROOT}/usr/share/doc/nasm-2.11/html  &&

cp -v doc/html/*.html    ${RPM_BUILD_ROOT}/usr/share/doc/nasm-2.11/html  &&

cp -v doc/*.{txt,ps,pdf} ${RPM_BUILD_ROOT}/usr/share/doc/nasm-2.11       &&

cp -v doc/info/*         ${RPM_BUILD_ROOT}/usr/share/info                   &&

install-info ${RPM_BUILD_ROOT}/usr/share/info/nasm.info ${RPM_BUILD_ROOT}/usr/share/info/dir


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