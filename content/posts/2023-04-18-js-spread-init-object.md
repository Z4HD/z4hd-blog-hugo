---
title: 使用ES2018中的展开语法为对象设置默认值
date: 2023-04-18T10:43:30+08:00
lastmod: 2023-04-18T05:15:30.793Z
draft: false
tags:
  - JavaScript
categories:
  - 代码
featuredImagePreview: ""
lightgallery: false
toc:
  enable: false
---

使用展开语法合并对象，实现优雅的为对象属性赋默认值。

<!--more-->

## 引言

思考下面这个函数，它接受一个对象，并取出其中的属性做一些操作。

```javascript
function dataProcessor(data){
  console.log(data.a);
  console.log(data.b);
  console.log(data.c);
}

dataProcessor({a:1,b:2,c:3});
/*
> "1"
> "2"
> "3"
*/
```

如果传入的对象没有包含所有的属性，那么没有赋值的属性会输出 `undefined`。

```javascript
dataProcessor({a:1});
/*
> "1"
> undefined
> undefined
*/
```

比较经典的思维是使用 `if` 判断是否存在属性，但如果对象存在很多的成员，一个一个去判断不现实，而且大量的 `if` 会使得代码难以维护。

```javascript
function dataProcessor(data){
  // 默认值
  if(!data.a) data.a=0;
  if(!data.b) data.b=0;
  if(!data.c) data.c=0;
  // 处理
  console.log(data.a);
  console.log(data.b);
  console.log(data.c);
}
```

## 使用展开语法合并对象

下面的代码定义一个模板对象，其中包含所有的属性及其默认值，然后使用展开语法构建对象字面量，用 `data` 中的属性值覆盖模板 `template` 中的同名属性。

```javascript
function dataProcessor(data){
  // 默认值
  const template = {a:0,b:0,c:0};
  data = {...template, ...data};
  // 处理
  console.log(data.a);
  console.log(data.b);
  console.log(data.c);
}

dataProcessor({a:1});
/*
> 1
> 0
> 0
*/
```

上述方法具备语法简洁、易于维护且能够在不修改已有函数调用的前提下增加对象属性的优点。但仍具备一定的局限性：

1. 如果需要在对象的某个属性不存在时执行赋默认值之外的操作，仍需在展开前使用 `if` 判断。
2. 如果需要删除某个属性，仍然建议对代码库进行清理以避免非预期的行为。

也可以将其封装为函数。

```javascript
function setDefault(data){
  const template = {a:0,b:0,c:0};
  return {...template, ...data};
}
```

## Reference

1. [展开语法](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/Spread_syntax) - MDN
2. [Svelte Quick Tip: Creating a toast notification system](https://dev.to/danawoodman/svelte-quick-tip-creating-a-toast-notification-system-ge3) - DEV Community
