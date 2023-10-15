---
title: Visual Studio Code 连接远程 Podman Dev Container
subtitle: ""
date: 2023-01-18T09:11:07+08:00
lastmod: 2023-10-15T03:44:25.776Z
draft: false
tags:
  - GNU/Linux
  - Visual Studio Code
  - Podman
categories:
  - 代码
  - 实用软件
featuredImagePreview: /images/vscr-architecture.png
lightgallery: true
toc:
  enable: true
---

使用 [Visual Studio Code](https://code.visualstudio.com/) 通过 SSH 连接远端服务器中使用 [Podman](https://podman.io/) 创建的 Dev Container。

具备如下优势：

- 本地除了 Visual Studio Code （含插件）和 SSH 之外无需安装任何开发依赖，避免污染本地环境。
- 除 `vscode-server` 之外一切开发依赖均位于容器之中，避免污染远端环境。
- 多谢 Podman 之 rootless 特性，服务器无需维持一个 root 权限的 Docker Deamon 长期运行，减少了可能的攻击面。
- 可将开发环境部署工作写入 `Dockerfile` 和  快速重建 Dev Container

劣势：

- 远端服务器和 Dev Container 中均会被安装 `.vscode-server`。
- 容器会常驻后台除非手动停止。

<!--more-->

## 名词解释

此处约定一些名词概念，作用域仅限本文。

- 本地（Local OS）：一台可以运行 Visual Studio Code，用于敲代码的电脑，比如你正在用的主力机。
- 远端（Remote OS）：一台可以通过SSH连接的远程服务器，用于开发环境，可能是NAS/VPS/老旧电脑...
- 开发容器（Dev Container）：用于安装开发环境的容器。感觉“开发容器”这词有点动词的味道，这里认为它是名词。
- VSC：**V**isual **S**tudio **C**ode

{{< admonition info "INFO" true >}}
`vscode-server` != [Visual Studio Code for the Web](https://code.visualstudio.com/docs/editor/vscode-web)
{{</admonition>}}

## 基本架构概述

千言万语不如一张图。

{{< mermaid >}}
graph LR;
    A(本地 VSCode) -->|SSH| B(服务端 vscode-server)
    B --> |服务端 Podman| D(Dev Container)
    D -->|端口转发| A
{{< /mermaid >}}

## 0x00 准备工作

### 本地准备

1. 安装VSC
2. 安装SSH，用于登录远端服务器的SSH密钥对不建议设置密码，防止VSC因为密码卡住。
3. 安装VSC插件：[Visual Studio Code Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) *此插件文档很详细，推荐阅读。*

不用WSL的可以选择卸载WSL插件或者手动安装 [Remote - SSH](https://aka.ms/vscode-remote/download/ssh) 和 [Dev Containers](https://aka.ms/vscode-remote/download/containers)

### 远端准备

1. 配置SSH
2. 安装 Podman (或者用之前装好的)
3. 足够的磁盘空间（个人建议20G+）

## 0x01 连接远端SSH

>阅读：[Remote Development using SSH](https://code.visualstudio.com/docs/remote/ssh)

完成上面的文档，我们已经有了一个SSH远程开发环境，此时可以在远端服务器中下载/克隆你的项目文件。

>阅读：[Alternate ways to install Docker - Podman](https://code.visualstudio.com/remote/advancedcontainers/docker-options#_podman)

根据上面的教程（英文）编辑插件设置，将`Containers: Docker Path`的值替换为 `podman`。完成后检查*远程资源管理器 -> Dev Container*，如能看到正在运行的 Podman 容器，则配置成功。

## 0x02 创建 devcontainer.json

{{< admonition tip "TIP" true >}}
本步建议在项目文件夹中进行。
{{</admonition>}}

>推荐阅读：[Create a Dev Container](https://code.visualstudio.com/docs/devcontainers/create-dev-container)

别被文档里密密麻麻的JSON吓到，创建 `devcontainer.json` 的最好办法是按F1选 **Dev Containers: Add Dev Container Configuration Files...**

Podman 作为一种别样的 rootless 容器工具，需要在 `devcontainer.json` 中附加额外的配置：

```json
"runArgs": [
  "--userns=keep-id"
],
"containerEnv": {
  "HOME": "/home/node"
}
```

上述设置可以避免VSC自动在开发容器中安装 `vscode-server` 时遇到 `mkdir: cannot create directory '/root': Permission denied`

不要忘了添加自己喜欢的VSC插件。此处指定的插件会在容器内安装 code server 时自动安装。

```json
"customizations": {
    "vscode": {
      "extensions": [
        "Gruntfuggly.todo-tree",
        "mhutchie.git-graph"
      ]
    }
  }
```

## 0x03 构建开发容器镜像

{{< admonition tip "TIP" true >}}
**容器构建尤其是首次构建必须在 Remote SSH 状态下进行**

开发容器镜像应根据你所用开发环境的实际需求进行构建，此处以使用恶臭 Node.js 的 Svelte Kit 前端项目为例。
{{</admonition>}}

根据实际开发环境需求编辑 `Dockerfile`，此处以一个典型的 Node.js 开发环境为例。包含最新版 `npm` 和 `cnmp`。

```Dockerfile
FROM node:18

# Install basic development tools
RUN apt update && apt install -y less man-db sudo

# Ensure default `node` user has access to `sudo`
ARG USERNAME=node
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Install cnpm (mainland network only)
RUN npm -g config set registry=https://registry.npmmirror.com \
    && npm install npm@latest -g \
    && npm install cnpm -g
```

## 0x04 进入开发容器

`F1` --> `Dev Containers: Reopen in Container`

## 参考文献

- [Replacing Docker with Podman for your VSCode DevContainers](https://blog.lifeishao.com/2021/12/30/replacing-docker-with-podman-for-your-vscode-devcontainers/) *点评：此文主要介绍在 Windows 下连接本地WSL中运行的 Podman 的步骤*
- Develop on a remote Docker host - [Connect using the Remote - SSH extension](https://code.visualstudio.com/remote/advancedcontainers/develop-remote-host#_connect-using-the-remote-ssh-extension-recommended) *点评：此VSC文档提供了推荐的连接远程 docker host 中 Dev Containers 的步骤*
- [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers) *点评：此VSC文档详细的介绍了 Dev Containers 的种种特性，__很长__，很详细。*