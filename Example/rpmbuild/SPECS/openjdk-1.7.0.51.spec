%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     IcedTea provides a build harness for the OpenJDK package, Oracle's open-sourced Java development environment. In order to provide a completely free runtime environment, similar to Oracle's closed distribution, the IcedTea build harness also provides free, and arguably better versions of parts of the JDK which have not been open-sourced to date. OpenJDK is useful for developing Java programs and provides a complete runtime environment to run Java programs. 
Name:       openjdk
Version:    1.7.0.51
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  about-java
Requires:  apache-ant
Requires:  certificate-authority-certificates
Requires:  cpio
Requires:  cups
Requires:  gtk
Requires:  giflib
Requires:  nspr
Requires:  unzip
Requires:  wget
Requires:  which
Requires:  xorg-libraries
Requires:  zip
Source0:    http://icedtea.classpath.org/download/source/icedtea-2.4.5.tar.xz
Source1:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/corba.tar.gz
Source2:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/hotspot.tar.gz
Source3:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/openjdk.tar.gz
Source4:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/jaxp.tar.gz
Source5:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/jaxws.tar.gz
Source6:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/langtools.tar.gz
Source7:    http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/jdk.tar.gz
Source8:    http://www.linuxfromscratch.org/patches/blfs/7.5/icedtea-2.4.5-add_cacerts-1.patch
Source9:    http://www.linuxfromscratch.org/patches/blfs/7.5/icedtea-2.4.5-fixed_paths-1.patch
Source10:    http://www.linuxfromscratch.org/patches/blfs/7.5/icedtea-2.4.5-fix_tests-1.patch
Source11:    ftp://ftp.mozilla.org/pub/mozilla.org/js/rhino1_7R3.zip
URL:        http://icedtea.classpath.org/download/source
%description
 IcedTea provides a build harness for the OpenJDK package, Oracle's open-sourced Java development environment. In order to provide a completely free runtime environment, similar to Oracle's closed distribution, the IcedTea build harness also provides free, and arguably better versions of parts of the JDK which have not been open-sourced to date. OpenJDK is useful for developing Java programs and provides a complete runtime environment to run Java programs. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/opt/jdk/bin
mkdir -pv ${RPM_BUILD_ROOT}/opt/jdk
mkdir -pv ${RPM_BUILD_ROOT}/etc/profile.d
mkdir -pv ${RPM_BUILD_ROOT}/opt
mkdir -pv ${RPM_BUILD_ROOT}/usr/share
unzip ../rhino1_7R3.zip             &&
install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/java &&

install -v -m755 rhino1_7R3/*.jar ${RPM_BUILD_ROOT}/usr/share/java

cp -v ../corba.tar.gz     . &&
cp -v ../hotspot.tar.gz   . &&
cp -v ../jaxp.tar.gz      . &&
cp -v ../jaxws.tar.gz     . &&
cp -v ../jdk.tar.gz       . &&
cp -v ../langtools.tar.gz . &&
cp -v ../openjdk.tar.gz   .
patch -Np1 -i ../icedtea-2.4.5-add_cacerts-1.patch
patch -Np1 -i ../icedtea-2.4.5-fixed_paths-1.patch
patch -Np1 -i ../icedtea-2.4.5-fix_tests-1.patch
unset JAVA_HOME                                               &&
./autogen.sh                                                  &&
./configure --with-jdk-home=${RPM_BUILD_ROOT}/opt/OpenJDK-1.7.0.51-bin --with-version-suffix=BLFS --enable-nss --disable-system-kerberos --with-parallel-jobs=$(getconf _NPROCESSORS_ONLN) &&
make
export DISPLAY=:20     &&
Xvfb :20 -screen 0 1x1x24 -ac&
echo $!>  Xvfb.pid     &&
make -k jtregcheck     &&
kill -9 `cat Xvfb.pid` &&
unset DISPLAY          &&
rm -f Xvfb.pid
cp -R openjdk.build/j2sdk-image ${RPM_BUILD_ROOT}/opt/OpenJDK-1.7.0.51 &&

ln -v -nsf OpenJDK-1.7.0.51-bin ${RPM_BUILD_ROOT}/opt/jdk

cat > /etc/profile.d/openjdk.sh << "EOF"
# Begin /etc/profile.d/openjdk.sh
# Set JAVA_HOME directory
JAVA_HOME=/opt/jdk
# Adjust PATH
pathappend $JAVA_HOME/bin PATH
# Auto Java CLASSPATH
# Copy jar files to, or create symlinks in this directory
AUTO_CLASSPATH_DIR=/usr/share/java
pathprepend . CLASSPATH
for dir in `find ${AUTO_CLASSPATH_DIR} -type d 2>/dev/null`; do
    pathappend $dir CLASSPATH
done
for jar in `find ${AUTO_CLASSPATH_DIR} -name "*.jar" 2>/dev/null`; do
    pathappend $jar CLASSPATH
done
export JAVA_HOME CLASSPATH
unset AUTO_CLASSPATH_DIR dir jar
# End /etc/profile.d/openjdk.sh
EOF
mandb -c ${RPM_BUILD_ROOT}/opt/jdk/man

cd ${RPM_BUILD_ROOT}/opt/jdk

bin/keytool -list -keystore jre/lib/security/cacerts
cat > /opt/jdk/bin/mkcacerts << "EOF"
#!/bin/sh
# Simple script to extract x509 certificates and create a JRE cacerts file.
function get_args()
    {
        if test -z "${1}" ; then
            showhelp
            exit 1
        fi
        while test -n "${1}" ; do
            case "${1}" in
                -f | --cafile)
                    check_arg $1 $2
                    CAFILE="${2}"
                    shift 2
                    ;;
                -d | --cadir)
                    check_arg $1 $2
                    CADIR="${2}"
                    shift 2
                    ;;
                -o | --outfile)
                    check_arg $1 $2
                    OUTFILE="${2}"
                    shift 2
                    ;;
                -k | --keytool)
                    check_arg $1 $2
                    KEYTOOL="${2}"
                    shift 2
                    ;;
                -s | --openssl)
                    check_arg $1 $2
                    OPENSSL="${2}"
                    shift 2
                    ;;
                -h | --help)
                    showhelp
                    exit 0
                    ;;
                *)
                    showhelp
                    exit 1
                    ;;
            esac
        done
    }
function check_arg()
    {
        echo "${2}" | grep -v "^-" > /dev/null
        if [ -z "$?" -o ! -n "$2" ]; then
            echo "Error:  $1 requires a valid argument."
            exit 1
        fi
    }
# The date binary is not reliable on 32bit systems for dates after 2038
function mydate()
    {
        local y=$( echo $1 | cut -d" " -f4 )
        local M=$( echo $1 | cut -d" " -f1 )
        local d=$( echo $1 | cut -d" " -f2 )
        local m
        if [ ${d} -lt 10 ]; then d="0${d}"; fi
        case $M in
            Jan) m="01";;
            Feb) m="02";;
            Mar) m="03";;
            Apr) m="04";;
            May) m="05";;
            Jun) m="06";;
            Jul) m="07";;
            Aug) m="08";;
            Sep) m="09";;
            Oct) m="10";;
            Nov) m="11";;
            Dec) m="12";;
        esac
        certdate="${y}${m}${d}"
    }
function showhelp()
    {
        echo "`basename ${0}` creates a valid cacerts file for use with IcedTea."
        echo ""
        echo "        -f  --cafile        The path to a file containing PEM formated CA"
        echo "                            certificates.  May not be used with -d/--cadir."
        echo "        -d  --cadir         The path to a diectory of PEM formatted CA"
        echo "                            certificates.  May not be used with -f/--cafile."
        echo "        -o  --outfile       The path to the output file."
        echo ""
        echo "        -k  --keytool       The path to the java keytool utility."
        echo ""
        echo "        -s  --openssl       The path to the openssl utility."
        echo ""
        echo "        -h  --help          Show this help message and exit."
        echo ""
        echo ""
    }
# Initialize empty variables so that the shell does not pollute the script
CAFILE=""
CADIR=""
OUTFILE=""
OPENSSL=""
KEYTOOL=""
certdate=""
date=""
today=$( date +%Y%m%d )
# Process command line arguments
get_args ${@}
# Handle common errors
if test "${CAFILE}x" == "x" -a "${CADIR}x" == "x" ; then
    echo "ERROR!  You must provide an x509 certificate store!"
    echo "\'$(basename ${0}) --help\' for more info."
    echo ""
    exit 1
fi
if test "${CAFILE}x" != "x" -a "${CADIR}x" != "x" ; then
    echo "ERROR!  You cannot provide two x509 certificate stores!"
    echo "\'$(basename ${0}) --help\' for more info."
    echo ""
    exit 1
fi
if test "${KEYTOOL}x" == "x" ; then
    echo "ERROR!  You must provide a valid keytool program!"
    echo "\'$(basename ${0}) --help\' for more info."
    echo ""
    exit 1
fi
if test "${OPENSSL}x" == "x" ; then
    echo "ERROR!  You must provide a valid path to openssl!"
    echo "\'$(basename ${0}) --help\' for more info."
    echo ""
    exit 1
fi
if test "${OUTFILE}x" == "x" ; then
    echo "ERROR!  You must provide a valid output file!"
    echo "\'$(basename ${0}) --help\' for more info."
    echo ""
    exit 1
fi
# Get on with the work
# If using a CAFILE, split it into individual files in a temp directory
if test "${CAFILE}x" != "x" ; then
    TEMPDIR=`mktemp -d`
    CADIR="${TEMPDIR}"
    # Get a list of staring lines for each cert
    CERTLIST=`grep -n "^-----BEGIN" "${CAFILE}" | cut -d ":" -f 1`
    # Get a list of ending lines for each cert
    ENDCERTLIST=`grep -n "^-----END" "${CAFILE}" | cut -d ":" -f 1`
    # Start a loop
    for certbegin in `echo "${CERTLIST}"` ; do
        for certend in `echo "${ENDCERTLIST}"` ; do
            if test "${certend}" -gt "${certbegin}"; then
                break
            fi
        done
        sed -n "${certbegin},${certend}p" "${CAFILE}" > "${CADIR}/${certbegin}.pem"
        keyhash=`${OPENSSL} x509 -noout -in "${CADIR}/${certbegin}.pem" -hash`
        echo "Generated PEM file with hash:  ${keyhash}."
    done
fi
# Write the output file
for cert in `find "${CADIR}" -type f -name "*.pem" -o -name "*.crt"`
do
    # Make sure the certificate date is valid...
    date=$( ${OPENSSL} x509 -enddate -in "${cert}" -noout | sed 's/^notAfter=//' )
    mydate "${date}"
    if test "${certdate}" -lt "${today}" ; then
        echo "${cert} expired on ${certdate}! Skipping..."
        unset date certdate
        continue
    fi
    unset date certdate
    ls "${cert}"
    tempfile=`mktemp`
    certbegin=`grep -n "^-----BEGIN" "${cert}" | cut -d ":" -f 1`
    certend=`grep -n "^-----END" "${cert}" | cut -d ":" -f 1`
    sed -n "${certbegin},${certend}p" "${cert}" > "${tempfile}"
    echo yes | env LC_ALL=C "${KEYTOOL}" -import -alias `basename "${cert}"` -keystore "${OUTFILE}" -storepass 'changeit' -file "${tempfile}"
    rm "${tempfile}"
done
if test "${TEMPDIR}x" != "x" ; then
    rm -rf "${TEMPDIR}"
fi
exit 0
EOF
/opt/jdk/bin/mkcacerts -d "/etc/ssl/certs/"  -k "/opt/jdk/bin/keytool" -s "/usr/bin/openssl" -o "/opt/jdk/jre/lib/security/cacerts"

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod 0644 openjdk.build/j2sdk-image/lib/sa-jdi.jar   &&

chown -R root:root /opt/OpenJDK-1.7.0.51

cat >> /etc/man_db.conf << "EOF" &&

MANDATORY_MANPATH     /opt/jdk/man

MANPATH_MAP           /opt/jdk/bin     /opt/jdk/man

MANDB_MAP             /opt/jdk/man     /var/cache/man/jdk

EOF

chmod -c 0755 /opt/jdk/bin/mkcacerts
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog