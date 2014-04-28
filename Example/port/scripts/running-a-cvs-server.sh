#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=running-a-cvs-server
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{

cd ${SOURCES} 

}
build()
{
mkdir -pv /srv/cvsroot 
chmod 1777     /srv/cvsroot 
export CVSROOT=/srv/cvsroot 
cvs init

cd <sourcedir> 
cvs import -m "<repository test>" <cvstest> <vendortag> <releasetag>

cvs co cvstest

export CVS_RSH=/usr/bin/ssh 
cvs -d:ext:<servername>:/srv/cvsroot co cvstest

(grep anonymous /etc/passwd || useradd anonymous -s /bin/false -u 98) 
echo anonymous: > /srv/cvsroot/CVSROOT/passwd 
echo anonymous > /srv/cvsroot/CVSROOT/readers

cvs -d:pserver:anonymous@<servername>:/srv/cvsroot co cvstest


}
download;unpack;build
