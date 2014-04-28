#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=postgresql
version=9.3.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.postgresql.org/pub/source/v9.3.3/postgresql-9.3.3.tar.bz2
nwget ftp://ftp.postgresql.org/pub/source/v9.3.3/postgresql-9.3.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" postgresql-9.3.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/DEFAULT_PGSOCKET_DIR/s@/tmp@/run/postgresql@' src/include/pg_config_manual.h 
sed -i -e 's@psql\\"@& -h /tmp@' src/test/regress/pg_regress{,_main}.c 
sed -i -e 's@gres\\"@& -k /tmp@' src/test/regress/pg_regress.c 
./configure --prefix=/usr --enable-thread-safety --docdir=/usr/share/doc/postgresql-9.3.3 
make

make install      
make install-docs

make -C contrib/<SUBDIR-NAME> install

install -v -dm700 /srv/pgsql/data 
install -v -dm755 /run/postgresql 
groupadd -g 41 postgres 
useradd -c "PostgreSQL Server" -g postgres -d /srv/pgsql/data -u 41 postgres 
chown -Rv postgres:postgres /srv/pgsql /run/postgresql 
su - postgres -c '/usr/bin/initdb -D /srv/pgsql/data'

su - postgres -c '/usr/bin/postmaster -D /srv/pgsql/data > /srv/pgsql/data/logfile 2>&1 &'

su - postgres -c '/usr/bin/createdb test' 
echo "create table t1 ( name varchar(20), state_province varchar(20) );" | (su - postgres -c '/usr/bin/psql test ') 
echo "insert into t1 values ('Billy', 'NewYork');" | (su - postgres -c '/usr/bin/psql test ') 
echo "insert into t1 values ('Evanidus', 'Quebec');" | (su - postgres -c '/usr/bin/psql test ') 
echo "insert into t1 values ('Jesse', 'Ontario');" | (su - postgres -c '/usr/bin/psql test ') 
echo "select * from t1;" | (su - postgres -c '/usr/bin/psql test')

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-postgresql


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
