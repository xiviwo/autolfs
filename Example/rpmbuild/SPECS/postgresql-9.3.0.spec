%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     PostgreSQL is an advanced object-relational database management system (ORDBMS), derived from the Berkeley Postgres database management system. 
Name:       postgresql
Version:    9.3.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp5.us.postgresql.org/pub/PostgreSQL/source/v9.3.0/postgresql-9.3.0.tar.bz2
URL:        ftp://ftp5.us.postgresql.org/pub/PostgreSQL/source/v9.3.0
%description
 PostgreSQL is an advanced object-relational database management system (ORDBMS), derived from the Berkeley Postgres database management system. 
%pre
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
sed -e "s@DEFAULT_PGSOCKET_DIR  \"/tmp\"@DEFAULT_PGSOCKET_DIR  \"/run/postgresql\"@" -i src/include/pg_config_manual.h 
sed -i -e 's@psql\\"@& -h /tmp@' src/test/regress/pg_regress{,_main}.c 
sed -i -e 's@gres\\"@& -k /tmp@' src/test/regress/pg_regress.c 
./configure --prefix=/usr --enable-thread-safety --docdir=/usr/share/doc/postgresql-9.3.0 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/run
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/srv/pgsql
mkdir -pv ${RPM_BUILD_ROOT}/srv
mkdir -pv ${RPM_BUILD_ROOT}/srv/pgsql/data
make install       DESTDIR=${RPM_BUILD_ROOT} 

make install-docs DESTDIR=${RPM_BUILD_ROOT} 

make -C contrib/<SUBDIR-NAME> install DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm700 ${RPM_BUILD_ROOT}/srv/pgsql/data 

install -v -dm755 ${RPM_BUILD_ROOT}/run/postgresql 

su - postgres -c '/usr/bin/initdb -D ${RPM_BUILD_ROOT}/srv/pgsql/data'

su - postgres -c '/usr/bin/postmaster -D ${RPM_BUILD_ROOT}/srv/pgsql/data > ${RPM_BUILD_ROOT}/srv/pgsql/data/logfile 2>&1 &'

su - postgres -c '/usr/bin/createdb test' 
echo "create table t1 ( name varchar(20), state_province varchar(20) );" | (su - postgres -c '/usr/bin/psql test ') 
echo "insert into t1 values ('Billy', 'NewYork');" | (su - postgres -c '/usr/bin/psql test ') 
echo "insert into t1 values ('Evanidus', 'Quebec');" | (su - postgres -c '/usr/bin/psql test ') 
echo "insert into t1 values ('Jesse', 'Ontario');" | (su - postgres -c '/usr/bin/psql test ') 
echo "select * from t1;" | (su - postgres -c '/usr/bin/psql test')
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-postgresql DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
groupadd -g 41 postgres 

useradd -c "PostgreSQL Server" -g postgres -d /srv/pgsql/data -u 41 postgres 

chown -Rv postgres:postgres /srv/pgsql /run/postgresql 
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog