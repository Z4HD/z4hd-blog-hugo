---
title: 打包备份 Android 手机的 Internal Storage 至 PC
date: 2022-12-22T19:45:48+08:00
lastmod: 2022-12-23T03:09:57.875Z
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

本文探讨一种备份 Internal Storage (内置存储)[^1] 的方法，具备下列特性：

- 直接将备份文件传输至PC，不产生额外的中间文件。
- 支持 gzip/bzip2/xz 等压缩方式[^2]
- 备份文件作为tar包，可以浏览文件列表或提取其中的部分文件。以及其他 tar archive 特性。
- 使用管道（pipe）直接将 tar 包释放到内置存储，不产生额外的中间文件。

<!--MORE-->

{{< admonition danger >}}
**不当操作可能对您的设备和数据造成不可逆的损害。**

在执行任何ADB指令前务必进行细致的检查，确保已经理解将要进行的操作。
{{< /admonition >}}

{{< admonition warning "平台支持" true >}}

平台支持：GNU/Linux，Windows (with [git-bash](https://gitforwindows.org/))

详见：[*已知问题*](#已知问题)
{{</admonition>}}

## exec-out 与 exec-in

ADB有两个不包含在 help 中的命令：`exec-out` 和 `exec-in`。作用分别为向标准输出输出“不加料”的内容；和从标准输入读取内容，做为 command 的标准输入。

网上相关资料比较少，列出一些链接供参考。

- [Add "exec" service: shell commands with no pty.](https://android.googlesource.com/platform/system/core/+/5d9d434efadf1c535c7fea634d5306e18c68ef1f) - Google Git
- [Read binary stdout data like screencap data from adb shell?](https://stackoverflow.com/questions/13578416) - StackOverflow
- [Transferring binary data over ADB shell](https://stackoverflow.com/questions/11689511) - StackOverflow

## 备份

### GNU/Linux or Git Bash on Windows

将 `/sdcard` 打包并在PC端用 gzip 压缩，压缩等级5。不包含 `/sdcard/Android/`

```shell
adb exec-out "cd /sdcard; tar -c --exclude Android/ -f - ." | gzip -5 > PATH_TO_BACKUP_FILE.tar.gz
```

- `cd /sdcard;` Internal Storage路径，不同手机可能有区别。此项也用来指定 tar 包中的根目录。
- `--exclude Android/` 排除某个特定的目录，该选项可以根据实际情况修改并重复添加。详情参考 `man tar`。
- `-f -` 输出至标准输出。一般不用修改。
- `.` 指定要包含在 tar 包中的目录，修改此项可以单独打包指定的文件夹。

### Windows CMD 无压缩

将 `/sdcard` 打包，无压缩。不包含 `/sdcard/Android/`

```bat
adb exec-out "cd /sdcard; tar -c --exclude Android/ -f - ." > PATH_TO_BACKUP_FILE.tar
```

### Windows CMD + 7z.exe

将 `/sdcard` 打包并在PC端用 7z 压缩，默认压缩等级。不包含 `/sdcard/Android/`

```bat
adb exec-out "cd /sdcard; tar -c --exclude Android/ -f - ." | 7z a -si PATH_TO_BACKUP_FILE.tar.7z
```

可以在终端中看到7z输出当前已处理的数据量，四舍五入就是一个进度条。

## 还原

此处示例针对 `tar.7z`，`tar.gz` 使用标准 tar 命令即可处理，此处不再赘述。

### 本地测试

```shell
7z x -so PATH_TO_BACKUP_FILE.tar.7z | tar tvf -
```

### 真机还原测试

```shell
7z x -so PATH_TO_BACKUP_FILE.tar.7z | adb exec-in "tar tvf - > /sdcard/test.log"
adb shell "cat /sdcard/test.log"
```

### 解压 tar 包至 Internal Storage

{{< admonition warning "警告" true >}}
下列指令未经测试
{{</admonition>}}

```shell
7z x -so PATH_TO_BACKUP_FILE.tar.7z | adb exec-in "tar xf - -C /sdcard/ 2>/sdcard/extract.log"
```

## 已知问题

### 手机端 tar 压缩后文件在PC端得到 Unexpected EOF

CMD/git-bash 产生的 tar 文件 （使用 `tar tvf` 验证，下同）

```text
gzip: stdin: unexpected end of file
tar: Unexpected EOF in archive
tar: Error is not recoverable: exiting now
```

解决方案：移动端使用 `tar -c` 创建无压缩的 tar 文件，在PC端进行压缩。由于此操作用到管道(pipe)，而且要求压缩软件支持从标准输入读取，在 Windows 平台可能需要搭配 git-bash 或 WSL使用。或者使用CMD时仅保存无压缩的文件。

*我不太会用CMD的pipe特性，而且只知道有7z.exe能够从标准输入读取，此处留给读者自行尝试将前文的命令改写为CMD兼容。*

### PowerShell 使用 `>` 无法得到正确的 tar 文件

PowerShell 产生的 tar 文件

```text
gzip: stdin: not in gzip format
tar: Child returned status 1
tar: Error is not recoverable: exiting now
```

临时~~解决~~方案：不用 PowerShell

## 参考文献

- [How to backup compressed data from your android device to your computer](https://forum.xda-developers.com/t/how-to-backup-compressed-data-from-your-android-device-to-your-computer.3464777/)

<!--footnote-->
[^1]: [What is a data/media device?](https://twrp.me/faq/datamedia.html) - TeamWin
[^2]: [Gzip vs Bzip2 vs XZ Performance Comparison](https://www.rootusers.com/gzip-vs-bzip2-vs-xz-performance-comparison/) - RootUsers
