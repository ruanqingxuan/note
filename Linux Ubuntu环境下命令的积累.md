# Linux Ubuntu环境下命令的积累

[TOC]

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

- tar -zcvf filename.tar.gz filename

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

## vscode查找文件

ctrl+p

## wireshark去掉重复的包

editcap.exe -d D:\test\4.pcapng D:\test\4out.pacpng

## vscode翻译

alt+t
## vscode块注释
进行代码块注释的快捷键是"Alt + Shift + A"
ctrl+/
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

