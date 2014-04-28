#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=the-bash-shell-startup-files
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
:
}
build()
{


LC_ALL=<> locale charmap

LC_ALL=<> locale language
LC_ALL=<> locale charmap
LC_ALL=<> locale int_curr_symbol
LC_ALL=<> locale int_prefix

cat > /etc/profile << "EOF"
# Begin /etc/profile

export LANG=en_US.utf8
}
download;unpack;build
