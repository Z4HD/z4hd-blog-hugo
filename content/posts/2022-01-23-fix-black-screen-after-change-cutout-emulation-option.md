---
title: 拯救因开启刘海屏模拟而黑屏的手机
date: 2022-01-23T10:10:42.000Z
lastmod: 2022-04-30T06:11:27.665Z
draft: false
tags: []
categories:
  - 手机
featuredImagePreview: images/cutout-overlay-list.png
---

{{< admonition danger >}}
不当操作可能对您的设备和数据造成不可逆的损害。
{{< /admonition >}}

某日心血来潮，拿着刚刷入 Android12 的 OnePlus 5T，在 开发者选项->刘海屏 中随便点了一个，想着体验一下所谓“刘海屏”到底有多么的丑陋。手机卡顿了一下，屏幕一黑，再就没有亮起。

<!--more-->

强制重启后，开机动画一过，立马黑屏。好在 [DerpFest](https://derpfest.org/) 自带的 FPS Overlay 仍然倔强的显示在屏幕的左上角，长按电源键有震动，提醒我系统还是在工作的，只是因为模拟刘海屏的原因无法正常的显示出来而已。只要能关闭模拟刘海屏，便能恢复正常显示。

根据上述症状，确定解决问题的思路：通过外部手段关闭模拟刘海屏。有三种实现方式：

- 使用ADB在线关闭模拟刘海屏
- 使用 TWRP Recovery 离线访问系统文件，关闭模拟刘海屏
- 双清（所有数据灰飞烟灭）

## 0x00 进入 ADB Shell

由于之前通过ADB连接电脑时勾选了“一律允许此计算机进行调试”，用USB连上电脑后立刻就在 `adb devices` 中看到了处于 `device` 状态的手机。

{{< admonition question "无法通过ADB连接到电脑，怎么办？" true >}}
很遗憾，即使已经在开发者选项中开启了 ADB 调试，但没有使用勾选过“一律允许此计算机进行调试”的电脑进行连接，需要在手机屏幕上**手动点击**确定，否则设备将处于无法通过ADB进行操作的 `unauthorized` 状态。

对于无法自动连接的状况，只能另寻他法。
{{< /admonition >}}

***立即快进***到交互式 ADB Shell!

```shell
adb shell
```

## 0x01 通过 ADB Shell 关闭模拟刘海屏

{{< admonition info >}}
本节中所有命令在 ADB Shell 中运行。对于 OnePlus 5T，终端提示符形如：`dumpling:/ $`
{{< /admonition >}}

起初使用 `settings list`, 在三大名字空间中 `{system, secure, global}` 苦苦寻找，也没有找到带 `cutout` 字眼的设置项。部分机型可通过此方式找到掌管模拟刘海屏的设置项。[^1]

后来根据 Reference 中所述方法，通过禁用用于模拟刘海屏的叠加层 (Overlay) 来使模拟刘海屏的设置无效化。使用下列命令筛选需要禁用的叠加层:

```shell
cmd overlay list | grep cutout
```

{{< image src="images/cutout-overlay-list.png" caption="找到需要禁用的 Overlay" >}}

`[x]` 开头的行就是当前已启用的用于模拟刘海屏的叠加层，本例中为 `com.android.internal.display.cutout.emulation.wide`，使用下列指令禁用之。

```shell
cmd overlay disable <PACKAGE_NAME>
```

按下回车后手机当场起死回生，恢复了正常的显示。

## 0x02 其他理论上的方法

### TWRP

{{< admonition warning >}}
该方法未经实践检验。
{{< /admonition >}}

进入 TWRP 后挂在 `system` 和/或 `vendor`，进入下列路径之一（如果有）

- `/system/system/product/overlay`
- `/vendor/overlay`

搜索并删除一切和 `cutout` 有关的内容。

### 双清

{{< admonition failure "寄" >}}
寄
{{< /admonition >}}

又称恢复出厂设置，丢失几十个GB的数据，几分钟后又是一台好机。

## Reference

- [Warning - do not change Display cutout in Developer Settings!](https://www.reddit.com/r/Xiaomi/comments/iskxed) - Reddit

[^1]: [u/Allen_cl's replay](https://www.reddit.com/r/Xiaomi/comments/iskxed/comment/g5couwa) - Reddit
