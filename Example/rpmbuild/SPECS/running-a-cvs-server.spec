%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This section will describe how to set up, administer and secure a CVS server. 
Name:       running-a-cvs-server
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/general/cvsserver.html
%description
 This section will describe how to set up, administer and secure a CVS server. 
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

mkdir -pv ${RPM_BUILD_ROOT}/srv
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/srv/cvsroot/CVSROOT
mkdir -pv ${RPM_BUILD_ROOT}/bin
mkdir -pv ${RPM_BUILD_ROOT}/srv/cvsroot &&

export CVSROOT=${RPM_BUILD_ROOT}/srv/cvsroot &&
cvs init
cd <sourcedir> &&
cvs import -m "<repository test>" <cvstest> <vendortag> <releasetag>
cvs co cvstest
export CVS_RSH=${RPM_BUILD_ROOT}/usr/bin/ssh &&
cvs -d:ext:<servername>:/srv/cvsroot co cvstest
(grep anonymous ${RPM_BUILD_ROOT}/etc/passwd || useradd anonymous -s ${RPM_BUILD_ROOT}/bin/false -u 98) &&

echo anonymous: > ${RPM_BUILD_ROOT}/srv/cvsroot/CVSROOT/passwd &&

echo anonymous > ${RPM_BUILD_ROOT}/srv/cvsroot/CVSROOT/readers

cvs -d:pserver:anonymous@<servername>:/srv/cvsroot co cvstest

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod 1777     /srv/cvsroot &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog