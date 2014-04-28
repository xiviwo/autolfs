%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The FreeTTS package contains a speech synthesis system written entirely in the Java programming language. It is based upon Flite: a small run-time speech synthesis engine developed at Carnegie Mellon University. Flite is derived from the Festival Speech Synthesis System from the University of Edinburgh and the FestVox project from Carnegie Mellon University. The FreeTTS package is used to convert text to audible speech through the system audio hardware. 
Name:       freetts
Version:    1.2.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  apache-ant
Requires:  sharutils
Source0:    http://downloads.sourceforge.net/freetts/freetts-1.2.2-src.zip
Source1:    http://downloads.sourceforge.net/freetts/freetts-1.2.2-tst.zip
URL:        http://downloads.sourceforge.net/freetts
%description
 The FreeTTS package contains a speech synthesis system written entirely in the Java programming language. It is based upon Flite: a small run-time speech synthesis engine developed at Carnegie Mellon University. Flite is derived from the Festival Speech Synthesis System from the University of Edinburgh and the FestVox project from Carnegie Mellon University. The FreeTTS package is used to convert text to audible speech through the system audio hardware. 
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
mkdir -pv ${RPM_BUILD_ROOT}/opt/freetts/lib
mkdir -pv ${RPM_BUILD_ROOT}/opt/freetts-1.2.2/docs
mkdir -pv ${RPM_BUILD_ROOT}/opt/freetts-1.2.2
unzip -q freetts-1.2.2-src.zip -x META-INF/* &&
unzip -q freetts-1.2.2-tst.zip -x META-INF/*
sed -i 's/value="src/value="./' build.xml &&
cd lib      &&
sh jsapi.sh &&
cd ..       &&
ant
ant junit &&
cd tests &&
sh regression.sh &&
cd ..
install -v -m755 -d ${RPM_BUILD_ROOT}/opt/freetts-1.2.2/{lib,docs/{audio,images}} &&

install -v -m644 lib/*.jar ${RPM_BUILD_ROOT}/opt/freetts-1.2.2/lib                &&

install -v -m644 *.txt RELEASE_NOTES docs/*.{pdf,html,txt,sx{w,d}} ${RPM_BUILD_ROOT}/opt/freetts-1.2.2/docs           &&

install -v -m644 docs/audio/*  ${RPM_BUILD_ROOT}/opt/freetts-1.2.2/docs/audio     &&

install -v -m644 docs/images/* ${RPM_BUILD_ROOT}/opt/freetts-1.2.2/docs/images    &&

cp -v -R javadoc               ${RPM_BUILD_ROOT}/opt/freetts-1.2.2                &&

ln -v -s freetts-1.2.2 ${RPM_BUILD_ROOT}/opt/freetts

cp -v -R bin    ${RPM_BUILD_ROOT}/opt/freetts-1.2.2        &&

install -v -m644 speech.properties $JAVA_HOME/jre/lib &&
cp -v -R tools  ${RPM_BUILD_ROOT}/opt/freetts-1.2.2        &&

cp -v -R mbrola ${RPM_BUILD_ROOT}/opt/freetts-1.2.2        &&

cp -v -R demo   ${RPM_BUILD_ROOT}/opt/freetts-1.2.2

java -jar ${RPM_BUILD_ROOT}/opt/freetts/lib/freetts.jar -text "This is a test of the FreeTTS speech synthesis system"

java -jar ${RPM_BUILD_ROOT}/opt/freetts/lib/freetts.jar -streaming -text "This is a test of the FreeTTS speech synthesis system"


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