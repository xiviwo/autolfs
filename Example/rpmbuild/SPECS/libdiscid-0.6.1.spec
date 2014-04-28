%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libdiscid package contains a library for creating MusicBrainz DiscIDs from audio CDs. It reads a CD's table of contents (TOC) and generates an identifier which can be used to lookup the CD at MusicBrainz (http://musicbrainz.org). Additionally, it provides a submission URL for adding the DiscID to the database. 
Name:       libdiscid
Version:    0.6.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.musicbrainz.org/pub/musicbrainz/libdiscid/libdiscid-0.6.1.tar.gz
Source1:    ftp://ftp.musicbrainz.org/pub/musicbrainz/libdiscid/libdiscid-0.6.1.tar.gz
URL:        http://ftp.musicbrainz.org/pub/musicbrainz/libdiscid
%description
 The libdiscid package contains a library for creating MusicBrainz DiscIDs from audio CDs. It reads a CD's table of contents (TOC) and generates an identifier which can be used to lookup the CD at MusicBrainz (http://musicbrainz.org). Additionally, it provides a submission URL for adding the DiscID to the database. 
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
./configure --prefix=/usr --disable-static &&
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