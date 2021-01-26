---
title: 配置 Visual Studio Code 作为 Git 默认合并工具和对比工具
date: 2021-01-23T07:32:43Z
lastmod: 2021-01-23T07:32:43Z
draft: false
tags:
    - git
    - Visual Studio Code
categories: 
    - 未分类
featuredImage: ""
lightgallery: false
---

将下列内容添加到 `.gitconfig` 中

```ini
# Comment: Start of "Extra Block"
# Comment: This is to unlock Visual Studio Code as your Git diff and Git merge tool
[merge]
    tool = vscode
[mergetool "vscode"]
    cmd = code --wait $MERGED
[diff]
    tool = vscode
[difftool "vscode"]
    cmd = code --wait --diff $LOCAL $REMOTE
# Comment: End of "Extra Block"
```

## 参考文献

[How to use Visual Studio Code as the default editor for Git MergeTool](https://stackoverflow.com/questions/44549733/how-to-use-visual-studio-code-as-the-default-editor-for-git-mergetool) - Stack Overflow
