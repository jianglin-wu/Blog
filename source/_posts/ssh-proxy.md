---
title: "SSH 端口转发"
date: "2019-04-24 15:10:00"
categories: 技术杂谈
tags:
- Linux
- SSH
---

## 描述

SSH 端口转发是一个特别强大好用的功能，这里将自己整理的笔记放在这里，如果你还没用过的话请往下看。



## 转发

### 本地端口转发

可作为跳板机访问其他设备等

```shell
$ ssh -N -L 2222:host1:22 host2
```

参数：

* -N 不显示终端
* -f 后台运行

### 远程端口转发

可用于内网穿透

```shell
$ ssh -N -R 8080:localhost:80 host1
```

默认情况下只侦听来自本地回环 `127.0.0.1` 的请求，如需要其他设备也能通过端口访问，则需要以下设置。

编辑 `/etc/ssh/sshd_config` 配置，将 `GatewayPorts` 参数改为 `yes`，然后重启：

/etc/ssh/sshd_config:

```
GatewayPorts yes
```

重启 sshd，然后重新执行转发命令：

```shell
$ service ssh restart
# or
$ systemctl restart sshd.service
```

### 动态转发

> 当我们在一个不安全的 WiFi 环境下上网，用 SSH 动态转发来保护我们的网页浏览及 MSN 信息无疑是十分必要的。

> 这种方式其实就是相当于socks代理，他会把本地的所有请求都转发到远程服务器上面，很实用哦，假如说你的那台服务器是在国外的话，你懂的！
创建了一个 SOCKS 代理服务。

当然，此代理配合 SwitchyOmege Chrome 插件使用应该是绝配。命令行 curl 等 可以通过 `export http_proxy=proxy_addr:port` 来访问。

```shell
$ ssh -D <local port> <SSH Server>
```


### X 协议转发

> 我们日常工作当中，可能会经常会远程登录到 Linux/Unix/Solaris/HP 等机器上去做一些开发或者维护，也经常需要以 GUI 方式运行一些程序，比如要求图形化界面来安装 DB2/WebSphere 等等。这时候通常有两种选择来实现：VNC 或者 X 窗口，让我们来看看后者。

打算找个时间玩玩，对比一下 VNC

```shell
$ export DISPLAY=<X Server IP>:<display #>.<virtual #>
```


## 其他

### 稳定性维持（使用 autossh 代替 ssh）

> 不幸的是 SSH 连接是会超时关闭的，如果连接关闭，隧道无法维持，那么 A 就无法利用反向隧道穿透 B 所在的 NAT 了，所以我们需要一种方案来提供一条稳定的 SSH 反向隧道。

> 一个最简单的方法就是 `autossh`，这个软件会在超时之后自动重新建立 SSH 隧道，这样就解决了隧道的稳定性问题。

macOS:

```shell
$ brew install autossh
```

参数

* -M: 负责通过这个端口监视连接状态


### 防火墙开放端口

云服务大多配置了防火区与安全组，访问时确保不被拦截，下面是 `iptables` 例子：

```shell
$ sudo iptables -I INPUT -p tcp --dport 6766 -j ACCEPT
```


## 参考

* [SSH原理与运用（二）：远程操作与端口转发](http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html)
* [实战 SSH 端口转发](https://www.ibm.com/developerworks/cn/linux/l-cn-sshforward/index.html)
* [SSH隧道：内网穿透实战](https://cherrot.com/tech/2017/01/08/ssh-tunneling-practice.html)
* [SSH手册](http://linux.51yip.com/search/ssh)
* [Linux下的wget和curl如何使用http proxy](https://blog.csdn.net/kkdelta/article/details/50466772)
* [SSH反向代理实现内网穿透，绑定0.0.0.0而不是127.0.0.1](https://blog.csdn.net/u012911347/article/details/80765894)
* [Why can I not connect to a reverse SSH tunnel port remotely, even with GatewayPorts enabled?](https://superuser.com/questions/767524/why-can-i-not-connect-to-a-reverse-ssh-tunnel-port-remotely-even-with-gatewaypo)
* [使用SSH反向隧道进行内网穿透](https://bingozb.github.io/32.html)