%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Lua is a powerful light-weight programming language designed for extending applications. It is also frequently used as a general-purpose, stand-alone language. Lua is implemented as a small library of C functions, written in ANSI C, and compiles unmodified in all known platforms. The implementation goals are simplicity, efficiency, portability, and low embedding cost. The result is a fast language engine with small footprint, making it ideal in embedded systems too. 
Name:       lua
Version:    5.1.5
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.lua.org/ftp/lua-5.1.5.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/lua-5.1.5-shared_library-2.patch
URL:        http://www.lua.org/ftp
%description
 Lua is a powerful light-weight programming language designed for extending applications. It is also frequently used as a general-purpose, stand-alone language. Lua is implemented as a small library of C functions, written in ANSI C, and compiles unmodified in all known platforms. The implementation goals are simplicity, efficiency, portability, and low embedding cost. The result is a fast language engine with small footprint, making it ideal in embedded systems too. 
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
patch -Np1 -i %_sourcedir/lua-5.1.5-shared_library-2.patch 
sed -i '/#define LUA_ROOT/s:/usr/local/:/usr/:' src/luaconf.h 
make linux %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/pkgconfig
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make INSTALL_TOP=${RPM_BUILD_ROOT}/usr TO_LIB="liblua.so liblua.so.5.1 liblua.so.5.1.5" INSTALL_DATA="cp -d" INSTALL_MAN=${RPM_BUILD_ROOT}/usr/share/man/man1 install  DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/doc/lua-5.1.5 

cp -v doc/*.{html,css,gif,png} ${RPM_BUILD_ROOT}/usr/share/doc/lua-5.1.5

cat > /usr/lib/pkgconfig/lua.pc << "EOF"
V=5.1
R=5.1.5
prefix=/usr
INSTALL_BIN=${prefix}/bin
INSTALL_INC=${prefix}/include
INSTALL_LIB=${prefix}/lib
INSTALL_MAN=${prefix}/man/man1
INSTALL_LMOD=${prefix}/share/lua/${V}
INSTALL_CMOD=${prefix}/lib/lua/${V}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
Name: Lua
Description: An Extensible Extension Language
Version: ${R}
Requires: 
Libs: -L${libdir} -llua -lm
Cflags: -I${includedir}
EOF

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