### 1. 配置工作主机到目标主机的远程SSH免密登录

#在工作主机 上生成秘钥对

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

#在工作主机 上生成秘钥对

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

#修改目标主机配置文件，允许root用户远程登录

sudo vim /etc/ssh/sshd_config

#设置可通过口令认证SSH
---
      PasswordAuthentication yes

      #允许root用户登录
      
      PermitRootLogin yes

---

### 3. NFS
  - 脚本：[nfs_client.sh](bash/nfs_client.sh) [nfs_server.sh](bash/nfs_server.sh)   \
    配置文件：
    [/etc/exports](config/exports)
  - **在目标主机运行 `nfs_server.sh`**
    ![](img6/nfs_server.PNG)
  - **在工作主机运行 `nfs_client.sh`**
    ![](img6/error1.PNG)
 `root:root`

### 4. DHCP
- 脚本：[dhcp.sh](bash/dhcp.sh) \
  配置文件：[/dhcp/dhcpd.conf](config/dhcpd.conf) [/etc/default/isc-dhcp-server](config/isc-dhcp-server)

### 5. Samba
- 配置文件：
- 在linux端执行如下操作
  ```bash
  ## 安装Samba服务器
  sudo apt-get install samba
  ## 创建Samba共享专用的用户 
  sudo useradd -M -s /sbin/nologin smbuser
  sudo passwd smbuser
  sudo smbpasswd -a smbuser
  ```

### 6. DNS

- 在目标主机上

  * 安装bind9

 --sudo apt update && sudo apt install bind9
  * 修改配置文件`sudo vim /etc/bind/named.conf.options`

    # 添加
    listen-on { 192.168.57.1; };
    allow-transfer { none; };
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    ```
  ![](img6/setting1.PNG)
  * 编辑配置文件`/etc/bind/named.conf.local`
    #添加如下配置
    zone "cuc.edu.cn" {
        type master;
        file "/etc/bind/db.cuc.edu.cn";
    };
   
  ![](img6/setting2.PNG)
  * 生成配置文件`db.cuc.edu.cn`

        $ sudo cp /etc/bind/db.local /etc/bind/db.cuc.edu.cn
  * 编辑配置文件`sudo vim /etc/bind/db.cuc.edu.cn`

    ![db_config](img/setting3.PNG)
  * 重启bind9：`sudo service bind9 restart`
