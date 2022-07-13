---
title: luci seems to be corrupt, unable to find section 'main'
date: 2022-07-13T10:53:50+08:00
lastmod: 2022-07-13T03:14:00.144Z
draft: false
categories:
  - 运维
tags:
  - openWRT
---

## 症状

访问路由器管理界面，网页返回一行孤独的错误。

```text
/usr/lib/lua/luci/dispatcher.lua:431: /etc/config/luci seems to be corrupt, unable to find section 'main'
```

<!--MORE-->
可是刚刚还能正常登录，近期也没有进行什么特殊的设置。而且除了管理界面之外的其他功能都正常工作。

多亏了万能的搜索引擎，发现可能是 `rpcd` 死了，遂通过 SSH 连接至路由器。

```text
root@Router:~# ps | grep rpc
 1238 root      3812 S    /sbin/rpcd -s /var/run/ubus/ubus.sock -t 30
 4796 root      1316 S    grep rpc
```

考虑到有的 `rpcd` 虽然活着，但它已经死了，仍然将其重启。

## 解决方案

SSH 连接至路由器，执行下面的指令重启 `rpcd`。

```shell
service rpcd restart
```

尝试访问路由器管理界面，成功。

## Reference

- [openwrt/luci#2231](https://github.com/openwrt/luci/issues/2231#issuecomment-487406823)