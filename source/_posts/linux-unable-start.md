---
title: "Deepin 无法启动解决过程记录"
date: "2018-08-21 19:32:00"
categories: Linux
tags:
- deepin
---


## 前言

在网上搜寻了一大圈找到些零零散散的解决方式，也有一些我自己的解决方式，在这里整理一下。在做开发的时候系统奇卡无比，具体的状况为：鼠标光标不跟随、Super 键无反应、Alt+Tab 切换无反应、使用其他设备 SSH 无法连接到主机、关机键按了也不会关机。经过一分钟的漫长等待也不见好转，最后只能使用一招强制关机（按着关机键 5-6 秒，或者有一个专门的强制断电按钮）。

重启过程中进入了下面这个界面，无论怎么敲回车继续、还是 Ctrl+D、还是其他方式，结果都是再次进入到了这个界面。图片是在[这里](https://bbs.deepin.org/forum.php?mod=viewthread&tid=146086)拿的，我也试着按这个帖子提出方案解决，不过信息不够完整，场景也有一定差别。

[![5fa96056cf77de798756325166fcd743.md.jpg](https://psyduck.top/images/2019/03/20/5fa96056cf77de798756325166fcd743.md.jpg)](https://image-cdn.hahhub.com/image/o6eB)



## 如何解决

### 寻找原因

试着查看系统启动日志，重启不停的按 `F12`，可以选择启动项。我选择【deepin 高级模式启动】，启动过程中可以看到很多系统信息，其中我看到有一个 `/storage` 磁盘挂载失败，原因是这个磁盘设备没有被找到。

`/stoage` 是我修改 `/etc/fstab` 文件自动挂载的一个磁盘，用来存储我工作中的文件。这时候大概可以猜到是因为系统操作这个磁盘的数据时，被我强制断电造成了数据损坏，导致系统无法挂载磁盘启动失败。

想要系统能够正常启动，我们首先让系统不去挂载这个已经损坏的磁盘。Linux 中一切皆文件，使用任何支持 `ext4` 文件系统的系统修改 `/etc/fstab` 文件便能解决。



### 查找系统磁盘

重启选择启动项，选择【deepin PE 系统】，这时候会启动一个简单的备份数据系统。这个系统和平时使用的系统不是同一个，所以修改 `/etc/fstab` 也只是修改的 PE 系统的信息，所以需要先找到原来系统的磁盘。我们使用以下命令查看所有磁盘设备：

```bash
$ ls /dev/disk/by-uuid
```

以下是我所有的磁盘设备

```
lrwxrwxrwx 1 root root  10 8月  20 02:04 0cbeb26d-3441-459a-8aa9-4033ecbade47 -> ../../sda1
lrwxrwxrwx 1 root root  10 8月  20 02:04 0d0dbfa7-d1c7-496b-96bc-dca05efb5b48 -> ../../sdb5
lrwxrwxrwx 1 root root  10 8月  20 02:04 D68CE5608CE53B9D -> ../../sdb1
lrwxrwxrwx 1 root root  10 8月  20 02:04 ed5a4f76-db0a-495c-bbe7-a66c67a0650d -> ../../sdb6
```

查看已经挂载到 PE 系统的磁盘设备，可以使用 `df -h` 与 `mount -l` 命令：

```bash
$ df -h
```

以下是我已经挂载的磁盘列表

```
文件系统        容量  已用  可用 已用% 挂载点
udev            7.8G     0  7.8G    0% /dev
tmpfs           1.6G  1.5M  1.6G    1% /run
/dev/sda1       220G   36G  172G   18% /
tmpfs           7.8G  205M  7.6G    3% /dev/shm
tmpfs           5.0M  4.0K  5.0M    1% /run/lock
tmpfs           7.8G     0  7.8G    0% /sys/fs/cgroup
/dev/sdb6       305G   14G  276G    5% /storage
tmpfs           1.6G   44K  1.6G    1% /run/user/1000
/dev/sdb1       311G   69G  242G   23% /media/jianglin-wu/D68CE5608CE53B9D
/dev/sdb5       220G   19G  190G    9% /media/jianglin-wu/0d0dbfa7-d1c7-496b-96bc-dca05efb5b48
```

去每个已挂载的的设备挂载点查看是否是自己的系统磁盘

```
$ ls /stotage # 查看 /dev/sdb6 设备
$ ls /media/jianglin-wu/D68CE5608CE53B9D # 查看 /dev/sdb1 设备
$ ls /media/jianglin-wu/0d0dbfa7-d1c7-496b-96bc-dca05efb5b48 # 查看 /dev/sdb5 设备
```

如果此时还没有找到自己的系统磁盘，那么系统磁盘可能在未挂载从设备中，使用 `mount` 命令挂载磁盘：

```bash
$ mount /dev/sdb5 /mnt # /dev/sdb5 挂载的磁盘，/mnt 挂载的目录
```

如果出现：can't read superblock 错误，那么这就是那个损坏的磁盘。先不管，先找到系统磁盘。



### 取消挂载磁盘

假如我们已经找到了系统所在的磁盘，并且已经挂载到系统上。接着我们修改该磁盘的 `etc/fstab` 文件，使用 `vi` 或 `vim` 发现系统上并没有安装。执行 `apt-get install vi vim` 你会发现找不到这个包，执行 `apt-get update` 也没有下载源，你难道想到了配置下载源？你是要下载一个浏览器 copy 进去还是一字一键的敲进去？

答案是使用 [HERE document](https://my.oschina.net/u/1032146/blog/146941)：

```
$ cd /media/jianglin-wu/0d0dbfa7-d1c7-496b-96bc-dca05efb5b48/etc # 进入磁盘所在目录
$ cp fstab fstab.bak # 备份文件
$ cat fstab # 查看原配置
# /dev/sda1
UUID=0d0dbfa7-d1c7-496b-96bc-dca05efb5b48    /          ext4    rw,relatime,data=ordered    0    1

UUID=ed5a4f76-db0a-495c-bbe7-a66c67a0650d    /storage   ext4    defaults    0   0

# 使用 HERE document 覆盖方式编辑文件，一行一行的复制和修改，输入 EOF 回车进行保存操作。
# 保存后一定要检查配置，复制以 Tab 符号分隔的字段时，粘贴出来的内容 Tab 字符会消失。
# 导致内容合并到一块儿，系统无法识别启动不了（别问我怎么知道）
$ cat > fstab << EOF
> UUID=0d0dbfa7-d1c7-496b-96bc-dca05efb5b48    /            ext4    rw,relatime,data=ordered    0    1
> # UUID=ed5a4f76-db0a-495c-bbe7-a66c67a0650d    /storage   ext4    defaults    0   0
> EOF

$ cat fstab # 检查修改的配置，注意空格 Tab 分隔是否正确
```

修改其他用到损坏磁盘的引用，如果你没有就跳过。我在 `etc/rc.local` 中配置了程序自动启动，开机它会自动运行 `/storage` 目录下的 Shell。

```bash
$ cd /media/jianglin-wu/0d0dbfa7-d1c7-496b-96bc-dca05efb5b48/etc # 进入磁盘所在目录
$ mv rc.local rc.local-old  # 将其重命名其他名字，启动时先不让它运行
```

此时如果你的配置没有问题，那么重启后便能够正常启动。



### 修复磁盘

当系统能够正常启动后，那么第一件事情就是修复损坏的磁盘。第一步挂载磁盘，这里先说说 `mount` 挂载与编辑 `/etc/fstab` 挂载的区别，`mount` 挂载在机器重启后便不生效了，而 `/etc/fstab` 的配置永久生效。所以我们使用第一种方式，如果磁盘有问题重启便能恢复。

下面的命令是挂载磁盘，实际上你在挂载损坏的磁盘时会抛出异常，如果下面这样：

```bash
$ mount /dev/sdb5 /mnt
# 挂载损坏的磁盘这里会报错
mount: /dev/sdb5: can't read superblock
```

修复步骤是按照 [意外断电造成 mount 挂载硬盘报错：can’t read superblock](https://www.5yun.org/16579.html) 这篇文章中描述的操作来做的，觉得篇幅过长请看下面精简后的内容。

首先使用 `tune2fs` 去查看文件系统的参数，在运行下面命令后找到 `Blocks per group` 字段后面的数值，我查看到的数值是 `32768`，记住这个数值。

```bash
$ tune2fs -l /dev/sdb5 # /dev/sdb5 替换为你的磁盘设备
# 在下面输出的内容中找到 Blocks per group 字段后的数值
```

通过 `fsck` 去修复矫正磁盘的数据，输入以下命令终端会询问你以下问题，`yes` 或 `no` ？你只需要全部回答 `yes` 就好了。

```bash
$ fsck.ext4 -b 32768 /dev/sdb5 # 32768 是你上一步查看的数值，/dev/sdb5 是你的磁盘设备
# 在后面的询问中全部回答 yes
```

完成前面的命令并且没有报错信息的话，那么恭喜你：你的数据修复了！后面的步骤就是恢复你对 `/etc/fstab` 文件的修改，以及其他比如 `/etc/rc.local` 的修改。最后一步重启就好了。



## 补充

### 罪魁祸首

在恢复正常使用的之后一天，我再次感受到了卡顿。最终找到了罪魁祸首 `kswapd0`，这个进程占用了我大量的 CPU。关于 `kswapd0` 可以查看 [kswapd0 进程CPU占用过高](https://blog.csdn.net/u012129607/article/details/74993302) 文章，总得来说应避免内存占用过高，避免十天半个月不关电脑。下面是简短的 `kswapd0` 的描述：

> kswapd0 占用过高是因为物理内存不足，使用 swap 分区与内存换页操作交换数据，导致CPU占用过高。



### U 盘启动修复

[Linux Deepin Note-fsck 命令](https://buptldy.github.io/2016/08/30/2016-08-30-deepin/) 中介绍了 **U 盘启动方式**修改挂载文件与修复磁盘。没有实际尝试过，放这里有兴趣的可以试试。

> 用 deepin 安装 u 盘启动，出现选择安装语言的界面时，按 ctrl+alt+F1，进入 tty，然后输入 startx，进入 live cd 模式，挂载硬盘的根分区，然后修改 /etc/fstab 文件，把里面的 /home 分区里的启动项注释掉。mount 命令在开始时会读取这个文件，确定设备和分区的挂载选项，注释掉后开机就不会挂载 /home 分区。

> 修改后退出 live cd 模式进入原系统，因为没有挂载损坏的 /home 分区，所以能进入系统，但是是不能进入图形界面的，进入文字界面执行下述命令修护损坏的 /home 分区，其中 /dev/sda6 为 /home 分区所在的设备名，设备名可以通过 fdisk -l 查看。

> sudo fsck -y /dev/sda6 修复成功后，取消/etc/fstab的注释，重启即可。




**相关链接**

* [cannot open access to console, the root account is locked.](https://bbs.deepin.org/forum.php?mod=viewthread&tid=146086)
* [linux shell 的 here document 用法 (cat << EOF)](https://my.oschina.net/u/1032146/blog/146941)
* [意外断电造成 mount 挂载硬盘报错：can’t read superblock](https://www.5yun.org/16579.html)
* [kswapd0 进程CPU占用过高](https://blog.csdn.net/u012129607/article/details/74993302)
