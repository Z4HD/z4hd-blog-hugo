---
title: Termux 中安装 gevent 库
date: 2017-08-11T19:04:15.000Z
categories:
  - 手机
tags:
  - Terumx
  - Python
---

好像现在不需要这么麻烦了，此文章仅供存档。

<!--more-->

## 引言

偶然在网上发现了一个暴力扫描二级域名的Python2神器：[subDomainsBrute](https://github.com/lijiejie/subDomainsBrute)

这个神器必须由 Python2.7 ~~强力~~驱动，同时还需要 *dnspython* 和 *gevent* 两个Python库。为了实现“~~电脑手机随时随地爆域名~~”，安装这两个库是必不可少的步骤。

## 准备工作

在Linux系统（或者Termux）中安装gevent前请务必确保您安装了 `gcc` 和 `python-dev`，不然会发生一些谜之错误。

## 正文

电脑上安装 dnspython 和 gevent 的过程会被pip瞬间完成，可在 Termux 上安装时，dnspython 倒是瞬间完成了，gevent 会出现下面的错误。

``` shell
Installing collected packages: gevent
  Running setup.py install for gevent ... error

中间省略.......

    copying src/gevent/libev/stathelper.c -> build/lib.linux-aarch64-2.7/gevent/libev
    running build_ext
    Running '(cd  "/data/data/com.termux/files/usr/tmp/pip-build-wanBBe/gevent/deps/libev"  && sh ./configure   && cp config.h "$OLDPWD" ) > configure-output.txt' in /data/data/com.termux/files/usr/tmp/pip-build-wanBBe/gevent/build/temp.linux-aarch64-2.7/libev
    ./configure: 1: eval: /bin/sh: not found
    configure: WARNING: 'missing' script is too old or missing
    configure: error: cannot run /bin/sh ./config.sub
    Traceback (most recent call last):
      File "<string>", line 1, in <module>
      File "/data/data/com.termux/files/usr/tmp/pip-build-wanBBe/gevent/setup.py", line 183, in <module>
        run_setup(EXT_MODULES, run_make=_BUILDING)

.....省略

      File "/data/data/com.termux/files/usr/lib/python2.7/subprocess.py", line 186, in check_call
        raise CalledProcessError(retcode, cmd)
    subprocess.CalledProcessError: Command '(cd  "/data/data/com.termux/files/usr/tmp/pip-build-wanBBe/gevent/deps/libev"  && sh ./configure   && cp config.h "$OLDPWD" ) > configure-output.txt' returned non-zero exit status 127

    ----------------------------------------
Command "/data/data/com.termux/files/usr/bin/python2 -u -c "import setuptools, tokenize;__file__='/data/data/com.termux/files/usr/tmp/pip-build-wanBBe/gevent/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /data/data/com.termux/files/usr/tmp/pip-U_0ve9-record/install-record.txt --single-version-externally-managed --compile" failed with error code 1 in /data/data/com.termux/files/usr/tmp/pip-build-wanBBe/gevent/
```

看来是configure程序找不到 `/bin/sh` 了，要知道在Termux中这个目录可不在这个地方。解决方法也很简单，在安装gevent之前键入下列指令：

``` shell
export CONFIG_SHELL=$PREFIX/bin/sh
```

然后重新用pip安装gevent，不出意外的话便能正常完成安装。

## 参考资料

- [/bin/sh: not found · Issue #104 · termux/termux-app](https://github.com/termux/termux-app/issues/104)
