#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=qt
version=4.8.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.qt-project.org/official_releases/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" qt-everywhere-opensource-src-4.8.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
export QT4LINK=/usr

sed -i -e "/#if/d" -e "/#error/d" -e "/#endif/d" config.tests/unix/libmng/libmng.cpp 

sed -i '/CONFIG -/ a\isEmpty(OUTPUT_DIR): OUTPUT_DIR = ../..' src/3rdparty/webkit/Source/WebKit2/DerivedSources.pro 

./configure -prefix         /usr -bindir         /usr/bin -plugindir      /usr/lib/qt4/plugins -importdir      /usr/lib/qt4/imports -headerdir      /usr/include/qt4 -datadir        /usr/share/qt4 -sysconfdir     /etc/xdg -docdir         /usr/share/doc/qt4 -demosdir       /usr/share/doc/qt4/demos -examplesdir    /usr/share/doc/qt4/examples -translationdir /usr/share/qt4/translations -confirm-license -opensource -release -dbus-linked -openssl-linked -system-sqlite -no-phonon -no-phonon-backend -no-nis -no-openvg -nomake demos -nomake examples -optimized-qmake   

make

find . -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;

make install 
rm -rf /usr/tests

for file in 3Support CLucene Core DBus Declarative DesignerComponents Designer Gui Help Multimedia Network OpenGL Script ScriptTools Sql Svg Test UiTools WebKit XmlPatterns Xml phonon; do

     [ -e /usr/lib/libQt${file}.prl ] && 
     sed -r '/^QMAKE_PRL_BUILD_DIR/d;s/(QMAKE_PRL_LIBS =).*/\1/' -i /usr/lib/libQt${file}.prl
done
unset file

export QT4DIR=/opt/qt-4.8.5 
export QT4LINK=/opt/qt4 

sed -i -e "/#if/d" -e "/#error/d" -e "/#endif/d" config.tests/unix/libmng/libmng.cpp 

sed -i '/CONFIG -/ a\isEmpty(OUTPUT_DIR): OUTPUT_DIR = ../..' src/3rdparty/webkit/Source/WebKit2/DerivedSources.pro 

./configure -prefix     $QT4DIR -sysconfdir /etc/xdg -confirm-license -opensource -release -dbus-linked -openssl-linked -system-sqlite -plugin-sql-sqlite -no-phonon -no-phonon-backend -no-nis -no-openvg -nomake demos -nomake examples -optimized-qmake     

make

make install
ln -svfn $QT4DIR /opt/qt4

for file in `basename -a -s .prl $QT4DIR/lib/lib*.prl`; do
       sed -r -e '/^QMAKE_PRL_BUILD_DIR/d' -e 's/(QMAKE_PRL_LIBS =).*/\1/' -i $QT4DIR/lib/${file}.prl

   perl -pi -e "s, -L$PWD/?\S+,,g" $QT4DIR/lib/pkgconfig/${file##lib}.pc
done

unset file

install -v -Dm644 src/gui/dialogs/images/qtlogo-64.png /usr/share/pixmaps/qt4logo.png       

install -v -Dm644 tools/assistant/tools/assistant/images/assistant-128.png /usr/share/pixmaps/assistant-qt4.png 

install -v -Dm644 tools/designer/src/designer/images/designer.png /usr/share/pixmaps/designer-qt4.png  

install -v -Dm644 tools/linguist/linguist/images/icons/linguist-128-32.png /usr/share/pixmaps/linguist-qt4.png  

install -v -Dm644 tools/qdbus/qdbusviewer/images/qdbusviewer-128.png /usr/share/pixmaps/qdbusviewer-qt4.png 

install -dm755 /usr/share/applications 

cat > /usr/share/applications/assistant-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Assistant 
Comment=Shows Qt4 documentation and examples
Exec=$QT4LINK/bin/assistant
Icon=assistant-qt4.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

cat > /usr/share/applications/designer-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Designer
Comment=Design GUIs for Qt4 applications
Exec=$QT4LINK/bin/designer
Icon=designer-qt4.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/linguist-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Linguist 
Comment=Add translations to Qt4 applications
Exec=$QT4LINK/bin/linguist
Icon=linguist-qt4.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/qdbusviewer-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 QDbusViewer 
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=$QT4LINK/bin/qdbusviewer
Icon=qdbusviewer-qt4.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

cat > /usr/share/applications/qtconfig-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Config 
Comment=Configure Qt4 behavior, styles, fonts
Exec=$QT4LINK/bin/qtconfig
Icon=qt4logo.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Settings;
EOF

cat > /etc/profile.d/qt4.sh << EOF
# Begin /etc/profile.d/qt4.sh

QT4DIR=/usr
export QT4DIR

# End /etc/profile.d/qt4.sh
EOF

cat >> /etc/ld.so.conf << EOF
# Begin Qt addition
   
/opt/qt4/lib
   
# End Qt addition
EOF

ldconfig

cat > /etc/profile.d/qt4.sh << EOF
# Begin /etc/profile.d/qt4.sh
   
QT4DIR=/opt/qt4
   
pathappend /opt/qt4/bin           PATH
pathappend /opt/qt4/lib/pkgconfig PKG_CONFIG_PATH
   
export QT4DIR
   
# End /etc/profile.d/qt4.sh
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
