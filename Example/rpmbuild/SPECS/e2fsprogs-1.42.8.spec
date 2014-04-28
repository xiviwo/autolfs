%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The E2fsprogs package contains the utilities for handling the ext2 file system. It also supports the ext3 and ext4 journaling file systems. 
Name:       e2fsprogs
Version:    1.42.8
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-1.42.8.tar.gz

URL:        http://prdownloads.sourceforge.net/e2fsprogs
%description
 The E2fsprogs package contains the utilities for handling the ext2 file system. It also supports the ext3 and ext4 journaling file systems. 
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
sed -i -e 's/mke2fs/$MKE2FS/' -e 's/debugfs/$DEBUGFS/' tests/f_extent_oobounds/script
mkdir -pv build
cd build
../configure --prefix=/usr         \
             --with-root-prefix="" \
             --enable-elf-shlibs   \
             --disable-libblkid    \
             --disable-libuuid     \
             --disable-uuidd       \
             --disable-fsck
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build

mkdir -pv $RPM_BUILD_ROOT/usr/share/info
mkdir -pv $RPM_BUILD_ROOT/usr/lib/
make install DESTDIR=$RPM_BUILD_ROOT 

make install-libs DESTDIR=$RPM_BUILD_ROOT 

gunzip -v ${RPM_BUILD_ROOT}/usr/share/info/libext2fs.info.gz

install-info --dir-file=/usr/share/info/dir ${RPM_BUILD_ROOT}/usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info ${RPM_BUILD_ROOT}/usr/share/info

install-info --dir-file=/usr/share/info/dir ${RPM_BUILD_ROOT}/usr/share/info/com_err.info


[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog