# QUIC+Dash+web服务器部署的思路和准备

[TOC]

## 开始前的准备

### GitHub

GitHub对于找到quic相关的资料非常好用，应该充分了解并且会熟练运用；

GitHub的新手教程：https://zhuanlan.zhihu.com/p/388451230

### 阿里云服务器

阿里云服务器用来作为我实验的服务器使用，quic和dash都需要用它，与实验关系密切

申请要求：一个普通服务器（可以直接通过后台登录不怕搞崩），100r以内

阿里云申请服务器教程：https://blog.csdn.net/SoulNone/article/details/126902213

## QUIC+Dash+web服务器的部署顺序及思路

### 目前的基本思路

QUIC->Web服务器->Dash

### QUIC部署要求

同时支持cubic和BBR

参考：https://github.com/quicwg/base-drafts/wiki/Implementations

#### QUIC所支持的拥塞控制协议

| QUIC版本                                         | Roles                                                        | 支持什么拥塞控制                           | 语言                  | 是否能使用HTTP3 |
| ------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------ | --------------------- | --------------- |
| aioquic                                          | client, server, library                                      | 未在src中找到拥塞控制                      | Python                | 否              |
| Akamai QUIC                                      | Server                                                       | 未找到源码                                 | 无语言证明            | 是              |
| AppleQUIC                                        | Client, Server                                               | 未找到源码                                 | C, Objective-C, Swift | 否              |
| **ats**（重点使用 Quiche ）                      | Server, Client                                               | BBR，cubic，reno（同时可以在 nginx上部署） | C++                   | 否              |
| **Chromium**（要下载整个平台，很难搞）           | library, client, server                                      | BBR，cubic                                 | C，C++                | 是              |
| f5                                               | Server, Client                                               | 与nginx-quic有关，未找到拥塞控制           | C                     |                 |
| haproxy                                          | server                                                       | 未在src中找到拥塞控制                      | C                     |                 |
| Haskell quic                                     | client, server, library                                      | 未在源码中找到拥塞控制                     | Haskell               |                 |
| kwik                                             | client, client library, server                               | 有自己的拥塞控制                           | Java                  |                 |
| **lsquic**（有开源服务器）                       | Client, Server, Library                                      | BBR，cubic                                 | C                     | 是              |
| **MsQuic**                                       | client, server                                               | BBR，cubic                                 | C                     |                 |
| **mvfst**（Facebook常用，找一下有没有web服务器） | client, server, library                                      | BBR,Copa,NewReno,CCP,Cubic                 | C++                   |                 |
| Neqo                                             | library, client, server (服务器主要用于客户端测试，对抗放大等重要功能的支持不完整或缺失) | 有自己的拥塞控制                           | Rust                  |                 |
| ngtcp2（nghttp3）                                | client, library, server                                      | 未在源码中找到拥塞控制                     | C                     | 是              |
| nginx                                            | server                                                       | 未在源码中找到拥塞控制                     | C                     |                 |
| nginx-cloudflare                                 | server                                                       | 未找到源码                                 | C                     |                 |
| **picoquic**                                     | library and test tools, test client, test server             | BBR，cubic                                 | C                     |                 |
| **Pluginized QUIC**                              | library, client and server                                   | BBR，cubic                                 | C (and eBPF)          |                 |
| quant                                            | client, library, server                                      | 未在源码中找到拥塞控制                     | C                     |                 |
| **quiche**                                       | library, client, server                                      | BBR，cubic，Reno                           | Rust                  | 是              |
| quicly                                           | client and server                                            | 未在源码中找到拥塞控制                     | C                     |                 |
| **Quinn**                                        | library, client, server                                      | BBR，cubic，new_reno                       | Rust                  |                 |
| quic-go                                          | client, library, server                                      | cubic                                      | Go                    |                 |
| s2n-quic                                         | library, client, server                                      | 有自己的拥塞控制                           | Rust                  |                 |
| **XQUIC**                                        | Client, Server, Library                                      | BBR，cubic，new_reno                       | C                     | 是              |
| Flupke                                           | client, client library, server                               | 未在源码中找到拥塞控制                     | Java                  | 是              |
| Node.js QUIC                                     | client, server                                               | 未在源码中找到拥塞控制                     | C++， JavaScript      | 是              |
| proxygen                                         | library, sample server/client                                | 未在源码中找到拥塞控制                     | C++                   | 是              |

- `client`- 支持连接的客户端角色/端。
- `server`- 支持连接的服务器角色/端。这包括诸如创建“侦听器”以接受传入连接之类的事情。
- 支持的协议越多越好

最好找同时支持客户端和服务器端的QUIC，语言选择自己最熟悉的，同时支持BBR和cubic的QUIC协议。决定在**Chromium**和**XQUIC**中选出一个作为要部署的QUIC

#### Chromium部署要求

仅在小端平台上受支持，https://quiche.googlesource.com/quiche/

下载命令：

```
git clone https://quiche.googlesource.com/quiche
```

要将 QUICHE 嵌入您的项目，需要实施平台 API 并创建构建文件。请注意，QUICHE 团队的路线图包括所有平台 API 的默认实现和开源构建文件。

Chromium需要100G的硬盘来下载整个项目，才可以使用quic，nginx支持，很难部署也很难改

#### XQUIC部署要求

https://github.com/alibaba/xquic/blob/main/docs/docs-zh/README-zh.md

QUIC开源库
1.google的gquic 起源最早, 不过它不是单独项目, 代码在chromium项目里边, 用的 是c++写的, 可能不是很适合。
2.微软的msquic, 用c写的, 跨平台, 不过开始得比较晚。
3.facebook的quic 用的是c++写的. 暂不考虑。
4.nginx的quic 没有自带client, 但它可与ngtcp2联调。
5.litespeed的 lsquic 是基于MIT的, 开始于2017年, 还算比较稳定, 用c语言编写, 各 主流平台都有通过测试, 有server/client/lib, 它用于自家的各种产品, 暂时看上去 是最合适的。
6.ngtcp2, 它是一个实验性质的quic client, 很简洁, 实现了几乎每一版ietf draft. 从 代码简洁性上来看, 它无疑是最好的。目前srs流媒体服务器、curl等开源项目有 基于ngtcp2做二次开发。

### web服务器部署要求

支持上述的quic

下面是你能够开箱即用的完整Web服务器（和当前的HTTP/3支持一起）的部分名单：

#### Apache

目前支持尚不明朗。还没有宣布任何支持。它可能还需要OpenSSL。（注意，它有一个Apache Traffic Server 实现[49]）。

#### NGINX（nginx-cloudflare，ats）

NGINX是定制化实现。它的实现时间不长，依然处于高度试验阶段。它有望在2021年底合并到NGINX主线。注意，还有一个补丁可以在 NGINX上运行Cloudflare 的quiche库，它目前可能更稳定。备选

#### Node.js（ngtcp2）

Node.js内部使用ngtcp2库。Node.js被OpenSSL进程所阻止，尽管它计划切换到QUIC-TLS fork以提升运行速度，ngtcp2未在源码中找到拥塞控制，否决

#### IIS（MsQuic）

目前支持尚不明朗，且没有宣布任何支持。不过它将有可能内部使用MsQuic库。

#### Hypercorn（aioquic）

Hypercorn集成了aioquic，试验性支持HTTP/3。aioquic未在src中找到拥塞控制

#### Caddy（quic-go）

Caddy[56]使用quic-go，全面支持HTTP/3。

不行，因为caddy -quic以go语言写成，caddy的quic支持也是主要通过 lucas-clemente/quic-go 来实现，但是quic-go只支持cubic，不符合要求，否定

#### H2O（quicly，picoquic）

H2O[57]使用quicly，全面支持HTTP/3，quicly未在源码中找到拥塞控制，否定

使用picoquic，picoquic支持cubic和BBR，但仅支持测试版本的客户端 和服务器端，备选

#### Envoy（Chromium）

##### 什么是Envoy

Envoy是一种 L7 代理和通信总线，专为大型现代面向服务的架构而设计。

Envoy最初由Lyft构建，是一个专为单一服务和应用程序设计的高性能 C++ 分布式代理，以及为大型微服务“服务网格”架构设计的通信总线和“通用数据平面”。基于对 NGINX、HAProxy、硬件负载均衡器和云负载均衡器等解决方案的学习，Envoy 与每个应用程序一起运行，并通过以与平台无关的方式提供通用功能来抽象网络。

#### OpenLiteSpeed（Lsquic）

##### 什么是OpenLiteSpeed

OpenLiteSpeed是款轻量级、高性能的Web服务器，与Nginx、Apache类似，可用于搭建网站的环境，性能上，LiteSpeed在WordPress、Magento 2、Joomla、OpenCart、HTTP/3等方面的测试上要比Apache、Nginx表现要好

OpenLitespeed使用LSQUIC，全面支持HTTP/3。

#### ASP.NET Core 中的 Kestrel Web 服务器实现（MsQuic）

##### ASP.NET Core

ASP.NET Core是一个免费且开放源代码的Web框架，以及由微软和社区开发的下一代ASP.NET。它是一个模块化框架，既可以Windows上的完整.NET Framework上运行，也可以在跨平台.NET Core上运行。

##### Kestrel

Kestrel 是包含在 ASP.NET Core 项目模板中的 Web 服务器，默认处于启用状态。

#### Proxygen：Facebook 的 C++ HTTP 库（mvfst）

Proxygen 支持 HTTP/3！

它依赖于用于[IETF QUIC传输实现的 Facebook 的](https://github.com/quicwg/base-drafts)[mvfst](https://github.com/facebookincubator/mvfst) 库，因此我们将该依赖项设为可选。您可以使用 构建 HTTP/3 代码、测试和示例二进制文件。`./build.sh --with-quic`

请注意一些重要的微妙差异：

即使“全面支持”也只是说“尽其所能”，而非“生产就绪（production-ready）”。比如，许多实现还没有全面支持连接迁移、0-RTT、服务器推送或HTTP/3优先级。

据我所知，其他没有列出的服务器（比如Tomcat）也没有宣布支持。

在列出的Web服务器中，只有 Litespeed、Cloudflare的NGINX 补丁和 H2O 是由密切参与 QUIC 和HTTP/3 标准化的人员开发的，因此这些服务器最有可能在早期效果最好。

如你所知，服务器的环境还没有完全成熟，但是肯定已经存在设置HTTP/3服务器的选项。但仅运行在服务器之上只是第一步，配置它和网络的其余部分才难上加难。

您将需要至少 3 GiB 的内存来编译`proxygen`及其依赖项。

#### Tengine（XQUIC）

Tengine是由淘宝网发起的Web服务器项目。它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。它的目的是打造一个高效、安全的Web平台。

支持XQUIC，备选

https://github.com/alibaba/tengine

### Dash部署要求

最好下载dash.js项目自己写播放页面，且可以在上述web服务器上搞出来

### 最后的部署思路

mvfst->Proxygen->Dash（Facebook的部署思路）

### 实验过程

#### 阿里云服务器申请（要求：100y以内，不要图形化界面）

试用（2.20-3.20）：2核4G，1M网络带宽，100G硬盘，Ubuntu22.04，所在地域：华北1（青岛），产品规格族：ecs.n4

打开云服务器-》创建新用户-》更改sudo权限-》在新用户wqn下开始部署

#### folly部署安装

根据：https://github.com/facebook/folly

出现The source directory "/home/wqn/work" does not appear to contain CMakeLists.txt：sudo cmake .. /home/wqn/work/folly

出现CMake Error at CMakeLists.txt:435 (add_library):
  Target "folly" links to target "fmt::fmt" but the target was not found.
  Perhaps a find_package() call is missing for an IMPORTED target, or an
  ALIAS target is missing?：fmt库缺失，下载fmt库

GitHub官方安装流程：

git clone https://github.com/facebook/folly
mkdir folly/build_ && cd folly/build_（是错的，建立 _build文件夹才是对的）
cmake ..
make -j $(nproc)
sudo make install

#### fizz部署安装

根据https://github.com/facebookincubator/fizz

#### mvfst的部署安装（实现quic）

！！！！重大问题：**错误：ninja: build stopped: subcommand failed.**：这是因为AckHandlerTest.cpp太大了，编译不了，把该文件拷出来用空文件替代即可。

根据：https://github.com/facebookincubator/mvfst

遇到下载不了依赖项的问题：升级一下apt-get

当cmake提示Could NOT find OpenSSL, try to set the path to OpenSSL root folder in the system variable时：sudo apt install libssl-dev

解决urllib.error.URLError: ＜urlopen error [Errno 104] Connection reset by peer＞：关闭vpn

sudo python3 ./build/fbcode_builder/getdeps.py --allow-system-packages build mvfst --install-prefix=$(pwd)/_build下载不了的时候可以改成root试试看

解决“Could not find OpenSSL. Install an OpenSSL development package”：sudo apt-get install libssl-dev

##### 测试：

```
cd $(python3 ./build/fbcode_builder/getdeps.py show-build-dir mvfst)/quic/samples/echo
```

./echo -mode=server -host=<host> -port=<port>

./echo -mode=client -host=<host> -port=<port>

#### re2c 安装

sudo yum install autoconf 

sudo yum install automake 

sudo yum install libtool 

git clone https://github.com/skvadrik/re2c 

cd re2c

 ./autogen.sh

 ./configure 

make 

sudo make install

sudo apt install re2c

#### proxygen部署（实现HTTP3）wqn.dfshan.net

git clone https://github.com/facebook/proxygen.git

cd proxygen 

./getdeps.sh 

cd _build/ && make test

自己下的依赖项：

1) git clone https://github.com/fmtlib/fmt.git
2) git clone https://github.com/google/googletest.git
3) git clone https://github.com/facebook/zstd.git
4) git clone https://github.com/facebook/folly.git
5) git clone https://github.com/facebookincubator/fizz
6) git clone https://github.com/facebook/wangle
7) git clone https://github.com/facebookincubator/mvfst

root@wqn:~/work/proxygen/proxygen/_build/deps/folly# ls
build  build.bat  build.sh  CMake  CMakeLists.txt  CODE_OF_CONDUCT.md  CONTRIBUTING.md  folly  LICENSE  README.md  static

root@wqn:~/work/proxygen/proxygen/_build/deps/fizz# ls
build  CODE_OF_CONDUCT.md  CONTRIBUTING.md  fizz  LICENSE  logo2x.png  README.md

root@wqn:~/work/proxygen/proxygen/_build/deps/wangle# ls
build  CONTRIBUTING.md  LICENSE  README.md  tutorial.md  wangle

root@wqn:~/work/proxygen/proxygen/_build/deps/mvfst# ls
build  build_helper.sh  cmake  CMakeLists.txt  CODE_OF_CONDUCT.md  CONTRIBUTING.md  getdeps.sh  install.sh  LICENSE  logo.png  quic  README.md

测试：_build/proxygen/httpserver/hq --mode=server --port=8080 --h2port=8080 --protocol=h3-29 --connect_udp=true

curl -v -k  https://localhost:8080

#### tcpdump抓本地包

tcpdump -nnvv -i lo port 80 -w test.pcap

test失败：

```
1346/1367 Testing: ConnectionFilterTest.Test
1346/1367 Test: ConnectionFilterTest.Test
Command: "/root/work/proxygen/proxygen/_build/proxygen/httpserver/tests/HTTPServerTests" "--gtest_filter=ConnectionFilterTest.Test"
Directory: /root/work/proxygen/proxygen/_build/proxygen/httpserver/tests
"ConnectionFilterTest.Test" start time: Feb 24 17:29 CST

Output:
----------------------------------------------------------

Note: Google Test filter = ConnectionFilterTest.Test
[==========] Running 1 test from 1 test suite.
[----------] Global test environment set-up.
[----------] 1 test from ConnectionFilterTest
[ RUN      ] ConnectionFilterTest.Test
*** Aborted at 1677230993 (unix time) try "date -d @1677230993" if you are using GNU date ***
PC: @                0x0 (unknown)
*** SIGSEGV (@0xa8) received by PID 23566 (TID 0x7fba499ff440) from PID 168; stack trace: ***
    @     0x7fba4c771046 (unknown)
    @     0x7fba4bb96520 (unknown)
```



    @     0x7fba4bb96520 (unknown)
    @     0x5555ef38ef74 proxygen::HTTPMessage::getStatusCode()
    @     0x5555ef281eb8 ConnectionFilterTest_Test_Test::TestBody()
    @     0x5555ef4644bf testing::internal::HandleExceptionsInMethodIfSupported<>()
    @     0x5555ef4553e6 testing::Test::Run()
    @     0x5555ef45562d testing::TestInfo::Run()
    @     0x5555ef455d33 testing::TestSuite::Run()
    @     0x5555ef45af3c testing::internal::UnitTestImpl::RunAllTests()
    @     0x5555ef464a87 testing::internal::HandleExceptionsInMethodIfSupported<>()
    @     0x5555ef455710 testing::UnitTest::Run()
    @     0x5555ef27648b main
    @     0x7fba4bb7dd90 (unknown)
    @     0x7fba4bb7de40 __libc_start_main
    @     0x5555ef277a05 _start
```
<end of output>

Test time =   0.19 sec
----------------------------------------------------------

Test Failed.
"ConnectionFilterTest.Test" end time: Feb 24 17:29 CST

"ConnectionFilterTest.Test" time elapsed: 00:00:00
----------------------------------------------------------
```

测试

```
_build/proxygen/httpserver/hq \
        --mode=server \
        --h2port=8080 \
        --port=8443 \
        --protocol=h3 \
        --cert=keys/server.pem \
        --key=keys/server.key \
        --static-root=./ \
        --host=0.0.0.0 \
        --connect_udp=true
_build/proxygen/httpserver/hq \     
        --mode=client \
        --port=8443 \
        --host=0.0.0.0 \
        --path=https://120.79.36.107:8443/test.html
curl -v -k https://120.79.36.107:8080/test.html      

```

可以通过winscp来互传文件

```
root@wqn:~/work/proxygen/proxygen# _build/proxygen/httpserver/hq         --help
hq: Warning: SetUsageMessage() never called

  Flags from ./src/logging.cc:
    -alsologtoemail (log messages go to these email addresses in addition to
      logfiles) type: string default: ""
    -alsologtostderr (log messages go to stderr in addition to logfiles)
      type: bool default: false
    -colorlogtostderr (color messages logged to stderr (if supported by
      terminal)) type: bool default: false
    -drop_log_memory (Drop in-memory buffers of log contents. Logs can grow
      very quickly and they are rarely read before they need to be evicted from
      memory. Instead, drop them from memory as soon as they are flushed to
      disk.) type: bool default: true
    -log_backtrace_at (Emit a backtrace when logging at file:linenum.)
      type: string default: ""
    -log_dir (If specified, logfiles are written into this directory instead of
      the default logging directory.) type: string default: ""
    -log_link (Put additional links to the log files in this directory)
      type: string default: ""
    -log_prefix (Prepend the log prefix to the start of each log line)
      type: bool default: true
    -logbuflevel (Buffer log messages logged at this level or lower (-1 means
      don't buffer; 0 means buffer INFO only; ...)) type: int32 default: 0
    -logbufsecs (Buffer log messages for at most this many seconds) type: int32
      default: 30
    -logemaillevel (Email log messages logged at this level or higher (0 means
      email all; 3 means email FATAL only; ...)) type: int32 default: 999
    -logfile_mode (Log file mode/permissions.) type: int32 default: 436
    -logmailer (Mailer used to send logging email) type: string
      default: "/bin/mail"
    -logtostderr (log messages go to stderr instead of logfiles) type: bool
      default: true
    -max_log_size (approx. maximum log file size (in MB). A value of 0 will be
      silently overridden to 1.) type: int32 default: 1800
    -minloglevel (Messages logged at a lower level than this don't actually get
      logged anywhere) type: int32 default: 0
    -stderrthreshold (log messages at or above this level are copied to stderr
      in addition to logfiles.  This flag obsoletes --alsologtostderr.)
      type: int32 default: 2
    -stop_logging_if_full_disk (Stop attempting to log to disk if the disk is
      full.) type: bool default: false

  Flags from ./src/utilities.cc:
    -symbolize_stacktrace (Symbolize the stack trace in the tombstone)
      type: bool default: true

  Flags from ./src/vlog_is_on.cc:
    -v (Show all VLOG(m) messages for m <= this. Overridable by --vmodule.)
      type: int32 default: 0
    -vmodule (per-module verbose level. Argument is a comma-separated list of
      <module name>=<log level>. <module name> is a glob pattern, matched
      against the filename base (that is, name ignoring .cc/.h./-inl.h). <log
      level> overrides any value given by --v.) type: string default: ""



  Flags from /build/gflags-WDCpEz/gflags-2.2.2/src/gflags.cc:
    -flagfile (load flags from file) type: string default: ""
    -fromenv (set flags from the environment [use 'export FLAGS_flag1=value'])
      type: string default: ""
    -tryfromenv (set flags from the environment if present) type: string
      default: ""
    -undefok (comma-separated list of flag names that it is okay to specify on
      the command line even if the program does not define a flag with that
      name.  IMPORTANT: flags in this list that have arguments MUST use the
      flag=value format) type: string default: ""

  Flags from /build/gflags-WDCpEz/gflags-2.2.2/src/gflags_completions.cc:
    -tab_completion_columns (Number of columns to use in output for tab
      completion) type: int32 default: 80
    -tab_completion_word (If non-empty, HandleCommandLineCompletions() will
      hijack the process and attempt to do bash-style command line flag
      completion on this value.) type: string default: ""

  Flags from /build/gflags-WDCpEz/gflags-2.2.2/src/gflags_reporting.cc:
    -help (show help on all flags [tip: all flags can have two dashes])
      type: bool default: false currently: true
    -helpfull (show help on all flags -- same as -help) type: bool
      default: false
    -helpmatch (show help on modules whose name contains the specified substr)
      type: string default: ""
    -helpon (show help on the modules named by this flag value) type: string
      default: ""
    -helppackage (show help on all modules in the main package) type: bool
      default: false
    -helpshort (show help on only the main module for this program) type: bool
      default: false
    -helpxml (produce an xml version of help) type: bool default: false
    -version (show version and build info and exit) type: bool default: false



  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/detail/MemoryIdler.cpp:
    -folly_memory_idler_purge_arenas (if enabled, folly memory-idler purges
      jemalloc arenas on thread idle) type: bool default: true



  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/executors/CPUThreadPoolExecutor.cpp:
    -dynamic_cputhreadpoolexecutor (CPUThreadPoolExecutor will dynamically
      create and destroy threads) type: bool default: true

  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/executors/GlobalExecutor.cpp:
    -folly_global_cpu_executor_threads (Number of threads global
      CPUThreadPoolExecutor will create) type: uint32 default: 0
    -folly_global_cpu_executor_use_throttled_lifo_sem (Use ThrottledLifoSem in
      global CPUThreadPoolExecutor) type: bool default: true
    -folly_global_cpu_executor_wake_up_interval_us (If
      --folly_global_cpu_executor_use_throttled_lifo_sem is true, use this
      wake-up interval (in microseconds) in ThrottledLifoSem) type: uint32
      default: 0
    -folly_global_io_executor_threads (Number of threads global
      IOThreadPoolExecutor will create) type: uint32 default: 0

  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/executors/IOThreadPoolExecutor.cpp:
    -dynamic_iothreadpoolexecutor (IOThreadPoolExecutor will dynamically create
      threads) type: bool default: true

  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/executors/ThreadPoolExecutor.cpp:
    -threadtimeout_ms (Idle time before ThreadPoolExecutor threads are joined)
      type: int64 default: 60000



  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/experimental/observer/detail/ObserverManager.cpp:
    -observer_manager_pool_size (How many internal threads ObserverManager
      should use) type: int32 default: 4



  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/init/Init.cpp:
    -logging (Logging configuration) type: string default: ""



  Flags from /root/work/proxygen/proxygen/_build/deps/folly/folly/synchronization/Hazptr.cpp:
    -folly_hazptr_use_executor (Use an executor for hazptr asynchronous
      reclamation) type: bool default: true



  Flags from /root/work/proxygen/proxygen/_build/deps/mvfst/quic/server/QuicServer.cpp:
    -qs_io_uring_use_async_recv (io_uring backend use async recv) type: bool
      default: true



  Flags from /root/work/proxygen/proxygen/_build/deps/wangle/wangle/ssl/SSLSessionCacheManager.cpp:
    -dcache_unit_test (All VIPs share one session cache) type: bool
      default: false



  Flags from /root/work/proxygen/proxygen/httpserver/samples/hq/HQCommandLine.cpp:
    -body (Filename to read from for POST requests) type: string default: ""
    -ccp_config (Additional args to pass to ccp. Ccp disabled if empty string.)
      type: string default: ""
    -cert (Certificate file path) type: string default: ""
    -client_auth_mode (Client authentication mode) type: string default: "none"
    -congestion (newreno/cubic/bbr/none) type: string default: "cubic"
    -conn_flow_control (Connection flow control) type: int32 default: 10485760
    -connect_timeout ((HQClient) connect timeout in ms) type: int32
      default: 2000
    -connect_udp (Whether or not to use connected udp sockets) type: bool
      default: false
    -d6d_base_pmtu (Client only. The base PMTU advertised to server)
      type: uint32 default: 1252
    -d6d_blackhole_detection_threshold (Server only. PMTU blackhole detection
      threshold, in # of packets) type: uint32 default: 5
    -d6d_blackhole_detection_window_secs (Server only. PMTU blackhole detection
      window in secs) type: uint32 default: 5
    -d6d_enabled (Enable d6d) type: bool default: false
    -d6d_probe_raiser_constant_step_size (Server only. The constant step size
      used to increase PMTU, only meaningful to ConstantStep probe size raiser)
      type: uint32 default: 10
    -d6d_probe_raiser_type (Server only. The type of probe size raiser. 0:
      ConstantStep, 1: BinarySearch) type: uint32 default: 0
    -d6d_probe_timeout_secs (Client only. The probe timeout advertised to
      server) type: uint32 default: 600
    -d6d_raise_timeout_secs (Client only. The raise timeout advertised to
      server) type: uint32 default: 600
    -early_data (Whether to use 0-rtt) type: bool default: false
    -h2port (HTTP/2 server port) type: int32 default: 6667
    -headers (List of N=V headers separated by ,) type: string default: ""
    -host (HQ server hostname/IP) type: string default: "::1"
    -httpversion (HTTP version string) type: string default: "1.1"
    -key (Private key file path) type: string default: ""
    -local_address (Local Address to bind to. Client only. Format should be
      ip:port) type: string default: ""
    -log_response (Whether to log the response content to stderr) type: bool
      default: true
    -log_response_headers (Whether to log the response headers to stderr)
      type: bool default: false
    -log_run_time (Whether to log the duration for which the client/server was
      running) type: bool default: false
    -logdir (Directory to store connection logs) type: string
      default: "/tmp/logs"
    -max_ack_receive_timestamps_to_send (Controls how many packet receieve
      timestamps the peer should send) type: uint32 default: 5
    -max_cwnd_mss (Max cwnd in unit of mss) type: uint32 default: 860000
    -max_receive_packet_size (Max UDP packet size Quic can receive) type: int32
      default: 1500
    -migrate_client ((HQClient) Should the HQClient make two sets of requests
      and switch sockets in the middle.) type: bool default: false
    -mode (Mode to run in: 'client' or 'server') type: string default: "server"
    -num_gro_buffers (Number of GRO buffers) type: uint32 default: 1
    -outdir (Directory to store responses) type: string default: ""
    -pacing (Whether to enable pacing on HQServer) type: bool default: false
    -pacing_timer_tick_interval_us (Pacing timer resolution) type: int32
      default: 200
    -path ((HQClient) url-path to send the request to, or a comma separated
      list of paths to fetch in parallel) type: string default: "/"
    -port (HQ server port) type: int32 default: 6666
    -pretty_json (Whether to use pretty json for QLogger output) type: bool
      default: true
    -protocol (HQ protocol version e.g. h3-29 or hq-fb-05) type: string
      default: ""
    -psk_file (Cache file to use for QUIC psks) type: string default: ""
    -qlogger_path (Path to the directory where qlog fileswill be written. File
      is called <CID>.qlog) type: string default: ""
    -quic_batch_size (Maximum number of packets that can be batched in Quic)
      type: uint32 default: 16
    -quic_batching_mode (QUIC batching mode) type: uint32 default: 0
    -quic_thread_local_delay_us (Thread local delay in microseconds)
      type: uint32 default: 1000
    -quic_use_thread_local_batching (Use thread local batching) type: bool
      default: false
    -quic_version (QUIC version to use. 0 is default) type: int64 default: 0
    -rate_limit (Connection rate limit per second per thread) type: int64
      default: -1
    -send_knob_frame (Send a Knob Frame to the peer when a QUIC connection is
      established successfully) type: bool default: false
    -sequential (Whether to make requests sequentially or in parallel when
      multiple paths are provided) type: bool default: false
    -stream_flow_control (Stream flow control) type: int32 default: 262144
    -threads (QUIC Server threads, 0 = nCPUs) type: int32 default: 0
    -transport_knobs (If send_knob_frame is set, this is the default transport
      knobs sent to peer) type: string default: ""
    -txn_timeout (HTTP Transaction Timeout) type: int32 default: 120000
    -use_ack_receive_timestamps (Replace the ACK frame with
      ACK_RECEIVE_TIMESTAMPS framewhich carries the received packet timestamps)
      type: bool default: false
    -use_inplace_write (Transport use inplace packet build and socket writing)
      type: bool default: false
    -use_version (Use set QUIC version as first version) type: bool
      default: true
```

./hq         --mode=server         --h2port=8080         --port=8443         --protocol=h3         --cert=/root/wqn.dfshan.net/cert1.pem         --key=/root/wqn.dfshan.net/privkey1.pem         --static-root=./         --host=0.0.0.0         --connect_udp=true



./hq         --mode=server         --h2port=8000         --port=8001       --protocol=h3         --cert=/home/cfz/wqn.dfshan.net/cert1.pem         --key=/home/cfz/wqn.dfshan.net/privkey1.pem         --static-root=./         --host=0.0.0.0         --connect_udp=true

./hq --mode=client  --h2port=8080         --port=8443  --host=0.0.0.0 --path=/
