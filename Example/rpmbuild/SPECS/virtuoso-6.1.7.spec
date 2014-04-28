%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Virtuoso is a cross-platform server that implements multiple server-side protocols as part of a single-server product offering. There is one server product that offers WebDAV/HTTP, Application, and Database-server functionality alongside Native XML Storage, Universal Data-Access Middleware, Business Process Integration and a Web-Services Platform. 
Name:       virtuoso
Version:    6.1.7
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libiodbc
Requires:  libxml2
Requires:  openssl
Requires:  openldap
Source0:    http://downloads.sourceforge.net/virtuoso/virtuoso-opensource-6.1.7.tar.gz
URL:        http://downloads.sourceforge.net/virtuoso
%description
 Virtuoso is a cross-platform server that implements multiple server-side protocols as part of a single-server product offering. There is one server product that offers WebDAV/HTTP, Application, and Database-server functionality alongside Native XML Storage, Universal Data-Access Middleware, Business Process Integration and a Web-Services Platform. 
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
sed -i "s|virt_iodbc_dir/include|&/iodbc|" configure  
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-iodbc=/usr --with-readline --without-internal-zlib --program-transform-name="s/isql/isql-v/" --disable-all-vads --disable-static                          
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/virtuoso-6.1.7 

ln -svf   -v          ../../virtuoso/doc ${RPM_BUILD_ROOT}/usr/share/doc/virtuoso-6.1.7

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-virtuoso DESTDIR=${RPM_BUILD_ROOT} 


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