---
title: Ubuntu 18.04 配置 VMware 的共享文件夹功能
date: 2018-09-24 23:34:19
tags:
    - Ubuntu
    - VMware
    - 虚拟机
categories: 
    - 技术
draft: false
description: 虚拟机与宿主间交换文件的方法之一
---

为啥 `/mnt/hgfs` 空空如也？是配置的失误还是软件的故障？~~今晚8点，《社会与法》，准时播出~~

<!--more-->

## 环境

- 宿主机：`Windows 10`
- 客户机：`Ubuntu 18.04`

## 安装 open-vm-tools

本人尝试了十万甚至九万次仍然没能成功安装 `vmware-tools` ，故改用[官方推荐](https://kb.vmware.com/s/article/2073803)的 [open-vm-tools](https://github.com/vmware/open-vm-tools)。

已经安装过的可以跳过此步。

```bash
sudo apt install open-vm-tools open-vm-tools-desktop fuse

reboot
```

{{< admonition tip >}}

## 你知道吗

- `open-vm-tools-desktop` 用于提供硬件加速、自适应分辨率和文件双向拖放等桌面环境下可能会用到的特性
- Ubuntu 18.04 默认的软件源中没有 `open-vm-tools-dkms` ,但事实证明不装也不影响使用文件共享。

{{< /admonition >}}

## 测试

如果能成功执行下列指令并能正常存取 `/mnt/hgfs` ，说明你的客户机已经完全支持存取宿主机的共享文件夹。下一步便是配置自动挂载了。

```bash
sudo vmhgfs-fuse -o allow_other .host:/ /mnt/hgfs
```

## 配置自动挂载

向 `/etc/fstab` 尾部添加如下内容。

```shell
.host:/      /mnt/hgfs        fuse.vmhgfs-fuse allow_other,defaults   0       0
```

不出意外的话，重启后即可在 `/mnt/hgfs` 中看到已设置为共享的宿主机文件夹了。

## 参考文献

> - [Ubuntu中安装虚拟工具条open-vm-tools](https://jingyan.baidu.com/article/54b6b9c0982f2f2d593b4762.html)
> - [在 VMware 虚拟机中安装 open-vm-tools](https://zhuanlan.zhihu.com/p/22488904)
