%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Git is a free and open source, distributed version control system designed to handle everything from small to very large projects with speed and efficiency. Every Git clone is a full-fledged repository with complete history and full revision tracking capabilities, not dependent on network access or a central server. Branching and merging are fast and easy to do. Git is used for version control of files, much like tools such as Mercurial, Bazaar, Subversion-1.8.3, CVS-1.11.23, Perforce, and Team Foundation Server. 
Name:       git
Version:    1.8.4
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  curl
Requires:  expat
Requires:  openssl
Requires:  python
Source0:    http://git-core.googlecode.com/files/git-1.8.4.tar.gz
Source1:    http://git-core.googlecode.com/files/git-manpages-1.8.4.tar.gz
Source2:    http://git-core.googlecode.com/files/git-htmldocs-1.8.4.tar.gz
URL:        http://git-core.googlecode.com/files
%description
 Git is a free and open source, distributed version control system designed to handle everything from small to very large projects with speed and efficiency. Every Git clone is a full-fledged repository with complete history and full revision tracking capabilities, not dependent on network access or a central server. Branching and merging are fast and easy to do. Git is used for version control of files, much like tools such as Mercurial, Bazaar, Subversion-1.8.3, CVS-1.11.23, Perforce, and Team Foundation Server. 
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
./configure --prefix=/usr --libexecdir=/usr/lib --with-gitconfig=/etc/gitconfig 
make %{?_smp_mflags} 
make html %{?_smp_mflags} 

make man %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/man-pages
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man
mkdir -pv ${RPM_BUILD_ROOT}/etc/ssl/certs
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4
make install DESTDIR=${RPM_BUILD_ROOT} 

make install-man DESTDIR=${RPM_BUILD_ROOT} 

make htmldir=${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4 install-html               DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -p ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/man-pages/{html,text}         

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/{git*.txt,man-pages/text}     

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/{git*.,index.,man-pages/}html 

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical/{html,text}         

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical/{*.txt,text}        

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical/{*.,}html           

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto/{html,text}             

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto/{*.txt,text}            

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto/{*.,}html

tar -xf  %_sourcedir/git-manpages-1.8.4.tar.gz -C ${RPM_BUILD_ROOT}/usr/share/man --no-same-owner --no-overwrite-dir

mkdir -pv -p ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/man-pages/{html,text}         

tar -xf  ../git-htmldocs-1.8.4.tar.gz -C   ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4 --no-same-owner --no-overwrite-dir 

find ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4 -type d -exec chmod 755 {} \;     

find ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4 -type f -exec chmod 644 {} \;     

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/{git*.txt,man-pages/text}     

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/{git*.,index.,man-pages/}html 

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical/{html,text}         

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical/{*.txt,text}        

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/technical/{*.,}html           

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto/{html,text}             

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto/{*.txt,text}            

mv       ${RPM_BUILD_ROOT}/usr/share/doc/git-1.8.4/howto/{*.,}html

git config --system http.sslCAPath ${RPM_BUILD_ROOT}/etc/ssl/certs


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