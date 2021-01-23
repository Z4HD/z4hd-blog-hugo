---
title: PyInstaller打包单EXE时封装额外的资源文件
tags:
  - Python
  - PyInstaller
categories:
  - 代码
date: 2017-12-02T17:05:26.000Z
toc:
    enable: true
---

众所周知 PyInstaller 可以将 Python 脚本打包成单一的可执行文件，那么如果程序需要访问自带的外部资源时该怎么办呢？

<!--more-->

## 封装资源文件的必要性

1. 制作绿色便携的单EXE可执行文件
2. 有些文件不希望让最终用户轻易看到
3. ~~干净~~

## 目录

- [封装资源文件的必要性](#%e5%b0%81%e8%a3%85%e8%b5%84%e6%ba%90%e6%96%87%e4%bb%b6%e7%9a%84%e5%bf%85%e8%a6%81%e6%80%a7)
- [目录](#%e7%9b%ae%e5%bd%95)
- [建立配置文件](#%e5%bb%ba%e7%ab%8b%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
- [编辑配置文件](#%e7%bc%96%e8%be%91%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
  - [datas](#datas)
  - [Tree](#tree)
- [修改代码引用](#%e4%bf%ae%e6%94%b9%e4%bb%a3%e7%a0%81%e5%bc%95%e7%94%a8)
- [编译](#%e7%bc%96%e8%af%91)
- [参考资料](#%e5%8f%82%e8%80%83%e8%b5%84%e6%96%99)
- [额外说明](#%e9%a2%9d%e5%a4%96%e8%af%b4%e6%98%8e)

<!--
{% admonition info INFO %}
以下内容在[PyInstaller](http://www.pyinstaller.org/) 3.3上实测有效
{% endadmonition %}
-->

## 建立配置文件

键入下列指令建立spec配置文件，参数与直接使用PyInstaller时使用的参数相同，程序会自动帮你添加到配置文件中。

```shell
pyi-makespec -F -w –icon=<YourICON>.ico <YourPyScript>
```

_使用类似`pyinstaller -F XXX.spec`编译二进制程序时添加的参数可能没有效果。_

## 编辑配置文件

依据实际情况添加配置文件的引用。

### datas

此法适用于添加单个或几个文件

找到`Analysis()`的`datas=[]`，每个文件一个tuple（元组）格式如下：

```python
a = Analysis(
            ...
            datas=[('文件在当前系统中的位置','文件在可执行文件运行时相对于可执行文件的位置')],
            ...
            )
```

使用通配符可以同时添加所有匹配的文件

```python
a = Analysis(
     ...
     datas= [ ('/mygame/sfx/*.mp3', 'sfx' ) ],
     ...
     )
```

>更多高级用法请阅读PyInstaller文档（英文）：[Adding Data Files](https://pyinstaller.readthedocs.io/en/stable/spec-files.html#adding-data-files)

### Tree

此法适用于添加一整个目录的文件

**首先，在spec文件中添加如下内容：**

```python
extra_tree = Tree('./myimages', prefix = 'myimages')
```

**然后在 `a.scripts` 等 a. 开头文件所在的部分后添加 `extra_tree`。**

_表示还没有深入理解Tree，先复制粘贴了其他神触的步骤。_

>更多高级用法请阅读PyInstaller文档（英文）：[The Tree Class](https://pyinstaller.readthedocs.io/en/stable/advanced-topics.html#the-tree-class)

## 修改代码引用

在脚本开头添加下列代码：

```python
import sys, os
if getattr(sys, 'frozen', False):  # 运行于 |PyInstaller| 二进制环境
    basedir = sys._MEIPASS
else:  # 运行于一般Python 环境
    basedir = os.path.dirname(__file__)
```

找到所有涉及相对路径的文件操作，在路径前添加`basedir+`。示例：

```python
    with open(os.path.normpath(basedir + '\\ui.kv'), 'r', encoding='UTF-8') as f1:
        kv_str = f1.read()
```

其中 `os.path.normpath()` 用于标准化路径。详细信息请自行查阅 [Python 文档](https://docs.python.org/3.6/library/os.path.html?highlight=os%20path%20normpath#os.path.normpath)。

经此法修改的脚本可同时在单exe和使用解释器运行时使用相对路径读取打包的资源文件。

## 编译

接下来的步骤就比较轻松了，直接使用PyInstaller编译然后到`./dict`文件夹中找到你刚编译出来的可执行文件即可。

```shell
pyinstaller <YourPyScript>.spec
```

## 参考资料

- [PyInstaller打包单个bundle时封装额外的资源文件](http://www.tinyedi.com/pyinstallerda-bao-dan-ge-bundleshi-feng-zhuang-e-wai-de-zi-yuan-wen-jian/)

## 额外说明

```log
[CRITICAL] [Window      ] Unable to find any valuable Window provider.
```

如果要打包的程序使用了Kivy框架，则spec文件需做点修改，否则打包出的EXE由于依赖缺失无法正常加载窗口。

```python
# spec文件头部添加
from kivy.deps import sdl2, glew

#修改EXE(),添加需在**第一个关键词参数的前面**进行。
exe = EXE(
          ...
          *[Tree(p) for p in(sdl2.dep_bins + glew.dep_bins)],
          ...
          )
```
