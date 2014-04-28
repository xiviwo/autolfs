#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fop
version=1.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.apache.org/dist/xmlgraphics/fop/source/fop-1.1-src.tar.gz
nwget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-i586.tar.gz
nwget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" fop-1.1-src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
case `uname -m` in
  i?86)
    tar -xf ../jai-1_1_3-lib-linux-i586.tar.gz
    cp -v jai-1_1_3/lib/{jai*,mlibwrapper_jai.jar} $JAVA_HOME/jre/lib/ext/
    cp -v jai-1_1_3/lib/libmlib_jai.so             $JAVA_HOME/jre/lib/i386/
    ;;

  x86_64)
    tar -xf ../jai-1_1_3-lib-linux-amd64.tar.gz
    cp -v jai-1_1_3/lib/{jai*,mlibwrapper_jai.jar} $JAVA_HOME/jre/lib/ext/
    cp -v jai-1_1_3/lib/libmlib_jai.so             $JAVA_HOME/jre/lib/amd64/
    ;;
esac

ant compile 
ant jar-main 
ant javadocs 
mv build/javadocs .

ant docs

install -v -d -m755                                     /opt/fop-1.1 
cp -v  KEYS LICENSE NOTICE README                       /opt/fop-1.1 
cp -va build conf examples fop* javadocs lib status.xml /opt/fop-1.1 

ln -v -sf fop-1.1 /opt/fop

cat > ~/.foprc << "EOF"
FOP_OPTS="-Xmx<RAM_Installed>m"
FOP_HOME="/opt/fop"
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
