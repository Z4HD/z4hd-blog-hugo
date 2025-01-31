---
title: 防止后台运行的 podman 容器在当前用户退出SSH后离奇死亡
subtitle: ""
date: 2024-05-17T14:14:46+08:00
lastmod: 2025-01-31T15:25:39.666Z
draft: false
tags:
    - GNU/Linux
categories:
    - 运维
featuredImagePreview: images/systemd-user-logind-status.png
lightgallery: true
toc:
    enable: true
---

## 现象

使用 `podman-compose up -d` 启动容器后，容器在后台运行正常。但关闭SSH连接一段时间后（通常1h内）全部容器停止运行，退出代码（Exit Code）为0，代表容器被正常停止。

使用 `podman-compose logs` 查看日志，发现容器内的进程因接收到 `SIGTERM` 信号而正常停止。

由于 `docker-compose.yaml` 中已设置 `restart: unless-stopped`，容器只有被手动停止时不会自行重启，佐证了容器被正常停止的判断。

如果用户**保持登录**，则容器不会停止。

## 原因

{{< admonition tip true >}}
发现容器死了，应排查发送 `SIGTERM` 信号的凶手。仅设置保活治标不治本。
{{</admonition>}}

根据“用户不退出，容器不停止”的特点进行搜索，发现幕后真凶是 systemd 于 v230 版本引入的一项更改导致。

v230 版本将 `KillUserProcesses=` 的默认值由 `no` 变更为 `yes`，使得默认情况下 systemd 会在用户完全退出登录时，杀死用户名下的所有进程。

> 查看关于此更改的描述（英文原文）：[CHANGES WITH 230](https://github.com/systemd/systemd/blob/76153ad45f09b6ae45464f2e03d3afefbb4b2afe/NEWS#L274)

由于使用 podman 运行的 rootless 容器在 systemd 中属于当前用户名下的进程，因此不幸躺枪。

## 解决方案

下列解决方案任选其一。

### 启用 Lingering

```shell
loginctl enable-linger
```

{{< image src="images/systemd-user-logind-status.png" caption="loginctl user-status" >}}

{{< admonition note "检查当前用户是否启用 lingering？" true >}}

```shell
loginctl user-status
```

如有 `Linger: yes` ，说明当前用户已启用 lingering。
{{</admonition>}}

> 其他方法参考：[systemd - loginctl enable-linger/disable-linger ... but reading linger-status? - Server Fault](https://serverfault.com/questions/846441)

### 手动指定 systemd 的行为

编辑 `/etc/systemd/logind.conf`

```conf
KillUserProcesses=no
```

### tmux 保活

{{< admonition failure "不推荐此方法" false >}}
保持一个当前用户的 tmux session 在后台，可以临时缓解该问题。
{{</admonition>}}

## Reference

- Github Issue: [rootless podman containers stop after logging out / disconnecting ssh session](https://github.com/containers/podman/issues/12001)
- Systemd NEWS: [CHANGES WITH 230](https://github.com/systemd/systemd/blob/76153ad45f09b6ae45464f2e03d3afefbb4b2afe/NEWS#L274)
