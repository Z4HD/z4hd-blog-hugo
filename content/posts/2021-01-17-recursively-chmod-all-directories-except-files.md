---
title: 使用 find + chmod 批量修改目录或文件的权限
date: 2021-01-17T08:57:12.000Z
draft: false
tags:
    - GNU/Linux
categories:
    - 运维
lightgallery: false
---

使用 `chmod -R` 递归修改权限的时候会把文件和目录的权限都修改了，可有时候我们只想修改目录的权限，便不能直接用 `chmod -R` 修改。由于 `chmod` 命令不支持分别对文件或目录进行操作，因此我们需要借助 `find` 命令来分别筛选出待处理的文件或目录，并通过 `xargs` 将需要修改权限的对象传递给 `chmod` 进行修改。

<!--more-->

本文以分别将 `/path/to/base/dir` 目录下所有文件的权限指定为644，所有目录的权限指定为755为例。

```shell
# 修改目录权限
find /path/to/base/dir -type d -print0 | xargs -r -0 chmod 755
# 修改文件权限
find /path/to/base/dir -type f -print0 | xargs -r -0 chmod 644
```

理论上，本方法可适用于大量[^1]文件/目录。 `-r` [^2]参数使得如果 `find` 没有找到符合要求的对象则 `xargs` 不会执行 `chmod` 命令。

## 参考文献

- [How to recursively chmod all directories except files? - Super User](https://superuser.com/questions/91935/how-to-recursively-chmod-all-directories-except-files)
- `man find`
- `man xargs`

## 脚注

[^1]: [comment1864697_91938](https://superuser.com/questions/91935/how-to-recursively-chmod-all-directories-except-files#comment1864697_91938) by: Agargara
[^2]: 等效于 `--no-run-if-empty`，详情参考 xargs 手册。
