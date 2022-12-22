---
title: Windows 10 Visual Studio Code 界面部分模糊的解决方案
subtitle: 针对 NVIDIA 显卡用户
date: 2022-10-16T22:37:21+08:00
lastmod: 2022-12-22T03:28:14.314Z
draft: false
tags:
  - Windows
  - Visual Studio Code
categories:
  - 故障排除

featuredImagePreview: images/nv-control-panel-fxaa.png
lightgallery: true
---

## 症状

- 环境：Windows 10 x64 + NVIDIA RTX 2060 Mobile
- Visual Studio Code 界面部分或全部变得模糊。
- 鼠标点击模糊的位置，模糊的程度会改变。

<!--more-->

## 解决方案

{{< image src="images/nv-control-panel-fxaa.png" caption="禁用FXAA" >}}

在NVIDIA 控制面板中，禁用FXAA。

{{< admonition question "全局设置 or 程序设置？" true >}}

- 不特定多个应用程序中发生模糊现象，或不需要针对所有程序启用FXAA，使用**全局设置**。
- 只需要解决特定应用程序中文本的模糊现象，使用**程序设置**。

{{< /admonition >}}

## 参考文献

- [atom，vs2017、vscode 在 win10 下界面显示模糊怎么办？](https://www.zhihu.com/question/57583720/answer/1514233926) - runner time的回答 - 知乎
