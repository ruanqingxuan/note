# 实验：DASH 

[TOC]

# 的部署（客户端+服务器端）



## 一、资料准备

### nginx：HTTP和反向代理web服务器

Nginx (engine x) 是一个高性能的HTTP和反向代理web服务器，同时也提供了IMAP/POP3/SMTP服务。
其将源代码以类BSD许可证的形式发布，因它的稳定性、丰富的功能集、简单的配置文件和低系统资源的消耗而闻名。
Nginx是一款轻量级的Web 服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器，在BSD-like 协议下发行。其特点是占有内存少，并发能力强，事实上nginx的并发能力在同类型的网页服务器中表现较好。

最主流的三个Web服务器是Apache、 Nginx 、IIS。

（准备在服务器端部署该代理）

------

### FFmpeg：可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序

FFmpeg是一套可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序。采用LGPL或GPL许可证。它提供了录制、转换以及流化音视频的完整解决方案。它包含了非常先进的音频/视频编解码库libavcodec，为了保证高可移植性和编解码质量，libavcodec里很多code都是从头开发的。

（用作编码器）

------

### Bento4：视频切片工具

一个快速、现代、开源的 C++ 工具包，可满足您所有 MP4 和 DASH/HLS/CMAF 媒体格式的需求。Bento4 是一个 C++ 类库和工具，旨在读取和写入 ISO-MP4 文件。该格式是 Apple Quicktime 文件格式的衍生文件，因此 Bento4 也可用于读取和写入大多数 Quicktime 文件。除了支持 ISO-MP4，Bento4 还支持解析和多路复用 H.264 和 H.265 基本流、将 ISO-MP4 转换为 MPEG2-TS、打包 HLS 和 MPEG-DASH、<!--CMAF-->、内容加密、解密等等更多的。

（用作视频的切片工具）

------

## 二、正式开始

### nginx的下载

`wget https://nginx.org/en/download.html/nginx-1.20.2.tar.gz`

<!--PS：要用su权限打开nginx，否则报错-->

<!--关闭网页q-->

------

### 安装编码器（FFmpeg）

https://blog.csdn.net/LvGreat/article/details/103528349

------

### Bento4的下载

https://blog.csdn.net/LvGreat/article/details/103528864

------

### 部署NginxWithQUIC

https://blog.csdn.net/qq_37177958/article/details/120444034



nginx.conf 修改前

    #user  nobody;
    user root;
    worker_processes  1;
    
    #error_log  logs/error.log;
    #error_log  logs/error.log  notice;
    #error_log  logs/error.log  info;
    
    #pid        logs/nginx.pid;


​    
​    events {
​        worker_connections  1024;
​    }


​    
​    http {
​    	include       mime.types;
​    	default_type  application/octet-stream;
​    
​    	#log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
​    	#                  '$status $body_bytes_sent "$http_referer" '
​    	#                  '"$http_user_agent" "$http_x_forwarded_for"';
​    
​    	#access_log  logs/access.log  main;
​    
​    	log_format quic '$remote_addr - $remote_user [$time_local] '
​                        '"$request" $status $body_bytes_sent '                                       '"$http_referer" "$http_user_agent" "$quic"';
​    	access_log logs/access.log quic;
​    
​    	sendfile        on;
​    	#tcp_nopush     on;
​    
    	#keepalive_timeout  0;
    	keepalive_timeout  65;
    
    	#gzip  on;
    
    	server {
        	#listen       80;
        	#for quic
        	listen 443 http3 reuseport;
        	listen 443 ssl;
        	ssl_certificate server.crt;
        	ssl_certificate_key server.key;
        	ssl_protocols   TLSv1.3;
    
            server_name  localhost;
            #new
            root /usr/local/nginx/html;
    
            #charset koi8-r;
    
            #access_log  logs/host.access.log  main;
    
            location / {
                root /home/qnwang;
                #root   html;
                index  index.html index.htm;
                #new
                add_header Access-Control-Allow-Methods "GET,OPTIONS,POST,HEAD,PUT,DELETE";
                add_header Accept-Ranges "bytes";
                add_header Access-Control-Allow-Origin "*";
                add_header Access-Control-Expose-Headers "Content-Lengrh,Content-Range,Date,Server,Transfer-Encoding,origin,range,x-goog-meta-foo1";
                #index
                autoindex on;
                autoindex_exact_size off;
                autoindex_localtime on;
                #quic
                add_header Alt-Svc 'h3=":8443"; ma=86400';
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
    
            # deny access to .htaccess files, if Apache's document root
            # concurs with nginx's one
            #
            #location ~ /\.ht {
            #    deny  all;
            #}
        }


​    
​        # another virtual host using mix of IP-, name-, and port-based configuration
​        #
​        #server {
​        #    listen       8000;
​        #    listen       somename:8080;
​        #    server_name  somename  alias  another.alias;
​    
​        #    location / {
​        #        root   html;
​        #        index  index.html index.htm;
​        #    }
​        #}

        # HTTPS server
​        #
​        #server {
​        #    listen       443 ssl;
​        #    server_name  localhost;
​    

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

编译nginxQUIC版

sudo ./auto/configure                                 \
       --with-debug --with-http_v3_module  \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \

​       --with-stream_quic_module \

​       --with-cc-opt="-I../boringssl/include"   \
​       --with-ld-opt="-L../boringssl/build/ssl  \
​       -L../boringssl/build/crypto" \

```java
server {
    listen 443 ssl; # HTTP/1.1的TCP监听端口
    listen 443 http3 reuseport; # QUIC+HTTP/3的UDP监听
    ssl_protocols TLSv1.3; # QUIC 必须使用TLS 1.3
    ssl_certificate server.crt;
    ssl_certificate_key server.key;
    add_header Alt-Svc 'quic=":443"'; # 必须添加的Alt-Svc响应头
    add_header QUIC-Status $quic; # 必须添加的QUIC状态头
}
```





最后用了这个版本的nginx+quic教程

http://hk.javashuo.com/article/p-vaifumlg-vn.html



