%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GC package contains the Boehm-Demers-Weiser conservative garbage collector, which can be used as a garbage collecting replacement for the C malloc function or C++ new operator. It allows you to allocate memory basically as you normally would, without explicitly deallocating memory that is no longer useful. The collector automatically recycles memory when it determines that it can no longer be otherwise accessed. The collector is also used by a number of programming language implementations that either use C as intermediate code, want to facilitate easier interoperation with C libraries, or just prefer the simple collector interface. Alternatively, the garbage collector may be used as a leak detector for C or C++ programs, though that is not its primary goal. 
Name:       gc
Version:    7.4.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libatomic-ops
Source0:    http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/gc-7.4.0.tar.gz
URL:        http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source
%description
 The GC package contains the Boehm-Demers-Weiser conservative garbage collector, which can be used as a garbage collecting replacement for the C malloc function or C++ new operator. It allows you to allocate memory basically as you normally would, without explicitly deallocating memory that is no longer useful. The collector automatically recycles memory when it determines that it can no longer be otherwise accessed. The collector is also used by a number of programming language implementations that either use C as intermediate code, want to facilitate easier interoperation with C libraries, or just prefer the simple collector interface. Alternatively, the garbage collector may be used as a leak detector for C or C++ programs, though that is not its primary goal. 
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
sed -i 's#pkgdata#doc#' doc/doc.am &&
autoreconf -fi  &&
./configure --prefix=/usr --enable-cplusplus --disable-static --docdir=/usr/share/doc/gc-7.4.0 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man3
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 doc/gc.man ${RPM_BUILD_ROOT}/usr/share/man/man3/gc_malloc.3 &&

ln -sfv gc_malloc.3 ${RPM_BUILD_ROOT}/usr/share/man/man3/gc.3


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