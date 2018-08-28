#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(pwd)

# Use USTC CentOS mirror
cp -f $SCRIPT_DIR/CentOS-Base.repo /etc/yum.repos.d/
yum makecache
yum -y install epel-release
sed -e 's!^mirrorlist=!#mirrorlist=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
    -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
yum makecache

yum -y install wget curl

# To build QAT1.7
yum -y groupinstall "Development Tools"
yum -y install pciutils
yum -y install libudev-devel
yum -y install kernel-devel-$(uname -r)
yum -y install gcc
yum -y install openssl-devel

# Perf. tools & some useful debugging info.
yum -y install perf oprofile
yum -y install yum-utils
debuginfo-install -y kernel zlib glibc

yum -y install tcpdump wireshark

echo Done!

exit 0

