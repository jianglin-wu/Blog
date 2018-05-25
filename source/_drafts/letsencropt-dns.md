---
title: "使用Let's Encropt DNS 自动化发布证书"
tags:
---

本文针对使用家庭网络映射到公网构建服务器的用户，此类服务器大多是进行 DDNS 域名动态解析，由于网络提供商 ISP 封锁了80/443 等端口，Let's Encropt 使用 `--preferred-challenges` 的 `http` 和 `tls-sni` 方式就无效了，那么我们下面就使用 `dns` 方式验证域名。

手动：

脚本：acme.sh

cname无法找到，只能使用A记录。