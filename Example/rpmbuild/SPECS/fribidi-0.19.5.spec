%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The FriBidi package is an implementation of the Unicode Bidirectional Algorithm (BIDI). This is useful for supporting Arabic and Hebrew alphabets in other packages. 
Name:       fribidi
Version:    0.19.5
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://fribidi.org/download/fribidi-0.19.5.tar.bz2
URL:        http://fribidi.org/download
%description
 The FriBidi package is an implementation of the Unicode Bidirectional Algorithm (BIDI). This is useful for supporting Arabic and Hebrew alphabets in other packages. 
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
sed -i "s|glib/gstrfuncs\.h|glib.h|" charset/fribidi-char-sets.c 
sed -i "s|glib/gmem\.h|glib.h|"      lib/mem.h                   
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