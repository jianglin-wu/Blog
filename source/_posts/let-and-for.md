---
title: "我理解的 let 变量定义与 for 循环"
date: "2019-07-18 17:26:00"
categories: 前端
tags:
- 原理与基础
photos:
- https://image-cdn.hahhub.com/images/2019/08/04/284ec7189d50dd3283fe361053b32c9d.jpg
---

## 前言

今天看了下面两篇文章收获蛮大，然后对 let 与 for 也有了一些自己的理解，下面来仔细说说。

* [JS变量生命周期:为什么 let 没有被提升](https://juejin.im/post/5d2fb820e51d454f723025bb)
* [我用了两个月的时间才理解 let](https://zhuanlan.zhihu.com/p/28140450)

## 问题

先来个常见的异步场景，打印出来 5 个 `5` 数值。

```javascript
for (var i = 0; i < 5; i++) {
  i++;
  setTimeout(function() {
    console.log(i);
  }, 0);
}
// 5
// 5
// 5
// 5
// 5
```

而使用 let 定义的变量打印的结果却是 `0`、`1`、`2`、`3`、`4`。

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    console.log(i);
  }, 0);
}
// 0
// 1
// 2
// 3
// 4
```

## 先复习一下 for 循环知识

为了更好的理解代码执行，先来捋一下 for 循环执行的流程。

以下是一个简单的 for 循环，分别由 `for` 关键词、小括号、大括号组成。小括号由两个分号分割成三段，分别是初始化语句、条件语句、结束操作语句。大括号是具体任务的块级，拥有独立的作用域。

* 初始化语句: for 循环开始时执行，只会执行一次，接着执行条件语句。
* 条件语句: 循环任务的条件判断，表达式值为 `true` 就执行大括号块级任务，`false` 则结束循环。
* 结束操作语句: 每次块级任务执行完成后就会执行一次此结束语句，接着执行条件语句。


```
for (let i = 0; i < 5; i++) {
  console.log(i);
}
```

下面放张 for 循环流程图：

![](https://image-cdn.hahhub.com/images/2019/07/18/b7c192b0c817a4402fcadf131773757a.png)


## 来一步一步假设与验证

看到以上文档有的同学第一反应是：在异步引用 let 变量时内部就已经拿到那个值了。而实际上以下例子证明：let 声明的变量在异步中依旧只是一个引用。

```javascript
let i = 0;
setTimeout(function() {
  console.log(i);
}, 0);
i++;
// 1
```

接着我们来使用 let 来模拟一下 var 的行为。下面可以看出与使用 var 定义变量的区别就是把变量声明提升了。而造成这结果不一样的是 let 的作用域，那为什么 for 循环初始化语句中声明的变量就会和外部声明的变量不一样呢？

```javascript
let i = 0;
for (; i < 5; i++) {
  setTimeout(function() {
    console.log(i);
  }, 0);
}
// 5
// 5
// 5
// 5
// 5
```

在看完[《我用了两个月的时间才理解 let 》](https://zhuanlan.zhihu.com/p/28140450) 这篇文章后大概可以知道，for 循环中有个类似类似隐藏作用域这种操作。大概是对 i 变量进行重新声明赋值。

但通过以下示例看出 for 块级任务中的 `i` 变量，和 for 初始化语句中声明的 `i` 变量依旧是同一个内存地址。

```javascript
for (let i = 0; i < 5; i++) {
  i++;
  setTimeout(function() {
    console.log(i);
  }, 0);
}
// 1
// 3
// 5
```

接着尝试在异步中修改 i 变量，由此看出在不同次循环中的异步任务访问到的 i 变量不是在同一个内存地址。

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    i++;
    console.log(i);
  }, 0);
}
// 1
// 2
// 3
// 4
// 5
```

通过以下例子，可以看出一次循环中的多个异步任务访问的 i 变量是同一内存地址。

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    i++;
    console.log('1', i);
  }, 0);
  setTimeout(function() {
    i++;
    console.log('2', i);
  }, 0);
}
// '1', 1
// '2', 2
// '1', 2
// '2', 3
// '1', 3
// '2', 4
// '1', 4
// '2', 5
// '1', 5
// '2', 6
```

然后尝试在两段异步任务之间插入同步代码 `i++;`，发现循环只执行了三次，由此可以得出以下结论：

1. **同步任务中的 `i` 变量是和 for 初始化语句的 `i` 变量是同一内存地址**
1. **异步会保留当前这次循环下同步执行的最后结果，但又和其他次循环的 `i` 变量相隔离。**

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    i++;
    console.log('1', i);
  }, 0);
  i++;
  setTimeout(function() {
    i++;
    console.log('2', i);
  }, 0);
}
// '1', 2
// '2', 3
// '1', 4
// '2', 5
// '1', 6
// '2', 7
```

## 猜想

根据以上推断提出猜想：**当 for 循环初始化语句中声明了 let 变量，且在 for 循环块级任务中有异步函数引用了此变量时。js 引擎在 for 循环块级任务底部对该变量进行了一个复制操作，而异步任务引用的变量则是复制后的这个内存地址。**

当执行以下语句时：

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    console.log(i);
  }, 0);
}
```

实际上会对 `i` 变量增加一个复制操作，比如 js 引擎在底部插入 `let i = i;` 语句：

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    console.log(i);
  }, 0);
  let i = i; // js 引擎在底部自动插入
}
```

不过要注意上面这段代码无法正常执行，只是便于大家理解。无法执行的原因：for 循环块级任务代码中 let 声明 `i` 变量，在赋值之前尝试获取父级作用域 `i` 变量失败则抛出异常。

[《我用了两个月的时间才理解 let 》](https://zhuanlan.zhihu.com/p/28140450) 这篇文章也讲了变量的生命周期（created、initialized、assigned）。js 引擎在 for 循环块级任务一开始执行时就创建了这个 `i` 变量。**意味着在作用域任何位置一旦定义了这个变量，在这个作用域或子作用域就不可能访问到父级作用域这个同名的变量。** 而此时当前这个作用域的这个变量还没被初始化，最后访问一个没有为初始化的变量就直接抛出异常。

为了代码真正的可运行，并且尽可能准确，现在使用 var 来实现同样的功能。由于 var 在 for 循环中会变量提升，所以块级任务里会包裹一层 `iife` 自执行函数。

由于作用域中同一变量名不能定义变量的同时访问父级作用域的值，这里复制 `i` 变量的值就换个名字 `j`，然后让异步的函数来引用 `j` 这个变量。

```javascript
for (var i = 0; i < 5; i++) {
  (function() {
    setTimeout(function() {
      console.log(j);
    }, 0);
    var j = i;
  })();
}
// 0
// 1
// 2
// 3
// 4
```


## 证实猜想

这是在 for 循环中使用 `let` 定义变量，在块级任务中执行同步异步打印的结果。

```javascript
for (let i = 0; i < 5; i++) {
  setTimeout(function() {
    i++;
    console.log('1', i);
  }, 0);
  i++;
  setTimeout(function() {
    i++;
    console.log('2', i);
  }, 0);
}
// '1', 2
// '2', 3
// '1', 4
// '2', 5
// '1', 6
// '2', 7
```

接下来通过 var 来实现复制 `i` 变量，并让异步引用复制后的变量，最后打印出来的结果和上面一致：

```javascript
for (var i = 0; i < 5; i++) {
  (function() {
    setTimeout(function() {
      j++;
      console.log('1', j);
    }, 0);
    i++;
    setTimeout(function() {
      j++;
      console.log('2', j);
    }, 0);
    var j = i;
  })();
}
// '1', 2
// '2', 3
// '1', 4
// '2', 5
// '1', 6
// '2', 7
```
