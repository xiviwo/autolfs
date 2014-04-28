#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gparted
version=0.17.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/gparted/gparted-0.17.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gparted-0.17.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-doc --disable-static 
make

make install

cp -v /usr/share/applications/gparted.desktop /usr/share/applications/gparted.desktop.back 
sed -i 's/Exec=/Exec=sudo -A /'               /usr/share/applications/gparted.desktop      

cp -v /usr/share/applications/gparted.desktop /usr/share/applications/gparted.desktop.back 
sed -i 's:/usr/sbin/gparted:/usr/sbin/gparted_polkit:' /usr/share/applications/gparted.desktop      

cat > /usr/sbin/gparted_polkit << "EOF" 
#!/bin/bash

pkexec /usr/sbin/gparted $@
EOF
chmod -v 0755 /usr/sbin/gparted_polkit

cat > /usr/share/polkit-1/actions/org.gnome.gparted.policy << "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>

  <action id="org.freedesktop.policykit.pkexec.run-gparted">
    <description>Run GParted</description>
    <message>Authentication is required to run GParted</message>
    <defaults>
      <allow_any>no</allow_any>
      <allow_inactive>no</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/sbin/gparted</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
  </action>

</policyconfig>
EOF
chmod -v 0644 /usr/share/polkit-1/actions/org.gnome.gparted.policy


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
