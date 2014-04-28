%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Flex package contains a utility for generating programs that recognize patterns in text. 
Name:       flex
Version:    2.5.37
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://prdownloads.sourceforge.net/flex/flex-2.5.37.tar.bz2

URL:        http://prdownloads.sourceforge.net/flex
%description
 The Flex package contains a utility for generating programs that recognize patterns in text. 
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
sed -i -e '/test-bison/d' tests/Makefile.in
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.5.37
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/usr/bin
make install DESTDIR=$RPM_BUILD_ROOT 

ln -sv libfl.a ${RPM_BUILD_ROOT}/usr/lib/libl.a

cat > ${RPM_BUILD_ROOT}/usr/bin/lex << "EOF"

#!/bin/sh
# Begin /usr/bin/lex
exec /usr/bin/flex -l "$@"
# End /usr/bin/lex
EOF

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/bin/lex
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog