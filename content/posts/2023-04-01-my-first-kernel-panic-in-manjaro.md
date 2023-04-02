---
title: 处理 Manjaro Linux 升级后内核错误
subtitle: 年轻人的第一次 Kernel Panic
date: 2023-04-01T22:28:30+08:00
lastmod: 2023-04-02T04:25:59.020Z
draft: false
tags:
  - GNU/Linux
categories:
  - 运维

featuredImagePreview: /images/2023-04-01-kernel-panic.jpg
lightgallery: true

toc:
  enable: true
---

记一次 Stable Update[^1] 后由于内核版本较低不支持 `zstd` 导致的内核错误（Kernel Panic）。

<!--more-->

## 0x00 现象

```bash
sudo pamac update && reboot
```

{{< image src="/images/2023-04-01-kernel-panic.jpg" caption="内核恐慌 （蹬蹬咚）" >}}

## 0x01 原因分析

关键错误信息如下：

```text
[+] Initramfs unpacking failed: invalid magic at start of compressed archive
[-] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
```

`VFS: unable to mount root fs on unknown-block(0 0)` 意味着内核无法挂载根文件系统。[^2] 考虑到在本例中根文件系统使用了经典的 `ext4` 文件系统，因此问题不太可能由于内核不支持所用文件系统导致。考虑到当 `grub` 中 `root=` 参数错误时可能会导致此问题，通过 chroot 后重新安装 `grub` 尝试解决失败，因此排除 `grub` 的问题。

继续从另一条错误信息 `Initramfs unpacking failed: invalid magic at start of compressed archive` 入手，通过通过很多很好的检索[^3]，最终确认原因如下：

- [Stable Update] 2023-03-31[^1] 引入了一个 `mkinitcpio` 更新 （`34-1.1 -> 35.2-1`），此更新将 initramfs 的默认压缩方式由 `gzip` 修改为 `zstd`[^4]
- 目前正在使用的 Linux Kernel 5.4 不支持 `zstd`，需要 5.10+
- 最终导致 `mkinitcpio` 生成的 initramfs 无法被内核读取。（`Initramfs unpacking failed`）

## 0x02 解决方案

> 1. 使用 Linux Kernel 5.10+ 引导
> 2. chroot 后修改 `COMPRESSION="gzip"`

### 开机

使用 Live CD 引导开机后 chroot 到当前 Manjaor Linux 安装[^5]，此过程可通过 `manjaro-chroot` 自动完成。

```bash
sudo manjaro-chroot -a
```

由于在 Live CD 环境中使用 `mhwd-kernel -i` 安装内核失败，因此先修改 initramfs 压缩方式为 `gzip`，待进入系统后再更新内核。

```bash
vim /etc/mkinitcpio.conf
```

删除 `#COMPRESSION="gzip"` 开头的 `#` (取消注释)

### 更新内核

选择 Manjaro Linux 中 5.x 内核最新的LTS版本 `5.15`

```bash
sudo mhwd-kernel -i linux515
```

更改 `/etc/mkinitcpio.conf` 中 `COMPRESSION="zstd"`（可选）

卸载旧内核（可选）

```bash
sudo mhwd-kernel -r linux54
```

## 2023-04-02 更新

目前 Manjaro Linux 官方已发布 `mkinitcpio 35.2-2`，其默认压缩方式已改回 `gzip`。`5.4` 内核的用户现已能够安全升级而不会内核恐慌。

## 感想

一个不滚包的用户，有两种可能性。一种是没有能力滚包。因为买不起高配的电脑和没有经常 `pacman -Syu` 等各种自身因素，他的人生都是失败的。第二种可能：有能力却不滚包的人，在有能力而没有滚包的想法时，那么这个人的思想境界便低到了一个令人发指的程度。一个有能力的人不付出行动来证明自己，只能证明此人技术素质修养之低下。是灰暗的，是不被真正的技术社区认可的，理解不了这种滚动的时刻保持最新的高雅包管理方式，他只能看到外表的版本堆砌，参不透其中深奥的 Kernel Panic，他整个人的层次就卡在这里了，只能度过一个相对失败的人生。

## Reference

----

[^1]: [[Stable Update] 2023-03-31 - Kernels, Plasma 5.27 LTS, Pamac, Phosh, Mesa, LibreOffice](https://forum.manjaro.org/t/stable-update-2023-03-31-kernels-plasma-5-27-lts-pamac-phosh-mesa-libreoffice/)
[^2]: [not syncing: VFS: Unable to mount root fs on unknown-block(0,0)](https://unix.stackexchange.com/questions/414655/not-syncing-vfs-unable-to-mount-root-fs-on-unknown-block0-0) - StackExchange
[^3]: [Initramfs unpacking failed: invalid magic as start of compressed](https://forum.manjaro.org/t/initramfs-unpacking-failed-invalid-magic-as-start-of-compressed/137451/12) - Support - Manjaro Linux Forum
[^4]: [Switch to zstd by default (2f4a2b59)](https://gitlab.archlinux.org/archlinux/mkinitcpio/mkinitcpio/-/commit/2f4a2b592fb98aab1a0e4f3135d4592219b7c25c) · Commits · Arch Linux / Mkinitcpio / mkinitcpio · GitLab
[^5]: [GRUB/Restore the GRUB Bootloader](https://wiki.manjaro.org/index.php/GRUB/Restore_the_GRUB_Bootloader#Use_manjaro-chroot) - Manjaro Wiki
