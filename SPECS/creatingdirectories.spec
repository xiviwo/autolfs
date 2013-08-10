Name:           creatingdirectories
Version:	1.0
Release:        1%{?dist}
Summary:	creatingdirectories

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/creatingdirs.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
CreatingDirectories

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT

mkdir -pv $RPM_BUILD_ROOT/var
mkdir -pv $RPM_BUILD_ROOT/
mkdir -pv $RPM_BUILD_ROOT/{bin,boot,etc/{opt,sysconfig},home,lib,mnt,opt,run}

mkdir -pv $RPM_BUILD_ROOT/{media/{floppy,cdrom},sbin,srv,var}

install -dv -m 0750 $RPM_BUILD_ROOT/root

install -dv -m 1777 $RPM_BUILD_ROOT/tmp $RPM_BUILD_ROOT/var/tmp

mkdir -pv $RPM_BUILD_ROOT/usr/{,local/}{bin,include,lib,sbin,src}

mkdir -pv $RPM_BUILD_ROOT/usr/{,local/}share/{doc,info,locale,man}

mkdir -v  $RPM_BUILD_ROOT/usr/{,local/}share/{misc,terminfo,zoneinfo}

mkdir -pv $RPM_BUILD_ROOT/usr/{,local/}share/man/man{1..8}

for dir in $RPM_BUILD_ROOT/usr $RPM_BUILD_ROOT/usr/local; do

  ln -sv share/{man,doc,info} $dir

done

case $(uname -m) in

 x86_64) ln -sv lib $RPM_BUILD_ROOT/lib64 && ln -sv lib $RPM_BUILD_ROOT/usr/lib64 ;;

esac

mkdir -v $RPM_BUILD_ROOT/var/{log,mail,spool}

ln -sv ../../run $RPM_BUILD_ROOT/var/run

ln -sv ../../run/lock $RPM_BUILD_ROOT/var/lock

mkdir -pv $RPM_BUILD_ROOT/var/{opt,cache,lib/{misc,locate},local}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog
