%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The CrackLib package contains a library used to enforce strong passwords by comparing user selected passwords to words in chosen word lists. 
Name:       cracklib
Version:    2.9.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/cracklib/cracklib-2.9.0.tar.gz
Source1:    http://downloads.sourceforge.net/cracklib/cracklib-words-20080507.gz
URL:        http://downloads.sourceforge.net/cracklib
%description
 The CrackLib package contains a library used to enforce strong passwords by comparing user selected passwords to words in chosen word lists. 
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
./configure --prefix=/usr --with-default-dict=/lib/cracklib/pw_dict --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/lib/cracklib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/dict
make install  DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libcrack.so.2* ${RPM_BUILD_ROOT}/lib 

ln -v -sf  %_sourcedir/../lib/libcrack.so.2.9.0 ${RPM_BUILD_ROOT}/usr/lib/libcrack.so

install -v -m644 -D ../cracklib-words-20080507.gz ${RPM_BUILD_ROOT}/usr/share/dict/cracklib-words.gz 

gunzip -v ${RPM_BUILD_ROOT}/usr/share/dict/cracklib-words.gz 

ln -v -s cracklib-words ${RPM_BUILD_ROOT}/usr/share/dict/words 

install -v -m755 -d ${RPM_BUILD_ROOT}/lib/cracklib 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo $(hostname) >>/usr/share/dict/cracklib-extra-words 

create-cracklib-dict /usr/share/dict/cracklib-words /usr/share/dict/cracklib-extra-words
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog