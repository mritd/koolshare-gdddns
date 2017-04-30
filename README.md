# koolshare-gdddns

## 简介 

> 这是一个适用于梅林固件(koolshare) 的 Godaddy DDNS 插件，开发参考了 [aliddns](https://github.com/kyriosli/koolshare-aliddns) ，并完善了一些安装卸载脚本

## 插件使用

- 首先自己的域名需要托管在 Godaddy
- 在 [Godaddy Developer](https://developer.godaddy.com/keys/) 网站上生成用于调用 Godaddy API 的 Key 和 Secret
- 安装本插件，填入对应 Key 和 Secret，并设置解析域名等相关参数即可

## 开发规范

鉴于 koolshare 还没有一个完整的开发文档(有的可以发我下，感谢)，以下总结了一些写这个插件摸索的一些经验


### 本插件目录结构规范

本插件目录结构如下

``` sh
├── LICENSE                          授权声明
├── README.md                        说明文档
├── build.sh                         编译脚本，一般为打包脚本，感觉也可以写点从源码编译的动作
├── gdddns                           插件主目录(目录名最好和文件名等一致，这是一种默认的约定，暂不确定乱写会不会有问题)
│   ├── res                          资源目录(一般放插件图标等静态资源文件，按照 web 开发的理解这里面可以放 js、css 等)
│   │   └── icon-gdddns.png          插件图标(命令方式最好和已有插件保持一致，即 icon-xxxx，图片格式暂不确定是否有要求，感觉应该没有)
│   ├── scripts                      插件辅助执行脚本(本插件只需要用脚本执行，其他插件如 shadowsocks 等有二进制执行文件，这里面放的都是辅助脚本)
│   │   ├── gdddns_config.sh         插件配置脚本(主要完成安装、卸载初始化配置等)
│   │   ├── gdddns_update.sh         本插件的主要执行脚本(DDNS 更新域名记录主要从这里执行)
│   │   ├── install_gdddns.sh        安装脚本(默认压缩包会被系统解压自动释放文件，这里面主要是向 DBUS 注册当前插件状态)
│   │   └── uninstall_gdddns.sh      卸载脚本(默认插件中心点击卸载后，会调用次脚本，主要执行反注册 DBUS 信息和删除插件文件)
│   └── webs                         页面资源文件(主要使用 asp 编写)
│       └── Module_gdddns.asp        插件设置页面(该页面通过 jQuery post 方式调用后端脚本，同时页面内可以使用标签动态调用 DBUS)
└── gdddns.tar.gz                    插件打包文件
```

**约定优于配置: 默认的安装卸载脚本文件名(install_xxxx、uninstall_xxxx) 请不要乱更改，否则可能不会执行；尤其是插件的文件名约定，
最好参考已有插件命名，不要乱造；比如有些插件把 `install.sh`、`uninstall.sh` 放在 `scripts` 目录外面，还不遵循命名规范，实际上
这些脚本并不会被执行，点击卸载时也只是固件自动做了 DBUS 反注册信息而已，实际文件并未被删除**


### 插件中心目录结构规

**实际上插件在打包成 tar.gz 文件后，安装时系统会自动解压，然后将插件各个目录中的内容释放到 `/koolshare` 目录，以下是 `/koolshare` 目录结构**


``` sh
koolshare
├── bin
├── configs
├── init.d
├── perp
├── res
├── scripts
└── webs
```

**从上面 koolshare 目录结构可以看出，实际上插件内的目录结构应该是与其一致的，一般是能少不能多，因为在安装后插件内各个目录中的文件
都会被释放到 `/koolshare` 目录下的相应目录中，除非特殊情情况，比如 shadowsocks 文件很多所以单独创建了文件件(在 `/koolshare`
下差创建了一个 ss 的目录)；**


















