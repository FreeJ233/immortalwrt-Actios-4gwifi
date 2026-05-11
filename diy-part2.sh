#!/bin/bash
# DIY脚本
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part2.sh
# 功能说明: OpenWrt DIY脚本第2部分（更新feeds之后）
# 版权: (c) 2019-2024 P3TERX <https://p3terx.com>
# 基于 MIT 开源协议，详见 /LICENSE

# 修改默认IP地址
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate


# 修改默认主题为 argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile


# 临时添加的插件
# git clone https://github.com/lkiuyu/luci-app-cpu-perf package/luci-app-cpu-perf
# git clone https://github.com/lkiuyu/luci-app-cpu-status package/luci-app-cpu-status
# git clone https://github.com/gSpotx2f/luci-app-cpu-status-mini package/luci-app-cpu-status-mini
# git clone https://github.com/lkiuyu/luci-app-temp-status package/luci-app-temp-status
# git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus

# luci-app-daed
# 1. 先删掉可能存在的旧版本（有些源码里可能叫 luci-app-daed 或 daed）
rm -rf feeds/luci/applications/luci-app-daed
rm -rf package/feeds/luci/luci-app-daed
rm -rf package/dae  # 如果你之前克隆过，也先删掉

# 2. 按照官方推荐克隆到 package/dae
git clone --depth 1 https://github.com/QiuSimons/luci-app-daed package/dae

# 自动注入 daed 所需的内核与插件配置
echo 'CONFIG_KERNEL_DEBUG_INFO=y' >> .config
echo 'CONFIG_KERNEL_DEBUG_INFO_BTF=y' >> .config
echo 'CONFIG_KERNEL_CGROUPS=y' >> .config
echo 'CONFIG_KERNEL_CGROUP_BPF=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-daed=y' >> .config
echo 'CONFIG_PACKAGE_daed=y' >> .config
echo 'CONFIG_PACKAGE_kmod-xdp-sockets-diag=y' >> .config

# 修复依赖问题（强制让编译系统检查依赖）
make defconfig

./scripts/feeds update -a
./scripts/feeds install -a
