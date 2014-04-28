%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     p7zip is the Unix command-line port of 7-Zip, a file archiver that archives with high compression ratios. It handles 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM, ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR, MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR and Z formats. 
Name:       p7zip
Version:    9.20.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/p7zip/p7zip_9.20.1_src_all.tar.bz2
URL:        http://downloads.sourceforge.net/p7zip
%description
 p7zip is the Unix command-line port of 7-Zip, a file archiver that archives with high compression ratios. It handles 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM, ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR, MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR and Z formats. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


sed -i -e 's/chmod 555/chmod 755/' -e 's/chmod 444/chmod 644/' install.sh &&
make all3
make DEST_HOME=${RPM_BUILD_ROOT}/usr DEST_MAN=${RPM_BUILD_ROOT}/usr/share/man DEST_SHARE_DOC=${RPM_BUILD_ROOT}/usr/share/doc/p7zip-9.20.1 install DESTDIR=${RPM_BUILD_ROOT} 


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