---
title: 用sha1sum批量校验文件完整性
tags:
    - CLI
    - CentOS
    - GNU/Linux
categories:
    - 实用软件
date: 2018-04-23T18:57:59.000Z
---

shell命令行下有 `md5sum` 、 `sha1sum` 和`sha256sum`等应用广泛的文件校验和实用程序，下面就以时下流行的 `sha1sum` 为例介绍如何批量创建和校验文件校验和。

<!--more-->

### 创建校验和

创建当前文件夹下所有文件的校验和并保存至 `example.sha1` ：

```bash
sha1sum * > example.sha1
```

### 验证校验和

校验`example.sha1`中列出的文件：

```bash
sha1sum -c example.sha1
```

### 参考文献

>[How do I check the SHA1 hash of a file? - Ask Ubuntu](https://askubuntu.com/questions/61826/how-do-i-check-the-sha1-hash-of-a-file)
