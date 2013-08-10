Name:           sysklogd
Version:	1.5
Release:        1%{?dist}
Summary:	The Sysklogd package contains programs for logging system messages,          such as those given by the kernel when unusual things happen.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/sysklogd.html
Source0:        http://www.infodrom.org/projects/sysklogd/download/sysklogd-1.5.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Sysklogd package contains programs for logging system messages,          such as those given by the kernel when unusual things happen.

%prep
%setup -q

%build
sed -i 's/MAN_USER = root/MAN_USER = mao/' Makefile 
sed -i 's/MAN_GROUP = root/MAN_GROUP = mao/' Makefile 

make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
for i in `seq 1 10`
do
	mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man$i
done
mkdir -pv $RPM_BUILD_ROOT/sbin

make BINDIR=$RPM_BUILD_ROOT/sbin install prefix=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc
cat > $RPM_BUILD_ROOT/etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


