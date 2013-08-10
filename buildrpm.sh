#!/bin/bash

set -e
specsdir=~/rpmbuild/SPECS
[ $(uname -m) = 'x86_64' ] && rpmdir=~/rpmbuild/RPMS/x86_64 || rpmdir=~/rpmbuild/RPMS/i386/
for file in $(ls $specsdir)
do
#echo $file

if ! ls $rpmdir || true | grep  -E "^${file%.spec}-[0-9]+" >/dev/null 2>&1; then

echo $file
rpmbuild -ba $specsdir/$file
fi 

done
#sudo rpm -ivh --replacepkgs  --force --nodeps --root /mnt/lfs $rpmdir/*.rpm
