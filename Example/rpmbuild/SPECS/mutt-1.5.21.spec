%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Mutt package contains a Mail User Agent. This is useful for reading, writing, replying to, saving, and deleting your email. 
Name:       mutt
Version:    1.5.21
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/mutt/mutt-1.5.21.tar.gz
Source1:    ftp://ftp.mutt.org/mutt/devel/mutt-1.5.21.tar.gz
URL:        http://downloads.sourceforge.net/mutt
%description
 The Mutt package contains a Mail User Agent. This is useful for reading, writing, replying to, saving, and deleting your email. 
%pre
groupadd -g 34 mail

chgrp -v mail /var/mail
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
./configure --prefix=/usr --sysconfdir=/etc --with-docdir=/usr/share/doc/mutt-1.5.21 --enable-pop --enable-imap --enable-hcache --without-qdbm --without-tokyocabinet --with-gdbm --without-bdb 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/mutt-1.5.21/samples
make install DESTDIR=${RPM_BUILD_ROOT} 

ln -v -s gpg2 ${RPM_BUILD_ROOT}/usr/bin/gpg


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat /usr/share/doc/mutt-1.5.21/samples/gpg.rc >> ~/.muttrc
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog