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
# rm -rf feeds/luci/applications/luci-app-daed
# rm -rf package/feeds/luci/luci-app-daed
# rm -rf package/dae  # 如果你之前克隆过，也先删掉

# 2. 按照官方推荐克隆到 package/dae
# git clone --depth 1 https://github.com/QiuSimons/luci-app-daed package/dae

# 防重复追加函数
add_config() {
    grep -qxF "$1" .config || echo "$1" >> .config
}

# 原有 daed 相关配置
add_config "CONFIG_KERNEL_DEBUG_INFO=y"
add_config "CONFIG_KERNEL_DEBUG_INFO_BTF=y"
add_config "CONFIG_KERNEL_CGROUPS=y"
add_config "CONFIG_KERNEL_CGROUP_BPF=y"
add_config "CONFIG_PACKAGE_luci-app-daed=y"
add_config "CONFIG_PACKAGE_daed=y"
add_config "CONFIG_PACKAGE_kmod-xdp-sockets-diag=y"

# 新增的内核配置（转换后）
add_config "CONFIG_KERNEL_BPF=y"
add_config "CONFIG_KERNEL_BPF_SYSCALL=y"
add_config "CONFIG_KERNEL_BPF_JIT=y"
# CONFIG_KERNEL_CGROUPS=y 已存在，无需重复
add_config "CONFIG_KERNEL_KPROBES=y"
add_config "CONFIG_KERNEL_NET_INGRESS=y"
add_config "CONFIG_KERNEL_NET_EGRESS=y"
add_config "CONFIG_KERNEL_NET_SCH_INGRESS=m"
add_config "CONFIG_KERNEL_NET_CLS_BPF=m"
add_config "CONFIG_KERNEL_NET_CLS_ACT=y"
add_config "CONFIG_KERNEL_BPF_STREAM_PARSER=y"
# 取消 DEBUG_INFO_REDUCED（确保完整调试信息）
grep -q "CONFIG_KERNEL_DEBUG_INFO_REDUCED=y" .config && sed -i 's/CONFIG_KERNEL_DEBUG_INFO_REDUCED=y/# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set/' .config
add_config "# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set"
add_config "CONFIG_KERNEL_KPROBE_EVENTS=y"
add_config "CONFIG_KERNEL_BPF_EVENTS=y"

# 修复依赖问题（强制让编译系统检查依赖）
make defconfig

./scripts/feeds update -a
./scripts/feeds install -a
