# xquic+tengine部署

## tengine部署

部署要求：添加ngx_http_xquic_module模块[tengine/modules/ngx_http_xquic_module at master · alibaba/tengine (github.com)](https://github.com/alibaba/tengine/tree/master/modules/ngx_http_xquic_module)

采用在曙光上编译完成后再移动到阿里云服务器上进行部署

### ngx_http_xquic_module

Tengine ngx_http_xquic_module 主要用于在服务端启用 QUIC/HTTP3 监听服务。

### 编译

ngx_http_xquic_module 编译依赖

依赖库：

- Tongsuo: https://github.com/Tongsuo-Project/Tongsuo          一个加密软件
- xquic: https://github.com/alibaba/xquic              quic协议

```
# 下载 Tongsuo，示例中下载 8.3.2 版本
wget -c "https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags/8.3.2.tar.gz"
tar -xf 8.3.2.tar.gz

# 下载 xquic，示例中下载 1.6.0 版本
wget -c "https://github.com/alibaba/xquic/archive/refs/tags/v1.6.0.tar.gz"
tar -xf v1.6.0.tar.gz

# 下载 Tengine 3.0.0 以上版本，示例从 master 获取最新版本，也可下载指定版本
git clone git@github.com:alibaba/tengine.git

# 编译 Tongsuo
cd Tongsuo-8.3.2
./config --prefix=/home/qnwang/worknew/babassl
make
make install
export SSL_TYPE_STR="babassl"
export SSL_PATH_STR="${PWD}"
export SSL_INC_PATH_STR="${PWD}/include"
export SSL_LIB_PATH_STR="${PWD}/libssl.a;${PWD}/libcrypto.a"
cd ../../

# 编译 xquic 库
cd xquic-1.6.0/
mkdir -p build; cd build
cmake -DXQC_SUPPORT_SENDMMSG_BUILD=1 -DXQC_ENABLE_BBR2=1 -DXQC_DISABLE_RENO=0 -DSSL_TYPE=${SSL_TYPE_STR} -DXQC_ENABLE_TESTING=1 -DSSL_PATH=${SSL_PATH_STR} -DSSL_INC_PATH=${SSL_INC_PATH_STR} -DSSL_LIB_PATH=${SSL_LIB_PATH_STR} ..
#若为1.6.2以上版本
cmake 增加-DXQC_NO_PID_PACKET_PROCESS=1即可成功编译
make
#不在曙光上编译
cp "libxquic.so" /usr/local/lib/
#在曙光上编译不需要这步，移动到自己的服务器上用下面这步
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/qnwang/worknew/xquic-1.6.0/build
cd ..

# 编译 Tengine
cd tengine

# 注：xquic 依赖 ngx_http_v2_module，需要参数 --with-http_v2_module
./configure \
  --prefix=/home/qnwang/worknew/tengine-install \
  --sbin-path=sbin/tengine \
  --with-xquic-inc="../xquic-1.6.0/include" \
  --with-xquic-lib="../xquic-1.6.0/build" \
  --with-http_v2_module \
  --without-http_rewrite_module \
  --add-module=modules/ngx_http_xquic_module \
  --with-openssl="../Tongsuo-8.3.2"

make
make install
```

### 移动

将在曙光上编译完成后的tengine-install，babassl，xquic1.6.0三个文件夹移动到阿里云即可

**注：路径必须与编译路径一致！**

```
rsync -av babassl qnwang@udpcc.dfshan.net:/home/qnwang/worknew
rsync -av xquic-1.6.0 qnwang@udpcc.dfshan.net:/home/qnwang/worknew
rsync -av tengine-install qnwang@udpcc.dfshan.net:/home/qnwang/worknew
```

### 浏览器使用 HTTP3

**注意：浏览器访问需要确保证书受信。**

浏览器默认不会使用 `HTTP3` 请求，需要服务端响应包头 `Alt-Svc` 进行升级说明，浏览器通过响应包头感知到服务端是支持 `HTTP3` 的，下次请求会尝试使用 `HTTP3`。

nginx.conf示例：

```
worker_processes  1;

user root;

error_log  logs/error.log debug;

events {
    worker_connections  1024;
}

xquic_log   "pipe:rollback /home/qnwang/worknew/tengine-install/logs/tengine-xquic.log baknum=10 maxsize=1G interval=1d adjust=600" info;

http {
    xquic_ssl_certificate        /home/qnwang/worknew/cert/fullchain.pem;
    xquic_ssl_certificate_key    /home/qnwang/worknew/cert/privkey.pem;
    #拥塞控制需要bbr，copa，cubic三种适用，其中copa不能适用，修改在下下一节有讲
    xquic_congestion_control bbr;
    xquic_socket_rcvbuf 5242880;
    xquic_socket_sndbuf 5242880;
    xquic_anti_amplification_limit 5;

    server {
        listen 80 default_server reuseport backlog=4096;
        #注意这里的端口要在1024以上
        listen 8443 default_server reuseport backlog=4096 ssl http2;
        listen 8443 default_server reuseport backlog=4096 xquic;

        server_name udpcc.dfshan.net;
        #注意这里的端口要在1024以上
        add_header Alt-Svc 'h3=":8443"; ma=2592000,h3-29=":8443"; ma=2592000' always;
        #ssl证书即https证书，将在下一节讲到
        ssl_certificate     /home/qnwang/worknew/cert/fullchain.pem;
        ssl_certificate_key /home/qnwang/worknew/cert/privkey.pem;
        #设置了根目录，可以不用
        location / {
            root   /home/qnwang/worknew/tengine-install;
            autoindex on;
            autoindex_exact_size   on;
        }
    }

}


```
nginx.conf默认示例：
```

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
#error_log  "pipe:rollback logs/error_log interval=1d baknum=7 maxsize=2G";

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;
    #access_log  "pipe:rollback logs/access_log interval=1d baknum=7 maxsize=2G"  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        #access_log  "pipe:rollback logs/host.access_log interval=1d baknum=7 maxsize=2G"  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # pass the Dubbo rpc to Dubbo provider server listening on 127.0.0.1:20880
        #
        #location /dubbo {
        #    dubbo_pass_all_headers on;
        #    dubbo_pass_set args $args;
        #    dubbo_pass_set uri $uri;
        #    dubbo_pass_set method $request_method;
        #
        #    dubbo_pass org.apache.dubbo.samples.tengine.DemoService 0.0.0 tengineDubbo dubbo_backend;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }

    # upstream for Dubbo rpc to Dubbo provider server listening on 127.0.0.1:20880
    #
    #upstream dubbo_backend {
    #    multi 1;
    #    server 127.0.0.1:20880;
    #}

    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}

```
### 浏览器验证

#### 开启tengine

```
 cd worknew/tengine-install/sbin/
 ./tengine
```

#### 可能会出现问题

Q1：XXX can't open

A1：检查报错路径，很有可能是tongsuo或xquic的路径不对导致打不开，直接重新编译移动，注意路径一致

Q2：openssl denied

A2：ssl证书没有权限，进入cert文件夹，使用chmod 777 *解决

Q3：libxquic.so找不到

A3：在曙光上编译没办法加入系统（没有sudo权限），用export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/qnwang/worknew/xquic-1.6.0/build手动加入到系统变量里解决

Q4：nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)

A4：没有相关权限，用以下方法解决

```
cd /home/qnwang/worknew/tengine-install/sbin
sudo chown root tengine
sudo chmod u+s tengine
```

**注意：最好不在sudo权限下启动tengine，可以看到很多错，如果./tengine没有任何问题那基本配置成功**

#### 浏览器访问

```
https://udpcc.dfshan.net:8443/
```

访问成功后（Microsoft浏览器）打开f12，查看network，看到网页由h3生成即可

#### wireshark抓包确认

wireshark抓包ip.addr == 8.217.128.122 && (quic || http3) 抓到http3包即可

## HTTPS（SSL）证书

HTTPS证书（也称为SSL证书）就像您网站的身份证。它向服务器证明您的网站就是您的网站。[Certbot⁤ (eff.org)](https://certbot.eff.org/)

HTTPS 证书实际上是您的域独有的一段数字和字母。当有人通过 HTTPS 访问您的网站时，系统会检查证书。如果匹配，则流入和流出您网站的所有数据都会在之后进行加密。该流程分为两步。 首先，管理软件向证书颁发机构证明该服务器拥有域名的控制权。 之后，该管理软件就可以申请、续期或吊销该域名的证书。

### 根据教程，创建https证书

```
sudo certbot certonly --standalone --register-unsafely-without-email
```

![image](https://github.com/ruanqingxuan/note/assets/119039883/29394a3d-a8b8-4539-8ff7-4952bd3f6edd)


### 将其copy到相关目录下

```
cp /etc/letsencrypt/live/udpcc.dfshan.net/fullchain.pem /home/qnwang/worknew/cert
cp /etc/letsencrypt/live/udpcc.dfshan.net/privkey.pem /home/qnwang/worknew/cert
```

若出现权限问题，则使用chmod 777 *解决

## copa配置

用当前配置copa无法使用，需要更改一处代码将copa连接上，ngx_xquic.c -> xquic.h

将ngx_xquic.c里设置拥塞控制的代码添加上copa接口![image](https://github.com/ruanqingxuan/note/assets/119039883/635ac8a0-3839-45c6-8be2-db140559e389)

xqc_copa_cb在xquic.h中声明

![image](https://github.com/ruanqingxuan/note/assets/119039883/62d69649-8d5e-41e5-82bf-cf1ba6b5eb2b)

因为只改动了tengine里的源代码，重新编译tengine到tengine-install里并移动即可
