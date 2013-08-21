LFS=/mnt/lfs
SOURCES=$(LFS)/sources
PackagesandPatches : Introduction 
Introduction:
	mkdir -pv $(LFS)/sources
	chmod -v a+wt $(LFS)/sources
	wget -i wget-list -P $(LFS)/sources
	pushd $(LFS)/sources
	md5sum -c md5sums
	popd
