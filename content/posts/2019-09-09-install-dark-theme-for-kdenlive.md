---
title: 在 Ubuntu 18.04 中为 Kdenlive 安装黑色主题
date: 2019-09-09T00:00:00.000Z
draft: false
tags:
    - GNU/Linux
    - KDE
    - Ubuntu
categories: 
    - 实用软件
toc:
    enable: false
---

在 Gnome 桌面环境下，刚装完 Kdenlive 时如果默认为白的发丑的界面，而且“主题”菜单下还只有一个“默认”，说明你的系统还没有安装适用于KDE桌面环境的主题。

<!--more-->

执行下面的指令安装 `kde-style-breeze-qt4`，再打开 Kdenlive 就能在主题菜单下找到 `Breeze Dark` 主题了。

```shell
sudo apt install kde-style-breeze-qt4
```

安装其他KDE主题同理。
