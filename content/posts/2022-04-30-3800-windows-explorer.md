---
title: 来自 3800s 的 Windows 10
subtitle: ""
date: 2022-04-30T13:19:29+08:00
lastmod: 2022-04-30T05:38:19.468Z
draft: false
tags:
  - Windows
categories:
  - 运维

featuredImage: ""
featuredImagePreview: ""

lightgallery: false
---

TL;DR 由于神秘原因，系统时间穿越到了3822年，使得explorer.exe 不断崩溃重启。将时间修改为20xx年后恢复正常。

<!--more-->

## 正文

最近帮人排除电脑疑难杂症的时候发现了 Windows Explorer 的一个神奇的BUG：如果系统时间被调节为38xx年，explorer.exe 就会不停的崩溃重启。

## 具体表现

- 安全模式下任务栏闪烁
- 鼠标焦点以固定的频率失去
- 30%左右的CPU占用，风扇狂转
- 任务管理器中拒绝访问的 `explorer.exe`

## 后续

通过将系统日期修改为正常的日期可以解决该问题。目前还没有尝试复现，因为我发现控制面板里的日期和时间设置最多只能改到2099年。

根据反馈，可能是使用 H3C iNode 进行连接的过程中，由于 iNode 自身的BUG造成的。重置 *（也有可能是重装）* iNode 配置后该问题不再出现。
