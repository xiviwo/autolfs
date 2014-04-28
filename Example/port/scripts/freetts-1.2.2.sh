#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=freetts
version=1.2.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/freetts/freetts-1.2.2-src.zip
nwget http://downloads.sourceforge.net/freetts/freetts-1.2.2-tst.zip

}
unpack()
{
preparepack "$pkgname" "$version" freetts-1.2.2-src.zip
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
unzip -q freetts-1.2.2-src.zip -x META-INF/* 
unzip -q freetts-1.2.2-tst.zip -x META-INF/*

sed -i 's/value="src/value="./' build.xml 
cd lib      
sh jsapi.sh 
cd ..       
ant

ant junit 
cd tests 
sh regression.sh 
cd ..

install -v -m755 -d /opt/freetts-1.2.2/{lib,docs/{audio,images}} 
install -v -m644 lib/*.jar /opt/freetts-1.2.2/lib                
install -v -m644 *.txt RELEASE_NOTES docs/*.{pdf,html,txt,sx{w,d}} /opt/freetts-1.2.2/docs           
install -v -m644 docs/audio/*  /opt/freetts-1.2.2/docs/audio     
install -v -m644 docs/images/* /opt/freetts-1.2.2/docs/images    
cp -v -R javadoc               /opt/freetts-1.2.2                
ln -v -s freetts-1.2.2 /opt/freetts

cp -v -R bin    /opt/freetts-1.2.2        
install -v -m644 speech.properties $JAVA_HOME/jre/lib 
cp -v -R tools  /opt/freetts-1.2.2        
cp -v -R mbrola /opt/freetts-1.2.2        
cp -v -R demo   /opt/freetts-1.2.2

java -jar /opt/freetts/lib/freetts.jar -text "This is a test of the FreeTTS speech synthesis system"

java -jar /opt/freetts/lib/freetts.jar -streaming -text "This is a test of the FreeTTS speech synthesis system"


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
