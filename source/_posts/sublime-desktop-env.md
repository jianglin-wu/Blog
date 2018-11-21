---
title: "Linux 快捷图标启动程序时如何设置环境变量"
categories: 技术杂谈
tags:
- Linux
- Sublime text
---

## 背景

最近在一台 Deepin 系统中配置开发环境，使用了 NVM 来安装 Node.js。NVM 可以安装多个 Node.js 版本来回切换，其原理就是更改 `$nvm` 这个环境变量，在终端启动初始化时通过`.bashrc` 将`$nvm`添加到 `$PATH`变量中。

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```



我使用的 Sublime Text 一般是直接点击启动图标运行的，并非在命令行中启动。Linux 中程序启动图标是一个 `*.desktop` 的配置文件，文件中 `Exec` 对应的值就是启动程序的命令（这个 `Exec` 命令可能有多个）。

```properties
[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Comment=Sophisticated text editor for code, markup and prose
Exec=/opt/sublime_text/sublime_text %F
Terminal=false
MimeType=text/plain;
Icon=sublime-text
Categories=TextEditor;Development;
StartupNotify=true
Actions=Window;Document;

[Desktop Action Window]
Name=New Window
Exec=/opt/sublime_text/sublime_text -n
OnlyShowIn=Unity;

[Desktop Action Document]
Name=New File
Exec=/opt/sublime_text/sublime_text --command new_file
OnlyShowIn=Unity;
```



**问题的产生：** 我的环境变量配置在 `.bashrc` 文件中，但是从图标启动时会直接执行命令，而没有初始化 `.bashrc` 这一过程。导致 Sublime Text 启动之后在 `$PATH` 变量中没有包含 `$nvm`，Sublime Text 中如 SublimeLiner 和 Prettier 等依赖 Node.js 程序的插件无法正常运行。



**如何解决：** 让 Sublime Text 能够正常的读取设置环境变量，便能够找到 Node.js 程序。





## 解决方法

### Desktop Exec 中设置环境变量

通过以下方式可以在启动前设置环境变量，但是在上面`.bashrc` 中执行了一个 `nvm.sh`脚本。我试过使用 `&&` 先执行 `nvm.sh` 再执行启动程序，但是结果并不是我想的那样。这不是我想要的那个方案，有兴趣的可以再尝试尝试。

```properties
Exec=env nvm=/path/to/node/home  /opt/sublime_text/sublime_text %F
```



### 设置 .xsessionrc 文件

在 `$HOME` 中新建 `.xsessionrc` 文件，将 `.bashrc` 中的 nvm 配置复制一份儿到这个文件中。保存完毕之后，注销重新登录桌面即可生效。

```shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```





## 参考链接

[Desktop entries - archlinux](https://wiki.archlinux.org/index.php/desktop_entries#Modify_environment_variables)

[Linux Desktop 环境变量设置 - 简书](https://www.jianshu.com/p/a936db2d8351)

