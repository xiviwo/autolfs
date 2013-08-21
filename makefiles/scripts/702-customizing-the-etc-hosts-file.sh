#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=customizing
version=
cat > /etc/hosts << "EOF"
	# Begin /etc/hosts (network card version)
127.0.0.1 localhost
<192.168.1.1> 	<HOSTNAME.example.org> 	[alias1] [alias2 ...]
# End /etc/hosts (network card version)
EOF
cat > /etc/hosts << "EOF"
	# Begin /etc/hosts (no network card version)
127.0.0.1 <HOSTNAME.example.org> 	<HOSTNAME> localhost
# End /etc/hosts (no network card version)
EOF
