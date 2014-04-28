export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    notes-on-building-software
Name:       notes-on-building-software
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/introduction/unpacking.html
%description
notes-on-building-software
%pre
%prep
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

mkdir -pv $RPM_BUILD_ROOT/lib
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/usr/bin
mkdir -pv $RPM_BUILD_ROOT/
tar -xvf filename.tar.gz
tar -xvf filename.tgz
tar -xvf filename.tar.Z
tar -xvf filename.tar.bz2
bzcat filename.tar.bz2 | tar -xv
gunzip -v patchname.gz
bunzip2 -v patchname.bz2
md5sum -c file.md5sum
md5sum <name_of_downloaded_file>
( <command> 2>&1 | tee compile.log && exit $PIPESTATUS )
make check < ../cups-1.1.23-testsuite_parms
cat > blfs-yes-test1 << "EOF"
#!/bin/bash
echo -n -e "\n\nPlease type something (or nothing) and press Enter ---> "
read A_STRING
if test "$A_STRING" = ""; then A_STRING="Just the Enter key was pressed"
else A_STRING="You entered '$A_STRING'"
fi
echo -e "\n\n$A_STRING\n\n"
EOF
yes | ./blfs-yes-test1
yes 'This is some text' | ./blfs-yes-test1
yes '' | ./blfs-yes-test1
ls -l ${RPM_BUILD_ROOT}/usr/bin | more
ls -l ${RPM_BUILD_ROOT}/usr/bin | more > redirect_test.log 2>&1
cat > blfs-yes-test2 << "EOF"
#!/bin/bash
ls -l /usr/bin | more
echo -n -e "\n\nDid you enjoy reading this? (y,n) "
read A_STRING
if test "$A_STRING" = "y"; then A_STRING="You entered the 'y' key"
else A_STRING="You did NOT enter the 'y' key"
fi
echo -e "\n\n$A_STRING\n\n"
EOF
yes | ./blfs-yes-test2 > blfs-yes-test2.log 2>&1
find ${RPM_BUILD_ROOT}/{,usr/}{bin,lib,sbin} -type f -exec strip --strip-unneeded {} \;
find ${RPM_BUILD_ROOT}/lib ${RPM_BUILD_ROOT}/usr/lib -not -path "*Image*" -a -name \*.la -delete

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig
chmod 755 blfs-yes-test1

chmod 755 blfs-yes-test2

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog