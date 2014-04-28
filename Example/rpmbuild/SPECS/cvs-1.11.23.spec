%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     CVS is the Concurrent Versions System. This is a version control system useful for projects using a central repository to hold files and then track all changes made to those files. These instructions install the client used to manipulate the repository, creation of a repository is covered at Running a CVS Server. 
Name:       cvs
Version:    1.11.23
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23/cvs-1.11.23.tar.bz2
Source1:    ftp://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23/cvs-1.11.23.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/cvs-1.11.23-zlib-1.patch
URL:        http://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23
%description
 CVS is the Concurrent Versions System. This is a version control system useful for projects using a central repository to hold files and then track all changes made to those files. These instructions install the client used to manipulate the repository, creation of a repository is covered at Running a CVS Server. 
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
patch -Np1 -i %_sourcedir/cvs-1.11.23-zlib-1.patch
sed -i -e 's/getline /get_line /' lib/getline.{c,h} &&
sed -i -e 's/^@sp$/& 1/'          doc/cvs.texinfo &&
touch doc/*.pdf
./configure --prefix=/usr --docdir=/usr/share/doc/cvs-1.11.23 &&
make %{?_smp_mflags} 
sed -e 's/rsh};/ssh};/' -e 's/g=rw,o=r$/g=r,o=r/' -i src/sanity.sh

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

make -C doc install-pdf && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 FAQ README ${RPM_BUILD_ROOT}/usr/share/doc/cvs-1.11.23


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