# Linux Ubuntu环境下命令的积累

## 登录远程linux服务器

```
ssh qnwang@ali.dfshan.net -p 2220
ssh root@8.218.243.162
ssh admin@udpcc.dfshan.net
```

轻量级阿里云服务器
用户登录名称 qnwang@1722098869150809.onaliyun.com
登录密码 meiguihua1975
root密码：dfshan123...

密码改成生日了
用powershell登录，也可以用cmd登录

quictest服务器密码：Meiguihua1975?

进入自己设置的用户：sudo su wqn

账号：黑喂狗

密码：330781cfz...

## 如何通过 ssh 给远程服务器传输文件

```
scp -P 2220 D:/wqn/elephants_dream_1080p24.y4m.xz qnwang@ali.dfshan.net:~/Documents
scp username@hostname:/path/to/remote/file /path/to/local/file
rsync -av proxygen root@8.218.243.162:/home/qnwang/work
rsync -av proxygen root@wqn.dfshan.net:/home/qnwang/work
rsync -av proxygen root@8.217.32.98:/home/qnwang/work
rsync -av tengine-install admin@udpcc.dfshan.net:/home/admin/AR/worknew
rsync -av tengine-install qnwang@udpcc.dfshan.net:/home/qnwang/worknew
#带端口的
rsync -av tengine -avuz -e 'ssh -p 2299' qnwang@igw.dfshan.net:/home/qnwang/worknew
rsync -r -va -e "ssh -p2210" *  qnwang@igw.dfshan.net:/home/qnwnag
在linux中下载文件可以用sz filename 的方法下载
```

## linux强制退出文档

```
:q!
```

## 查找正在运行的有关nginx的进程号

```
ps aux | grep nginx
sudo ./nginx
sudo ./nginx -s stop
sudo ./nginx -v
sudo ./nginx -t
ps -ef | grep “xxname”  这个命令可以看进程是否在执行
sudo pkill -9 tengine
kill %1
```

## 复制

```
cp -r /home/qnwang/Documents/output/. /var/www/html/
```

------

## 修改路径命令

```
echo $PATH

source /etc/profile
```

------

## 查看硬盘大小命令

```
df -h
```

## 改名

```
sudo mv test.txt new.txt
```

## 查看文件大小

```
ls -lh
```

## 查看网络及端口

```
netstat -ntulp | grep 443
netstat -aptn #打开
netstat -nupl #打开udp窗口
netstat -ntpl #打开tcp窗口
sudo lsof -i:443 #显示443端口的进程
.\chrome.exe --enable-quic --quic-version=h3-27 --origin-to-force-quic-on=tinychen.com:443 #打开谷歌的quic适用
netstat -anop | grep 8443
```

## 如何在vi编译器里显示行数

1. 输入命令  vim ~/.vimrc
2. 输入 set number
3. 保存即可

## 设置su的密码

sudo passwd root 输入密码

## Linux常用查找文件方法

### 一、which命令

**查找类型**：二进制文件；
**检索范围**：PATH环境变量里面指定的路径中查找；
**描述**：快速返回某个指定命令的位置信息。
**优点**：查找速度快
**缺点**：仅支持二进制文件

### 二、whereis命令

**查找类型**：二进制文件，man帮助文件，及源代码文件；
**检索范围**：/usr目录
**描述**： 快速返回某个指定命令的位置信息，及其man文件和源代码文件的位置信息（如果存在的话）。

也可以通过参数指定返回某一类查找结果：
-b: 仅查找二进制文件；
-m: 仅查找man帮助文件；
-s: 仅查找源代码文件；
**优点**：查找速度快
**缺点**：查找文件类型及范围均有限

### 三、find命令

find 路径/ -name “文件名”

#### 模糊查询
sudo find / -iname "*opencv*"

#### 全局搜索关键字
find / -name "*.*" | xargs grep -l instances

#### 查找所有包含 timersub关键字的文件
find / -name '*' | xargs grep 'timersub'

#### 借助 grep -r 只搜索子目录的内容就能够避免提示
find / -name '*' | xargs grep -r 'timersub' -v "权限不够"
find / -name '*' | xargs grep -r 'timersub' -v "Permission denied"

#### 在根目录 / 下查找cpuinfo文件
find / -name cpuinfo | xargs grep -r -v "Permission denied"

find / -name cudnn_version.h 2>&1 | grep -v "权限不够"
2>&1:将结果重定向到标准输出中

#### 删除文件名含有 “-unaligned.apk” 的文件
find / -name "*-unaligned.apk" | xargs rm -rf

## 下载

 wget https://boostorg.jfrog.io/artifactory/main/release/1.81.0/source/boost_1_81_0.tar.gz

wget https://github.com/fmtlib/fmt/releases/download/9.1.0/fmt-9.1.0.zip

sudo ./fuse/fuse ./nvme.json Nvme0n1 /home/wqn1/key/db/

git clone https://github.com/Tongsuo-Project/Tongsuo.git

sudo qemu-system-x86_64 -name cs-exp-zns -m 6G --enable-kvm -cpu host -smp 4 -hda ./ubuntu/ubuntu.qcow2 -net user,hostfwd=tcp:127.0.0.1:7777-:22,hostfwd=tcp:127.0.0.1:2222-:2000 -net nic -drive file=./ubuntu/nvme.qcow2,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm

sudo scripts/setup.sh

/sbin/ldconfig –v

## 试用服务器连接方式

**通过Workbench远程连接**（2.20-3.20）

## 删除

rm -rf 文件夹

## 查询其他用户

https://blog.csdn.net/web15286201346/article/details/126595972

## 权限

chmod 777 文件（扩大权限）

## 移动文件

sudo mv /home/wqn/work/folly/format-benchmark /home/wqn/work/

## 解压

**unzip t.zip**

## 升级

apt-get update

apt-get check

atp来验证本地系统的完整性和一致性，判断本地系统的软件包依赖性是否一致。

注：如果本地系统一致性严重破坏，则可以使用apt-get -f install 命令在使用apt以前手工修复被破坏的依赖性。

如果希望定期升级系统，保证及时升级，弥补安全漏洞，只需要apt-get update 和  apt-get upgrade（或apt-get dist-upgrade ）

## 配置镜像源

https://blog.csdn.net/m0_46223009/article/details/125905623

## 查看版本号

命令uname -v 可以查看版本号

扩大swap

## log文件直达底部：*键盘上按 shift + g*

## ubuntu —— 命令行访问网页的三种方法

### 1.第一种方法 links命令

$ apt install links

 $ links websol.cn

### 2.第二种方法 w3m命令

$ sudo apt-get install w3m 

$ w3m www.baidu.com

### 3.第三种方法 lynx命令

$ apt install lynx

 $ lynx websol.cn

## 关闭网页

q

y

## 卸载命令

sudo apt-get --purge remove 软件名

## 查看防火墙命令

ufw status

## 端口检查

netstat -lntu

lsof -i -P

## 曙光服务器登录

ssh qnwang@igw.dfshan.net -p2299

密码：010711

## 压缩命令和解压命令

https://blog.csdn.net/zong596568821xp/article/details/106024351

- tar -zxvf  filename.tar.gz filename

  --with-http_v2_module

## tc命令

看网卡上的命令：tc qdisc show dev eth0

设置丢包 ：tc  qdisc  add  dev  eth0  root  netem  loss  20%  

删除命令：tc qdisc del dev eth0 root netem

在Linux中，可以使用tc（traffic control）命令来指定IP地址的丢包率。tc命令是一个Linux内核的流量控制工具，可以控制网络接口的带宽、延迟、丢包等参数。

以下是一个使用tc命令指定IP地址设置丢包的示例：

1. 首先，使用以下命令创建一个限制带宽为1Mbps的qdisc（队列调度器）：

   ```
   tc qdisc add dev eth0 root handle 1: htb default 10
   tc class add dev eth0 parent 1: classid 1:1 htb rate 1Mbps
   ```

2. 然后，使用以下命令将IP地址为192.168.1.100的主机设置为丢包率为10%：

   ```
   tc qdisc add dev eth0 parent 1:10 handle 10: netem loss 10%
   tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 match ip dst 192.168.1.100 flowid 1:10
   ```

以上命令的含义如下：

- `tc qdisc add dev eth0 parent 1:10 handle 10: netem loss 10%`：将1:10类别的丢包率设置为10%。

- `tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 match ip dst 192.168.1.100 flowid 1:10`：将IP地址为192.168.1.100的流量流入1:10类别。

通过上述命令，我们成功地将IP地址为192.168.1.100的主机的丢包率设置为10%。如果需要恢复原始的丢包率设置，可以使用以下命令：

```
tc qdisc del dev eth0 root handle 1:
```

此命令将删除整个队列调度器，并恢复网络接口的默认设置。

### tc命令脚本

要使用tc netem命令定时变化丢包率，您可以编写一个简单的Shell脚本来实现。

以下是一个示例脚本，该脚本可以在不同时间段内循环更改丢包率：

```bash
#!/bin/bash

# 定义丢包率变化的时间段和对应的丢包率值
declare -a loss_rates=("10%" "20%" "30%" "40%" "50%")
declare -a durations=("10" "5" "15" "8" "12")

# 获取数组的长度
len=${#loss_rates[@]}

# 循环设置丢包率
while true; do
  # 遍历时间段和丢包率
  for ((i=0; i<len; i++)); do
    loss_rate=${loss_rates[$i]}
    duration=${durations[$i]}
    
    # 使用tc netem命令设置丢包率
    tc qdisc add dev eth0 root netem loss $loss_rate
    
    # 输出当前丢包率
    echo "设置丢包率为 $loss_rate，持续时间为 $duration 秒"
    
    # 等待指定的持续时间
    sleep $duration
    
    # 删除之前设置的丢包率规则
    tc qdisc del dev eth0 root netem
    
    # 输出丢包率恢复信息
    echo "丢包率恢复为正常"
    
    # 等待1秒钟，为下一个丢包率变化做准备
    sleep 1
  done
done
```

脚本中，我们定义了一个包含时间段和对应丢包率的数组。然后，脚本会循环遍历数组中的时间段和丢包率，并使用tc netem命令设置相应的丢包率。每个丢包率持续一段时间后，脚本会将丢包率恢复为正常。脚本会不断循环执行，使丢包率在不同时间段内变化。

请注意，在脚本中的`eth0`处，您需要将其替换为您要应用丢包率的网络接口名称。

将上述脚本保存为文件（例如`packet_loss_script.sh`），然后在终端中运行以下命令来执行脚本：

```bash
chmod +x packet_loss_script.sh
./packet_loss_script.sh
```

脚本将开始定时变化丢包率。您可以根据需要调整丢包率变化的时间段和对应的丢包率值，以及脚本中的其他细节。

## top命令

## gdb命令

n/s：单步运行

删除断点：d num1 - num5

显示断点：info

保存断点：save b XXX.bp

读取断点：gdb XXX -x XXX.bp

要使用gdb调试一个需要在命令行上输入参数的二进制文件，你可以按照以下步骤进行：

1. 打开终端，切换到二进制文件所在的目录。

2. 使用gdb命令打开二进制文件，同时在后面加上需要输入的参数。例如，如果你的二进制文件名为`myprogram`，需要输入两个参数`arg1`和`arg2`，那么可以使用以下命令：

   ```
   gdb myprogram --args arg1 arg2
   (gdb) watch cond
   ```

3. 这时gdb会进入调试模式，你可以使用各种gdb命令进行调试。

   - `break`命令可以设置断点，例如`break main`可以在程序的`main`函数处设置断点。
   - `run`命令可以运行程序，例如`run`命令会运行程序并将输入的参数传递给程序。
   - `next`命令可以执行下一条语句，`step`命令可以进入函数内部，`finish`命令可以执行完当前函数并返回到调用者。
   - `print`命令可以打印变量的值，例如`print i`可以打印变量`i`的值。
   - `backtrace`命令可以打印调用栈，查看程序执行的过程。
   - `quit`命令可以退出gdb调试模式。

4. 调试完成后，可以使用`quit`命令退出gdb。

需要注意的是，在gdb命令中，使用`--args`选项可以将后面的参数传递给被调试的程序，这样程序就能够接收到命令行参数并执行相应的操作。

 gdb --args ./hq  --mode=server         --h2port=8080         --port=8443         --protocol=h3         --cert=/root/wqn.dfshan.net/cert1.pem         --key=/root/wqn.dfshan.net/privkey1.pem         --static-root=./         --host=0.0.0.0         --connect_udp=true

gdb --args ./hq --mode=client  --h2port=8080    --port=8443  --host=wqn.dfshan.net  --path=https://wqn.dfshan.net:8080/index.html

./hq --mode=client  --h2port=8080    --port=8443  --host=wqn.dfshan.net  --path=https://wqn.dfshan.net:8080/index.html

## 在 VS Code 中，多行注释有两种方式：按行注释和按块注释。

按行注释的快捷键是 `Ctrl + /`，在需要注释的行上按下这个快捷键即可。如果要取消注释，可以再次按下 `Ctrl + /` 快捷键。

按块注释的快捷键是 `Shift + Alt + A`[[1](https://blog.csdn.net/mChales_Liu/article/details/106890204)][[2](https://blog.csdn.net/weixin_39818631/article/details/111744192)]，先用鼠标选中需要注释的一段代码，然后按下这个快捷键即可。如果要取消注释，也可以再次按下 `Shift + Alt + A` 快捷键。

除此之外，VS Code 还有很多其他的快捷键，比如换行、格式化、复制、生成代码等等，可以根据自己的需要进行学习和使用[[1](https://blog.csdn.net/mChales_Liu/article/details/106890204)][[2](https://blog.csdn.net/weixin_39818631/article/details/111744192)]。

## 抓包

tcpdump -i eth0 host 8.218.243.162 -w quicclient.pcap

 tcpdump -i eth0 -nn -s0 -v port 8443 -w quicserver.pcap

## ubuntu下生成测试用的大文件

dd if=/dev/zero of=test bs=1M count=1000

会生成一个 1000M 的 test 文件，文件内容为全 0（因从 /dev/zero 中读取，/dev/zero 为 0 源）

dd if=/dev/urandom of=testfile bs=1024 count=100

该命令将创建一个名为testfile的文件，该文件包含100个大小为1024字节的随机数据块，这将生成100个数据包。

## vscode命令总结

### vscode查找文件

ctrl+p

### vscode翻译

alt+t
### vscode块注释
进行代码块注释的快捷键是"Alt + Shift + A"
ctrl+/

### vscode自动整理代码格式：

```
Shift + Alt + F
```

## wireshark去掉重复的包

editcap.exe -d D:\test\4.pcapng D:\test\4out.pacpng

## 解决error while loading shared libraries: libXXX.so.X: cannot open shared object file: No such file

解决方法

（1）cd /etc/ld.so.conf.d

（2）sudo vim tmp-libs.conf

备注： 新建文件tmp-libs.conf，这个文件名称可以随便，只要文件后缀是.conf，可以在文件中写入 /usr/local/lib ，其实不写任何内容也是可以的，只创建一个空文件也可以。

（3）sudo ldconfig

备注：执行该命令的目的是更新 /etc/ld.so.cache，ld.so.cache 的更新是递增式的，就像PATH系统环境变量一样，不是从头重新建立，而是向上累加。只有重新开机，系统从零开始建立ld.so.cache文件。
## The command could not be located because'/usr/bin' is not included in the PATH environment variable
export PATH=/usr/bin:$PATH

(ifconfig)export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

vi ~/.bashrc

export PATH=/usr/bin:$PATH

source ~/.bashrc
## 生成.pem文件
cat server.crt server.key > server.pem
## git命令积累

git 初始化
```
git init
```
git 添加文件
```
git add
```
## git出错

error: src refspec master does not match any.
error: 推送一些引用到 'https://github.com/ruanqingxuan/octopus-xquic.git' 失败
这个错误通常是因为本地仓库中的 master 分支不存在或者为空，而你试图推送到远程仓库的 master 分支。请确保你的本地仓库中有一个名为 master 的分支，并且有至少一个提交记录。你可以通过以下命令创建一个 master 分支并提交至少一个更改：

```
git checkout -b master
git commit -m "Initial commit"
git push -u origin master
```

然后再尝试推送到远程仓库。

## 查看内存占用

ps

top

## 禁用密码登录

vi /etc/ssh/sshd_config

PasswordAuthentication no

sudo systemctl reload sshd

# sudo不用密码

## 🗒️ Answer
在 Linux 系统中，如果你希望某个用户执行 `sudo` 时不需要输入密码，可以通过修改 `sudoers` 文件来实现。以下是具体操作步骤：

1. **编辑 sudoers 文件**  
   使用 `visudo` 命令编辑 sudoers 文件：
   ```bash
   sudo visudo
   ```

2. **添加免密码规则**  
   在打开的文件中，找到适当的位置（通常是 `# User privilege specification` 部分），添加如下内容：
   ```bash
   username ALL=(ALL) NOPASSWD: ALL
   ```
   替换 `username` 为目标用户的用户名。  
   - `ALL=(ALL)`：表示该用户在任何主机上都可以使用 `sudo`。
   - `NOPASSWD: ALL`：表示用户不需要输入密码来运行任何 `sudo` 命令。

3. **保存并退出**  
   按 `Ctrl+O` 保存更改，然后按 `Ctrl+X` 退出。

4. **验证配置**  
   以目标用户身份运行 `sudo` 命令，确保不会提示输入密码。

⚠️ **注意**：
- 这样设置会降低系统的安全性，仅推荐在开发环境或受信任的环境中使用。

- 对生产环境中的关键用户谨慎设置。

  ## 重置服务器

  在服务器上生成 SSH 密钥可以按照以下步骤操作：

  1. **登录服务器**：  
     确保已经通过密码登录到目标服务器。

  2. **运行命令生成 SSH 密钥**：  
     执行以下命令生成密钥对（默认是 RSA 算法）：
     ```bash
     ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
     ```
     - `-t rsa` 指定使用 RSA 算法。
     - `-b 4096` 设置密钥长度为 4096 位。
     - `-C "your_email@example.com"` 添加注释（可省略）。

  3. **设置密钥保存路径**：  
     系统会提示：
     ```
     Enter file in which to save the key (/home/username/.ssh/id_rsa):
     ```
     - 按 Enter 使用默认路径：`~/.ssh/id_rsa`。
     - 如果要自定义路径，请输入完整路径。

  4. **设置密钥口令（可选）**：  
     系统会提示：
     ```
     Enter passphrase (empty for no passphrase):
     ```
     - 输入密钥的加密密码（留空表示不加密）。

  5. **检查生成的密钥文件**：  
     密钥文件通常保存在 `~/.ssh/` 目录下：
     - 私钥：`id_rsa`
     - 公钥：`id_rsa.pub`

  6. **配置公钥到远程账户（如有需要）**：  
     将公钥内容添加到 `~/.ssh/authorized_keys` 文件中以启用免密登录：
     ```bash
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
     chmod 700 ~/.ssh
     chmod 600 ~/.ssh/authorized_keys
     ```

  完成后，即可使用私钥进行 SSH 免密登录。


```bash
user@hostname ~]$ ssh root@pong
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the RSA key sent by the remote host is
6e:45:f9:a8:af:38:3d:a1:a5:c7:76:1d:02:f8:77:00.
Please contact your system administrator.
Add correct host key in /home/hostname /.ssh/known_hosts to get rid of this message.
Offending RSA key in /var/lib/sss/pubconf/known_hosts:4
RSA host key for pong has changed and you have requested strict checking.
Host key verification failed.
```

```bash
ssh-keygen -R <host>
ssh-keygen -R 192.168.3.10
```

## 🗒️ Answer

GLIBCXX_3.4.30 是由较新版本的 GCC 提供的，而较旧版本的 GCC（如 GCC 10）无法直接找到或使用它，因为它的标准库版本较低。要解决这个问题，可以尝试以下方法：

### 方法 1：为 GCC 10 提供对应版本的 `libstdc++.so`
1. **确认当前 `libstdc++.so` 路径：**
   检查系统中 `GLIBCXX_3.4.30` 是否存在：
   ```bash
   strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX
   ```
   如果找到了 `GLIBCXX_3.4.30`，记下路径（如 `/usr/lib/x86_64-linux-gnu/libstdc++.so.6`）。

2. **设置环境变量：**
   明确指定 GCC 10 使用的标准库路径：
   ```bash
   export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
   ```
   或直接运行：
   ```bash
   LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 gcc-10 ...
   ```

### 方法 2：安装多版本 GCC 并指定默认使用版本
如果您希望同时保留多个版本的 GCC，执行以下步骤：

1. **安装多个 GCC 版本：**
   ```bash
   sudo apt update
   sudo apt install gcc-10 g++-10 gcc-12 g++-12
   ```

2. **切换 GCC 版本：**
   使用 `update-alternatives` 切换到较新版本：
   ```bash
   sudo update-alternatives --config gcc
   sudo update-alternatives --config g++
   ```
   如果需要切回较旧版本，再重复执行以上命令。

3. **为旧版 GCC 手动指定兼容的 `libstdc++`：**
   为 GCC 10 创建一个配置文件，绑定特定 `libstdc++`，避免全局覆盖：
   ```bash
   mkdir -p $HOME/gcc10-env
   echo "/usr/lib/x86_64-linux-gnu" > $HOME/gcc10-env/libstdcxx.conf
   export LD_LIBRARY_PATH=$HOME/gcc10-env:$LD_LIBRARY_PATH
   ```

### 方法 3：编译静态链接的二进制文件
如果您需要独立运行 GCC 10 编译的程序，可以尝试将 `libstdc++` 静态链接到程序中：
```bash
g++-10 -static-libstdc++ -o output program.cpp
```

---

### 注意事项
- 不建议强行替换系统的 `libstdc++.so.6`，以免导致系统中其他程序无法正常运行。
- 如果问题依旧，可以使用容器（如 Docker）来创建隔离环境，分别运行不同版本的 GCC 和相关依赖。

## 🗒️ Answer

是的，云服务器上的 Ubuntu 版本可以更新到 22.04，但需要根据实际环境和云服务商提供的功能选择适当的升级方式。以下是常用的升级方法：

### 1. **在系统内升级**
适用于当前使用的是支持直接升级到 22.04 的版本（如 20.04 或 21.10）。

1. **更新当前系统：**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. **启用升级管理器：**
   ```bash
   sudo apt install update-manager-core
   ```
3. **启动升级：**
   ```bash
   sudo do-release-upgrade
   ```
   如果是 LTS 版本（如 20.04）并希望升级到下一个 LTS，请确保运行以下命令启用升级到 LTS：
   ```bash
   sudo do-release-upgrade -d
   ```

### 2. **通过云服务商的镜像重装**
部分云服务商（如阿里云、腾讯云、AWS 等）提供镜像管理工具，可以直接选择 Ubuntu 22.04 镜像重新部署服务器。如果当前系统版本过老（如 18.04 或更早），推荐使用此方法，避免复杂的升级过程可能带来的兼容性问题。

### 3. **升级注意事项**
- **备份数据：** 无论使用哪种方法，升级前务必备份重要数据。
- **兼容性检查：** 确保安装的服务、应用和驱动在 Ubuntu 22.04 上兼容。
- **网络条件：** 确保升级过程中有稳定的网络连接，避免中断。

完成升级后，可以通过以下命令确认版本：
```bash
lsb_release -a
```

## 🗒️ Answer

If you encounter the error "Please install all available updates for your release before upgrading" while trying to upgrade Ubuntu, it means there are pending updates that need to be installed before you can proceed with the release upgrade. To resolve this:

1. **Update your current system**:
   Run the following commands to ensure your system is fully updated:
   ```bash
   sudo apt update
   sudo apt upgrade
   sudo apt dist-upgrade
   ```

2. **Install updates**:
   After running the commands above, if any updates are pending, they will be installed. Once the process completes, you should be able to proceed with the upgrade using:
   ```bash
   sudo do-release-upgrade
   ```

3. **Check for specific errors**:
   If you still face issues, check if any specific packages or updates are blocked or failed during the update process. These should be resolved before attempting the release upgrade again.

After successfully installing all updates, try the release upgrade command again.

## pdb

如果希望删除所有断点，可以直接使用 `cl` 命令，不带参数：

(Pdb) cl

## 如何用vscode查找一个txt文件中大于5000的数值

要在 VSCode 中查找一个 `.txt` 文件中大于 5000 的数值，可以按照以下步骤操作：

1. **使用正则表达式搜索数值：**

   - 按 `Ctrl + F` 打开查找窗口。

   - 点击右侧的 **`.\*` 图标**，启用正则表达式模式。

   - 输入以下正则表达式查找大于 5000 的数字：

     ```
     \b([5-9]\d{3}|\d{5,})\b
     ```

     - `\b` 表示单词边界，确保匹配独立的数字。
     - `[5-9]\d{3}` 匹配 5000 到 9999。
     - `\d{5,}` 匹配五位或更多的数字。

2. **查看匹配结果：**

   - VSCode 会在文件中高亮所有匹配项。
   - 按 `Enter` 可以依次跳转到每个匹配项。

3. **全局文件查找：**

   - 按 `Ctrl + Shift + F` 打开全局查找。
   - 同样使用上述正则表达式在整个工作区查找。

### 注意

如果数字与其他字符相连或有不同分隔符，可以调整正则表达式。例如，若数字有逗号分隔，可用：

```
\b([5-9]\d{2}(,\d{3})*|\d{5,})\b
```

# 配置一个新服务器流程

## linux新建一个用户，并添加root权限和密码

以下是新建用户并赋予其 `root` 权限的步骤：

### 1. 创建新用户并设置密码

```bash
sudo useradd -m -s /bin/bash username
sudo passwd username
```

- `-m`：为用户创建主目录。
- `-s /bin/bash`：指定默认 shell。
- 将 `username` 替换为你要创建的用户名。

### 2. 将用户添加到 `sudo` 组

```bash
sudo usermod -aG sudo username
```

这会将用户添加到 `sudo` 组，允许其执行 `sudo` 命令。

### 3. 验证用户是否具有 `sudo` 权限

切换到新用户：

```bash
su - username
```

测试 `sudo` 权限：

```bash
sudo whoami
```

如果返回 `root`，表示用户权限配置成功。

### 4. 通过编辑 `sudoers` 文件赋予更高权限（可选）

如需进一步自定义权限：

```bash
sudo visudo
```

在 `root ALL=(ALL:ALL) ALL` 下添加：

```text
username ALL=(ALL:ALL) ALL
```

保存并退出 (`Ctrl + O` 保存, `Ctrl + X` 退出)。

用户现已具备完整 `root` 权限。

## ssh远程登录禁用密码

要禁用 SSH 的密码登录，仅允许密钥登录，可以按照以下步骤操作：

1. **配置 SSH 服务**：

   - 编辑 SSH 配置文件：

     ```bash
     sudo vi /etc/ssh/sshd_config
     ```

   - 查找以下参数并修改：

     ```text
     PasswordAuthentication no
     ChallengeResponseAuthentication no
     UsePAM no
     ```

   - 确保 `PubkeyAuthentication yes` 参数已经启用。

2. **添加公钥**：

   - 确保服务器的 `~/.ssh/authorized_keys` 文件包含你的公钥。

   - 如果公钥未添加，可以使用以下命令：

     ```bash
     ssh-copy-id user@remote_server
     ```

3. **重启 SSH 服务**：

   - 使配置生效：

     ```bash
     sudo systemctl restart sshd
     ```

4. **验证配置**：

   - 在配置生效前，**不要关闭当前终端**，新开一个终端测试密钥登录，确保配置正确。
   - 如果密钥登录成功且无密码提示，则配置已生效。

5. **附加建议**：

   - 禁止 

     ```
     root
     ```

      用户直接登录（增强安全性），修改 

     ```
     /etc/ssh/sshd_config
     ```

     ：

     ```text
     PermitRootLogin no
     ```

   - 再次重启 SSH 服务以应用配置。

此设置提高了服务器的安全性，防止因弱密码或暴力破解导致的潜在风险。

## 查看ubuntu版本，并升级到24.04（对齐版本）

1. **查看当前Ubuntu版本**： 打开终端，输入以下命令以查看当前系统的Ubuntu版本：

   ```bash
   lsb_release -a
   ```

   或者：

   ```bash
   cat /etc/os-release
   ```

   这将显示Ubuntu的版本信息。

2. **备份重要数据**： 在进行版本升级之前，务必备份您的数据。可以使用 `Timeshift` 或其他备份工具进行系统备份，以防万一升级失败。

3. **升级到Ubuntu 24.04 LTS**：

   - **方法一：通过命令行使用 `do-release-upgrade` 升级**：

     - 首先，更新当前系统的软件包：

       ```bash
       sudo apt update && sudo apt upgrade -y
       sudo apt dist-upgrade -y
       ```

     - 安装 

       ```
       update-manager-core
       ```

       ，如果尚未安装：

       ```bash
       sudo apt install update-manager-core
       ```

     - 然后运行以下命令进行版本升级：

       ```bash
       sudo do-release-upgrade
       ```

     - 按照提示进行升级，系统会自动检查更新并提供升级的步骤。

   - **方法二：通过修改软件源配置手动升级**：

     - 打开 `/etc/apt/sources.list` 文件，将源更改为 Ubuntu 24.04 的版本。
     - 修改 `/etc/apt/sources.list.d/` 目录下的源文件，确保它们指向 `focal`（Ubuntu 22.04）改为 `jammy` 或 `noble`（对应的24.04源）。

4. **重启系统**： 升级完成后，按照提示重启系统。

5. **验证升级成功**： 升级完成后，再次运行 `lsb_release -a` 命令，确保显示的是Ubuntu 24.04版本。

通过以上步骤，您可以顺利地将Ubuntu系统升级到24.04版本。

## Linux 系统中配置 `sudo` 权限不输入密码

要在 Linux 系统中配置 `sudo` 权限不输入密码，可以按照以下步骤进行设置：

### 步骤 1：编辑 sudoers 文件

1. 使用 

   ```
   visudo
   ```

    命令打开 sudoers 文件：

   ```bash
   sudo visudo
   ```

   这个命令会自动检测语法错误，防止出现配置错误。

### 步骤 2：找到相应的用户或用户组

1. 在文件中找到类似下面的行：

   ```
   %sudo   ALL=(ALL:ALL) ALL
   ```

   或者类似的行，表示 

   ```
   sudo
   ```

    组的成员可以执行所有命令。

### 步骤 3：禁用密码要求

1. 在相应的用户或者用户组的配置行后面，添加 `NOPASSWD:`，比如：

   ```bash
   %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
   ```

   这行配置意味着，属于 `sudo` 组的用户在执行 `sudo` 命令时，不再需要输入密码。

2. 如果你只想让某个特定用户免密，可以添加类似下面的配置：

   ```bash
   username ALL=(ALL) NOPASSWD: ALL
   ```

   这里的 `username` 是你希望免密码的用户名。

### 步骤 4：保存并退出

1. 编辑完成后，按 `Ctrl + X`，然后按 `Y` 确认保存并退出编辑。

### 步骤 5：测试配置

1. 配置完成后，可以用以下命令测试是否生效：

   ```bash
   sudo ls
   ```

   如果一切正常，应该不再要求输入密码。

### 注意事项：

- 这种配置可能会带来安全风险，特别是当用户能够不输入密码就执行系统命令时，因此应当谨慎使用，确保仅对可信用户或用户组进行此操作。
- 记得在执行 `visudo` 时，使用正确的文本编辑器，避免编辑错误导致系统无法正常使用 `sudo`。

通过上述步骤，你就可以配置 `sudo` 免密码登录。
