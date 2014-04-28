%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Openbox is a highly configurable desktop window manager with extensive standards support. It allows you to control almost every aspect of how you interact with your desktop. 
Name:       openbox
Version:    3.5.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  x-window-system-environment
Requires:  pango
Source0:    http://openbox.org/dist/openbox/openbox-3.5.2.tar.gz
URL:        http://openbox.org/dist/openbox
%description
 Openbox is a highly configurable desktop window manager with extensive standards support. It allows you to control almost every aspect of how you interact with your desktop. 
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
export LIBRARY_PATH=$XORG_PREFIX/lib
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/openbox-3.5.2 --disable-static                      &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/themes/*
mkdir -pv ${RPM_BUILD_ROOT}/etc/xdg
make install DESTDIR=${RPM_BUILD_ROOT} 

ls -d ${RPM_BUILD_ROOT}/usr/share/themes/*/openbox-3 | sed 's#.*es/##;s#/o.*##'


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cp -rf /etc/xdg/openbox ~/.config

echo openbox > ~/.xinitrc

cat > ~/.xinitrc << "EOF"

display -backdrop -window root /path/to/beautiful/picture.jpeg

exec openbox

EOF

cat > ~/.xinitrc << "EOF"

# make an array which lists the pictures:

picture_list=(~/.config/backgrounds/*)

# create a random integer between 0 and the number of pictures:

random_number=$(( ${RANDOM} % ${#picture_list[@]} ))

# display the chosen picture:

display -backdrop -window root "${picture_list[${random_number}]}"

exec openbox

EOF

cat > ~/.xinitrc << "EOF"

. /etc/profile

picture_list=(~/.config/backgrounds/*)

random_number=$(( ${RANDOM} % ${#picture_list[*]} ))

display -backdrop -window root "${picture_list[${random_number}]}"

numlockx

eval $(dbus-launch --auto-syntax --exit-with-session)

lxpanel &

exec openbox

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog