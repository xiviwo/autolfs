%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Qt is a cross-platform application framework that is widely used for developing application software with a graphical user interface (GUI) (in which cases Qt is classified as a widget toolkit), and also used for developing non-GUI programs such as command-line tools and consoles for servers. One of the major users of Qt is KDE. 
Name:       qt
Version:    5.1.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-lib
Requires:  mesalib
Requires:  xcb-util-image
Requires:  xcb-util-keysyms
Requires:  xcb-util-renderutil
Requires:  xcb-util-wm
Requires:  certificate-authority-certificates
Requires:  cups
Requires:  d-bus
Requires:  glib
Requires:  gst-plugins-base
Requires:  icu
Requires:  libjpeg-turbo
Requires:  libmng
Requires:  libpng
Requires:  libtiff
Requires:  openssl
Requires:  pcre
Requires:  sqlite
Source0:    http://download.qt-project.org/official_releases/qt/5.1/5.1.1/single/qt-everywhere-opensource-src-5.1.1.tar.xz
URL:        http://download.qt-project.org/official_releases/qt/5.1/5.1.1/single
%description
 Qt is a cross-platform application framework that is widely used for developing application software with a graphical user interface (GUI) (in which cases Qt is classified as a widget toolkit), and also used for developing non-GUI programs such as command-line tools and consoles for servers. One of the major users of Qt is KDE. 
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
sed -i "s:Context\* context}:&\n%lex-param {YYLEX_PARAM}:" qtwebkit/Source/ThirdParty/ANGLE/src/compiler/glslang.y 
sed -i -e "/#if/d" -e "/#error/d" -e "/#endif/d" qtimageformats/config.tests/libmng/libmng.cpp 
./configure -prefix         /usr -sysconfdir     /etc/xdg -bindir         /usr/lib/qt5/bin -headerdir      /usr/include/qt5 -archdatadir    /usr/lib/qt5 -datadir        /usr/share/qt5 -docdir         /usr/share/doc/qt5 -translationdir /usr/share/qt5/translations -examplesdir    /usr/share/doc/qt5/examples -confirm-license -opensource -dbus-linked -openssl-linked -system-sqlite -no-nis -nomake examples -opengl es2 -optimized-qmake   
make %{?_smp_mflags} 
find . -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
mkdir -pv ${RPM_BUILD_ROOT}/etc/profile.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/qt5/bin
mkdir -pv ${RPM_BUILD_ROOT}/opt
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/qt5/mkspecs/modules
mkdir -pv ${RPM_BUILD_ROOT}/etc/xdg
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -Dm644 qttools/src/assistant/assistant/images/assistant-128.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/assistant-qt5.png 

install -v -Dm644 qttools/src/designer/src/designer/images/designer.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/designer-qt5.png 

install -v -Dm644 qttools/src/linguist/linguist/images/icons/linguist-128-32.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/linguist-qt5.png 

install -v -Dm644 qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/qdbusviewer-qt5.png

sed -i -e "s:$PWD/qtbase:/usr/lib/qt5:g" ${RPM_BUILD_ROOT}/usr/lib/qt5/mkspecs/modules/qt_lib_bootstrap.pri 

find ${RPM_BUILD_ROOT}/usr/lib/*.prl -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d;s/\(QMAKE_PRL_LIBS =\).*/\1/' {} \;

for file in ${RPM_BUILD_ROOT}/usr/lib/qt5/bin/*

do
  ln -sfv ../lib/qt5/bin/$(basename $file) ${RPM_BUILD_ROOT}/usr/bin/$(basename $file)-qt5

done
sed -i "s:Context\* context}:&\n%lex-param {YYLEX_PARAM}:" qtwebkit/Source/ThirdParty/ANGLE/src/compiler/glslang.y 
sed -i -e "/#if/d" -e "/#error/d" -e "/#endif/d" qtimageformats/config.tests/libmng/libmng.cpp 
QT5DIR=${RPM_BUILD_ROOT}/opt/qt-5.1.1
./configure -prefix     $QT5DIR -sysconfdir ${RPM_BUILD_ROOT}/etc/xdg -confirm-license -opensource -dbus-linked -openssl-linked -system-sqlite -plugin-sql-sqlite -no-nis -nomake examples -opengl es2 -optimized-qmake     

make
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -Dm644 qttools/src/assistant/assistant/images/assistant-128.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/assistant-qt5.png 

install -v -Dm644 qttools/src/designer/src/designer/images/designer.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/designer-qt5.png 

install -v -Dm644 qttools/src/linguist/linguist/images/icons/linguist-128-32.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/linguist-qt5.png 

install -v -Dm644 qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/qdbusviewer-qt5.png

find $QT5DIR -name qt_lib_bootstrap.pri -exec sed -i -e "s:$PWD/qtbase:/$QT5DIR/lib/:g" {} \; 
find $QT5DIR -name \*.prl -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
ldconfig                         
cat > /etc/profile.d/qt.sh << EOF
# Begin /etc/profile.d/qt.sh
QTDIR=/usr
export QT5DIR
# End /etc/profile.d/qt.sh
EOF
ldconfig
cat > /etc/profile.d/qt.sh << EOF
# Begin /etc/profile.d/qt.sh
QT5DIR=/opt/qt5
pathappend /opt/qt5/bin           PATH
pathappend /opt/qt5/lib/pkgconfig PKG_CONFIG_PATH
export QT5DIR
# End /etc/profile.d/qt.sh
EOF
install -dm755 ${RPM_BUILD_ROOT}/usr/share/applications

cat > /usr/share/applications/assistant-qt5.desktop << "EOF"
[Desktop Entry]
Name=Qt5 Assistant 
Comment=Shows Qt5 documentation and examples
Exec=assistant-qt5
Icon=assistant-qt5
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF
cat > /usr/share/applications/designer-qt5.desktop << "EOF"
[Desktop Entry]
Name=Qt5 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt5 applications
Exec=designer-qt5
Icon=designer-qt5
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF
cat > /usr/share/applications/linguist-qt5.desktop << "EOF"
[Desktop Entry]
Name=Qt5 Linguist
Comment=Add translations to Qt5 applications
Exec=linguist-qt5
Icon=linguist-qt5
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF
cat > /usr/share/applications/qdbusviewer-qt5.desktop << "EOF"
[Desktop Entry]
Name=Qt5 QDbusViewer 
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=qdbusviewer-qt5
Icon=qdbusviewer-qt5
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo /opt/qt5 >> /etc/ld.so.conf 

cat >> /etc/profile.d/qt5.sh << "EOF"

pathappend /opt/qt5/lib/pkgconfig PKG_CONFIG_PATH

EOF

cat >> /etc/ld.so.conf << EOF

# Begin Qt addition

/opt/qt5/lib

# End Qt addition

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog