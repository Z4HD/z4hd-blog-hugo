---
title: 一行命令使用 ffmpeg 下载 m3u8 视频流
subtitle: ""
date: 2022-07-13T10:23:36+08:00
lastmod: 2022-07-13T02:55:02.746Z
draft: false
tags:
  - CLI
  - ffmpeg
categories:
  - 实用软件

featuredImage: ""
featuredImagePreview: ""

lightgallery: false
---

使用下面的指令将原始 m3u8 视频流原封不动的保存至 MKV 容器中，供后续处理。

```cmd
ffmpeg -i <指向m3u8文件的URL> -c copy <输出文件名>.mkv
```
