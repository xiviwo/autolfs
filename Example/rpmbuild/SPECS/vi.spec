%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    vi
Name:       vi
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/lfs/view/stable/prologue/hostreqs.html
%description
vi
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

mkdir -pv ${RPM_BUILD_ROOT}/dev
mkdir -pv ${RPM_BUILD_ROOT}/proc
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr
cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
echo "/bin/sh -> `readlink -f ${RPM_BUILD_ROOT}/bin/sh`"

echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
if [ -e ${RPM_BUILD_ROOT}/usr/bin/yacc ];

  then echo "/usr/bin/yacc -> `readlink -f ${RPM_BUILD_ROOT}/usr/bin/yacc`";

  else echo "yacc not found"; fi
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-

echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
if [ -e ${RPM_BUILD_ROOT}/usr/bin/awk ];

  then echo "/usr/bin/awk -> `readlink -f ${RPM_BUILD_ROOT}/usr/bin/awk`";

  else echo "awk not found"; fi
gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat ${RPM_BUILD_ROOT}/proc/version

m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
sed --version | head -n1
tar --version | head -n1
xz --version | head -n1
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
for lib in lib{gmp,mpfr,mpc}.la; do
  echo $lib: $(if find ${RPM_BUILD_ROOT}/usr/lib* -name $lib|

               grep -q $lib;then :;else echo not;fi) found
done
unset lib
EOF
bash version-check.sh

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog