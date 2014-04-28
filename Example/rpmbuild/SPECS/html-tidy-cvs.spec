%define dist BLFS
Summary:     The HTML Tidy package contains a command line tool and libraries used to read HTML, XHTML and XML files and write cleaned up markup. It detects and corrects many common coding errors and strives to produce visually equivalent markup that is both W3C compliant and compatible with most browsers. 
Name:       html-tidy-cvs
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/t/tidy-cvs_20101110.tar.bz2
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/t
%description
 The HTML Tidy package contains a command line tool and libraries used to read HTML, XHTML and XML files and write cleaned up markup. It detects and corrects many common coding errors and strives to produce visually equivalent markup that is both W3C compliant and compatible with most browsers. 
%pre
%prep
rm -rf %_builddir/%{name}-%{version}
mkdir -pv %_builddir/%{name}-%{version} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{name}-%{version}
	;;
	*tar)
	tar xf %SOURCE0 -C %{name}-%{version} 
	;;
	*)
	tar xf %SOURCE0 -C %{name}-%{version}  --strip-components 1
	;;
esac

%build
cd %_builddir/%{name}-%{version}
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %_builddir/%{name}-%{version}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/usr/share/doc
mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man1
make install DESTDIR=$RPM_BUILD_ROOT &&
install -v -m644 -D htmldoc/tidy.1 \
                    ${RPM_BUILD_ROOT}/usr/share/man/man1/tidy.1 &&
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/tidy-cvs_20101110 &&
install -v -m644    htmldoc/*.{html,gif,css} \
                    ${RPM_BUILD_ROOT}/usr/share/doc/tidy-cvs_20101110

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog