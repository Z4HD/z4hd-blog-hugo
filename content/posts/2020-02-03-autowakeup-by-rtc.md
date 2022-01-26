---
title: ASUS 笔记本使用 RTC Clock 设置 GNU/Linux 系统的自动开机
date: 2020-02-03T00:00:00.000Z
categories:
    - 运维
draft: false
toc:
    enable: true
tags:
    - GNU/Linux
    - Ubuntu
---

本文以 ASUS K42Jv 笔记本为例，主要介绍在 GNU/Linux 系统中设置自动开机的一种方法，内容偏重于实际操作，关于 RTC Clock 的原理则一笔带过，并不再赘述*自动开机是什么为什么要自动开机自动开机在哪里*等尽人皆知的话题。

部分文章[^1]认为 RTC Clock 唤醒是一种落后的技术，且不可靠。本文不探讨唤醒方式是否可靠的问题，劳烦读者自行试验。

## 什么情况下可以使用 RTC Clock 来实现自动开机？

1. 无法通过 BIOS 设置界面配置自动开机。
2. 不具备配置 Wake on LAN 的条件（比如无网络连接，各种原因无发送唤醒数据包等情况）
3. 主板支持 RTC Clock

## 我的电脑支持 RTC Clock Wakeup 吗？

查看内核日志，不同发行版的操作可能略有不同。

```shell
# Ubuntu
grep -i rtc /var/log/kern.log

# Ubuntu with systemd
sudo journalctl | grep rtc
```

应该有类似下方的输出。

```log
rtc_cmos 00:03: RTC can wake from S4
...
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
```

{{< admonition tip "亲自测试是否支持 RTC Clock Wakeup" false >}}
俗话说实践是检验真理的唯一标准，我们通过一个简单的小脚本来测试你的电脑是否能够通过 RTC Clock 自动唤醒。记得使用 ROOT 权限执行。

```shell
#!/bin/bash
# RUN AS ROOT!
echo 0 > /sys/class/rtc/rtc0/wakealarm
echo +180 > /sys/class/rtc/rtc0/wakealarm
poweroff
```

如果一切顺利，你的电脑将在3分钟（*180秒*）后自动开机。

如果你的电脑没有按照预期开机，不妨试试把 `+180` 修改为 `$(date '+%s' -d '+ 3 minutes')`，即传入**需要自动开机时间**的时间戳。

{{< /admonition >}}

## 利用 RTC Clock 配置自动开机

### 准备工作：关闭硬件时钟更新（可选）

{{< admonition warning >}}
目前尚不清楚在关机时系统对硬件时钟进行更新是否会对自动唤醒产生影响。如需尝试关闭，可参考[Disable hwclock updates](https://www.mythtv.org/wiki/ACPI_Wakeup#Disable_hwclock_updates)。
{{< /admonition >}}

本文所使用案例之 BIOS 时钟设置为本地时区时间而非UTC时间。

### 检查自动开机状态

执行以下命令获取当前RTC时钟的详细信息。

```shell
cat /proc/driver/rtc
```

输出示例如下

```log
rtc_time        : 22:17:23
rtc_date        : 2021-01-30
alrm_time       : 17:24:15
alrm_date       : 2021-01-31
alarm_IRQ       : no
alrm_pending    : no
update IRQ enabled      : no
periodic IRQ enabled    : no
periodic IRQ frequency  : 1024
max user IRQ frequency  : 64
24hr            : yes
periodic_IRQ    : no
update_IRQ      : no
HPET_emulated   : no
BCD             : yes
DST_enable      : no
periodic_freq   : 1024
batt_status     : okay
```

| 名称 | 值 | 说明 |
|:----|:----|:----|
| `rtc_time` | hh:mm:ss | RTC时间（硬件时钟/CMOS时间） |
| `rtc_data` | yyyy-mm-dd | RTC日期（硬件时钟/CMOS日期） |
| `alrm_time` | hh:mm:ss | 自动开机时间 |
| `alrm_date` | yyyy-mm-dd | 自动开机日期 |
| `alarm_IRQ` |   yes/no   | 指示是否设置了自动开机 |

### 手动设置自动开机

```shell
echo +$wakeup_time > /sys/class/rtc/rtc0/wakealarm
```

`$wakeup_time` 的数值与格式根据不同的主板可能略有差异。在*Linux.com上的某篇[^2]教程*中为需要自动开机时间的时间戳且开头没有`+`，但在部分 ASUS[^3] 笔记本上必须传入**需要自动开机的时间**与**当前时间**的时间戳之差（*也可以理解为经过指定秒数后自动开机*）才能成功设置自动开机。

执行完该设置指令后无任何回显，需要检查 `alarm_IRQ` 的值是否为 `yes` 来判断设置是否成功。

如果传入的 `wakeup_time` 值为0，则取消之前设置的自动开机时间。

### 使用 Shell 脚本

使用 Bash 脚本将时间换算为秒的工作交给计算机完成。下列例子借助 `date` 将用户输入的时间与当前时间做差，并将结果换算为秒数，最终传递给 `/sys/class/rtc/rtc0/wakealarm`。

{{< admonition info >}}
脚本可能需要根据实际情况进行修改。下方脚本仅供示例，在 `ASUS K42jv` with `Ubuntu 18.04` 上测试可用。
{{< /admonition >}}

```Shell
#!/bin/bash
# RUN AS ROOT!

read -p "输入自动开机时间:" d1
t1=$(date "+%s")
t2=$(date -d "$d1" "+%s")

t3=$(($t2-$t1))

echo $t3

echo +$t3 > /sys/class/rtc/rtc0/wakealarm
cat /proc/driver/rtc
```

## 参考文献和注释

- [ACPI Wakeup](https://www.mythtv.org/wiki/ACPI_Wakeup) - MythTV Official Wiki

[^1]: [Wake up and Shut Down Linux Automatically](https://www.linux.com/topic/networking/wake-and-shut-down-linux-automatically/) - Linux.com
[^2]: [Wake Up Linux With an RTC Alarm Clock](https://www.linux.com/training-tutorials/wake-linux-rtc-alarm-clock/) - Linux.com
[^3]: [Bug 12013](https://bugzilla.kernel.org/show_bug.cgi?id=12013#c38) - /sys/class/rtc/rtc0/wakealarm doesn't work, while /proc/acpi/alarm works - Asus P2-M2A690G
