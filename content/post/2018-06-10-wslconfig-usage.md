---
title: 使用 wslconfig 管理 Windows10 Linux 子系统
tags:
  - Windows
  - Linux
  - WSL
categories: 
  - 技术
date: 2018-06-10 13:23:34
description: 想要彻底删除体积庞大的 Windows 上的 Linux 子系统？
---

WSL Config (`wslconfig.exe`) 是一个用来管理运行于 *Windows上Linux子系统* 中 Linux 发行版的命令行工具。你可以用它列出当前已安装的Linux发行版、设置默认使用的发行版或者卸载发行版。

<!-- MORE -->

## 如何使用

查看所有可用的选项，运行下面的指令：
`wslconfig /?`

```cmd
wslconfig.exe
Performs administrative operations on Windows Subsystem for Linux

Usage:
    /l, /list [/all] - Lists registered distributions.
        /all - Optionally list all distributions, including distributions that
               are currently being installed or uninstalled.
    /s, /setdefault <DistributionName> - Sets the specified distribution as the default.
    /u, /unregister <DistributionName> - Unregisters a distribution.
```

## 列出已安装的发行版

列出当前已经安装且随时可用的发行版：

```cmd
wslconfig /list
```

列出所有发行版，包括正在安装、卸载和已损坏的发行版：

```cmd
wslconfig /list /all
```

## 设置默认发行版

```cmd
wslconfig /setdefault <DistributionName>
```

## 反注册（卸载）一个发行版

尽管可以通过 Windows应用商店 安装适用于WSL的Linux发行版，但不能通过应用商店卸载。WSL Config 使您能够卸载它们。

卸载后也可以在 Windows应用商店 重新安装发行版。

> **注意**: 卸载发行版时，会永久删除所有与该发行版有关的数据和设置。

用法：

```cmd
wslconfig /unregister <DistributionName>
```

示例：`wslconfig /unregister Ubuntu` 会将 Ubuntu 从当前可用的WSL发行版中彻底删除，之后运行 `wslconfig /list` 时该发行版便不会被列出。该发行版所占用的磁盘空间也会被释放。

## 参考资料

[Manage and configure WSL](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#managing-multiple-linux-distributions)
