---
title: Btrfs RAID1 故障处理笔记
subtitle: 案例驱动的Btrfs手册
date: 2024-01-22T23:10:51+08:00
lastmod: 2024-01-28T15:57:17.486Z
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

### 2. 删除丢失的设备

```shell
btrfs device remove <devid> <path>
```

### 3. 转换为single

```shell
btrfs balance start -f -sconvert=single,soft, -mconvert=dup,soft, -dconvert=single,soft, <mountpoint>
```

## Reference

- https://unix.stackexchange.com/questions/227560/
- https://serverfault.com/questions/1104331