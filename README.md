##Linux实验报告一
---
###软件环境
Ubuntu 18.04服务器64位

----

###实验问题
* 如何配置无人值守安装iso并在Virtualbox中完成自动化安装。
* virtualbox安装完Ubuntu后新添加的网卡如何实现系统引导自动启用和自动获取IP.
*  如何使用sftp在虚拟机和宿主机之间的传输文件。
  
##无人值守安装ios

----
先【有人值守】方式安装好 一个可用的 Ubuntu 系统环境

##安装过程
####有人值守下配置好一台双网卡的Linux18.04.4虚拟机
* 采用虚拟介质管理的方式clone一台linux18.04的虚拟机 
* 配置双网卡 NAT+Host-Only
  ![alt](C:\linux-2020-chenwenwens\chap0x01\img\双网卡.PNG)


1. 虚拟机命令行里输入命令 ifconfig -a
2. 发现有网卡未启动，手动启动，并重新查看网卡IP，记录IP地址:192.168.208.3

----

####配置
* 出现问题：ssh start时出错
参考资料<https://blog.csdn.net/qq_24898865/article/details/81069226>
1. 更新源列表
打开"终端窗口"，输入`undo apt-get update `
2. 安装openssh-server
在终端中输入: `sudo apt-get install openssh-server`
3. 查看查看ssh服务是否启动
打开"终端窗口"，输入`sudo ps -e |grep ssh`
####PUTTY
* 下载并安装PUTTY
**利用克隆的虚拟机完成批量加载用psftp把某些文件从Windows复制进虚拟机**
使用putty连接这台虚拟机
* 在PuTTY里进行操作。发现安装操作只能以root身份登录才能使用
/用户登录mount操作失败/
* 用sudo passwd root进行root身份密码更改，再进行root登录，重新执行操作。     

>在当前用户目录下创建一个用于挂载iso文件的目录
mkdir loopdir

>提示目录已存在File exists
>挂载iso文件到该目录：mount -o loop ubuntu-18.04.4-server-amd64.iso loopdir
>创建一个工作目录用于克隆光盘内容：mkdir cd
>同步光盘内容：rsync -av loopdir / cd
>卸载iso：sudo umount loopdir
>进入目标工作目录，并编辑Ubuntu安装引导界面增加一个新菜单项入口
>添加以下内容后强制保存退出


``` 
label autoinstall
  menu label ^Auto Install Ubuntu Server
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet
  ```

### 总结与反思
1.应该一边看视频一边操作，这样印象更深刻
2.实验做了好久，最后悔的是每次都忘记给虚拟机备份，不小心代码都弄没了就要全重写
3.实验还是有许许多多不是特别清楚的地方需要再好好研究研究