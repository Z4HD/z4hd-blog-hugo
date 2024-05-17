---
title: Btrfs RAID1 故障处理笔记
subtitle: 案例驱动的Btrfs手册
date: 2024-01-22T23:10:51+08:00
lastmod: 2024-05-17T06:10:27.330Z
draft: true
tags:
    - GNU/Linux
categories:
    - 运维
featuredImagePreview: ""
lightgallery: true
toc:
    enable: true
---

BTRFS 启动！

<!--more-->

## 0x00 创建RAID1

```shell
mkfs.btrfs -L <label> -d raid1 -m raid1 <p1> <p2>
```

修改 Label

```shell
btrfs filesystem label [<device>|<mount_point>] [<newlabel>]
```

## 0x01 离线替换硬盘

场景：开机后，1块硬盘掉盘，OMV自动挂载无提示，内核中有错误日志。

### 1. 验证掉盘情况

```shell
btrfs filesystem show /dev/sdc
```

### 2. 降级模式挂载故障分区

```shell
mount -o rw,degraded <dev> <tmpdir>
```

### 3. 替换

```shell
btrfs replace start -B <devid> <newdev> <mountpoint>
```

### 4. 完成后重启

消除 `WARNING: Multiple block group profiles detected`

```shell
btrfs balance start -f -sconvert=raid1,profiles=single,soft, -mconvert=raid1,profiles=single,soft, -dconvert=raid1,profiles=single,soft, <mountpoint>
```

## 0x02 在线替换（未实验）

场景：正常运行中，一块硬盘MISSING，此时文件系统仍能正常RW

```shell
btrfs replace start -B <devid> <newdev> <mountpoint>
```

## 0x03 原盘清空后恢复

场景：阵列中的一块硬盘在离线状态下被完全擦除。（修复坏块）

## 0x04 RAID1降级为single

场景：掉一块盘，将剩余的好盘降级为single

### 1. 降级模式挂载故障分区

```shell
mount -o rw,degraded <dev> <tmpdir>
```

### 2. 转换为single

```shell
btrfs balance start -f -sconvert=single,soft, -mconvert=dup,soft, -dconvert=single,soft, <mountpoint>
```

not test

```shell
btrfs balance start -f -sconvert=DUP -mconvert=DUP -dconvert=single <mount>
```

### 3. 删除丢失的设备

```shell
btrfs device remove <devid> <path>
```

## 0x05 single 升级为 RAID1

场景：加一块盘，将 single 数据盘与新盘组成 RAID1

{{< admonition note "sda 还是 sda1 ?" true >}}

虽然 btrfs-device 文档中，以单设备文件系统（single-device filesystem） 为例创建RAID1。但考虑到磁盘型号不同可能导致其最大可用容量存在微小的差别，因此笔者通过在每块硬盘上创建单个大小完全相同，且比最大可用容量略小的分区，以避免在未来更换硬盘时遇到可用容量不同的问题。

无论是硬盘（sda）还是分区（sda1），都属于块设备，因此都能够被 btrfs device 处理。

{{< /admonition >}}

### 1. 添加新的块设备

{{< admonition tip "TIPS" true >}}
待添加的块设备（本例为：`/dev/sde1`）必须是空文件系统。如已创建文件系统，可使用 wipefs 清除之。

否则会报错。

```log
ERROR: /dev/sde1 appears to contain an existing filesystem (btrfs)
```

{{< /admonition >}}

```shell
wipefs -a /dev/sde1
btrfs device add /dev/sde1 /mnt
```

### 2. 转换为 RAID1

```shell
btrfs -v balance start -sconvert=raid1,soft -mconvert=raid1,soft -dconvert=raid1,soft <mount point>
```

## Reference

- [How to replace a device in BTRFS RAID-1 filesystem?](https://unix.stackexchange.com/questions/227560/) - Unix & Linux Stack Exchange
- [linux - Can I replace a disk in btrfs raid1 without a reboot?](https://serverfault.com/questions/1104331) - Server Fault
