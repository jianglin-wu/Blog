---
title: "记录博客搭建过程"
categories: 技术杂谈
tags:
- blog
- hexo
---

此帖用来记录使用 Hexo 工具生成与管理博客，并且将博客部署到 Github Pages。

## 安装
首先安装 hexo-cli、模板、依赖，并启动服务查看是否安装正常。

```bash
$ npm install hexo-cli -g
$ hexo init blog
$ cd blog
$ npm install
$ hexo server
```


## 配置自动部署
安装部署插件。

```bash
$ npm install hexo-deployer-git -S
```

在根目录 `_config.yml` 文件中加入以下配置。
```yml
deploy:
  type: git
  repo: [仓库地址]
  branch: [部署分支]
```

## 配置生成订阅 RSS
RSS 用于订阅博客，用户可根据 RSS 文件获取博客最新状态。

```bash
$ npm install hexo-generator-feed -S
```

在根目录 `_config.yml` 文件中加入以下配置。
```yml
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content:
  content_limit: 140
  content_limit_delim: ' '
```

## 加入页面自动刷新

只需安装一个插件就可实现浏览器自动刷新功能，大幅提升文档编写效率。

```bash
$ npm install hexo-browsersync -S
```

## 加入评论功能

待续...