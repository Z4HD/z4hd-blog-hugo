---
title: 通过 ffmpeg 重新编码解决 Premiere Pro 导入可变帧速率视频后音画不同步的问题
subtitle: ""
date: 2022-04-30T13:40:43+08:00
lastmod: 2022-04-30T06:13:35.729Z
draft: false
tags:
  - Premiere Pro
  - ffmpeg
categories:
  - 音频视频

lightgallery: false
---

## 现象

1. 视频后半段明显的音画不同步
2. 预览窗口中，当前位置波形与实际播放的声音内容不能对应

## 产生原因

是由于视频采用了可变帧速率（VFR）技术而Pr对此支持并不完美所导致的。虽然自 Pr CC 2018 后，Pr本身已经对VFR有了一定的支持，但导入个别VFR视频仍然会产生音画不同步的现象。

## 解决方案

使用 FFmpeg 将 VFR 视频转换为 CFR，并使用 `-af aresample=async=1000` 对音频进行重采样，确保音画同步。

### 关键参数

1. 位于 `-i` 前的 `-vsync cfr`
2. 位于 `-i` 后的 `-af aresample=async=1000`

### 示例：硬件加速编码 NVENC

推荐在安装有 NVIDIA 显卡时优先采用。

```shell
ffmpeg -vsync cfr -i <输入视频> -pix_fmt yuv420p -r <目标帧率> -c:v h264_nvenc -b:v <视频码率> -af aresample=async=1000 -b:a <音频码率> <输出文件名>.mp4
```
