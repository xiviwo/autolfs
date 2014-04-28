%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     rox-filer is a fast, lightweight, gtk2 file manager. 
Name:       rox-filer
Version:    2.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libglade
Requires:  shared-mime-info
Source0:    http://downloads.sourceforge.net/rox/rox-filer-2.11.tar.bz2
URL:        http://downloads.sourceforge.net/rox
%description
 rox-filer is a fast, lightweight, gtk2 file manager. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/rox/ROX
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/usr/share
mkdir -pv ${RPM_BUILD_ROOT}/path/to/hostname
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
cd ROX-Filer                                                        &&
sed -i 's:g_strdup(getenv("APP_DIR")):"/usr/share/rox":' src/main.c &&
mkdir -pv build                        &&
pushd build                        &&
  ../src/configure LIBS="-lm -ldl" &&
  make                             &&
popd
mkdir -pv -p ${RPM_BUILD_ROOT}/usr/share/rox                              &&

cp -av Help Messages Options.xml ROX images style.css .DirIcon ${RPM_BUILD_ROOT}/usr/share/rox &&

cp -av ../rox.1 ${RPM_BUILD_ROOT}/usr/share/man/man1                  &&

cp -v  ROX-Filer ${RPM_BUILD_ROOT}/usr/bin/rox                        &&

cd ${RPM_BUILD_ROOT}/usr/share/rox/ROX/MIME                           &&

ln -svf text-x-{diff,patch}.png                       &&
ln -svf application-x-font-{afm,type1}.png            &&
ln -svf application-xml{,-dtd}.png                    &&
ln -svf application-xml{,-external-parsed-entity}.png &&
ln -svf application-{,rdf+}xml.png                    &&
ln -svf application-x{ml,-xbel}.png                   &&
ln -svf application-{x-shell,java}script.png          &&
ln -svf application-x-{bzip,xz}-compressed-tar.png    &&
ln -svf application-x-{bzip,lzma}-compressed-tar.png  &&
ln -svf application-x-{bzip-compressed-tar,lzo}.png   &&
ln -svf application-x-{bzip,xz}.png                   &&
ln -svf application-x-{gzip,lzma}.png                 &&
ln -svf application-{msword,rtf}.png
cat > ${RPM_BUILD_ROOT}/path/to/hostname/AppRun << "HERE_DOC"

#!/bin/bash
MOUNT_PATH="${0%/*}"
HOST=${MOUNT_PATH##*/}
export MOUNT_PATH HOST
sshfs -o nonempty ${HOST}:/ ${MOUNT_PATH}
rox -x ${MOUNT_PATH}
HERE_DOC
cat > ${RPM_BUILD_ROOT}/usr/bin/myumount << "HERE_DOC" &&

#!/bin/bash
sync
if mount | grep "${@}" | grep -q fuse
then fusermount -u "${@}"
else umount "${@}"
fi
HERE_DOC
ln -svf  %_sourcedir/rox/.DirIcon ${RPM_BUILD_ROOT}/usr/share/pixmaps/rox.png &&

mkdir -pv -p ${RPM_BUILD_ROOT}/usr/share/applications &&

cat > ${RPM_BUILD_ROOT}/usr/share/applications/rox.desktop << "HERE_DOC"

[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Rox
Comment=The Rox File Manager
Icon=rox
Exec=rox
Categories=GTK;Utility;Application;System;Core;
StartupNotify=true
Terminal=false
HERE_DOC

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -Rv root:root /usr/bin/rox /usr/share/rox      &&

chmod 755 /path/to/hostname/AppRun

chmod 755 /usr/bin/myumount
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog