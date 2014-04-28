%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libmusicbrainz package contains a library which allows you to access the data held on the MusicBrainz server. This is useful for adding MusicBrainz lookup capabilities to other applications. 
Name:       libmusicbrainz
Version:    2.1.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.musicbrainz.org/pub/musicbrainz/historical/libmusicbrainz-2.1.5.tar.gz
Source1:    ftp://ftp.musicbrainz.org/pub/musicbrainz/historical/libmusicbrainz-2.1.5.tar.gz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/libmusicbrainz-2.1.5-missing-includes-1.patch
URL:        http://ftp.musicbrainz.org/pub/musicbrainz/historical
%description
 The libmusicbrainz package contains a library which allows you to access the data held on the MusicBrainz server. This is useful for adding MusicBrainz lookup capabilities to other applications. 
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
patch -Np1 -i %_sourcedir/libmusicbrainz-2.1.5-missing-includes-1.patch &&
./configure --prefix=/usr &&
make %{?_smp_mflags} 
(cd python && python setup.py build)

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/libmusicbrainz-2.1.5
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 -D docs/mb_howto.txt ${RPM_BUILD_ROOT}/usr/share/doc/libmusicbrainz-2.1.5/mb_howto.txt

(cd python && python setup.py install)

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