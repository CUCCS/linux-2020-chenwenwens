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
  
  ![alt](./img/捕获.png)
##配置双网卡 NAT+Host-Only

![alt](./img/双网卡.png)

1. 虚拟机命令行里输入命令 ifconfig -a
   发现有网卡未启动


   ![alt](./img/捕获7.png)


2. 手动启动，并重新查看网卡IP，记录IP地址:192.168.208.3
   ![alt](./img/捕获8.png)

----

###配置安装SSH
* 出现问题：ssh start时出错
参考资料<https://blog.csdn.net/qq_24898865/article/details/81069226>

**解决**
1. 更新源列表
打开"终端窗口"，输入`undo apt-get update `
2. 安装openssh-server
在终端中输入: `sudo apt-get install openssh-server`
3. 查看查看ssh服务是否启动
打开"终端窗口"，输入`sudo ps -e |grep ssh`

----
####PUTTY
 *  **下载并安装PUTTY**

  ![alt](./img/捕获5.png)

* **利用克隆的虚拟机完成批量加载用psftp把某些文件从Windows复制进虚拟机**


![alt](./img/PPFTP.png)
  


* **使用putty连接这台虚拟机**
  
![alt](./img/2.png)
* 在PuTTY里进行操作。发现安装操作只能以root身份登录才能使用
/用户登录mount操作失败/
###解决
* 用sudo passwd root进行root身份密码更改，再进行root登录，重新执行操作。 
  ![alt](./img/更改身份.png)    

---

>在当前用户目录下创建一个用于挂载iso文件的目录
mkdir loopdir

>提示目录已存在`File exists`
>挂载iso文件到该目录：`mount -o loop ubuntu-18.04.4-server-amd64.iso loopdir`
>创建一个工作目录用于克隆光盘内容：`mkdir cd`
>同步光盘内容：`rsync -av loopdir / cd`
![alt](./img/3.png)
>卸载iso：`sudo umount loopdir`
>进入目标工作目录，并编辑Ubuntu安装引导界面增加一个新菜单项入口
![alt](./img/last.png)


>添加以下内容后强制保存退出
``` 
label autoinstall
  menu label ^Auto Install Ubuntu Server
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet
  ```
  ![alt](./img/1.png)

  ----
  
  * 将Ubuntu官方文档preseed.cfg从宿主机Windows复制到虚拟机，并保存到新创建的工作目录
  `〜/ cd / preseed / ubuntu-server-autoinstall.seed`

* 修改isolinux / isolinux.cfg
   将超时300改为超时10


* 重新生成md5sum.txt（用root登陆）
`cd /home/cuc/cd && find . -type f -print0 | xargs -0 md5sum > md5sum.txt`

* 封闭的后的目录到.iso
`IMAGE = custom.iso BUILD = / home / cuc / cd /安装genisoimage sudo apt install genisoimagemkisofs -r -V“自定义Ubuntu安装CD” -cache-inodes -J -l -b isolinux / isolinux.bin -c isolinux / boot.cat- no-emul-boot-引导负载大小4 -boot-info-table -o $ IMAGE $ BUILD`

* 查看〜/ clone下制作好的custom.iso

* 在windows打开psftp窗口，执行get custom.iso，从虚拟机中将custom.iso这个副本文件复制出来

**安装**

-----
### 总结与反思
>1.应该一边看视频一边操作，这样印象更深刻
2.实验做了好久，最后悔的是每次都忘记给虚拟机备份，不小心代码都弄没了就要全重写
3.实验还是有许许多多不是特别清楚的地方需要再好好研究研究

---

### 参考资料
1. <https://blog.csdn.net/qq_24898865/article/details/81069226>
2. <https://github.com/c4pr1c3/LinuxSysAdmin/blob/master/chap0x01.exp.md>
3. <https://blog.csdn.net/u010649766/article/details/88745690>
4. <https://askubuntu.com/questions/704035/no-eth0-listed-in-ifconfig-a-only-enp0s3-and-lo>