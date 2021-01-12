---
title: 自用倒计时js脚本
categories:
  - 代码
date: 2017-07-25T11:38:15.000Z
description: 从jb51.net上抄的脚本，本人对其略加改造。
---

从[jb51.net](http://jb51.net/)上抄的脚本，本人对其略加改造。

<!--more-->

``` javascript
function getRTime(CustomTime,Tid){
 var EndTime= new Date(CustomTime);
 var NowTime = new Date();
 var t =EndTime.getTime() - NowTime.getTime();
 var d=0;
 var h=0;
 var m=0;
 var s=0;
 var text;
  if(t>=0){
    d=Math.floor(t/1000/60/60/24)
    h=Math.floor(t/1000/60/60%24);
    m=Math.floor(t/1000/60%60);
    s=Math.floor(t/1000%60);
  }
/*总写入*/
 text = d + "天&nbsp;" + h + "小时&nbsp;" + m + "分钟&nbsp;" + s + "秒";
 document.getElementById(Tid).innerHTML=text;
 var ff="getRTime('"+CustomTime+"','"+Tid+"')"
 setTimeout(ff,1000)
}
```

### 使用方法

在文档加载完成后调用一次```GetRTime（yourCustomTime，DisplayElementID）```函数即可。

参数1为目标时间，格式推荐```YY/MM/DD hh:mm:ss```或者其他可被```Date```对象接受的格式；参数2为展示倒计时内容的HTML标签的ID。

### 演示

``` html
距离2017年暑假还有：<span id="HT" style="color:red;"></span>
```

``` js
GetRTime('2017/7/14','HT');
```

距离2020年全面小康还有：<span id="HT" style="color:red;"></span>

<script>
function GetRTime(CustomTime,Tid){
 var EndTime= new Date(CustomTime);
 var NowTime = new Date();
 var t =EndTime.getTime() - NowTime.getTime();
 var d=0;
 var h=0;
 var m=0;
 var s=0;
 var text;
  if(t>=0){
    d=Math.floor(t/1000/60/60/24)
    h=Math.floor(t/1000/60/60%24);
    m=Math.floor(t/1000/60%60);
    s=Math.floor(t/1000%60);
  }
/*总写入*/
 text = d + "天&nbsp;" + h + "小时&nbsp;" + m + "分钟&nbsp;" + s + "秒";
 document.getElementById(Tid).innerHTML=text;

 var ff="GetRTime('"+CustomTime+"','"+Tid+"')"
 setTimeout(ff,1000)
}
GetRTime('2020/1/1','HT');
</script>
