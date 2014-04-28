%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The FOP (Formatting Objects Processor) package contains a print formatter driven by XSL formatting objects (XSL-FO). It is a Java application that reads a formatting object tree and renders the resulting pages to a specified output. Output formats currently supported include PDF, PCL, PostScript, SVG, XML (area tree representation), print, AWT, MIF and ASCII text. The primary output target is PDF. 
Name:       fop
Version:    1.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  apache-ant
Source0:    http://archive.apache.org/dist/xmlgraphics/fop/source/fop-1.1-src.tar.gz
Source1:    http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-i586.tar.gz
Source2:    http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz
URL:        http://archive.apache.org/dist/xmlgraphics/fop/source
%description
 The FOP (Formatting Objects Processor) package contains a print formatter driven by XSL formatting objects (XSL-FO). It is a Java application that reads a formatting object tree and renders the resulting pages to a specified output. Output formats currently supported include PDF, PCL, PostScript, SVG, XML (area tree representation), print, AWT, MIF and ASCII text. The primary output target is PDF. 
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

mkdir -pv ${RPM_BUILD_ROOT}/opt
case `uname -m` in
  i?86)
    tar -xf  %_sourcedir/jai-1_1_3-lib-linux-i586.tar.gz
    cp -v jai-1_1_3/lib/{jai*,mlibwrapper_jai.jar} $JAVA_HOME/jre/lib/ext/
    cp -v jai-1_1_3/lib/libmlib_jai.so             $JAVA_HOME/jre/lib/i386/
    ;;
  x86_64)
    tar -xf  %_sourcedir/jai-1_1_3-lib-linux-amd64.tar.gz
    cp -v jai-1_1_3/lib/{jai*,mlibwrapper_jai.jar} $JAVA_HOME/jre/lib/ext/
    cp -v jai-1_1_3/lib/libmlib_jai.so             $JAVA_HOME/jre/lib/amd64/
    ;;
esac
ant compile &&
ant jar-main &&
ant javadocs &&
mv build/javadocs .
ant docs
install -v -d -m755                                     ${RPM_BUILD_ROOT}/opt/fop-1.1 &&

cp -v  KEYS LICENSE NOTICE README                       ${RPM_BUILD_ROOT}/opt/fop-1.1 &&

cp -va build conf examples fop* javadocs lib status.xml ${RPM_BUILD_ROOT}/opt/fop-1.1 &&

ln -v -sf fop-1.1 ${RPM_BUILD_ROOT}/opt/fop


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat > ~/.foprc << "EOF"

FOP_OPTS="-Xmx<RAM_Installed>m"

FOP_HOME="/opt/fop"

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog