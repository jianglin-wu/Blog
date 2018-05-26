---
title: 前端应用如何指定编译环境与运行环境？
date: 2018-04-25 14:03:00
categories: 前端
tags:
- 编译打包
---

## 开始之前
**运行环境指的是什么？**
问题的答案相当宽泛，但在前端应用中大多指 `JavaScript` 的执行上下文，在代码执行的时候需要知道当前处于哪种状态？当前能做什么？应该做什么？

**代码运行中会遇到哪些环境？**
客观上的不同（实现上的）：
* 执行环境(静态编译和运行配置文件的 Node 环境、执行页面渲染和交互逻辑的浏览器环境)。
* 操作系统(Linux/Windows/Mac OS/Android/IOS)。
* 浏览器(MS/FF/GC)。
* 设备(Mobile/Pad/PC)。
* 分辨率(720/1080/2K/4K/5K)
* 以及各平台的版本。

主观上的不同（意识上的，需人为的去定义的环境）：
1. 本地开发环境：编译代码到内存、启动本地 `Server` 和 `Mock` 数据、生成 `map` 文件、监听文件修改热更新。
2. 线上生产环境：对代码压缩混淆，去除注释，去除警告，生成文件到本地目录。
3. 测试环境：与线上环境高度一致，但使用的是测试数据。
4. DEBUG 模式：如：生产环境与测试环境开启调试模式时生成 map 文件进行线上调试，开发环境下打开调试模式时连接后端调试服务器。


**为什么要人为的定义不同的运行环境？**
1. 服务器地址不同：测试服务器，线上服务器，以及后端开发人员的开发服务器(后端找不到 BUG 的时候用[严肃脸])。
2. 地址跳转：单点登录跳转登录页。
2. 静态文件使用 CDN 的应用：静态文件基本路径在开发环境是“/”、测试和生产环境是“https://www.cdn.com/”。
3. 第三方接入：如第三方聊天的 SDK 需要使用一些 key 鉴权，应该对 key 进行区分，否则会造成在测试环境的消息发送到生产环境中。
4. 线上为 HTTPS 协议：并不是所有情况下都能通过 `//:` 方式获取资源，所以还是有必要区分该用 `http://` 还是 `https//`。
5. 前端监控：记录应用运行报错是在生产环境出现的还是测试环境出现的，或者仅仅只是在生产环境才进行监控。
6. 部分新功能只对测试和开发环境开放：对于还不稳定的功能在生产环境打包时忽略或隐藏入口。



## 准备开始
**了解环境变量的用法**
定义：
```bash
# Linux/Mac OS
$ NODE_ENV=production
# Windows
$ set NODE_ENV=production
# NodeJS
> process.env.NODE_ENV=production
```

取值：
```bash
# Linux/Mac OS: `$PATH` 或 `${PATH}`
$ echo $PATH
# Windows: `%PATH%`
$ echo %PATH%
# NodeJS: process.env.PATH
> console.log(process.env.PATH)
```

cross-env: 能够跨平台设置环境变量。
```bash
# 安装
$ npm install -g cross-env
# 使用: 行首添加 cross-env 就可以了，多个变量用空格隔开。
$ cross-env NODE_ENV=production node app.js。
$ cross-env NODE_ENV=production DEBUG=true
```

注意: `cross-env` 定义的变量生命周期仅在同一条命令中有效，使用 `&&` 或 `;` 合并的命令无法读取到变量。关于合并命令：类 Unix 系统支持 `&&` 与 `;`，windows 仅支持 `&&`，为了更好的兼容性应优先使用 `&&`。
```bash
# 使用 `&&` 或 `;` 合并的命令无法读取到变量
$ cross-env NODE_ENV=production && node app.js
# or
$ cross-env NODE_ENV=production; node app.js

# 正确的方式使用空格隔开
$ cross-env NODE_ENV=production node app.js
```


**了解 npm script 的用法：**
`npm` 支持将命令行写到 `package.json` 的 `script` 中，使用 `npm run [属性名]` 即可运行对应的命令。
```javascript
{
  // ...
  "scripts": {
    "start": "node server.js",
  },
  // ...
}
```
参考阮一峰[《npm script 使用指南》](http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html)



## 开始配置
**应用的运行环境：**
根据实际情况整理出应用的几种运行环境，对每个环境命名，让应用配置更加易懂思想明确。
1. 开发环境
1. 测试环境
1. 回归测试、UI测试环境
1. 预上线环境
1. 生产环境

**调试模式：**
对每个环境支持是否处于调试模式，调试模式时处于当前环境的项目可以根据需要进行配置。

**使用变量去表示：**
* `NODE_ENV`：已存在的，仅存在 `development` 和 `production` 两种值。
* `NODE_STAGE`：自定义的，可以配置为任何字符串，可约定为 `w0`、`w1`、`w2` 三种值，默认为 `undefined`。
* `DEBUG`：自定义的，可配置为 `true` 或 `false`，值也可以是接口服务器 `URL`，默认为 `undefined`。

**定义环境变量到编译环境：**
```bash
# Roadhog：
$ cross-env DISABLE_ESLINT=true roadhog dev
# Webpack:
$ cross-env DISABLE_ESLINT=true DEBUG=true webpack
```

**获取环境变量并定义全局常量到运行环境：**
Roadhog: `@1.x` 版本及以前对 `roadhogrc.js` 文件配置，`@2.x` 版本及之后对 `.webpackrc.js` 文件配置，为 [define](https://github.com/sorrycc/roadhog/blob/master/README_zh-cn.md#define) 配置参数 。
```javascript
export default {
  // ...
  "define": {
    "process.env.NODE_ENV": process.env.NODE_ENV,
    "process.env.DEBUG": process.env.DEBUG,
    "process.env.NODE_STAGE": process.env.NODE_STAGE,
  },
  // ...
}
```

Webpack: 在 `plugins` 中加入 [DefinePlugin](https://doc.webpack-china.org/plugins/define-plugin/) 配置。
```javascript
plugins: [
  new webpack.DefinePlugin({
    "process.env.NODE_ENV": process.env.NODE_ENV,
    "process.env.DEBUG": process.env.DEBUG,
    "process.env.NODE_STAGE": process.env.NODE_STAGE,
  })
]
```

**使用全局常量**
全局常量在编译时就已经替换到生成的文件中了，运行环境直接可以读取替换的值。
```javascript
const debug = process.env.DEBUG;
const nodeStage = process.env.NODE_STAGE;
const nodeEnv = process.env.NODE_ENV;
// 根据常量获取当前环境名称
const ENV_NAME = debug ? 'debug' : (nodeStage || nodeEnv);

// 每个环境的不同值
const apiUrls = {
  debug: debug || '',
  development: 'http://api-0.xxx.com/',
  w0: 'https://api-0.xxx.com/',
  w1: 'https://api-1.xxx.com/',
  w2: 'https://api-2.xxx.com/',
  production: 'https://api.xxx.com/',
};

// 获取当前环境对应的值
export const API_URL = apiUrls[ENV_NAME];
```


**设置命令别名**
```javascript
{
  // ...
  "scripts": {
    "start": "cross-env roadhog dev",
    "start:no-proxy": "cross-env NO_PROXY=true roadhog dev",
    "build": "roadhog build",
    "build:w0": "cross-env NODE_STAGE=w0 roadhog build",
    "build:w1": "cross-env NODE_STAGE=w1 roadhog build",
    "build:w2": "cross-env NODE_STAGE=w2 roadhog build",
    // "start:debug": "cross-env DEBUG=http://192.168.16.166:19006/ npm run start",
  },
  // ...
}
```

**如何使用**
使用 npm script 直接运行命令，内部实现是对几个环境变量设置不同的值，对值进行判断区分，可以无限扩展值与命令。
```bash
# 开发环境
$ npm run start
# 开发环境调试
$ cross-env DEBUG=http://127.0.0.1:9090/ npm run start
# 测试环境
$ npm run build:wo
# 回归测试、UI测试环境
$ npm run build:wo
# 预上线环境
$ npm run build:wo
# 生产环境
$ npm run build
```

**保持原则**
配置集中化，各环境数据尽量一致。否则可能会导致不同的环境使用不同的数据，单从测试环境无法进行全面的测试。



## 相关实践
**生成动态内容 HTML 文件（Roadhog 配置）**
说明：生成用于控制用户权限的 `refresh.html` 文件，跳转到服务器接口鉴权。

配置：添加 `webpack.config.js` 文件，为 `webpackConfig.plugins` 添加 [HtmlWebpackPlugin](https://github.com/jantimon/html-webpack-plugin) 实例化内容，根据环境变量获取当前环境重定向地址。
```javascript
const HtmlWebpackPlugin = require('html-webpack-plugin');
const constant = require('./src/common/constant');

module.exports = function (webpackConfig, env) {
  if (Array.isArray(webpackConfig.plugins)) {
    webpackConfig.plugins.push(new HtmlWebpackPlugin({
      title: 'App',
      filename: 'refresh.html',
      template: './src/index.ejs',
      inject: false,
      refresh: `0; url=${constant.REDIRECT}`,
    }));
  }
  return webpackConfig;
}
```

模板： 修改 `./src/index.ejs` 文件。
```htmlbars
  <!-- ... -->
  <% if (htmlWebpackPlugin.options.refresh) { %>
  <meta http-equiv="refresh" content="<%= htmlWebpackPlugin.options.refresh %>">
  <% } %>
  <title><%= htmlWebpackPlugin.options.title %></title>
  <!-- ... -->
```


编译之后：生成 `refresh.html` 文件，跳转地址为当前指定环境的对应的服务器地址。
```html
  <!-- ... -->
  <meta http-equiv="refresh" content="0; url=https://api.xxx.com/jump?toUrl=https://xxx.com/index.html">
  <title>App</title>
  <!-- ... -->
```

**正确的获取当前地址，以及用浏览器正确的打开该地址（Roadhog 配置）:**
说明：这个实践与环境变量没有多大关联，但对这个功能有需求的人也不少所以写下来。很多工具都支持自动从浏览器打开当前应用，但是都是 `localhost`，当移动设备或其他 PC 打开则需要输入本地 IP 地址才能打开。如果应用中做了登录验证的跳转操作，使用 IP 访问设备很有可能跳转到登录或登录成功后跳转的是自己设备的 `localhost` 地址，会导致页面无法打开。

获取主机地址：当编译环境获取主机地址时获取当前 IP 地址，当在运行环境中获取主机地址时获取 `location.hostname` 地址。由于配置文件同时在 Node 环境与浏览器环境使用，并且期望不同环境获取值的方式不同，这个用到 `UMD` 加载方式根据环境取值。
```javascript
let host = 'localhost';
(() => {
  if (typeof exports === 'object') {
    /* eslint-disable */
    const os = require('os');
    /* eslint-enable */
    const ifaces = os.networkInterfaces();
    Object.keys(ifaces).forEach((keyName) => {
      ifaces[keyName].forEach(({ family, internal, address }) => {
        if (family === 'IPv4' && !internal) {
          host = address;
        }
      });
    });
  } else {
    host = global.location.hostname;
  }
})();
console.log('host:', host);
```

关闭默认打开浏览器：为 `BROWSER` 环境变量传入 `none` 参数即可关闭自动打开浏览器。
```bash
$ cross-env DISABLE_ESLINT=true BROWSER=none roadhog dev
```

配置：添加或修改 `webpack.config.js` 文件，为 `webpackConfig.plugins` 添加 [OpenBrowserPlugin](https://github.com/baldore/open-browser-webpack-plugin) 插件实例化内容，传入获取的当前主机地址。
```javascript
const OpenBrowserPlugin = require('open-browser-webpack-plugin');
const constant = require('./src/common/constant');

module.exports = function (webpackConfig, env) {
  if (Array.isArray(webpackConfig.plugins)) {
    webpackConfig.plugins.push(new OpenBrowserPlugin({
      url: constant.HOST_URL,
    }));
  }
  return webpackConfig;
}
```


## 最后
希望本文的内容能对你有所价值，如有问题或指教欢迎在评论中指出。
作者： 吴江林
日期： 2018年4月28日
（完）
