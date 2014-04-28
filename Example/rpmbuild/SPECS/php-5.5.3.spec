%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     PHP is the PHP Hypertext Preprocessor. Primarily used in dynamic web sites, it allows for programming code to be directly embedded into the HTML markup. It is also useful as a general purpose scripting language. 
Name:       php
Version:    5.5.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  apache
Requires:  libxml2
Source0:    http://us2.php.net/distributions/php-5.5.3.tar.bz2
Source1:    ftp://ftp.isu.edu.tw/pub/Unix/Web/PHP/distributions/php-5.5.3.tar.bz2
Source2:    http://www.php.net/download-docs.php
URL:        http://us2.php.net/distributions
%description
 PHP is the PHP Hypertext Preprocessor. Primarily used in dynamic web sites, it allows for programming code to be directly embedded into the HTML markup. It is also useful as a general purpose scripting language. 
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
./configure --prefix=/usr --sysconfdir=/etc --with-apxs2 --with-config-file-path=/etc --with-zlib --enable-bcmath --with-bz2 --enable-calendar --enable-dba=shared --with-gdbm --with-gmp --enable-ftp --with-gettext --enable-mbstring --with-readline              
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/php/doc/Archive_Tar/docs
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/php/doc/Structures_Graph
make install                                          DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 php.ini-production ${RPM_BUILD_ROOT}/etc/php.ini     

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3 

install -v -m644    CODING_STANDARDS EXTENSIONS INSTALL NEWS README* UPGRADING* php.gif ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3 

ln -v -sfn          ${RPM_BUILD_ROOT}/usr/lib/php/doc/Archive_Tar/docs/Archive_Tar.txt ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3 

ln -v -sfn          ${RPM_BUILD_ROOT}/usr/lib/php/doc/Structures_Graph/docs ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3

install -v -m644 ../php_manual_en.html.gz ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3 

gunzip -v ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3/php_manual_en.html.gz

tar -xvf  %_sourcedir/php_manual_en.tar.gz -C ${RPM_BUILD_ROOT}/usr/share/doc/php-5.5.3 --no-same-owner

sed -i 's@php/includes"@&\ninclude_path = ".:/usr/lib/php"@' ${RPM_BUILD_ROOT}/etc/php.ini


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