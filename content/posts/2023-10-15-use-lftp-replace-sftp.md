---
title: 使用 lftp 替代 sftp
subtitle: ""
date: 2023-10-15T13:51:37+08:00
lastmod: 2023-10-15T06:28:28.627Z
draft: false
tags:
    - GNU/Linux
categories:
    - 实用软件
featuredImagePreview: ""
lightgallery: false
toc:
    enable: false
---

## 0x00 基本参数

{{< admonition info INFO >}}
按照实际情况修改 `<VAR>` 中的内容。
{{< /admonition >}}

```shell
lftp -p <端口> -u <用户名> sftp://<服务器地址/域名>
```

## 0x01 使用私钥登录

如何使用私钥登陆 ssh 服务器此处不再赘述，详见各类 ssh 教程。

建议先使用 sftp 尝试登陆，以排除 ssh 本身的配置问题。

{{< admonition tip 指定一个不在默认位置的私钥 false >}}
根据 [lftp 的 man 手册](https://lftp.yar.ru/lftp-man-alt.html)，需要在配置文件中修改 `sftp:connect-program` 来手动指定私钥的位置。

```shell
set sftp:connect-program "ssh -a -x -i <私钥的绝对路径路径>"
```

建议将上述代码添加到 `~/.lftprc` 中。

还可以使用使用 `ssh-agent` + `ssh-add` 达到相同的目的。

{{< /admonition >}}

## 0x02 使用带密码的私钥登录

```shell
lftp -u <用户名>,<私钥密码> sftp://<服务器地址>
```

## 0x03 使用无密码的私钥登录

```shell
lftp -u <用户名>, sftp://<服务器地址>
```

其中 `-u` 参数用户名后的逗号是必须的。作用为指定一个空密码，以避免 lftp 在每次运行时询问密码。
