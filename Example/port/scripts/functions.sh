env
preparepack()
{
cd ${SOURCES}
local shortname=$1
local version=$2
local packname=$3
rm -rf ${shortname}-${version} 
rm -rf ${shortname}-build
mkdir -pv ${shortname}-${version}  
case $packname in 
	*.zip)
	unzip -x $packname -d ${shortname}-${version}
	;;
	*)
	tar xf $packname -C ${shortname}-${version} --strip-components 1
	;;
esac
}

nwget()
{
local packlink=$1
wget --no-check-certificate -nc --timeout=60 --tries=5 $packlink -P ${SOURCES}
}
