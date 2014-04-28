%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The zsh package contains a command interpreter (shell) usable as an interactive login shell and as a shell script command processor. Of the standard shells, zsh most closely resembles ksh but includes many enhancements. 
Name:       zsh
Version:    5.0.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/zsh/zsh-5.0.2.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/zsh-5.0.2-makeinfo-1.patch
Source2:    http://downloads.sourceforge.net/zsh/zsh-5.0.2-doc.tar.bz2
URL:        http://downloads.sourceforge.net/zsh
%description
 The zsh package contains a command interpreter (shell) usable as an interactive login shell and as a shell script command processor. Of the standard shells, zsh most closely resembles ksh but includes many enhancements. 
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
tar --strip-components=1 -xvf  %_sourcedir/zsh-5.0.2-doc.tar.bz2
patch -Np1 -i %_sourcedir/zsh-5.0.2-makeinfo-1.patch 
./configure --prefix=/usr --bindir=/bin --sysconfdir=/etc/zsh --enable-etcdir=/etc/zsh                  
make %{?_smp_mflags} 

makeinfo  Doc/zsh.texi --html      -o Doc/html        
makeinfo  Doc/zsh.texi --html --no-split --no-headers -o Doc/zsh.html    
makeinfo  Doc/zsh.texi --plaintext -o Doc/zsh.txt

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2/html
make install  DESTDIR=${RPM_BUILD_ROOT} 

make infodir=${RPM_BUILD_ROOT}/usr/share/info install.info DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2/html 

install -v -m644    Doc/html/* ${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2/html 

install -v -m644    Doc/zsh.{html,txt} ${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2

make htmldir=${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2/html install.html  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 Doc/zsh.dvi ${RPM_BUILD_ROOT}/usr/share/doc/zsh-5.0.2

mv -v ${RPM_BUILD_ROOT}/usr/lib/libpcre.so.* ${RPM_BUILD_ROOT}/lib 

ln -v -sf  %_sourcedir/../lib/libpcre.so.0 ${RPM_BUILD_ROOT}/usr/lib/libpcre.so

mv -v ${RPM_BUILD_ROOT}/usr/lib/libgdbm.so.* ${RPM_BUILD_ROOT}/lib 

ln -v -sf  %_sourcedir/../lib/libgdbm.so.3 ${RPM_BUILD_ROOT}/usr/lib/libgdbm.so


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/shells << "EOF"

/bin/zsh

/bin/zsh-5.0.2

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog