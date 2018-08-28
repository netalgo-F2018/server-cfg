#!/bin/bash
# 
# root saves time!
# 

set -euo pipefail

SCRIPT_DIR=$(pwd)
ROOT_DIR=/opt
RTE_SDK=$ROOT_DIR/DPDK/dpdk-18.05
RTE_TARGET=build
ICP_ROOT=$ROOT_DIR/QAT
QATZIP_ROOT=$ROOT_DIR/QATzip
PKTGEN=$ROOT_DIR/dpdk-pktgen

test -e pktgen_tx.conf && test -e dh895xcc_dev0.conf

mkdir -p $ROOT_DIR
echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages

# Refer to https://core.dpdk.org/doc/quick-start/
function install_dpdk
{
    echo ===begin install DPDK at $RTE_SDK

    DPDK_REPO_URL=https://github.com/DPDK/dpdk.git
    mkdir -p $RTE_SDK && cd $RTE_SDK && \
        git clone $DPDK_REPO_URL . && git checkout -b my18.05 v18.05

    make config T=x86_64-native-linuxapp-gcc
    sed -ri 's,(PMD_PCAP=).*,\1y,' build/.config

    make -j8 > /dev/null

    echo ===end install DPDK at $RTE_SDK
    echo -e "\n\n"
}

function cfg_dpdk
{
    echo ===begin configure DPDK at $RTE_SDK

    test -e $RTE_SDK || install_dpdk
    cd $RTE_SDK

    modprobe uio || true
    rmmod igb_uio || true
    insmod ./build/kmod/igb_uio.ko
    ./usertools/dpdk-devbind.py -b igb_uio 03:00.0 03:00.1

    mkdir -p /mnt/huge
    umount /mnt/huge || true
    mount -t hugetlbfs nodev /mnt/huge

    echo ===end configure DPDK at $RTE_SDK
    echo -e "\n\n"
}

# Refer to https://01.org/sites/default/files/downloads/intelr-quickassist-technology/336212qatswgettingstartedguiderev003.pdf
function install_qat
{
    echo ===begin install QAT at $ICP_ROOT

    QAT_1_7_URL=https://01.org/sites/default/files/downloads/intelr-quickassist-technology/qat1.7.l.4.2.0-00012.tar.gz
    QAT_1_7=$(mktemp)

    mkdir -p $ICP_ROOT && cd $ICP_ROOT

    wget -O $QAT_1_7 $QAT_1_7_URL && \
        tar --no-same-owner -xf $QAT_1_7
    ./configure && make -j8 > /dev/null && make install

    echo ===end install QAT at $ICP_ROOT
    echo -e "\n\n"
}

function cfg_qat
{
    echo ===begin configure QAT at $ICP_ROOT

    test -e $ICP_ROOT || install_qat

    cp -f $SCRIPT_DIR/dh895xcc_dev0.conf /etc/ && service qat_service restart

    echo ===end configure QAT at $ICP_ROOT
    echo -e "\n\n"
}

function install_qatzip
{
    echo ===begin install QATzip at $QATZIP_ROOT

    QATZIP_REPO_URL=https://github.com/intel/QATzip.git

    mkdir -p $QATZIP_ROOT && cd $QATZIP_ROOT
    git clone $QATZIP_REPO_URL . && git checkout -b my0.2.5 v0.2.5

    ./configure --with-ICP_ROOT=$ICP_ROOT && \
        make -j8 all > /dev/null && \
        make install

    echo ===end install QATzip at $QATZIP_ROOT
    echo -e "\n\n"
}

# Refer to https://github.com/intel/QATzip
function cfg_qatzip
{
    echo ===begin configure QATzip at $QATZIP_ROOT

    test -e $QATZIP_ROOT || install_qatzip
    cd $QATZIP_ROOT

    rmmod usdm_drv || true
    insmod $ICP_ROOT/build/usdm_drv.ko max_huge_pages=512 max_huge_pages_per_process=16

    echo ===end configure QATzip at $QATZIP_ROOT
    echo -e "\n\n"
}

function install_pktgen
{
    echo ===begin install DPDK-pktgen at $PKTGEN

    PKTGEN_REPO_URL=https://github.com/rhiswell/dpdk-pktgen.git

    mkdir -p $PKTGEN && cd $PKTGEN
    git clone $PKTGEN_REPO_URL .

    make RTE_SDK=$RTE_SDK RTE_TARGET=$RTE_TARGET

    echo ===end install DPDK-pktgen at $PKTGEN
    echo -e "\n\n"
}

function cfg_pktgen
{
    echo ===begin configure DPDK-pktgen at $PKTGEN

    test -e $PKTGEN || install_pktgen

    cp -f $SCRIPT_DIR/pktgen_tx.conf $PKTGEN/config

    echo ===end configure DPDK-pktgen at $PKTGEN
    echo -e "\n\n"
}

cfg_qat
cfg_qatzip
cfg_dpdk
cfg_pktgen

echo Done!

exit 0
