---
title: 图片颜色反相时保持色彩
subtitle: ""
date: 2023-06-03T19:49:41+08:00
lastmod: 2023-06-03T12:43:51.618Z
draft: true
tags: []
categories:
  - 实用软件
featuredImagePreview: ""
lightgallery: true
toc:
  enable: false
---

一种奇怪的需求：使用颜色反相将黑色背景的图片转换为白色背景图片的同时保持原有的色彩。

<!--more-->

黑色背景的图片如果直接打印出来，会非常费墨。只应用颜色反相，虽然黑底变成白底了，但蓝色也变成黄色了，鬼火也变成蓝火了。本文探讨了一种方法，能够在应用颜色反相后保持除灰度外其余颜色不变。

以 [GIMP](https://www.gimp.org/) 为例，对待处理的图片依次执行下列命令：

1. 颜色 -> 反向
2. 颜色 -> 色相-浓度，将“色相（Range of affected hues）”设置为 `-180`

此时图片应为白底黑字，但除黑白灰外的其他颜色仍维持原色。

<!-- 此处插入效果图 -->

如果需要对多张图片进行上述处理，推荐使用[BIMP](https://github.com/alessandrofrancesconi/gimp-plugin-bimp)插件，该插件为GIMP添加了批处理功能，与 Photoshop 中基于录制动作的批处理不同，BIMP需要用户在执行前手动编排动作指令及参数（指令序列可以导入导出）。

中文版GIMP找对应指令名称可能需要参考对应的英文文档。

中文名称 | 指令名
:- | :-
反向 | `gimp-drawable-invert`
色相-浓度 | `gimp-drawable-hue-saturation`
