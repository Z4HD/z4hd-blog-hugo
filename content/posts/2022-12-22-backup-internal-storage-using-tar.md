---
title: 打包备份 Android 手机的 Internal Storage 至电脑
date: 2022-12-22T19:45:48+08:00
lastmod: 2022-12-22T14:06:35.041Z
draft: true

tags:
  - ADB
categories:
  - 手机

featuredImagePreview: ""
lightgallery: true

toc:
  enable: true
---

本文探讨一种备份 Internal Storage (内置存储)[^1] 的方法，具备下列特性：

- 直接将备份文件顺序传输至PC，不产生额外的中间文件。
- 支持 gzip/bzip2/xz 压缩[^2]（压缩相关运算在手机端CPU中进行）
- 备份文件作为压缩包（tar），可以浏览文件列表或提取其中的部分文件。以及其他 tar archive 特性。

<!--MORE-->

{{< admonition warnring "平台支持" true >}}

平台支持：GNU/Linux，Windows (with **git-bash**)

详见：[*已知问题*](#已知问题)
{{</admonition>}}

## exec-out 与 exec-in

ADB有两个不包含在 help 中的命令：`exec-out` 和 `exec-in`。作用分别为向标准输出输出“不加料”的内容；和从标准输入读取内容，做为 command 的标准输入。

网上相关资料比较少，列出一些链接供参考。

- [Add "exec" service: shell commands with no pty.](https://android.googlesource.com/platform/system/core/+/5d9d434efadf1c535c7fea634d5306e18c68ef1f) - Google Git
- [Read binary stdout data like screencap data from adb shell?](https://stackoverflow.com/questions/13578416) - StackOverflow
- [Transferring binary data over ADB shell](https://stackoverflow.com/questions/11689511) - StackOverflow

## 备份

将 `/sdcard` 打包并用 gzip 压缩。不包含 `/sdcard/Android/`

```shell
./adb exec-out "cd /sdcard; tar -cz --exclude Android/ -f - ." > PATH_TO_BACKUP_FILE.tar.gz
```

`--exclude Android/` 排除某个特定的目录，该选项可以根据实际情况修改并重复添加。详情参考 `man tar`。

## 还原

TODO: 目前还没有找到能直接还原的方法。

## 已知问题

PowerShell 和 CMD 使用 `>` 无法得到正确的 tar 文件。

CMD/git-bash 产生的 tar 文件 （使用 `tar tvf` 验证，下同）

```text
gzip: stdin: unexpected end of file
tar: Unexpected EOF in archive
tar: Error is not recoverable: exiting now
```

PowerShell 产生的 tar 文件

```text
gzip: stdin: not in gzip format
tar: Child returned status 1
tar: Error is not recoverable: exiting now
```

## 参考文献

- [How to backup compressed data from your android device to your computer](https://forum.xda-developers.com/t/how-to-backup-compressed-data-from-your-android-device-to-your-computer.3464777/)

<!--footnote-->
[^1]: [What is a data/media device?](https://twrp.me/faq/datamedia.html) - TeamWin
[^2]: [Gzip vs Bzip2 vs XZ Performance Comparison](https://www.rootusers.com/gzip-vs-bzip2-vs-xz-performance-comparison/) - RootUsers
