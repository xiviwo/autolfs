%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    creating-directories
Name:       creating-directories
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/lfs/view/stable/chapter06/creatingdirs.html
%description
creating-directories
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/local/lib64
mkdir -pv ${RPM_BUILD_ROOT}/usr/
mkdir -pv ${RPM_BUILD_ROOT}/var
mkdir -pv ${RPM_BUILD_ROOT}/tmp
mkdir -pv ${RPM_BUILD_ROOT}/var/run
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib64
mkdir -pv ${RPM_BUILD_ROOT}/var/
mkdir -pv ${RPM_BUILD_ROOT}/
mkdir -pv ${RPM_BUILD_ROOT}/run
mkdir -pv ${RPM_BUILD_ROOT}/usr/libexec
mkdir -pv ${RPM_BUILD_ROOT}/var/tmp
mkdir -pv ${RPM_BUILD_ROOT}/lib64
mkdir -pv ${RPM_BUILD_ROOT}/root
mkdir -pv ${RPM_BUILD_ROOT}/{bin,boot,etc/{opt,sysconfig},home,lib,mnt,opt}

mkdir -pv ${RPM_BUILD_ROOT}/{media/{floppy,cdrom},sbin,srv,var}

install -dv -m 0750 ${RPM_BUILD_ROOT}/root

install -dv -m 1777 ${RPM_BUILD_ROOT}/tmp ${RPM_BUILD_ROOT}/var/tmp

mkdir -pv ${RPM_BUILD_ROOT}/usr/{,local/}{bin,include,lib,sbin,src}

mkdir -pv ${RPM_BUILD_ROOT}/usr/{,local/}share/{color,dict,doc,info,locale,man}

mkdir -pv  ${RPM_BUILD_ROOT}/usr/{,local/}share/{misc,terminfo,zoneinfo}

mkdir -pv  ${RPM_BUILD_ROOT}/usr/libexec

mkdir -pv ${RPM_BUILD_ROOT}/usr/{,local/}share/man/man{1..8}

case $(uname -m) in
 x86_64) ln -svf lib ${RPM_BUILD_ROOT}/lib64     && 

         ln -svf lib ${RPM_BUILD_ROOT}/usr/lib64 && 

         ln -svf lib ${RPM_BUILD_ROOT}/usr/local/lib64 ;;

esac
mkdir -pv ${RPM_BUILD_ROOT}/var/{log,mail,spool}

ln -svf /run ${RPM_BUILD_ROOT}/var/run

ln -svf /run/lock ${RPM_BUILD_ROOT}/var/lock

mkdir -pv ${RPM_BUILD_ROOT}/var/{opt,cache,lib/{color,misc,locate},local}


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