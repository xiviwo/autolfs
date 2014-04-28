#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=qt
version=5.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.qt-project.org/official_releases/qt/5.2/5.2.1/single/qt-everywhere-opensource-src-5.2.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" qt-everywhere-opensource-src-5.2.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
export QT5LINK=/usr

./configure -prefix         /usr -sysconfdir     /etc/xdg -bindir         /usr/bin -headerdir      /usr/include/qt5 -archdatadir    /usr/lib/qt5 -datadir        /usr/share/qt5 -docdir         /usr/share/doc/qt5 -translationdir /usr/share/qt5/translations -examplesdir    /usr/share/doc/qt5/examples -confirm-license -opensource -dbus-linked -openssl-linked -system-sqlite -no-nis -nomake examples -opengl es2 -optimized-qmake   
make

find . -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;

make install

sed -e "s:$PWD/qtbase:/usr/lib/qt5:g" -i /usr/lib/qt5/mkspecs/modules/qt_lib_bootstrap_private.pri 

find /usr/lib/lib{qgsttools_p,Qt5*}.prl -exec sed -i -r '/^QMAKE_PRL_BUILD_DIR/d;s/(QMAKE_PRL_LIBS =).*/\1/' {} \;

export QT5DIR=/opt/qt-5.2.1 
export QT5LINK=/opt/qt5 

./configure -prefix     $QT5DIR -sysconfdir /etc/xdg -confirm-license -opensource -dbus-linked -openssl-linked -system-sqlite -no-nis -nomake examples -opengl es2 -optimized-qmake     
make

make install 
ln -svfn $QT5DIR /opt/qt5

find $QT5DIR -name qt_lib_bootstrap_private.pri -exec sed -i -e "s:$PWD/qtbase:/$QT5DIR/lib/:g" {} \; 

find $QT5DIR -name \*.prl -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;

install -v -dm755 /usr/share/pixmaps/                  

install -v -Dm644 qttools/src/assistant/assistant/images/assistant-128.png /usr/share/pixmaps/assistant-qt5.png 

install -v -Dm644 qttools/src/designer/src/designer/images/designer.png /usr/share/pixmaps/designer-qt5.png  

install -v -Dm644 qttools/src/linguist/linguist/images/icons/linguist-128-32.png /usr/share/pixmaps/linguist-qt5.png  

install -v -Dm644 qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png /usr/share/pixmaps/qdbusviewer-qt5.png 

install -dm755 /usr/share/applications 

cat > /usr/share/applications/assistant-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Assistant 
Comment=Shows Qt5 documentation and examples
Exec=$QT5LINK/bin/assistant
Icon=assistant-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

cat > /usr/share/applications/designer-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt5 applications
Exec=$QT5LINK/bin/designer
Icon=designer-qt5.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/linguist-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Linguist
Comment=Add translations to Qt5 applications
Exec=$QT5LINK/bin/linguist
Icon=linguist-qt5.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/qdbusviewer-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 QDbusViewer 
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=$QT5LINK/bin/qdbusviewer
Icon=qdbusviewer-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

cat > /etc/profile.d/qt5.sh << EOF
# Begin /etc/profile.d/qt5.sh

QT5DIR=/usr
export QT5DIR

# End /etc/profile.d/qt5.sh
EOF

cat >> /etc/ld.so.conf << EOF
# Begin Qt addition

/opt/qt5/lib

# End Qt addition
EOF

ldconfig

cat > /etc/profile.d/qt5.sh << EOF
# Begin /etc/profile.d/qt5.sh

QT5DIR=/opt/qt5

pathappend /opt/qt5/bin           PATH
pathappend /opt/qt5/lib/pkgconfig PKG_CONFIG_PATH

export QT5DIR

# End /etc/profile.d/qt5.sh
EOF

cat > /usr/bin/setqt4 << 'EOF'
if [ "x$QT5DIR" != "x/usr" ]; then pathremove  $QT5DIR/bin; fi
if [ "x$QT4DIR" != "x/usr" ]; then pathprepend $QT4DIR/bin; fi
echo $PATH
EOF

cat > /usr/bin/setqt5 << 'EOF'
if [ "x$QT4DIR" != "x/usr" ]; then pathremove  $QT4DIR/bin; fi
if [ "x$QT5DIR" != "x/usr" ]; then pathprepend $QT5DIR/bin; fi
echo $PATH
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
