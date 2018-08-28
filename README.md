# Server balabala...
This is for administrater!

## Server Configurations

两台 [x86 服务器](https://www.supermicro.org.cn/products/system/1u/5018/sys-5018d-fn4t.cfm)（[Quick Reference Guide](https://www.supermicro.org.cn/QuickRefs/superserver/1U/QRG-1775.pdf)），硬件、软件配置相同。

### Remote login

只能 RSA 登录，所以需要提供你的公钥：

- qat0: ssh root@192.168.1.70 -i ~/path/to/your/id_rsa
- qat1: ssh root@192.168.1.71 -i ~/path/to/your/id_rsa

### Hardware in short

- 一颗 Intel(R) Xeon(R) CPU D-1541 @ 2.10GHz. 8 Cores. 没开超线程.
- Memory: 8G.
- 1T HDD. 7200 rpm.
- [Intel QAT Adapter 8950](https://www.intel.com/content/www/us/en/ethernet-products/gigabit-server-adapters/quickassist-adapter-8950-brief.html).
- 一块 Ethernet Connection X552/X557-AT 10GBASE-T. 2 ports.

### Software in short

- OS: CentOS Linux release 7.5.1804 (Core).
- QAT driver 1.7. [Download link](https://01.org/sites/default/files/downloads/intelr-quickassist-technology/qat1.7.l.4.2.0-00012.tar.gz) (ICP_ROOT=/opt/QAT).
- [QATzip 0.2.5](https://github.com/intel/QATzip)(QATZIP_ROOT=/opt/QATzip).
- [DPDK 18.05](https://github.com/DPDK/dpdk/releases/tag/v18.05) (RTE_SDK=/opt/DPDK/dpdk-18.05).

## Tips on Server Usage

- Only root user, so be careful.
- File path `/root/workspace` is for development, so create a directory with your name here and then do some development.

## Automater

```bash
cd /root/workspace && git clone https://github.com/netalgo-F2018/server-cfg.git && \
cd server-cfg && bash cfg_all.sh && echo Done!
```
