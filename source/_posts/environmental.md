---
title: "为前端应用指定不同环境"
date: "2018-04-25 14:03:00"
categories: 前端
tags:
- 构建打包
- 环境变量
---

## 介绍

### 程序当中的环境指的是什么？

这答案很宽泛，影响代码执行上下文的因素都可以称为环境，在代码执行的时候需要知道当前处于哪种状态？当前能做什么？应该做什么？比如说下列环境的不同，可以会导致程序运行的结果不一致。
- 执行环境（编译状态的 Node.js 环境、页面渲染和交互逻辑的浏览器环境）。
- 操作系统（Linux/Windows/Mac OS/Android/IOS）。
- 浏览器（MS/FF/GC）。
- 设备（Mobile/Pad/PC）。
- 分辨率（720/1080/2K/4K/5K）
- 以及各平台的版本。

但今天的话题主要是谈论下面几种环境
- 本地开发环境：编译代码到内存、启动本地开发服务器和 `Mock` 数据、监听文件修改热更新等。
- 线上生产环境：对代码压缩混淆，去除注释和警告信息，生成代码文件与 Map 文件。
- 应用的环境：应用会部署在线上、预上线、测试等多个环境，他们的代码基本一致，仅 API 和配置参数不一样。


### 为什么要定义不同的运行环境？

为了区分出以下列出的不同情况：
1. 服务器地址不同：线上服务器地址，不同测试环境的服务器地址。
1. 地址跳转：单点登录跳转需要携带的不同环境的登录页地址。
1. CDN 加速域名：本地开发环境一般是相对路径 `/`、测试环境和线上环境是分别不同的域名。
1. 第三方配置：比如聊天上传等，应该对配置进行区分，否则会造成在测试环境的消息发送到线上环境中。
1. 前端监控：记录应用运行报错是在生产环境出现的还是测试环境出现的，或者仅仅只是在生产环境才进行监控。


## 正文

### 了解环境变量的用法

以下定义了一个 `NODE_ENV` 环境变量，它的值为字符串 `production`。
```bash
# Linux/Mac OS
$ NODE_ENV=production

# Windows
$ set NODE_ENV=production

# NodeJS
> process.env.NODE_ENV=production
```

以下从系统中读取了一个 `NODE_ENV` 环境变量，并且打印出来。
```bash
# Linux/Mac OS: $PATH 或 ${PATH}
$ echo $PATH

# Windows: %PATH%
$ echo %PATH%

# NodeJS: process.env.PATH
> console.log(process.env.PATH)
```


由于 Windows、Linux、Mac 设置环境变量不一致，可以使用 `cross-env` 来跨平台设置环境变量，设置后就可以在 Node.js 中读取出来。

```bash
# 安装
$ npm install -g cross-env

# 使用: 行首添加 cross-env 就可以了，多个变量用空格分隔。
$ cross-env NODE_ENV=production DEBUG=true
# 设置环境变量并运行 Node.js
$ cross-env NODE_ENV=production node app.js
```

注意 `cross-env` 定义的变量生命周期仅在同一条命令中有效，使用 `&&` 或 `;` 分隔的多条命令将访问不到上一个命令设置的值。

```bash
# ❌ 错误的用法
# 使用 `&&` 分隔
$ cross-env NODE_ENV=production && node app.js
# 使用 `;` 分隔
$ cross-env NODE_ENV=production; node app.js

# ✅ 正确的用法
# 使用空格隔开
$ cross-env NODE_ENV=production node app.js
```


### 了解并使用 `npm script`：

`npm` 支持将命令行写到 `package.json` 的 `script` 中，使用 `npm run [属性名]` 便可运行对应的命令，并且会将当前目录下 `node_modules/.bin/` 添加到 `PATH` 变量里。详细描述请参考阮一峰[《npm script 使用指南》](http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html)

```json
{
  "scripts": {
    "start": "node server.js",
  }
}
```


## 开始配置

### 应用的运行环境：

根据实际情况整理应用需要的运行环境，对每个环境命名，以及使用时所用的命令：

* 本地开发环境：`npm run start`
* 测试环境: `npm run build:test`
* 预上线: `npm run build:stage`
* 线上环境: `npm run build:prod`


或者提前在打包每个环境的代码前定义变量（如编写在 `~/.bashrc`），临时变量可以以下方式指定。

* 本地开发环境：`npm run start`
* 测试环境: `cross-env NODE_STAGE=test npm run build`
* 预上线: `cross-env NODE_STAGE=stage npm run build`
* 线上环境: `cross-env NODE_STAGE=prod npm run build`


## 用变量去标识：

* `NODE_ENV`：默认在构建工具中就定义的变量，一般仅存在 `development` 和 `production` 两种值。
* `NODE_STAGE`：我们手动新增的变量，可以配置为任何字符串，按照应用环境的定义设置为 `test`、`stage`、`prod`，如果不设置则为 `undefined`。


### 定义环境变量到编译环境：

比如以下命令定义了一个 `DISABLE_ESLINT` 变量，同时启动了构建打包工具。注意此时定义的环境变量仅在构建环境的 Node.js 中可访问，在应用的运行时环境访问不到该变量。

```bash
# Webpack:
$ cross-env DISABLE_ESLINT=true webpack
```

### 通过环境变量为运行环境定义全局常量：

这里使用 [DefinePlugin](https://webpack.docschina.org/plugins/define-plugin/) 插件进行配置，它允许在编译时生成自定义的全局常量。只需要在配置文件的插件列表下添加以下配置。

```javascript
plugins: [
  new webpack.DefinePlugin({
    "process.env.NODE_ENV": process.env.NODE_ENV,
    "process.env.NODE_STAGE": process.env.NODE_STAGE,
  })
]
```

### 使用全局常量

项目在编译后全局常量的值就会替换到生成的文件中了，使用全局常量便可实现动态选择连接后台服务器地址等等操作。

```javascript
const nodeStage = process.env.NODE_STAGE;
const nodeEnv = process.env.NODE_ENV;

// 根据常量获取当前环境名称
const ENV_NAME = nodeStage || nodeEnv;

// 每个环境的服务器地址
const apiUrls = {
  development: 'http://api.xxx.dev.domain.com/',
  test: 'http://api.xxx.test.domain.com/',
  stage: 'http://api.xxx.stage.domain.com/',
  production: 'http://api.xxx.domain.com/',
};

// 获取当前环境对应的值
export const API_URL = apiUrls[ENV_NAME];
```


### 设置命令别名

设置好别名之后就算是完成配置了，这时就可以在如 Jenkins 上的不同环境直接写入对应的 Bash 指令。

```json
{
  "scripts": {
    "start": "cross-env DISABLE_ESLINT=true roadhog dev",
    "build:test": "cross-env NODE_STAGE=test DISABLE_ESLINT=true roadhog build",
    "build:stage": "cross-env NODE_STAGE=stage DISABLE_ESLINT=true roadhog build",
    "build:prod": "cross-env DISABLE_ESLINT=true roadhog build"
  },
}
```


### 保持原则

* 配置尽量集中化，比如将所有常量统一写入到 `src/common/constant.js` 文件下。
* 各环境常量可以变化，但业务逻辑必须高度一致，否则测试环境只能是摆设。


## 相关实践

### 按配置生成 HTML

比如某些单点登录应用会有一个 `refresh.html` 文件，这个文件会调取服务端接口更新会话状态。它的地址是硬编码到 HTML 文件中的。我们希望这个地址可以从配置文件中读取。我们使用 [HtmlWebpackPlugin](https://github.com/jantimon/html-webpack-plugin) 插件来生成 HTML。

```javascript
// 此文件根据 NODE_STAGE 环境变量标识导出不同配置
const constant = require('./src/common/constant');

// ....
new HtmlWebpackPlugin({
  title: 'App',
  filename: 'refresh.html',
  template: './src/index.ejs',
  inject: false,
  meta: {
    refresh: {
      'http-equiv': 'refresh',
      content: `0; url=${constant.toUrl}`,
    },
  },
});
// ....
```

编译完成后生成的 `refresh.html` 文件硬编码地址为对应环境地址。

```html
  <!-- ... -->
  <meta http-equiv="refresh" content="0; url=https://api.xxx.domain.com/jump?toUrl=https://xxx.domain.com/index.html">
  <title>App</title>
  <!-- ... -->
```
