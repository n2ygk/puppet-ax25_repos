#!/bin/sh
# script to build necessary ham radio kernels
# Tested for CentOS 6 & 7
# Installs the kernel SRPM that matches the current running system and patches it to add CONFIG_HAMRADIO, etc.
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
sudo yum install -y rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto \
     audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel \
     ncurses-devel newt-devel numactl-devel pciutils-devel python-devel zlib-devel \
     rng-tools openssl-devel libunwind-devel
sudo rngd -r /dev/urandom
###
# Let's try upgrading the kernel since 3.10.0 (CentOS 7.2) seems to have know ALSA bugs
###
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
sudo yum --enablerepo=elrepo-kernel install kernel-ml

# pick the package based on current installed kernel
# assumes facter (puppet) is installed
l=`facter kernelrelease`
m=`facter architecture`
k=`basename ${l} .${m}`
r=`facter operatingsystemrelease`
KSRPM=kernel-${k}.src.rpm
KSPEC=kernel.spec

case `facter operatingsystemmajrelease` in
    6) # patch the generic-rhel (centos) config to include hamradio, ax25, mkiss.
	if [ ! -f $KSRPM ]; then
	    curl -s -o kernel-${k}.src.rpm http://vault.centos.org/${r}/updates/Source/SPackages/kernel-${k}.src.rpm
	fi
	rpm -i $KSRPM 2>&1 | grep -v exist
	patch -b ~/rpmbuild/SOURCES/config-generic-rhel <<EOF
*** config-generic-rhel.org	2016-10-15 19:35:55.788353017 +0000
--- config-generic-rhel	2016-10-15 19:37:40.042352872 +0000
***************
*** 361,373 ****
  # CONFIG_BAYCOM_SER_HDX is not set
  # CONFIG_BPQETHER is not set
  # CONFIG_DMASCC is not set
! # CONFIG_MKISS is not set
  # CONFIG_SCC_DELAY is not set
  # CONFIG_SCC is not set
  # CONFIG_SCC_TRXECHO is not set
  # CONFIG_YAM is not set
  # CONFIG_AX25_DAMA_SLAVE is not set
! # CONFIG_AX25 is not set
  # CONFIG_NETROM is not set
  # CONFIG_ROSE is not set
  # CONFIG_NET_DIVERT is not set
--- 361,373 ----
  # CONFIG_BAYCOM_SER_HDX is not set
  # CONFIG_BPQETHER is not set
  # CONFIG_DMASCC is not set
! CONFIG_MKISS=m
  # CONFIG_SCC_DELAY is not set
  # CONFIG_SCC is not set
  # CONFIG_SCC_TRXECHO is not set
  # CONFIG_YAM is not set
  # CONFIG_AX25_DAMA_SLAVE is not set
! CONFIG_AX25=m
  # CONFIG_NETROM is not set
  # CONFIG_ROSE is not set
  # CONFIG_NET_DIVERT is not set
***************
*** 621,627 ****
  # CONFIG_DE620 is not set
  # CONFIG_EQUALIZER is not set
  # CONFIG_HAMACHI is not set
! # CONFIG_HAMRADIO is not set
  # CONFIG_I2C_PCA_ISA is not set
  # CONFIG_I82092 is not set
  # CONFIG_INFINIBAND_AMSO1100 is not set
--- 621,627 ----
  # CONFIG_DE620 is not set
  # CONFIG_EQUALIZER is not set
  # CONFIG_HAMACHI is not set
! CONFIG_HAMRADIO=y
  # CONFIG_I2C_PCA_ISA is not set
  # CONFIG_I82092 is not set
  # CONFIG_INFINIBAND_AMSO1100 is not set

EOF
	;;
    7) 	case $k in
	    3*) # distributed (old kernel)
		if [ ! -f $KSRPM ]; then
		    curl -s -o kernel-${k}.src.rpm http://vault.centos.org/${r}/updates/Source/SPackages/kernel-${k}.src.rpm
		fi
		rpm -i $KSRPM 2>&1 | grep -v exist
		# patch the x86_64 kernel config (no longer a generic?)
		patch -b ~/rpmbuild/SOURCES/kernel-3.10.0-x86_64.config <<EOF
*** kernel-3.10.0-x86_64.config	2016-10-23 18:43:25.340026051 +0000
--- .config	2016-10-23 18:54:06.467043220 +0000
***************
*** 1270,1276 ****
  CONFIG_NET_PKTGEN=m
  # CONFIG_NET_TCPPROBE is not set
  CONFIG_NET_DROP_MONITOR=y
! # CONFIG_HAMRADIO is not set
  # CONFIG_CAN is not set
  # CONFIG_IRDA is not set
  CONFIG_BT=m
--- 1269,1294 ----
  CONFIG_NET_PKTGEN=m
  # CONFIG_NET_TCPPROBE is not set
  CONFIG_NET_DROP_MONITOR=y
! CONFIG_HAMRADIO=y
! 
! #
! # Packet Radio protocols
! #
! CONFIG_AX25=m
! # CONFIG_AX25_DAMA_SLAVE is not set
! # CONFIG_NETROM is not set
! # CONFIG_ROSE is not set
! 
! #
! # AX.25 network device drivers
! #
! CONFIG_MKISS=m
! # CONFIG_6PACK is not set
! # CONFIG_BPQETHER is not set
! # CONFIG_BAYCOM_SER_FDX is not set
! # CONFIG_BAYCOM_SER_HDX is not set
! # CONFIG_BAYCOM_PAR is not set
! # CONFIG_YAM is not set
  # CONFIG_CAN is not set
  # CONFIG_IRDA is not set
  CONFIG_BT=m

EOF
		;;
	    4.8.5*elrepo*) # www.elrepo.org version
		KNSRPM=kernel-ml-${k}.nosrc.rpm
		KSPEC=kernel-ml-4.8.spec
		if [ ! -f $KNSRPM ]; then
		    curl -s -o $KNSRPM http://elrepo.org/linux/kernel/el7/SRPMS/$KNSRPM
		    rpm -ivh $KNSRPM
		fi
		rpm -i $KNSRPM 2>&1 | grep -v exist

		KSRC=`rpm -qlp $KNSRPM | grep linux-`
		if [ ! -f rpmbuild/SOURCES/$KSRC ]; then
		    curl -s -o rpmbuild/SOURCES/$KSRC https://www.kernel.org/pub/linux/kernel/v4.x/$KSRC
		fi
		patch -b ~/rpmbuild/SOURCES/config-4.8.5-x86_64 <<EOF
*** config-4.8.5-x86_642016-10-29 23:36:23.852877337 +0000
--- .config2016-10-29 23:40:18.729883627 +0000
***************
*** 1451,1457 ****
  # CONFIG_NET_PKTGEN is not set
  # CONFIG_NET_TCPPROBE is not set
  CONFIG_NET_DROP_MONITOR=y
! # CONFIG_HAMRADIO is not set
  # CONFIG_CAN is not set
  # CONFIG_IRDA is not set
  CONFIG_BT=m
--- 1451,1476 ----
  # CONFIG_NET_PKTGEN is not set
  # CONFIG_NET_TCPPROBE is not set
  CONFIG_NET_DROP_MONITOR=y
! CONFIG_HAMRADIO=y
! 
! #
! # Packet Radio protocols
! #
! CONFIG_AX25=m
! # CONFIG_AX25_DAMA_SLAVE is not set
! # CONFIG_NETROM is not set
! # CONFIG_ROSE is not set
! 
! #
! # AX.25 network device drivers
! #
! CONFIG_MKISS=m
! # CONFIG_6PACK is not set
! # CONFIG_BPQETHER is not set
! # CONFIG_BAYCOM_SER_FDX is not set
! # CONFIG_BAYCOM_SER_HDX is not set
! # CONFIG_BAYCOM_PAR is not set
! # CONFIG_YAM is not set
  # CONFIG_CAN is not set
  # CONFIG_IRDA is not set
  CONFIG_BT=m

EOF
		;;
	esac
	;;
esac
# set a custom build ID
sed -e 's/^#define buildid \..*$/%define buildid .n2ygk/' \
    -e 's/^# % define buildid .*$/%define buildid n2ygk/' \
    -i.bak ~/rpmbuild/SPECS/$KSPEC
# build kernel for my architecture
rpmbuild -ba --target=$(uname -m) rpmbuild/SPECS/$KSPEC
# build firmware for my kernel
rpmbuild -ba --target noarch --with firmware --without debug --without doc --without perftool --without perf rpmbuild/SPECS/$KSPEC
