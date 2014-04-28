%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The TeX Live package is a comprehensive TeX document production system. It includes TEX, LaTeX2e, ConTEXt, Metafont, MetaPost, BibTeX and many other programs; an extensive collection of macros, fonts and documentation; and support for typesetting in many different scripts from around the world. 
Name:       install-tl-unx
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
URL:        http://mirror.ctan.org/systems/texlive/tlnet
%description
 The TeX Live package is a comprehensive TeX document production system. It includes TEX, LaTeX2e, ConTEXt, Metafont, MetaPost, BibTeX and many other programs; an extensive collection of macros, fonts and documentation; and support for typesetting in many different scripts from around the world. 
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

mkdir -pv ${RPM_BUILD_ROOT}/etc/profile.d
tar -xf install-tl-unx.tar.gz &&
cd install-tl-<CCYYMMDD>
TEXLIVE_INSTALL_PREFIX=${RPM_BUILD_ROOT}/opt/texlive ./install-tl

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/profile.d/extrapaths.sh << "EOF"

pathappend /usr/share/man                        MANPATH

pathappend /opt/texlive/2013/texmf-dist/doc/man  MANPATH

pathappend /usr/share/info                       INFOPATH

pathappend /opt/texlive/2013/texmf-dist/doc/info INFOPATH

pathappend /opt/texlive/2013/bin/x86_64-linux

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog