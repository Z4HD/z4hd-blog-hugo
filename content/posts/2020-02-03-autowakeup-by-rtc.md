---
title: ASUS 笔记本使用 RTC Clock 设置 GNU/Linux 系统的自动开机
date: 2020-02-03
categories: 
    - 运维
draft: true
---

本文主要介绍在 GNU/Linux 系统中设置自动开机的一种方法，内容偏重于实际操作，关于 RTC Clock 的原理则一笔带过，并不再赘述*自动开机是什么为什么要自动开机自动开机在哪里*等尽人皆知的话题。

## RTC Clock 是什么？

我也讲不明白，总之是一种过时但好用的技术。

## 我的电脑支持 RTC Clock 吗？

## 利用 RTC Clock 配置自动开机

### 检查自动开机状态

```shell
cat /proc/driver/rtc
```

| 名称 | 值 | 说明 |
|:----:|:----:|:----:|
|   `Alarm_IRQ`   |   yes/no   |    指示是否设置了自动开机  |
|      |      |      |
|      |      |      |

### 设置自动开机

```shell
echo $wakeup_time > /sys/class/rtc/rtc0/wakealarm
```

`wakeup_time` 在*Linux.com上的某篇教程*中为需要自动开机时间的时间戳，但在部分 ASUS 笔记本上必须传入**需要自动开机的时间**与**当前时间**的时间戳之差*（也可以理解为经过指定秒数后自动开机）*才能成功设置自动开机。

执行完该设置指令后无任何回显，需要检查 `alarm_IRQ` 的值是否为 `yes` 来判断设置是否成功。

如果传入的 `wakeup_time` 值为0，则取消之前设置的自动开机时间。

## 参考文献

- [Bug 12013](https://bugzilla.kernel.org/show_bug.cgi?id=12013#c38) - /sys/class/rtc/rtc0/wakealarm doesn't work, while /proc/acpi/alarm works - Asus P2-M2A690G
