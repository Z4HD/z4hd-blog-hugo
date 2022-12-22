---
title: ADB PULL vs MTP
subtitle: 文件传输速度实际对比
date: 2022-12-22T11:19:55+08:00
lastmod: 2022-12-22T11:12:38.619Z
draft: false
tags:
  - ADB
categories:
  - 手机

featuredImagePreview: ""
lightgallery: true

toc:
  enable: true
---

将文件从 Android 手机传输到PC的两种常用方式如下：

- MTP
- adb pull

本文将从实际传输速度的角度，对上述两种传输方式进行对比。

<!--more-->

{{< admonition info "INFO" true >}}
由于本文不是一篇严谨的研究，故存在下列局限性：

- 本文暂不涉及使用 [`adb exec-out`](https://stackoverflow.com/a/31401447) 通过管道（pipe）传输数据的方式。
- 本文不探讨理论分析的内容。
- 本文只涉及 Windows 平台下的 MTP 实现。不探讨其他平台下的 MTP 实现。
- 由于作者时间有限，没有将测试重复三次以上，测试结果可能受到某些偶然因素的影响。
{{< /admonition >}}

## 准备工作

{{< admonition note "测试平台" false >}}
Phone: *OnePlus 5T*

- [USB](https://zh.wikipedia.org/wiki/USB) 2.0，理论传输速度 480 Mbps = 60 MB/s
- Android 12, [DerpFest](https://derpfest.org/) ROM

PC: *Windows 10 兼容机*

ADB:

```
Android Debug Bridge version 1.0.41
Version 33.0.3-8952118
```
{{< /admonition >}}

测试过程中，将手机通过原装数据线直接连接到电脑后面板的USB3.0接口上，以减少可能出现的线路损耗。

在手机的 Internal Storage 中创建一个大小为 1GB 的空文件。稍后会将这个文件在手机和电脑之间来回拷贝并计量消耗的时间。

```shell
dd if=/dev/zero of=/sdcard/test.1gb bs=1M count=1024
```

此时可以顺便测试出手机的顺序写性能为 300 MB/s 左右。

{{< admonition info "关于 /sdcard" false >}}
`/sdcard/` 应该是一个指向 Internal Storage 的链接，但并不是所有手机都有这个链接。关于 Internal Storage 的更多信息可以参考下面的文章。

>[What is a data/media device?](https://twrp.me/faq/datamedia.html) - TeamWin
{{< /admonition >}}

## MTP

在文件资源管理器中，对测试文件执行无情拖拽。手动计时。

{{< admonition example "结果" false >}}

方式 | 时间 | 速度
:- | :- | :-
Phone -> PC | 34.56s | 29.63 MB/s
PC -> Phone | 28.16s | 36.36 MB/s

{{< /admonition >}}

## ADB PULL

使用ADB拉取文件到PC的当前目录下。

```shell
adb pull /sdcard/test.1gb .
```

{{< admonition example "结果" false >}}
```
/sdcard/test.1gb: 1 file pulled, 0 skipped. 33.4 MB/s (1073741824 bytes in 30.674s)
```
{{< /admonition >}}

将当前目录中 `test.1gb` 推送至手机 Internal Storage 的根目录。

{{< admonition bug "由于压缩使测速结果失真" false >}}

```
test.1gb: 1 file pushed, 0 skipped. 950.3 MB/s (1073741824 bytes in 1.078s)
```

push指令瞬间完成，可能是由于压缩导致的，使用 `-Z` 参数关闭压缩。更多参数详见 `adb --help`，此处不做展开。

通过本次测试还可以发现，对于 `adb pull`，压缩默认关闭；对于 `adb push`，压缩默认启用。
{{< /admonition >}}

```shell
adb push -Z test.1gb /sdcard/
```

{{< admonition example "结果" false >}}
```
test.1gb: 1 file pushed, 0 skipped. 28.9 MB/s (1073741824 bytes in 35.494s)
```
{{< /admonition >}}

## 测速结果对比

方式 | MTP | ADB PULL
:- | :- | :-
Phone -> PC | 29.63 MB/s | 33.4 MB/s
PC -> Phone | 36.36 MB/s | 28.9 MB/s

## 总结

通过上表可以发现，MTP和ADB之间的速度并没有本质上的区别。而且他们都比 USB 2.0 的理论速度慢了约50%。不过如果考虑到MTP的固有问题（*例如：手机上刚下载好的文件电脑上看不到；查看含有大量文件的文件夹时缓慢的加载速度*），以及表中微小的速度差异，从手机向电脑拷贝文件的最佳方案是使用 `adb pull`，从电脑向手机拷贝文件的最佳方案是使用**MTP**。
