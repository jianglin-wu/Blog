---
title: "前端应用如何指定编译环境与运行环境？"
date: "2018-04-25 14:03:00"
categories: 前端
tags:
- 编译打包
---

## 开始之前

**程序的环境指的是什么？**

这答案很宽泛，在前端应用中大多指 `JavaScript` 的执行上下文，在代码执行的时候需要知道当前处于哪种状态？当前能做什么？应该做什么？



**代码运行中会遇到哪些环境？**

客观上的不同：

* 执行环境(编译状态的 Node.js 环境、页面渲染和交互逻辑的浏览器环境)。
* 操作系统(Linux/Windows/Mac OS/Android/IOS)。
* 浏览器(MS/FF/GC)。
* 设备(Mobile/Pad/PC)。
* 分辨率(720/1080/2K/4K/5K)
* 以及各平台的版本。


主观上的不同：

1. 本地开发环境：编译代码到内存、运行本地 `Server` 和 `Mock` 数据、监听文件修改进行热更新。
2. 线上生产环境：对代码压缩混淆，去除注释，去除警告，生成文件与 Map 文件。
3. 测试环境：与线上环境高度一致，但连接的是测试服务器。
4. DEBUG 模式：在生产环境与测试环境开启调试模式时生成 Map 或者打印日志等。开发环境下打开调试模式时命令行指定后端调试服务器等。



**为什么要人为的定义不同的运行环境？**

为了区分出以下列出的不同情况：

1. 服务器地址不同：测试服务器，线上服务器，以及后端开发启动的服务器(后端找不到 BUG 断点调试时用的[严肃脸])。
2. 地址跳转：单点登录跳转不同环境的登录页。
2. 使用 CDN 的应用：项目文件 Base URL 在开发环境为 `/`、测试为 `https://test.cdn.com/`，在生产环境为 `https://www.cdn.com/` 等。
3. 第三方接入：如第三方聊天的 SDK 需要使用一些 Key 鉴权，应该对 Key 进行区分，否则会造成在测试环境的消息发送到生产环境中。
4. 线上环境为 HTTPS 协议：并不是所有情况下都能通过 `//:` 方式获取资源，所以还是有必要区分该用 `http://` 还是 `https//`。
5. 前端监控：记录应用运行报错是在生产环境出现的还是测试环境出现的，或者仅仅只是在生产环境才进行监控。
6. 部分新功能仅对测试和开发环境开放：对于还不稳定的功能在生产环境打包时忽略或隐藏入口（不推荐这样用）。



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
# Linux/Mac OS: $PATH 或 ${PATH}
$ echo $PATH

# Windows: %PATH%
$ echo %PATH%

# NodeJS: process.env.PATH
> console.log(process.env.PATH)
```

跨平台设置环境变量工具 `cross-env` ：

```bash
# 安装
$ npm install -g cross-env

# 使用: 行首添加 cross-env 就可以了，多个变量用空格分隔。
$ cross-env NODE_ENV=production DEBUG=true
# 设置环境变量并运行 Node.js
$ cross-env NODE_ENV=production node app.js
```

注意 `cross-env` 定义的变量生命周期仅在同一条命令中有效，使用 `&&` 或 `;` 分隔的多条命令将访问不到设置的值。

```bash
# 使用 `&&` 或 `;` 合并的命令无法读取到变量
$ cross-env NODE_ENV=production && node app.js
# or
$ cross-env NODE_ENV=production; node app.js

# 正确的方式使用空格隔开
$ cross-env NODE_ENV=production node app.js
```


**了解并使用 npm script：**

`npm` 支持将命令行写到 `package.json` 的 `script` 中，使用 `npm run [属性名]` 便可运行对应的命令，并且会将当前目录下 `node_modules/.bin/` 添加到 `PATH` 变量里。详细描述请参考阮一峰[《npm script 使用指南》](http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html)

```javascript
{
  // ...
  "scripts": {
    "start": "node server.js",
  },
  // ...
}
```



## 开始配置

**应用的运行环境：**

<!-- 根据[规范](http://git.highso.com.cn:81/fe/fe-blog/issues/12#%E9%A1%B9%E7%9B%AE%E8%84%9A%E6%9C%AC%E8%A7%84%E8%8C%83)整理对应的环境，以及使用时所用的命令： -->

根据实际情况整理应用需要的运行环境，对每个环境命名，以及使用时所用的命令：

* 本地开发环境：`npm run start`
* 开发环境: `npm run build:dev`
* test1 环境: `npm run build:test1`
* test0 环境: `npm run build:test0`
* 回归测试: `npm run build:reg`
* 预上线: `npm run build:stage`
* 性能测试: `npm run build:perf`
* 线上环境: `npm run build:prod`

**调试模式：**

通过一个变量，对任意环境标识是否处于调试模式。当任意环境处于调试模式时，可以根据实际需求进行日志的打印、配置的调整、Map 的生成等。



**用变量去标识：**

* `NODE_ENV`：默认在构建工具中就定义的变量，一般仅存在 `development` 和 `production` 两种值。
* `NODE_STAGE`：我们手动新增的变量，可以配置为任何字符串，按照应用环境的定义设置为 `dev` | `test1` | `test0` | `reg` | `stage` | `pref` | `prod` 七种值，如果不设置则为 `undefined`。
* `DEBUG`：我们手动新增的变量，按自己的需求随意配置，可配置为 `true` 或 `false`，值也可以是接口服务器 `URL`，如果不设置则为 `undefined`。



**定义环境变量到编译环境：**

以下命令定义了一个 `DISABLE_ESLINT` 变量，同时启动了构建打包工具。需注意此时定义的变量在编译环境可以访问，但在运行环境访问不到该变量。

```bash
# Roadhog：
$ cross-env DISABLE_ESLINT=true roadhog dev
# Webpack:
$ cross-env DISABLE_ESLINT=true webpack
```

**通过环境变量为运行环境定义全局常量：**

这里使用 [DefinePlugin](https://webpack.docschina.org/plugins/define-plugin/) 插件进行配置，它允许在编译时生成自定义的全局常量。以下是两种构建工具的配置方式。

Roadhog：在配置文件中添加以下配置便可直接生效（`roadhog@1.x` 及以前版本为 `roadhogrc.js` 文件，`roadhog@2.x` 及之后版本为 `.webpackrc.js` 文件），[查看 define 配置文档](https://github.com/sorrycc/roadhog/blob/master/README_zh-cn.md#define)。

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

Webpack: 在配置文件的插件列表下添加以下配置。

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

项目在编译后全局常量的值就会替换到生成的文件中了，使用全局常量便可实现动态选择连接后台服务器地址等等操作。

```javascript
const debug = process.env.DEBUG;
const nodeStage = process.env.NODE_STAGE;
const nodeEnv = process.env.NODE_ENV;

// 根据常量获取当前环境名称
const ENV_NAME = debug ? 'debug' : (nodeStage || nodeEnv);

// 每个环境的服务器地址
const apiUrls = {
  debug: debug || '',
  development: 'http://api.xxx.dev.domain.com/',
  dev: '',
  test1: 'http://api.xxx.test1.domain.com/',
  test0: 'http://api.xxx.test0.domain.com/',
  reg: 'http://api.xxx.reg.domain.com/',
  stage: 'http://api.xxx.stage.domain.com/',
  perf: '',
  production: 'http://api.xxx.domain.com/',
};

// 获取当前环境对应的值
export const API_URL = apiUrls[ENV_NAME];
```


**设置命令别名**

设置好别名之后就算是完成配置了，这时就可以在如 Jenkins 上的不同环境直接写入对应的 Bash 指令。

```javascript
{
  // ...
  "scripts": {
    "start": "cross-env DISABLE_ESLINT=true roadhog dev",
    "build:dev": "cross-env NODE_STAGE=dev DISABLE_ESLINT=true roadhog build",
    "build:test0": "cross-env NODE_STAGE=test0 DISABLE_ESLINT=true roadhog build",
    "build:test1": "cross-env NODE_STAGE=test1 DISABLE_ESLINT=true roadhog build",
    "build:reg": "cross-env NODE_STAGE=reg DISABLE_ESLINT=true roadhog build",
    "build:stage": "cross-env NODE_STAGE=stage DISABLE_ESLINT=true roadhog build",
    "build:perf": "cross-env NODE_STAGE=perf DISABLE_ESLINT=true roadhog build",
    "build:prod": "cross-env DISABLE_ESLINT=true roadhog build",
    // "start:debug": "cross-env DEBUG=http://192.168.x.x:8888/ npm run start",
  },
  // ...
}
```


**保持原则**

* 配置尽量集中化，比如将所有常量统一写入到 `src/common/constant.js` 文件下。
* 各环境常量可以变化，但业务逻辑必须高度一致，否则测试环境只能是摆设。



## 相关实践

**按配置动态生成 HTML（Roadhog 配置方式）**

使用 OAuth 开发的单点登录应用会有一个 `refresh.html` 文件，这个文件会调取服务端接口更新会话状态。它内部有一个服务器地址，我们希望这个地址可以从配置文件中读取。我们可以添加 `webpack.config.js` 文件，Roadhog 工具可以通过这个文件对最后实例化的配置进行修改。我们使用 [HtmlWebpackPlugin](https://github.com/jantimon/html-webpack-plugin) 插件来生成 HTML，首先需要安装它：

```bash
$ npm install -D html-webpack-plugin
```
然后在获取到 Webpack 实例化配置时，将该插件追加到 `webpackConfig.plugins` 插件列表中，此时 `refresh.html` 重定向服务器地址便可从配置文件中拿取。

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

在上面的步骤中已经拿到了配置信息，而下面这一步是修改 HTML 模板将内容生成出来。`src` 目录下有一个 `index.ejs` 文件，这是 `index.html` 的模板文件。现在我们需要生成 `refresh.html` 文件，与 `index.html` 共用一个模板文件，所以将下面内容添加到 `src/index.ejs` 文件 `head` 元素中。

```htmlbars
  <!-- ... -->
  <% if (htmlWebpackPlugin.options.refresh) { %>
  <meta http-equiv="refresh" content="<%= htmlWebpackPlugin.options.refresh %>">
  <% } %>
  <title><%= htmlWebpackPlugin.options.title %></title>
  <!-- ... -->
```



编译完成后生成的 `refresh.html` 文件重定向地址为常量文件中配置的值。

```html
  <!-- ... -->
  <meta http-equiv="refresh" content="0; url=https://api.xxx.domain.com/jump?toUrl=https://xxx.domain.com/index.html">
  <title>App</title>
  <!-- ... -->
```

**正确获取开发环境 Host 地址，并用浏览器自动打开该地址（Roadhog 配置方式）:**

多数构建工具开发模式下启动时都会从浏览器中自动打开，但一般都是以 `localhost` 作为访问地址，或者以 IP 地址作为 Host 时，在有多个虚拟网卡的情况下获取的 IP 地址往往不是我们想要的地址。如果移动设备或其他设备访问当前的服务，在进行登录跳转时就会跳到不能访问的地址，导致应用无法访问或登录。

那么我们就自己动手去获取想要的地址，动手之前先禁用工具默认打开浏览器的行为。给 npm scripts 中 `start` 与 `start:no-proxy` 命令设置 `BROWSER` 环境变量，并且它的值为 `none`。[Roadhog 环境变量文档](https://github.com/sorrycc/roadhog/blob/master/README_zh-cn.md#环境变量)，如下所示：

```bash
$ cross-env DISABLE_ESLINT=true BROWSER=none roadhog dev
```

现在我们就获取主机地址，在编译环境中通过 Node.js 的 `os` 模块来获取，在运行环境中通过 `window` 对象的 `location.hostname` 来获取。由于我的 `src/common/constant.js` 配置文件同时在编译环境与运行环境中使用，所以这里使用了 `UMD` 方式的代码结构：

```javascript
let host = 'localhost';
(() => {
  if (typeof exports === 'object') {
    /* eslint-disable */
    const os = require('os');
    /* eslint-enable */
    const ifaces = os.networkInterfaces();
    Object.keys(ifaces).forEach((keyName) => {
      if (/vmware/gi.test(keyName)
        || /docker/gi.test(keyName)
        || /vboxnet/gi.test(keyName)
        || /br/gi.test(keyName)) {
        return;
      }
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

最后安装 [open-browser-webpack-plugin](https://github.com/baldore/open-browser-webpack-plugin) 这个插件：

```bash
$ npm install -D open-browser-webpack-plugin
```

添加或修改 `webpack.config.js` 文件，为该插件传入 URL 参数，并将实例化的对象追加到 Webpack 插件列表实例中。

```javascript
const OpenBrowserPlugin = require('open-browser-webpack-plugin');
const constant = require('./src/common/constant');

module.exports = function (webpackConfig) {
  if (Array.isArray(webpackConfig.plugins)) {
    webpackConfig.plugins.push(new OpenBrowserPlugin({
      url: constant.HOST_URL,
    }));
  }
  return webpackConfig;
}
```


## 最后

希望本文的内容能对你有所价值，如有疑问或指教欢迎在评论中指出。

日期： 2018年4月28日

更新： 2018年8月17日

（完）
