---
title: 让 Podman 容器具备访问 IPv6 网络的能力
date: 2024-03-02T14:25:57+08:00
lastmod: 2024-03-02T07:53:18.254Z
draft: false
tags:
    - GNU/Linux
    - Podman
categories:
    - 运维
featuredImagePreview: ""
lightgallery: true
toc:
    enable: true
---

由于 Podman 默认网络 `podman` 未启用 IPv6，因此默认情况下，容器仅具备访问 IPv4 网络的能力。

通过本文所述的方法可以让容器内运行的程序具备访问 IPv6 网络的能力。

<!--more-->

## 0x00 系统需求

- 宿主机（host）具备有效的IPv6地址，能够正常访问 IPv6 网络。
- Podman 4.0+
- Podman 网络堆栈已切换为 netavark [^1]

{{< admonition question "如何检查 Podman 当前正在使用何种网络堆栈？" false >}}
执行 `podman info | grep -i networkBackend`

检查输出为 `networkBackend: netavark`，证明 Podman 当前正在使用的网络堆栈为 netavark 。
{{< /admonition >}}

## 0x01 创建 IPv6 双栈网络

创建一个名称为 `podnetv6` 的用户定义网络，名称可以自定义，此处仅作示例。

```shell
podman network create --ipv6 podnetv6
```

## 0x02 将容器接入 IPv6 双栈网络

将网络连接至正在运行的容器。

```shell
podman network connect podnetv6 <CONTAINER NAME>
podman restart <CONTAINER NAME>
```

对于新运行的容器，可以直接使用 0x01 步中创建的 IPv6 双栈网络，而非默认的 IPv4 单栈网络 `podamn` 。

```shell
podman run --network podnetv6
```

{{< admonition note "注意" true >}}
如需通过 IPv6 地址访问容器，建议在执行 `podman network connect` 或 `podman run` 时添加 `--ip6` 为容器分配静态IPv6地址。

分配的静态地址应当位于所连接的网络的网段内。不知道虚拟网络的网段信息？请执行 `podman network inspect <NETWORK NAME>`
{{< /admonition >}}

## Reference

- [Podman 4.0's new network stack: What you need to know](https://www.redhat.com/sysadmin/podman-new-network-stack)
- [How to configure Podman 4.0 for IPv6](https://developers.redhat.com/articles/2022/08/10/how-conifgure-podman-40-ipv6) - Red Hat Developer
- [Configuring Networking for Podman](https://docs.oracle.com/en/operating-systems/oracle-linux/podman/podman-ConfiguringNetworkingforPodman.html) - Orcale Linux Podman User's Guide

[^1]: [将网络堆栈从 CNI 切换到 Netavark](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/proc_switching-the-network-stack-from-cni-to-netavark_assembly_setting-container-network-modes) - Red Hat Customer Portal
