%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This package provides a library for learning linear classifiers for large scale applications. It supports Support Vector Machines (SVM) with L2 and L1 loss, logistic regression, multi class classification and also Linear Programming Machines (L1-regularized SVMs). Its computational complexity scales linearly with the number of training examples making it one of the fastest SVM solvers around. 
Name:       liblinear
Version:    1.94
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles/liblinear-1.94.tar.gz
URL:        http://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles
%description
 This package provides a library for learning linear classifiers for large scale applications. It supports Support Vector Machines (SVM) with L2 and L1 loss, logistic regression, multi class classification and also Linear Programming Machines (L1-regularized SVMs). Its computational complexity scales linearly with the number of training examples making it one of the fastest SVM solvers around. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/include
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make lib
install -vm644 linear.h ${RPM_BUILD_ROOT}/usr/include &&

install -vm755 liblinear.so.1 ${RPM_BUILD_ROOT}/usr/lib &&

ln -sfv liblinear.so.1 ${RPM_BUILD_ROOT}/usr/lib/liblinear.so


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