---
title: Fedora 34 中无法修改无线网卡的 county code
subtitle: ""
date: 2022-10-16T23:19:29+08:00
lastmod: 2022-10-16T15:23:17.002Z
draft: false
tags:
  - GNU/Linux
  - Fedora
categories:
  - 运维
  - 故障排除
---

## 症状

无法正常设置WiFi Country Code，也无法通过  `iw reg get` 查看到正确的 Country Code 信息。

<!--more-->

## 问题原因

f34的软件源中的 `crda` 已被 `wireless-regdb` 取代。

## 解决方案

```shell
sudo dnf install wireless-regdb
```

安装完成后重启，使用 `iw reg get` 查看到的区域信息应恢复正常。

```shell
$ iw reg get
global
country US: DFS-FCC
        (2402 - 2472 @ 40), (N/A, 30), (N/A)
        (5170 - 5250 @ 80), (N/A, 30), (N/A), AUTO-BW
        (5250 - 5330 @ 80), (N/A, 24), (0 ms), DFS, AUTO-BW
        (5490 - 5730 @ 160), (N/A, 24), (0 ms), DFS
        (5735 - 5835 @ 80), (N/A, 30), (N/A)
        (57240 - 70200 @ 2160), (N/A, 40), (N/A)

```

后续便可以通过 `sudo iw reg set` 设置无线网卡的 Country Code。

## Reference

- [e877342](https://src.fedoraproject.org/rpms/crda/c/e877342d3cbb4b7b287db4e2d16771bbec6d6c7a
) Obsoleted by wireless-regdb 
