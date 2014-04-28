#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xinetd
version=2.3.15
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xinetd-2.3.15.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" xinetd-2.3.15.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e "s/exec_server/child_process/" xinetd/builtins.c        
sed -i -e "/register unsigned count/s/register//" xinetd/itox.c  
./configure --prefix=/usr --mandir=/usr/share/man --with-loadavg 
make

make install

cat > /etc/xinetd.conf << "EOF"
# Begin /etc/xinetd
# Configuration file for xinetd

defaults
{
      instances       = 60
      log_type        = SYSLOG daemon
      log_on_success  = HOST PID USERID
      log_on_failure  = HOST USERID
      cps             = 25 30
}

# All service files are stored in the /etc/xinetd.d directory

includedir /etc/xinetd.d

# End /etc/xinetd
EOF

install -v -d -m755 /etc/xinetd.d 

cat > /etc/xinetd.d/systat << "EOF" 
# Begin /etc/xinetd.d/systat

service systat
{
   disable           = yes
   socket_type       = stream
   wait              = no
   user              = nobody
   server            = /bin/ps
   server_args       = -auwwx
   only_from         = 128.138.209.0
   log_on_success    = HOST
}

# End /etc/xinetd.d/systat
EOF

cat > /etc/xinetd.d/echo << "EOF" 
# Begin /etc/xinetd.d/echo

service echo
{
   disable     = yes
   type        = INTERNAL
   id          = echo-stream
   socket_type = stream
   protocol    = tcp
   user        = root
   wait        = no
}

service echo
{
   disable     = yes
   type        = INTERNAL
   id          = echo-dgram
   socket_type = dgram
   protocol    = udp
   user        = root
   wait        = yes
}

# End /etc/xinetd.d/echo
EOF

cat > /etc/xinetd.d/chargen << "EOF" 
# Begin /etc/xinetd.d/chargen

service chargen
{
   disable        = yes
   type           = INTERNAL
   id             = chargen-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}

service chargen
{
   disable        = yes
   type           = INTERNAL
   id             = chargen-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}

# End /etc/xinetd.d/chargen
EOF

cat > /etc/xinetd.d/daytime << "EOF" 
# Begin /etc/xinetd.d/daytime

service daytime
{
   disable        = yes
   type           = INTERNAL
   id             = daytime-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}

service daytime
{
   disable        = yes
   type           = INTERNAL
   id             = daytime-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}

# End /etc/xinetd.d/daytime
EOF

cat > /etc/xinetd.d/time << "EOF"
# Begin /etc/xinetd.d/time

service time
{
   disable        = yes
   type           = INTERNAL
   id             = time-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}

service time
{
   disable        = yes
   type           = INTERNAL
   id             = time-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}

# End /etc/xinetd.d/time
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-xinetd

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

/etc/rc.d/init.d/xinetd start


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
