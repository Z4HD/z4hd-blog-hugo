---
title: 【转载】strongSwan配置惨痛教训
categories:
  - 运维
photo: /gallery/SW.png
date: 2017-09-02 20:43:12
description: 因为喜欢WIN8 METRO UI的风格，所以买了一个NOKIA手机，搭载WP8.1系统。平时用惯了 iPhone 的 PPTP 拨VPN的方式在WP8.1里居然不能使用 PPTP 的方式拨VPN了，WP8.1里拨VPN只支持IKEv2方式，然而google后发现搭建IKEv2教程非常少，中文教程更是可怜的狠。
---

>本文转载自[琼台博客](http://www.qttc.net/)
>文章地址：<http://www.qttc.net/201409447.html>
>这篇文章给博主带来了极大的帮助，故转载之以助其流芳千古。

因为喜欢WIN8 METRO UI的风格，所以买了一个NOKIA手机，搭载WP8.1系统。平时用惯了 iPhone 的 PPTP 拨VPN的方式在WP8.1里居然不能使用 PPTP 的方式拨VPN了，WP8.1里拨VPN只支持IKEv2方式，然而google后发现搭建IKEv2教程非常少，中文教程更是可怜的狠。

但Linode大流量不用放着很浪费，于是终于找到一篇像样的教程后开始照着教程安装，教程是5.13版本，而最新的strongSwan已经5.20版本，喜欢新版本的我毫不犹豫就下了5.2版本开始安装。过程都很顺利，安装、生成证书、下到iPhone，win8，NOKIA上，都能成功使用IKEv2方式拨上VPN，但都有一个问题：都打不开任何网页，win8的网络标志直接打上一个叹号。但ssh还连接着，证明可能是DNS问题，于是我换了N组DNS，包括google的 `8.8.8.8` / `8.8.4.4` 都试过了，问题还是一样。又没有任何头绪的情况下，只好暂时放弃改天再弄。往后那几天我一直认为是DNS问题，但一直情况依旧，证书从域名换到IP方式也不行，strongSwan从5.2降到5.13还是不行，真没辙了。
今天依旧打开服务器，突然想起是不是iptables这个害人的玩意，于是执行了一句：

``` sh
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

结果手机端打开youtube.com瞬间显示，毫无压力，随后的twitter/facebook/google都搞定。顿时泪崩，原来是我没有给nat做rule，真是血的教训啊！！
