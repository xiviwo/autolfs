%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     MariaDB is a community-developed fork and a drop-in replacement for the MySQL relational database management system. 
Name:       mariadb
Version:    10.0.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  openssl
Requires:  libevent
Source0:    http://tweedo.com/mirror/mariadb/mariadb-10.0.8/kvm-tarbake-jaunty-x86/mariadb-10.0.8.tar.gz
Source1:    ftp://mirrors.fe.up.pt/pub/mariadb/mariadb-10.0.8/kvm-tarbake-jaunty-x86/mariadb-10.0.8.tar.gz
URL:        http://tweedo.com/mirror/mariadb/mariadb-10.0.8/kvm-tarbake-jaunty-x86
%description
 MariaDB is a community-developed fork and a drop-in replacement for the MySQL relational database management system. 
%pre
groupadd -g 40 mysql  || :

useradd -c "MySQL Server" -d /srv/mysql -g mysql -s /bin/false -u 40 mysql || :
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
sed -i "s@data/test@\${INSTALL_MYSQLTESTDIR}@g" sql/CMakeLists.txt &&
sed -i "s/srv_buf_size/srv_sort_buf_size/" storage/innobase/row/row0log.cc &&
mkdir -pv build &&
cd build &&
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_DOCDIR=share/doc/mysql -DINSTALL_DOCREADMEDIR=share/doc/mysql -DINSTALL_MANDIR=share/man -DINSTALL_MYSQLSHAREDIR=share/mysql -DINSTALL_MYSQLTESTDIR=share/mysql/test -DINSTALL_PLUGINDIR=lib/mysql/plugin -DINSTALL_SBINDIR=sbin -DINSTALL_SCRIPTDIR=bin -DINSTALL_SQLBENCHDIR=share/mysql/bench -DINSTALL_SUPPORTFILESDIR=share/mysql -DMYSQL_DATADIR=/srv/mysql -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock -DWITH_EXTRA_CHARSETS=complex -DTOKUDB_OK=0 .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build &&

mkdir -pv ${RPM_BUILD_ROOT}/run/mysqld
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/mysql
mkdir -pv ${RPM_BUILD_ROOT}/srv/mysql
make install DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm 755 ${RPM_BUILD_ROOT}/etc/mysql &&

cat > /etc/mysql/my.cnf << "EOF"
# Begin /etc/mysql/my.cnf
# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 3306
socket          = /run/mysqld/mysqld.sock
# The MySQL server
[mysqld]
port            = 3306
socket          = /run/mysqld/mysqld.sock
datadir         = /srv/mysql
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
sort_buffer_size = 512K
net_buffer_length = 16K
myisam_sort_buffer_size = 8M
# Don't listen on a TCP/IP port at all.
skip-networking
# required unique id between 1 and 2^32 - 1
server-id       = 1
# Uncomment the following if you are using BDB tables
#bdb_cache_size = 4M
#bdb_max_lock = 10000
# Uncomment the following if you are using InnoDB tables
#innodb_data_home_dir = /srv/mysql
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = /srv/mysql
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
#innodb_buffer_pool_size = 16M
#innodb_additional_mem_pool_size = 2M
# Set .._log_file_size to 25 % of buffer pool size
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50
[mysqldump]
quick
max_allowed_packet = 16M
[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates
[isamchk]
key_buffer = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M
[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M
[mysqlhotcopy]
interactive-timeout
# End /etc/mysql/my.cnf
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-mysql DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
mysql_install_db --basedir=/usr --datadir=/srv/mysql --user=mysql &&

chown -R mysql:mysql /srv/mysql

install -v -m755 -o mysql -g mysql -d /run/mysqld &&

mysqld_safe --user=mysql 2>&1 >/dev/null &

mysqladmin -u root password ping

mysqladmin -p shutdown
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog