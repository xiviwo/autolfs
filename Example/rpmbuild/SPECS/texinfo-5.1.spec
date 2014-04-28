%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Texinfo package contains programs for reading, writing, and converting info pages. 
Name:       texinfo
Version:    5.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/texinfo/texinfo-5.1.tar.xz

URL:        http://ftp.gnu.org/gnu/texinfo
%description
 The Texinfo package contains programs for reading, writing, and converting info pages. 
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
patch -Np1 -i %_sourcedir/texinfo-5.1-test-1.patch
./configure --prefix=/usr
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/usr/share/info
make install DESTDIR=$RPM_BUILD_ROOT 

make TEXMF=/usr/share/texmf install-tex DESTDIR=$RPM_BUILD_ROOT 

cd ${RPM_BUILD_ROOT}/usr/share/info

rm -v dir
for f in *
do install-info $f dir 2>/dev/null

done

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
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