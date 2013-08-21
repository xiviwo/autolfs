#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=the
version=
cat > /etc/profile << "EOF"
	# Begin /etc/profile
export LANG=<ll>_<CC>.<charmap><@modifiers>
# End /etc/profile
EOF
