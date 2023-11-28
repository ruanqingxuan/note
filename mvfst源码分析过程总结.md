# mvfst源码分析

[TOC]

https://github.com/facebookincubator/mvfst

## ChatGPT结果

mvfst 是一个由 Facebook 开发的基于 C++ 的高性能 TCP/IP 网络库，是 Folly 库的一部分。它主要用于构建高效、高可靠性的服务端应用程序。在本文中，我将介绍 mvfst 的一些重要的源码细节。

### 基本架构

mvfst 主要分为四个层次：

1. 网络层（Network Layer）：提供套接字通信和事件驱动的 I/O 操作；
2. 传输层（Transport Layer）：提供基于 TCP 的传输协议，以及数据包的拆包和组包功能；
3. QUIC 层（QUIC Layer）：提供基于 QUIC 协议的传输协议，以及重传、拥塞控制和流量控制等功能；
4. 应用层（Application Layer）：提供 HTTP/3 等高层协议。

### 套接字通信

mvfst 的套接字通信基于 libevent，使用了事件驱动的模式。它使用了封装好的 AsyncSocket 类，提供了类似于 Berkeley 套接字的接口。在 AsyncSocket 中，数据的读写操作都是非阻塞的，并且支持超时机制。

### 传输层

在传输层中，mvfst 提供了 Packetization 和 Framing 两个功能。

Packetization 主要完成的任务是将应用层的数据打包成数据包进行传输。mvfst 中实现了 PacketizationQueue 类，用于维护待发送的数据包队列，同时也提供了可配置的参数，比如最大数据包大小、数据包重传策略等。

Framing 主要完成的任务是将数据包的头部和数据部分分开处理。mvfst 中实现了 QuicPacket 和 QuicHeader 类来处理数据包的头部和数据部分，其中 QuicPacket 包含了 QuicHeader 和数据部分，QuicHeader 中包含了源地址、目的地址、流标识、ACK 策略等信息。

### QUIC 层

在 QUIC 层中，mvfst 实现了 QUIC 协议的重传、拥塞控制和流量控制等功能。

   **重传主要是根据接收到的 ACK 包，确定丢失的数据包，并进行重传。mvfst 中实现了 LossDetector 和 RtxTimer 类，分别用于丢包检测和重传计时。**

​	拥塞控制主要是根据网络拥塞情况，调整数据包的发送速率。mvfst 中实现了 CongestionController 类，通过调整拥塞窗口和拥塞阈值，控制数据包的发送速率。

​	流量控制主要是根据接收方的能力，控制发送方的数据流量。mvfst 中实现了 FlowControl 类，通过调整发送方的窗口大小，控制数据流量。

以下是 mvfst 文档的一些有用资源：

1. Mvfst GitHub 代码库：https://github.com/facebookincubator/mvfst
2. Mvfst 官方文档：https://facebookincubator.github.io/mvfst/
3. Mvfst 简介博客文章：https://engineering.fb.com/2018/08/07/data-center-engineering/mvfst/
4. Mvfst 开发者论坛：https://groups.google.com/g/mvfst-dev

## Introduction

​	mvfst（发音为move fast ）是Facebook 在 C++ 中对IETF QUIC协议的客户端和服务器实现。QUIC 是一种基于 UDP 的可靠、多路传输协议，将成为互联网标准。mvfst的目标是构建 QUIC 传输协议的高性能实现，应用程序可以适应互联网和数据中心的用例。mvfst已经在 Android、iOS 应用程序以及服务器上进行了大规模测试，并具有支持大规模部署的多项功能。

## Features

**服务器功能**：

- 具有线程本地架构的多线程 UDP 套接字服务器，能够扩展到多核服务器
- 可定制的连接 ID 路由。[默认的 Connection-Id 路由实现与katran](https://github.com/facebookincubator/katran)无缝集成
- 用于启用服务器零停机重启的 API，以便应用程序在重启时不必断开连接。
- 用于公开传输和服务器统计信息以实现可调试性的 API
- 零 Rtt 连接建立和可定制的零 RTT 路径验证
- 支持 UDP 通用分段卸载 (GSO)，以实现更快的 UDP 写入。

**客户端功能**：

- 原生happy eyeballs支持ipv4和ipv6之间让应用不需要自己实现
- 可插入的拥塞控制和支持关闭拥塞控制以插入特定于应用程序的控制算法

## Source Layout

- `quic/api`：定义应用程序可用于与 QUIC 传输层交互的 API。
- `quic/client`: 客户端传输实现
- `quic/codec`：协议的读写编解码器实现
- `quic/common`: 常用实用函数的实现
- `quic/congestion_control`: Cubic、Copa等不同拥塞控制算法的实现
- `quic/flowcontrol`: 流量控制功能的实现
- `quic/handshake`: 实现加密握手层
- `quic/happyeyeballs`: 实现 IPV4 和 IPV6 连接竞赛并选出获胜者的机制
- `quic/logging`: 日志框架的实现
- **`quic/loss`: 不同丢失恢复算法的实现（毕设重点）**
- `quic/samples`：示例客户端和服务器
- `quic/server`: 服务器传输实现
- `quic/state`：定义和实现连接和流级别的状态工件和状态机

## mvfst/**quic**/loss

​	考虑了一下，决定从和毕设相关性最高的代码开始分析：

### **QuicLossFunctions.cpp**

#### 以下是一些常见的auto编程术语：

1. 自动类型推导：auto关键字可以让编译器自动推导变量的类型，无需手动指定。
2. 自动变量：使用auto关键字声明的变量，其类型由编译器自动推导。
3. 自动存储类别：auto关键字可以与static或extern等存储类别关键字一起使用，表示变量的存储类别由编译器自动推导。
4. 自动迭代器：C++11引入了auto关键字可以用于推导迭代器类型。
5. 自动函数返回值类型：使用auto关键字作为函数返回类型，编译器可以自动推导函数返回值的类型。
6. 自动模板类型推导：C++17引入了auto关键字可以用于自动推导函数模板的参数类型。

//前向声明

```
bool hasAckDataToWrite(const QuicConnectionStateBase& conn);
WriteDataReason hasNonAckDataToWrite(const QuicConnectionStateBase& conn);
std::chrono::microseconds calculatePTO(const QuicConnectionStateBase& conn);
```

//判断conn 是否持续拥塞

//持续拥塞仅针对于AppData空间

```
bool isPersistentCongestion
calculateAlarmDuration(const QuicConnectionStateBase& conn) 
#分成两个模式（alarm_Method），早期重传或重新排序，PTO：进程超时，并针对这两个模式对AlarmDuration进行计算，不同模式有不同计算方案
```

//L105：这个函数应该在一些可能改变丢失检测计时器的事件之后被调用，例如写入发生、超时发生或数据包被确认

```
template <class Timeout, class ClockType = Clock>
void setLossDetectionAlarm(QuicConnectionStateBase& conn, Timeout& timeout) 
```

//L113：即使我们没有任何未完成的数据包，我们也可能有新数据或丢失的数据要发送。 当我们收到 PTO 事件时，可能只有克隆的数据包未完成。 由于 cwnd 可能设置为 min cwnd，我们可能无法发送数据。 然而，我们可能仍有未发送或已知丢失的数据位于缓冲区中。 在这种情况下，我们应该设置一个计时器，以便能够在下一个 PTO 上发送此数据。

```
 bool hasDataToWrite = hasAckDataToWrite(conn) ||
      (hasNonAckDataToWrite(conn) != WriteDataReason::NO_WRITE);
  auto totalPacketsOutstanding = conn.outstandings.numOutstanding();
```

//L123：我们有这个条件来消除我们有的情况的歧义。
     (1) 所有未完成的数据包都是经过处理的克隆，没有数据可写。 (2)所有outstanding都是已经处理完的clone，有数据可写。 如果只有没有数据的克隆，那么我们就不需要设置定时器。 这将释放 evb。 但是，在 PTO 验证事件之后，克隆会占用 cwnd 中的空间。 如果我们还有数据要写入，我们将无法写入它们，因为我们可能会被 cwnd 阻塞。 所以我们必须设置丢失计时器，以便我们可以使用克隆的松弛数据包空间写入此数据。

```
if (!hasDataToWrite && conn.outstandings.packetEvents.empty() &&
      totalPacketsOutstanding == conn.outstandings.numClonedPackets()) 
#没有数据可以写且所有未完成的数据包均clone
```

//L146：前一个计时器或 Ack 可以清除 lossTime 而无需设置新计时器，例如，如果这样的计时器或 ack 将所有内容标记为丢失，或将每个标记为已确认。 在那种情况下，如果已经设置了早期重传定时器，我们应该清除它

//L187：如果应设置损失计时器，则处理未结清的损失并返回 true。 否则为false

//L204：这个函数应该在一些可能发生的事件之后被调用触发丢失检测，例如：数据包被确认

```
folly::Optional<CongestionController::LossEvent> detectLossPackets
```

//L218：丢失检测计时器触发时调用的函数

```
template <class ClockType = Clock>void onLossDetectionAlarm
```

//L261：在 RegularQuicWritePacket 中处理流以防丢失

//L263：已处理：此数据包是否是已处理的克隆

```
void markPacketLoss
```

//L277：我们在零 rtt 拒绝期间强制将零 rtt 数据包标记为丢失。

```
void markZeroRttPacketsLost
```



#### MaxStreamDataFrame（最大流数据帧）

是一种用于传输数据的协议数据单元（PDU），在传输控制协议（TCP）中使用。它是TCP数据段的一种形式，用于传输大量数据。MaxStreamDataFrame最初是在QUIC（快速UDP互联网连接）协议中定义的，但已被TCP引入，以提高TCP在高延迟网络中的效率。

MaxStreamDataFrame提供了一种流式传输数据的方式，它可以在不等待确认的情况下传输大量数据。这对于需要快速传输大量数据的应用程序非常有用。MaxStreamDataFrame中包含数据负载，以及用于管理数据流的元数据，如流ID和数据偏移量等信息。

MaxStreamDataFrame可以在TCP的流控制机制下进行传输，这意味着发送方可以根据接收方的能力来限制发送数据的速率，从而防止过载和网络拥塞。



#### "emplace()" 

是C++ STL容器中的一个函数，用于在容器中构造一个新的元素。它的作用是在不需要创建临时对象的情况下，直接在容器中构造新元素。

具体来说，emplace() 函数会将元素直接构造在容器的内部，而不是先创建一个临时对象，再将其移动或复制到容器中。这样可以避免不必要的对象拷贝和移动操作，从而提高代码的性能。

在中文中，"emplace()" 可以翻译为"就地构造" 或者 "原地构造"。



#### `forward_as_tuple` 

是一个 C++ 标准库函数，定义在头文件 `<utility>` 中，用于将一个参数序列转发为一个 std::tuple 类型的对象。它的语法如下：

```
cppCopy codetemplate <class... Args>
std::tuple<Args&&...> forward_as_tuple(Args&&... args) noexcept;
```

`forward_as_tuple` 的作用类似于 `std::forward`，它们都可以用来实现完美转发。但是，`std::forward` 将参数转发为特定类型的引用，而 `forward_as_tuple` 则将参数转发为一个 std::tuple 类型的对象。

`forward_as_tuple` 接受一个参数序列，该序列可以包括任意数量和类型的参数。它返回一个 std::tuple 类型的对象，该对象包含了与输入序列相同数量和类型的元素。这些元素是对输入序列中每个元素的转发引用，因此可以在函数调用中实现完美转发。

以下是 `forward_as_tuple` 的一个示例用法：

```
cppCopy code#include <iostream>
#include <tuple>
#include <utility>

template <typename... Args>
void foo(Args&&... args) {
  // 将参数转发为 std::tuple 类型的对象
  auto tuple_args = std::forward_as_tuple(std::forward<Args>(args)...);

  // 访问元素并输出
  std::cout << "Tuple elements: ";
  std::apply([](auto&&... args) {
    ((std::cout << std::forward<decltype(args)>(args) << " "), ...);
  }, tuple_args);
  std::cout << std::endl;
}

int main() {
  int x = 1;
  double y = 2.0;
  std::string z = "Hello";

  // 调用 foo 函数并实现完美转发
  foo(x, y, z);
}
```

输出：

```
pythonCopy code
Tuple elements: 1 2 Hello
```

在这个示例中，我们定义了一个名为 `foo` 的函数，并使用 `forward_as_tuple` 将函数参数转发为一个 std::tuple 类型的对象。然后，我们使用 `std::apply` 将这个 std::tuple 类型的对象作为参数传递给一个 Lambda 表达式，Lambda 表达式可以访问元素并输出它们的值。最后，我们在 `main` 函数中调用 `foo` 函数，并将一些参数传递给它，这些参数将在函数调用中实现完美转发。



#### func

在C和C++编程中，__func__是一个内置的预定义宏，用于返回当前函数的名称（字符串常量）。这个宏通常用于调试和错误报告中，以帮助程序员确定问题所在。

以下是一个示例程序，展示了如何使用__func__宏：

```
cCopy code#include <stdio.h>

void foo() {
    printf("当前函数是：%s\n", __func__);
}

int main() {
    foo();
    return 0;
}
```

输出结果为：

```
当前函数是：foo
```

可以看到，__func__宏返回了当前函数的名称"foo"。在程序的不同函数中使用__func__宏，可以方便地输出当前正在执行的函数名称，有助于调试和诊断错误。





#### MaxDataFrame帧

用于告知对等方当前连接上的最大数据帧大小。这对于流控制非常重要，因为它允许对等方在不超过其处理能力的前提下发送尽可能多的数据。

当对等方接收到一个MaxDataFrame帧时，它将更新其内部数据结构以反映新的最大数据帧大小。这个值将用于计算流量控制窗口大小，以及发送数据时的最大帧大小。

总之，MaxDataFrame帧是QUIC协议中一种非常重要的帧类型，用于优化流控制和数据传输效率。



#### BufMeta

在 QUIC 中，BufMeta（缓冲区元数据）是一个结构体，用于跟踪数据包的缓冲区的元数据信息。BufMeta 结构体包含以下字段：

- offset：缓冲区中的数据包起始位置偏移量。
- len：数据包的长度。
- remaining：缓冲区中剩余的未使用空间长度。
- contiguous_len：缓冲区中连续可用的空间长度。

BufMeta 结构体的主要目的是为了帮助 QUIC 实现对数据包的快速处理和传输。通过跟踪缓冲区中每个数据包的元数据信息，QUIC 实现可以更有效地利用缓冲区，从而提高数据包的传输速度和性能。



#### end（）

在 C++ 中，end() 是一个函数，用于返回容器中的末尾位置的迭代器。

例如，如果你有一个 std::vector<int>，你可以使用 end() 函数来获取该向量的最后一个元素的迭代器，如下所示：

```
arduinoCopy codestd::vector<int> myVector {1, 2, 3, 4, 5};
auto it = myVector.end(); // 获取 myVector 的末尾迭代器
--it; // 将迭代器递减一次，此时 it 指向 5
```

需要注意的是，end() 返回的迭代器指向的是容器中的最后一个元素的下一个位置，所以如果你想要遍历容器中的所有元素，通常应该从容器的起始位置开始迭代，直到 end() 返回的迭代器之前的位置。

另外，对于一些容器，比如 std::array，其大小是固定的，因此 end() 返回的迭代器指向的是容器中最后一个元素的位置，而不是最后一个元素的下一个位置。



#### DsrAck 

DsrAck 的中文意思是“快速重传确认”，它是指一种网络协议中的一种机制。在传输数据时，接收方会给发送方发送一个确认信息，告诉发送方它已经收到了数据。如果发送方没有收到确认信息，它就会认为数据没有被正确地接收，然后尝试重新发送数据。DsrAck 就是一种快速重传确认机制，它可以在没有收到确认信息时，尽快地重传数据，以提高数据传输的效率和可靠性。



#### WriteCryptoFrame 

WriteCryptoFrame 的作用是将 QUIC 协议中的加密数据写入帧中。下面是 WriteCryptoFrame 的实现：

```
scssCopy codevoid WriteCryptoFrame(QuicDataWriter* writer,
                      QuicStreamId stream_id,
                      uint64_t offset,
                      QuicByteCount data_length,
                      const QuicEncryptedPacket& encrypted) {
  QuicByteCount header_length = GetCryptoHeaderLength(stream_id);
  QUICHE_DCHECK_LE(header_length + data_length,
                   encrypted.length() - encrypted.length_of_packet_number());

  // 写入帧类型和帧头
  writer->WriteUInt8(kCryptoFrameType);
  writer->WriteStreamId(stream_id, QuicUtils::GetStreamIdLength(stream_id));
  writer->WriteVarInt62(offset);

  // 写入加密数据
  writer->WriteBytes(encrypted.data() + encrypted.length_of_packet_number() +
                     header_length, data_length);
}
```

该函数接收以下参数：

- `writer`：一个指向 QuicDataWriter 对象的指针，用于将数据写入帧中。
- `stream_id`：一个 uint64_t 类型的数值，表示要写入加密数据的流的 ID。
- `offset`：一个 uint64_t 类型的数值，表示写入加密数据的偏移量。
- `data_length`：一个 QuicByteCount 类型的数值，表示要写入的加密数据的字节数。
- `encrypted`：一个 QuicEncryptedPacket 对象，其中包含了加密数据和必要的帧头信息。

在函数实现中，首先计算出加密帧的头部长度，然后写入帧类型、流 ID 和偏移量。最后，写入指定数量的加密数据。

#### RstStreamFrame

RstStreamFrame（复位流帧）是QUIC协议中的一种类型的帧，用于表示在数据传输期间发生的错误或异常情况，例如连接中断、数据包丢失等等。该帧通常由接收方发送给发送方，以指示发送方停止向接收方发送数据。

RstStreamFrame包含以下字段：

- Stream ID：表示要复位的流的ID。
- Error Code：表示复位原因的错误代码。
- Final Size：可选字段，表示在发送复位帧之前接收方已经成功接收的数据大小。

需要注意的是，复位帧通常是一种紧急帧，因为它指示着在数据传输期间发生了错误或异常情况，需要立即处理。

#### "StreamDataBlockedFrame" 可以翻译为 "数据流阻塞帧"。

它是QUIC协议中的一种控制帧，用于通知对端某个数据流的发送方，该数据流上的数据无法被接收方处理，并且需要等待一段时间或者其他操作来解除阻塞。这个帧包含以下字段：

- Stream ID：标识受阻塞的数据流的ID。
- Stream offset：表示接收方已经处理完的数据字节数，即阻塞发生的位置。
- Data limit：表示接收方能够处理的最大数据量，即发送方需要限制发送数据的数量，直到接收方处理了一定量的数据。

当接收方收到这个帧时，它会根据Stream ID和Stream offset来确定哪个数据流受阻塞，并根据Data limit来调整自己的接收窗口。发送方在收到这个帧后，应该减少发送到该数据流的数据量，以避免发送超过接收方的限制，从而继续发送数据。

#### DataBlockedFrame（数据阻塞帧）

是QUIC（快速可靠的传输协议）中的一种帧类型。当一个端点发送数据时，另一个端点可能会因为缓冲区已满而无法接收数据。当接收端点无法接收更多数据时，它将发送DataBlockedFrame给发送端点，以通知发送端点减慢发送速度，避免数据丢失。发送端点可以通过减少发送速度或等待DataUnblockedFrame来解除阻塞状态。

#### QuicSimpleFrame

QUIC简单帧（Quic Simple Frame）是QUIC协议中的一种数据帧类型，用于传输一些简单的数据信息，例如PING，ACK等。它相对于其他类型的数据帧，如STREAM和CRYPTO帧，比较轻量级，不需要进行加密和解密等操作。由于QUIC协议是基于UDP的，QUIC简单帧可以通过UDP数据包在客户端和服务器之间进行传输。

#### PacketNumberSpace

QUIC 中的 PacketNumberSpace 可以翻译为“数据包编号空间”。

#### lossvisitor

QUIC中的"lossVisitor"参数是指一个用于检测和处理数据包丢失的访问者对象。当QUIC协议中的数据包在传输过程中发生丢失时，lossVisitor会被调用来处理这个问题。lossVisitor会跟踪丢失的数据包，并尝试通过重传或其他方式来解决问题。lossVisitor还可以记录数据包丢失的原因，以便在后续的故障排除和调试中提供有用的信息。

#### delayUntilLost

QUIC协议中的"delayUntilLost"参数指的是在没有收到确认消息的情况下，等待发送方判断数据包已经丢失所需的时间长度。在QUIC中，发送方会等待一段时间来确认数据包是否已经到达接收方。如果在这段时间内没有收到确认消息，发送方就会认为数据包已经丢失，并尝试重新发送数据包。

delayUntilLost参数控制发送方等待确认消息的时间长度。如果确认消息没有在这段时间内到达，发送方就会认为数据包已经丢失，并尝试重新发送数据包。这个参数的默认值在不同的实现中可能会有所不同，通常会根据网络延迟和丢包率等因素进行调整。

#### observerLossEvent

"observerLossEvent" 是QUIC（快速UDP互联网连接）协议中的一个参数，用于指示观察者（例如，网络管理员或调试工具）在网络中检测到的数据包丢失事件的数量。

当观察者在网络中检测到数据包丢失事件时，它会更新该参数的值，以便其他人可以了解网络的可靠性。该参数的值通常以百分比形式表示，表示网络中发生的数据包丢失事件占总数据包数的比例。

#### PacketNumberSpace

是QUIC协议中的术语，用于标识不同类型的数据包所使用的Packet Number（数据包编号）的范围。QUIC协议中定义了4个不同的Packet Number Space，分别为Initial、Handshake、0-RTT和Application Data。每个Packet Number Space都有自己的Packet Number编码规则和Packet Number范围。在QUIC协议中，数据包的编号是用于保证数据包的有序传输和识别重复数据包的重要机制。

#### maybeStreamFrame

在QUIC协议中，maybeStreamFrame参数是一个布尔值，用于指示一个数据包是否可能包含流数据帧（stream frame）。QUIC协议使用流（stream）来表示双方之间传输的数据流，每个流都有自己的流ID，可以被独立地管理和控制。在QUIC协议中，数据被分割成小的数据包，每个数据包包含一个或多个数据帧（data frame），数据帧可以是连接流控制帧（connection-level flow control frames）或流控制帧（stream-level flow control frames），也可以是加密帧（encryption frames）或重传帧（retransmission frames）。

maybeStreamFrame参数用于指示一个数据包是否包含流数据帧。如果maybeStreamFrame为true，那么接收端需要检查数据包中是否包含流数据帧；如果maybeStreamFrame为false，那么接收端可以忽略该数据包中的所有流数据帧，因为该数据包只包含连接流控制帧或其他类型的帧。

#### `value_or`

是C++标准库中的一个函数模板，其作用是返回一个可选值（`optional`）的值，如果可选值包含了一个值，那么就返回该值，否则返回一个默认值。

函数模板的声明如下：

```
cCopy codetemplate<class T>
constexpr T value_or( const optional<T>&& opt, T&& def_value );
```

参数说明：

- `opt`：可选值（`optional`）对象。
- `def_value`：默认值，如果可选值为空，就返回该值。

例如，下面的代码演示了如何使用 `value_or` 函数：

```
cCopy code#include <iostream>
#include <optional>

int main() {
    std::optional<int> opt1 = 42;
    std::optional<int> opt2 = std::nullopt;
    
    std::cout << "opt1 value: " << opt1.value_or(0) << std::endl; // 输出：opt1 value: 42
    std::cout << "opt2 value: " << opt2.value_or(0) << std::endl; // 输出：opt2 value: 0
    
    return 0;
}
```

在上面的示例中，我们定义了两个 `optional` 对象，`opt1` 包含一个整数值 `42`，而 `opt2` 是一个空值（`std::nullopt`）。我们使用 `value_or` 函数获取这些值，并在 `opt2` 的情况下提供了一个默认值 `0`。最终，我们打印出这些值

#### a=b>c

C++ 中，"a=b>c" 的意思是比较变量 b 和 c 的大小关系，如果 b 大于 c，则将结果 true 赋值给变量 a；如果 b 小于等于 c，则将结果 false 赋值给变量 a。

具体的语法和含义如下：

- ">" 表示大于号，用于比较两个数的大小关系。
- "b > c" 表示判断变量 b 是否大于变量 c。
- "a = b > c" 表示将比较结果赋值给变量 a，因为 ">" 的优先级高于 "="，所以先比较 b 和 c 的大小关系，再将比较结果赋值给变量 a。

因此，如果 b 大于 c，表达式的值为 true，将赋值给 a；否则表达式的值为 false，将赋值给 a。

#### reorderDistance

是QUIC协议中的一个参数，用于确定数据包重排序的距离阈值。当QUIC在网络中遇到数据包丢失或延迟时，它会启动重传机制以确保数据的完整性和可靠性。在此过程中，如果QUIC接收到的数据包的顺序与其发送顺序不同，则会发生数据包重排序。

reorderDistance参数确定了在何种情况下QUIC将数据包视为重排序。具体来说，当接收到的数据包与期望的下一个数据包之间的距离小于等于reorderDistance时，QUIC将其视为已经到达的但被重排序的数据包，而不是丢失的数据包。这个参数的默认值是16，但可以根据网络质量和特定应用的需求进行调整。

#### lostByReorder

QUIC中的"lostByReorder"参数是指在传输过程中，允许的数据包乱序最大数量。当数据包超过此数量时，QUIC会将其视为已丢失，并触发相应的重传机制。该参数的默认值通常为2，这意味着如果有超过2个数据包乱序，QUIC就会认为这些数据包已丢失并重传它们。

需要注意的是，这个参数的值应该根据具体情况进行调整，以在保证网络效率的同时，尽可能地减少数据包丢失和重传的次数。如果该值设置得太小，会增加网络流量和延迟，而如果设置得太大，可能会导致不必要的重传和网络拥塞。

#### CHECK_GT

在C++中，CHECK_GT的意思是“检查大于”，用于检查一个值是否大于另一个值。

以下是CHECK_GT的示例用法：

```
cCopy code#include <glog/logging.h>

int main() {
  int x = 5;
  int y = 10;

  // Check that x is greater than y.
  CHECK_GT(x, y) << "Error: x must be greater than y.";

  return 0;
}
```

在上面的例子中，如果x不大于y，则程序将抛出一个错误并打印出错误消息“Error: x must be greater than y.”。这个错误消息是通过CHECK_GT的流插入运算符（<<）附加到CHECK_GT宏中的。

注意，为了使用CHECK_GT，您需要在代码中包含Google日志库（glog）。

#### lossTimeoutDividend

在QUIC协议中，lossTimeoutDividend参数是用来计算丢包超时（loss timeout）时间的因子。具体来说，该参数用于确定在丢包检测到后，等待多长时间才认为数据包已经丢失。

该参数的值越大，表示等待的时间越长，因此可以更好地容忍网络延迟和抖动，但是会增加丢包检测的时间和网络负担。相反，该参数的值越小，表示等待的时间越短，因此可以更快地检测到丢包，但是会更加敏感于网络抖动和延迟。

在QUIC实现中，通常会根据网络延迟和抖动的情况来动态调整该参数的值，以在可接受的性能范围内实现尽可能准确的丢包检测。

#### "timeReorderingThreshDivisor"

QUIC协议中的timeReorderingThreshDivisor参数指的是时间重排序阈值除数，它用于确定网络延迟和抖动对数据包顺序重排的影响程度。在QUIC协议中，接收端会根据该参数计算出一个时间阈值，超过该阈值的数据包将被认为是乱序的，并进行重排。

该参数的默认值为3，这意味着接收端将以最近三个数据包的最大延迟时间作为时间阈值。如果一个数据包的延迟时间超过该阈值，则该数据包将被认为是乱序的，并将被重新排序。如果该参数的值较小，接收端将更容易将数据包视为乱序，从而导致不必要的重排。如果该参数的值较大，则接收端将更容易将数据包视为有序，从而可能导致乱序数据包的丢失。因此，该参数的值应该根据具体应用场景进行调整。

#### maybeStreamFrame

在QUIC协议中，maybeStreamFrame参数是一个布尔值，用于指示一个数据包是否可能包含流数据帧（stream frame）。QUIC协议使用流（stream）来表示双方之间传输的数据流，每个流都有自己的流ID，可以被独立地管理和控制。在QUIC协议中，数据被分割成小的数据包，每个数据包包含一个或多个数据帧（data frame），数据帧可以是连接流控制帧（connection-level flow control frames）或流控制帧（stream-level flow control frames），也可以是加密帧（encryption frames）或重传帧（retransmission frames）。

maybeStreamFrame参数用于指示一个数据包是否包含流数据帧。如果maybeStreamFrame为true，那么接收端需要检查数据包中是否包含流数据帧；如果maybeStreamFrame为false，那么接收端可以忽略该数据包中的所有流数据帧，因为该数据包只包含连接流控制帧或其他类型的帧。

#### PTO

QUIC（快速UDP互联网连接）是一种基于UDP协议的传输层协议，用于提高Web应用程序的性能和安全性。QUIC协议中包含了一些PTO（握手超时）参数，下面是这些参数的中文说明：

1. 初始握手超时时间（Initial Handshake Timeout）：客户端在发送初始握手数据包之后，等待服务器响应的时间。默认值为3秒。
2. 空闲超时时间（Idle Timeout）：在QUIC连接建立后，如果在一段时间内没有收到任何数据包，则连接将被关闭。该参数定义了这段时间的长度，以秒为单位。默认值为30秒。
3. 连接迁移超时时间（Connection Migration Timeout）：当客户端需要将QUIC连接从一个IP地址迁移到另一个IP地址时，它需要等待服务器响应的时间。该参数定义了这个等待时间的长度，以毫秒为单位。默认值为500毫秒。
4. 探测超时时间（Probe Timeout）：在QUIC连接空闲超时之前，客户端会向服务器发送一个探测数据包，以确保连接仍然有效。该参数定义了客户端等待服务器响应的时间，以毫秒为单位。默认值为15秒。
5. 慢启动阈值（Slow Start Threshold）：QUIC协议使用慢启动算法来控制发送速度。当发送速度达到慢启动阈值时，算法会转换为拥塞避免算法。该参数定义了慢启动阈值的大小，以字节为单位。默认值为16KB。

请注意，不同的QUIC实现可能会使用不同的默认参数值，并且这些值可能会因应用程序的特定需求而进行调整。

QUIC协议中的丢包率参数可以称为"丢包率阈值"或"丢包率限制"，常用缩写为"PTO"（Packet Tolerance Offset）。

丢包率阈值是指，在QUIC连接中，如果发送方连续多次发包没有收到接收方的ACK确认，就会认为发生了丢包，并触发一系列的重传机制。丢包率阈值可以控制发送方对丢包的容忍程度，一般取值范围为5%到15%不等。如果丢包率超过阈值，则会触发Pacing限制，降低发送速率以避免网络拥塞。

丢包率阈值一般由QUIC协议的实现者进行调整，具体取值根据网络环境、带宽、延迟等因素而异。在实际使用中，可以通过修改QUIC协议的配置文件或使用相关工具来调整丢包率阈值。

#### 析构函数

析构函数（Destructor）是在对象被销毁时自动调用的函数。析构函数的主要作用是在对象生命周期结束时释放对象所占用的资源，例如内存、文件等。

析构函数的语法格式如下：

```
cCopy code~类名()
{
    //析构函数的代码
}
```

在C++中，析构函数没有参数，也不需要返回类型。析构函数的名称与类名相同，只是在前面加上了一个波浪号（~）。

当一个对象的生命周期结束时（例如对象被删除或者超出其作用域范围），就会自动调用该对象的析构函数。在析构函数中，可以释放对象所占用的资源，例如关闭文件、释放内存等。如果没有定义析构函数，编译器会自动生成一个默认的析构函数，但该默认析构函数可能不会执行所需要的清理操作，因此在定义类时最好显式地定义析构函数。

需要注意的是，析构函数不应该显式调用，它是在对象生命周期结束时自动调用的。在程序中不应该使用 delete 或 free 函数来手动销毁一个对象，这样会导致析构函数不被调用，从而可能会引发内存泄漏等问题。



#### quic发送

QUIC实现库有多种选择，包括Google的开源QUIC库、Cloudflare的开源QUIC库、Facebook的MVFST等等。这些库都提供了API接口，使得开发者可以使用它们来发送数据。

以Google的开源QUIC库为例，其发送数据的代码可以参考以下示例：

```
cCopy code// 创建QUIC连接
std::unique_ptr<QuicConnection> connection = QuicConnectionHelper::CreateConnection(
  server_addr, client_addr, helper.get(), alarm_factory.get(), writer, std::move(connection_helper),
  std::move(initializer), perspective, version);

// 创建QUIC数据流
std::unique_ptr<QuicStream> stream(connection->CreateOutgoingDynamicStream());

// 向QUIC数据流中写入数据
stream->WriteOrBufferData(data, length, fin_flag);
```

这里，我们首先创建了一个QUIC连接对象，然后使用该连接对象创建了一个QUIC数据流对象，最后使用数据流对象的WriteOrBufferData方



mvfst 是一个基于 C++ 的网络库，其发送数据的代码可以在其源代码中找到。以下是一个简单的发送数据示例代码：

```
cCopy code// 创建一个 EventBase 对象
folly::EventBase evb;

// 创建一个 AsyncSocket 对象
auto socket = folly::AsyncSocket::newSocket(&evb, address, port);

// 发送数据
socket->writeChain(
  &evb,
  folly::IOBuf::copyBuffer("Hello World!"),
  nullptr /* write success callback */,
  nullptr /* write error callback */);
```

这段代码使用 `AsyncSocket` 对象的 `writeChain()` 方法来发送数据。`writeChain()` 方法的第一个参数是一个 `EventBase` 对象，这个对象是 mvfst 中所有异步 I/O 操作的事件循环。第二个参数是要发送的数据，这里使用 `IOBuf::copyBuffer()` 方法创建了一个 `IOBuf` 对象，该对象包含了要发送的数据。第三个和第四个参数是可选的回调函数，用于在数据发送成功或

mvfst 是一个开源的 C++ 库，用于实现高性能的 TCP/IP 网络通信。发送数据包的函数取决于您使用的 API，以下是一些常用的发送数据包函数：

- `folly::AsyncUDPSocket::write()`: 发送 UDP 数据包
- `folly::AsyncSocket::write()`: 发送 TCP 数据包
- `wangle::OutputBuffer::write()`: 将数据包添加到输出缓冲区，待发送
- `wangle::Pipeline::write()`: 将数据包写入网络套接字

请注意，这些函数的确切用法和参数可能因您的具体用例而异。建议查阅相关文档或参考 mvfst 的示例代码以获取更多信息。

#### `useConnectionEndWithErrorCallback` 

参数是指在使用 QUIC 协议时，当连接结束并且发生错误时要调用的回调函数。



在 QUIC 协议中，当连接出现错误时，会触发一个 `QUIC_CONNECTION_END` 事件，这个事件可以被使用 `useConnectionEndWithErrorCallback` 参数的应用程序捕获。应用程序可以在捕获这个事件后，执行一些特定的操作，比如记录日志、重新连接等。



这个回调函数接受一个参数，表示连接结束的原因。这个参数可以是以下几种类型之一：



- `QUIC_NO_ERROR`：表示连接没有发生错误，正常结束。
- `QUIC_INTERNAL_ERROR`：表示连接发生了内部错误。
- `QUIC_CONNECTION_CANCELLED`：表示连接被取消。
- `QUIC_CONNECTION_TIMEOUT`：表示连接超时。
- `QUIC_PEER_GOING_AWAY`：表示对端正在关闭连接。
- `QUIC_UNSUPPORTED_VERSION`：表示连接的协议版本不支持。
- `QUIC_INVALID_MIGRATION`：表示连接迁移失败。



使用 `useConnectionEndWithErrorCallback` 参数可以帮助应用程序更好地处理连接异常情况，提高连接的可靠性和稳定性。

#### "pathValidationTimeout"

参数指的是QUIC连接在验证服务器地址的路径（path）时等待响应的超时时间。当客户端发送验证请求到服务器后，如果在指定的时间内未收到服务器的响应，则连接将被认为是失败的。

在QUIC协议中，客户端和服务器在建立连接之前需要进行路径验证，以确保数据可以在双方之间传输。pathValidationTimeout参数允许设置等待路径验证的超时时间，以便在网络连接较差或服务器响应较慢的情况下，可以适当延长等待时间以避免连接失败。

#### idleTimeout

QUIC（Quick UDP Internet Connection）中的idleTimeout参数指的是连接处于空闲状态的时间，超过该时间后连接将被关闭。该参数用于控制服务器和客户端之间的空闲连接的生命周期，以避免资源浪费和提高系统的性能。

在QUIC中，idleTimeout参数是指在连接建立后，如果在一段时间内没有数据交换，则该连接将被视为空闲连接。服务器可以通过该参数来配置一个时间限制，在该时间限制内如果没有数据交换，则服务器将主动关闭连接。这个参数的默认值是30秒。

需要注意的是，如果在idleTimeout时间内没有任何数据交换，但是连接仍然处于活跃状态（例如仍在进行文件传输或其他长时间运行的任务），则该连接不会被关闭。

#### keepaliveTimeout

在QUIC协议中，keepaliveTimeout参数用于指定在没有数据传输时，保持活动状态的最大时间（以毫秒为单位）。当一个连接处于空闲状态（没有任何数据传输）时，该参数允许发送一个keep-alive消息来确保连接仍然处于活动状态。

如果超过指定的keepaliveTimeout时间没有数据传输，则连接将被视为已断开，并且可能会触发重新连接或关闭连接的操作。这个参数的值可以根据网络环境和应用程序的需求进行调整。

请注意，keepaliveTimeout参数仅适用于没有数据传输的连接。如果有数据传输正在进行，则连接将保持活动状态，直到数据传输完成或连接被明确关闭。

#### drainTimeout

在QUIC协议中，`drainTimeout`参数指定了连接断开之前等待数据排空的时间。具体来说，当连接关闭时，服务器会等待一段时间以确保所有数据都被接收方读取。如果在这段时间内读取操作没有完成，则服务器将关闭连接并丢弃任何剩余的未读数据。

因此，`drainTimeout`参数决定了这个等待时间的长度。在一些场景下，可以通过减少`drainTimeout`的值来快速关闭连接并释放资源，但这也可能会导致数据丢失。在其他情况下，可以增加`drainTimeout`的值来确保所有数据都被接收方读取完毕，但这可能会延长连接关闭时间并占用服务器资源。

总之，`drainTimeout`参数的设置需要根据具体情况进行权衡，以平衡连接关闭速度和数据完整性。

#### readLooper

readLooper参数是指一个用于循环读取数据的对象或函数。在QUIC协议中，网络数据通常以数据包的形式传输，而readLooper参数的作用是不断地从网络中读取数据包，并将这些数据包传递给协议的其他部分进行处理。

具体来说，readLooper参数通常被用作传输层协议中的一个线程或循环。该线程或循环负责从网络中读取数据，并将读取到的数据传递给协议的其他部分，例如解密和验证数据包、处理连接状态等。在QUIC协议中，readLooper参数通常被用于传输层的实现中，用于管理数据包的接收和处理过程。

#### peekLooper

在QUIC协议中，peekLooper是一个可选参数，用于指定在接收到新数据时应执行的操作。具体来说，peekLooper参数用于指定一个回调函数，在每次接收到新数据时都会调用该函数。这个回调函数的作用是检查新数据并决定是否需要采取进一步的操作，例如读取数据、关闭连接等。该回调函数应该采取非常快速的操作，以确保不会影响QUIC协议的性能。

C++中的移动函数（move function）是一个用于转移对象所有权的函数，通常用于提高代码效率和避免不必要的复制。

#### std::move()

在C++11中，引入了一个新的标准库头文件<utility>，其中定义了std::move()函数。该函数接受一个左值（lvalue）引用参数，将其转换为右值（rvalue）引用，从而实现对象的移动而非复制。移动一个对象通常比复制对象更快，并且在某些情况下也更安全，因为它避免了不必要的内存分配和释放。



例如，假设有一个具有大量数据的vector对象，而我们希望将其传递给一个函数。如果我们传递该对象的副本，那么就会复制整个vector，这可能非常耗时和浪费内存。相反，如果我们使用std::move()将该对象转移到函数中，那么函数就可以直接访问该对象的内存，而无需进行复制。以下是一个示例：



```
cCopy code#include <iostream>
#include <utility>
#include <vector>

void process_vector(std::vector<int>&& vec) {
  // 处理vector对象
}

int main() {
  std::vector<int> v{1, 2, 3, 4, 5};

  // 移动vector对象v到函数process_vector中
  process_vector(std::move(v));

  // v现在为空
  std::cout << "v.size() = " << v.size() << std::endl;

  return 0;
}
```



在上面的示例中，我们使用std::move()将vector对象v移动到process_vector()函数中，该函数接受一个右值引用参数。由于v被移动了，它现在为空，因为所有权已经转移到了process_vector()函数中。

#### C++ CHECK（C++测试框架）是一个流行的C++测试框架，用于编写和运行测试。

C++ CHECK使用称为测试用例的函数来组织测试。每个测试用例都包含一系列断言，用于检查测试的行为是否正确。如果测试用例中的任何一个断言失败，则该测试用例将失败。

以下是一个简单的C++ CHECK测试用例的示例：

```
iniCopy code#include <check.h>

TEST_CASE("addition works correctly") {
    int a = 2;
    int b = 3;
    int result = a + b;
    CHECK_EQUAL(result, 5);
}
```

在这个例子中，我们定义了一个名为“addition works correctly”的测试用例，该测试用例检查两个整数的加法是否正常工作。我们使用CHECK_EQUAL宏来比较结果与预期结果是否相等。

要运行此测试，您需要将测试代码编译成可执行文件，然后运行该文件。在测试运行期间，C++ CHECK将输出有关每个测试用例的信息，包括测试是否成功或失败以及失败原因。

C++ CHECK还提供了许多其他有用的断言宏，例如CHECK_TRUE（检查条件是否为真）和CHECK_FALSE（检查条件是否为假）。使用这些宏可以帮助您编写更全面和可靠的测试，以确保您的代码能够按预期工作。

#### qlogRefcnt_

在 QUIC Qlog 中，"RefCnt" 参数表示事件相关对象的引用计数。当对象被引用时，该参数的值会增加。相反，当对象被释放时，该参数的值会减少。通过记录这些事件，我们可以追踪对象的生命周期，了解何时创建、何时引用和何时释放它们。

因此，"RefCnt" 参数在 QUIC Qlog 中是一个很有用的指标，可以帮助开发人员跟踪对象的引用计数，并发现潜在的内存泄漏问题。

#### DCHECK_NE

C++中的`DCHECK_NE`是一个调试宏，用于检查两个值不相等。

该宏在Google开发的C++库中定义，用于在调试版本中进行条件检查，以确保代码的正确性。

`DCHECK_NE`宏采用两个参数，如果这两个参数的值相等，那么该宏将触发断言，并输出一条错误消息，指示哪个参数的值是不正确的。

以下是`DCHECK_NE`宏的示例用法：

```
cCopy codeint x = 10;
int y = 20;
DCHECK_NE(x, y);
```

在上面的示例中，如果x和y的值相等，那么`DCHECK_NE`宏将触发断言，并输出一条错误消息。

需要注意的是，`DCHECK_NE`宏仅在调试版本中生效，因此在发布版本中不会进行条件检查。

#### CloseState

QUIC（快速UDP互联网连接）的CloseState参数表示连接关闭的状态。它是一个枚举类型的变量，包含以下值：

1. CLOSED：连接已经关闭，不再可以使用。
2. FAREWELL_SENT：表示连接已经发送了farewell packet（告别数据包），但是还没有收到对方的ACK确认。
3. FAREWELL_RECEIVED：表示连接已经收到了对方发送的farewell packet，并且已经发送了ACK确认。
4. TIME_WAIT：表示连接在等待一段时间后才能被完全关闭，以确保在这段时间内所有未接收的数据都能被处理完毕。

这些状态用于在QUIC连接关闭期间进行跟踪和处理。



#### QUIC SharedGuard 

是一个用于多线程编程的工具，用于保护共享数据结构的线程安全。SharedGuard 的基本思想是，对于共享数据结构的访问，必须先获得锁，然后才能访问数据。在访问完成后，需要释放锁。

SharedGuard 包含三个重要的成员函数：

1. Lock() 函数：用于获得锁，如果锁已经被其他线程持有，则该函数会阻塞当前线程，直到锁被释放。
2. Unlock() 函数：用于释放锁，通常在访问共享数据结构后调用。
3. TryLock() 函数：用于尝试获得锁，如果锁已经被其他线程持有，则该函数会立即返回 false，否则会返回 true。

SharedGuard 的使用方法如下：

```
arduinoCopy code#include <mutex>
#include <iostream>

class MyData {
public:
  void DoSomething() {
    std::lock_guard<std::mutex> lock(mutex_);
    // 访问共享数据结构
  }

private:
  std::mutex mutex_;
};

int main() {
  MyData data;
  data.DoSomething();
  return 0;
}
```

在这个例子中，我们使用 std::mutex 类型作为锁来保护共享数据结构。在 MyData::DoSomething() 函数中，我们使用 std::lock_guard 类型来管理锁的生命周期，这样就能确保在函数结束时自动释放锁。



#### closeNow

函数是一个用于关闭连接的函数。

它的作用是立即关闭一个连接，不管是否还有未发送完的数据包。这个函数通常在需要快速关闭连接的情况下使用，比如在发生错误或异常情况时，或者在需要立即停止正在进行的任务时。

函数的具体实现取决于使用的通信协议和编程语言。在使用QUIC协议的情况下，可以通过调用相应的API函数来实现关闭连接的功能。例如，在使用Go语言的QUIC库时，可以调用Connection对象的Close方法来关闭连接。

closeNow函数的具体语法和参数取决于具体的实现。通常，它需要指定要关闭的连接对象或连接标识符，以及一些可选的参数，比如关闭连接时需要发送的最后一个数据包。

#### DCHECK

DCHECK函数是一个宏，通常用于C++代码中，用于在运行时检查条件是否为真。如果条件为假，DCHECK将触发一个断言并终止程序的执行。与普通的assert断言不同，DCHECK只在调试模式下进行检查，在发布模式下被完全忽略。

DCHECK的名称来源于"debug check"，其设计目的是在调试期间帮助开发人员检测代码中的错误。当一个DCHECK检查失败时，程序会停止执行，并输出错误消息。DCHECK通常用于检查参数的有效性、指针是否为空等等情况。

以下是一个使用DCHECK的示例：

```
arduinoCopy codeint divide(int x, int y) {
  DCHECK(y != 0);
  return x / y;
}
```

在这个示例中，DCHECK检查除数y是否为零。如果y为零，DCHECK将终止程序的执行，并输出错误消息。

需要注意的是，DCHECK函数只在调试模式下进行检查。在发布模式下，所有DCHECK语句都将被完全删除，不会对程序的性能产生任何影响。因此，DCHECK语句不应该包含任何具有副作用的代码，例如修改变量或调用函数。

DCHECK宏的定义通常是由具体的开发工具链或框架提供的，不同的实现可能略有差异。

#### quicWriteDataToSocketImpl函数

是QUIC协议中的一个函数，用于将数据写入套接字。它是QUIC实现中的一部分，通常由底层网络堆栈使用，以在应用程序和网络之间传输数据。该函数可能实现了一些数据传输的细节，例如缓冲和分段，以确保数据能够有效地在网络上传输。

#### TODO

在C++注释中，TODO是一种常见的标记，用于表示“待办事项”（to do），即需要在以后的时间里完成的任务或修复的问题。TODO通常用于标识代码中需要添加功能、修复bug、改进性能或优化等需要进一步处理的事项。在编写代码时使用TODO可以帮助程序员更好地组织和管理他们的工作，并提醒他们注意哪些问题需要解决。一些开发环境（如Visual Studio）会自动将TODO标记突出显示，并提供一些功能（如查找所有TODO）来帮助程序员跟踪和管理待办事项。

#### `iobufChainBasedBuildScheduleEncrypt` 函数是QUIC协议中用于构建、调度和加密缓冲区链的函数。

其主要功能是将待发送的数据存储在一个或多个缓冲区中，然后对这些缓冲区进行加密，最后将加密后的数据发送出去。该函数采用了链式缓冲区的设计，即将多个缓冲区串联起来形成一个链表，以便更高效地处理数据。

具体来说，`iobufChainBasedBuildScheduleEncrypt` 函数接收以下参数：

- `conn`：指向表示QUIC连接的结构体的指针。
- `stream`：指向表示QUIC流的结构体的指针。
- `data`：待发送的数据。
- `len`：待发送数据的长度。
- `fin`：标志位，表示是否为流的结束数据。
- `buffer_size`：缓冲区大小。
- `cb`：指向回调函数的指针，用于在缓冲区链中的每个缓冲区被加密后通知调用者。
- `cb_data`：回调函数的上下文数据。

该函数的主要流程如下：

1. 将待发送的数据存储在缓冲区链中。
2. 对缓冲区链进行加密，加密后的数据存储在新的缓冲区链中。
3. 调用回调函数，通知调用者每个加密后的缓冲区的信息。
4. 将加密后的缓冲区链中的数据发送出去。

需要注意的是，该函数可能会阻塞，直到加密过程完成。此外，该函数还会负责处理流量控制和拥塞控制等问题，以确保数据传输的可靠性和效率。

#### `handleNewStreamDataWritten` 函数

是 QUIC 协议中用于处理新流数据已写入的函数。该函数会在 QUIC 协议栈中处理新写入的数据，并通知 QUIC 流接收方新数据已写入。

具体来说，`handleNewStreamDataWritten` 函数接收以下参数：

- `conn`：指向表示 QUIC 连接的结构体的指针。
- `stream`：指向表示 QUIC 流的结构体的指针。
- `offset`：新数据在流中的偏移量。
- `length`：新数据的长度。
- `fin`：标志位，表示是否为流的结束数据。
- `acked`：标志位，表示是否已确认接收到数据。

该函数的主要功能是在 QUIC 协议栈中处理新写入的数据。它会根据写入的数据，更新流的状态信息和连接的状态信息，包括但不限于以下内容：

- 更新流的接收窗口，以便接收方可以继续接收数据。
- 更新连接的拥塞窗口，以便更好地控制发送数据的速率。
- 如果已确认接收到数据，还会更新流的流量控制窗口和连接的流量控制窗口。

此外，如果新写入的数据是流的结束数据，该函数还会相应地更新流和连接的状态信息，以标记该流已结束。最后，该函数会通知 QUIC 流接收方新数据已写入，并触发相应的事件。

需要注意的是，`handleNewStreamDataWritten` 函数只处理新写入的数据，对于之前已写入但未被确认接收的数据，它并不会重新处理。

#### 函数名：handleNewStreamBufMetaWritten

函数功能：处理新的流缓冲区元数据已写入的事件

函数描述：此函数在QUIC协议的实现中使用，用于处理新的流缓冲区元数据已写入的事件。当一个新的流被创建并与远程端点建立连接时，该函数被调用。函数的主要作用是更新QUIC连接状态以反映新的流的存在，并在必要时创建新的流缓冲区以存储数据。

函数参数：该函数没有显式参数。

函数返回值：该函数没有显式返回值。

#### 克隆写入

克隆写入（Clone Writing）是指在QUIC协议中的一种数据传输技术，可以让数据同时传输到多个接收端。当一个QUIC连接需要将数据发送给多个接收端时，克隆写入技术可以将数据仅仅发送一次，并在传输过程中将数据复制到多个接收端。

这种技术在传输大量数据时可以显著提高效率，因为它避免了数据在不同接收端之间的重复传输，从而节省了网络带宽和传输时间。同时，克隆写入技术还可以减少传输期间的延迟，提高数据传输的实时性。

#### updateConnection

updateConnection 函数是 QUIC（Quick UDP Internet Connections）协议中用于更新连接状态的函数。该函数用于在 QUIC 连接过程中修改已建立的连接的参数或状态。

函数签名如下：

```
csharpCopy code
int updateConnection(Connection* conn, ConnectionParameters* params);
```

其中，`conn` 是指向 QUIC 连接的指针，`params` 是指向要更新的连接参数的指针。该函数返回一个整数值，表示更新操作的状态，一般为 0 表示成功，-1 表示失败。

在实现时，该函数通常会根据 `params` 参数的值更新连接的状态，并在必要时发送 QUIC 数据包以通知对端。具体更新哪些参数以及如何发送数据包等实现细节取决于具体的 QUIC 实现。

需要注意的是，QUIC 是一个快速迭代的协议，各个版本之间的差异较大，因此具体的实现可能会有所不同。此外，QUIC 还处于不断发展之中，最新的规范请参考 IETF 的相应文档。

#### "quic increaseNextPacketNum" 函数

的作用是增加 QUIC 协议中下一个待发送的数据包编号（Packet Number）。下面是一个可能的函数实现（仅供参考）：

```
scssCopy codevoid increaseNextPacketNum() {
    uint64_t currentNum = getNextPacketNum();
    currentNum += 1;
    setNextPacketNum(currentNum);
}
```

其中，`getNextPacketNum()` 函数用于获取当前下一个待发送的数据包编号，`setNextPacketNum(uint64_t num)` 函数用于设置下一个待发送的数据包编号为 `num`。这个函数的具体实现可能会因为具体的 QUIC 实现而略有不同。

#### "writeCloseCommon" 函数

是一种计算机程序中的代码功能，通常用于网络通信协议中。它的作用是在通信结束时向对方发送一个关闭连接的请求。具体实现方式可能因不同的网络协议而异。

#### test文件

mvfst是Facebook开源的一个C++实现的HTTP/3服务器，test.cpp是mvfst代码仓库中的一个测试文件。这个测试文件的作用是用于测试mvfst中的某些功能是否正常工作。测试文件通常包含一些测试用例，用于检测代码的正确性和健壮性，以确保代码在修改后仍然能够按照预期的方式工作。在mvfst中，test.cpp文件中的测试用例可以帮助开发人员在开发和修改代码时验证代码是否正确。

#### processCallbacksAfterWriteData

在mvfst中，processCallbacksAfterWriteData函数的作用是在写入数据后处理回调。具体来说，当mvfst从网络中读取到数据并将其写入缓冲区后，它会检查是否有注册了回调函数，以便在数据被写入后执行特定的操作。这些回调函数可能包括对写入数据的确认或对写入数据的处理，例如解密或解压缩。processCallbacksAfterWriteData函数就是在写入数据后处理这些回调函数的过程。

#### 在mvfst中，“quiescence”是指网络通信的一种状态，

表示在该状态下网络上的所有传输活动已经停止。因此，“after quiescence”指的是在网络处于静默状态之后的某个时间点，通常是指在网络空闲一段时间之后采取的操作或执行的操作。例如，在mvfst中，可以在网络处于静默状态一段时间后启动连接关闭操作以释放资源。

#### 其中makeBatchWriter函数是用于创建一个批量写入器（BatchWriter）的函数。

批量写入器是一种用于将数据缓存并批量发送的机制。当应用程序需要发送大量的小数据包时，使用批量写入器可以显著提高网络吞吐量和性能。

makeBatchWriter函数的作用是创建一个新的批量写入器，并设置其相关参数，例如最大批量大小和缓存池大小等。创建成功后，可以使用返回的批量写入器对象进行数据写入操作。

需要注意的是，makeBatchWriter函数是mvfst库中的一个函数，具体使用方法和参数取决于所使用的版本和上下文环境。

#### Happy Eyeballs

在mvfst中，Happy Eyeballs是一种用于TCP连接优化的算法。其中，HappyEyeballsState是一种状态机，用于跟踪和管理这个算法的状态。

具体而言，Happy Eyeballs算法可以在IPv4和IPv6之间自动选择更快的连接。HappyEyeballsState状态机则可以帮助跟踪每个连接的状态，并在必要时切换到更快的连接。这种状态机是实现Happy Eyeballs算法的关键部分之一，可以帮助提高网络连接的速度和性能。

#### explicit

在 C++ 中，关键字“explicit”用作带有单个参数的构造函数的说明符，以指示构造函数仅应用于显式类型转换，而不应用于隐式转换。

当构造函数被标记为“显式”时，这意味着编译器将仅使用该构造函数进行直接初始化，其中构造函数是用其参数显式调用的。编译器不会将构造函数用于隐式转换，例如将不同类型的参数传递给需要该类对象的函数时。

例如，考虑一个名为“MyClass”的类，它带有一个标记为显式的“int”构造函数：

```
阿杜伊诺复制代码class MyClass {
public:
    explicit MyClass(int value) : _value(value) {}
private:
    int _value;
};
```

使用 explicit 关键字，将允许进行以下初始化：

```
scss复制代码
MyClass obj1(10);  // Direct initialization
```

但是以下会产生编译器错误：

```
爪哇复制代码
MyClass obj2 = 10; // Implicit conversion
```

在第二种情况下，不允许从“int”到“MyClass”的隐式转换，因为构造函数被标记为“explicit”。

#### HQServerParams是MVFAST中的一个结构体，用于存储与HQ（HTTP/3）协议相关的服务器参数。

具体来说，HQServerParams结构体包含了以下字段：

- num_worker_threads：服务器工作线程数。
- max_session_recv_queue_length：服务器接收队列的最大长度。
- max_concurrent_incoming_streams：同时处理的最大请求流数。
- max_incoming_unidirectional_streams：最大无方向请求流数。
- max_stream_duration：最大请求持续时间。
- idle_timeout：空闲连接超时时间。
- max_header_list_size：最大请求头长度。

通过设置这些参数，可以调整服务器的行为以满足不同应用程序的需求。例如，增加工作线程数和提高接收队列的最大长度可以提高服务器的吞吐量，而减少空闲连接的超时时间可以减少连接的延迟。

#### onTransportReadyFn_

在MVFST中，onTransportReadyFn_是一个回调函数，它会在一个传输（transport）已经准备就绪时被调用。传输是指在网络上两个应用程序之间建立的连接，用于传输数据。

具体来说，onTransportReadyFn_是HTTP/3（HQ）传输协议中的一个回调函数，当HQ传输准备好时，该函数将被触发。该函数是在HQSession实例化时进行设置的。它是一个可调用的对象（callable object），可以是一个函数指针、函数对象或者Lambda表达式等，用于处理传输就绪事件。

当传输就绪时，onTransportReadyFn_被调用，以HQTransport作为参数。HQTransport包含了与一个HTTP/3连接相关的所有信息和状态，如发送和接收数据的流、传输级错误和流级错误等。开发者可以在onTransportReadyFn_中实现自定义的处理逻辑，例如创建一个HTTP请求并发送给远程服务器，或者开始接收远程服务器发送的数据等。

#### onDestroy

在软件开发中，onDestroy通常是一个方法或者函数名，表示在对象被销毁之前需要执行的操作。在MVFST中，onDestroy函数是一个回调函数，用于在销毁一个对象之前执行一些清理操作。

具体来说，在MVFST中，onDestroy函数是一个回调函数对象，通常在创建一个对象时进行设置，用于在对象被销毁之前执行一些清理操作，例如释放内存、关闭文件、取消定时器、断开网络连接等等。它是在对象销毁时自动被调用的，通常用于避免资源泄露和保证程序的正确性。

例如，在MVFAST中，HQSession的onDestroy函数会在HQSession被销毁之前执行一些清理操作，例如关闭网络连接、取消定时器、释放内存等等。这些操作可以确保HQSession被正确地销毁，避免资源泄露和程序错误。

#### getRequestHandler

在Web应用程序中，getRequestHandler通常是指一个处理HTTP请求的函数或对象。在MVFST中，getRequestHandler是HTTP请求处理器的一个接口，它定义了处理HTTP请求的方法。

具体来说，getRequestHandler是在HTTPServer实例化时设置的，用于指定如何处理客户端的HTTP请求。该接口定义了一个名为onRequest的纯虚函数，它需要由子类实现。当HTTPServer接收到一个HTTP请求时，它会调用getRequestHandler函数返回的HTTP请求处理器对象的onRequest函数，传递HTTP请求的相关信息作为参数。开发者可以在onRequest函数中实现自定义的请求处理逻辑，例如根据请求URL路由到不同的处理函数、解析请求参数、生成响应内容等等。

#### getParseErrorHandler

需要注意的是，MVFST中提供了默认的HTTP请求处理器HQRequestHandler，它实现了getRequestHandler接口并提供了一些常见的请求处理逻辑。如果开发者不需要自定义请求处理逻辑，可以直接使用HQRequestHandler。

在proxygen中，getParseErrorHandler是HTTPRequest类的一个方法，用于获取HTTP请求解析错误处理器。当proxygen解析HTTP请求时，如果遇到语法错误或其他错误，会触发解析错误处理器来处理该错误。

具体来说，getParseErrorHandler返回一个指向HTTPErrorPageFactory类型的函数指针，用于指定处理HTTP请求解析错误的函数。HTTPErrorPageFactory类型是一个回调函数类型，它接受一个HTTPStatus类型的参数（表示HTTP错误状态码），返回一个std::unique_ptr[folly::IOBuf](javascript:void(0))类型的指针，表示HTTP响应的消息体。

开发者可以通过重写这个函数指针，实现自定义的HTTP请求解析错误处理逻辑。例如，当解析错误发生时，可以返回一个自定义的错误消息体，告诉客户端发生了什么错误。默认情况下，proxygen会使用proxygen::SimpleController来处理解析错误，返回一个默认的错误消息体。

需要注意的是，getParseErrorHandler只能在HTTPRequest的子类中调用，例如HTTPMessage、HTTPHeaders、HTTPMethod等等。

#### attachSession

在proxygen中，attachSession是HTTPSessionController类的一个方法，用于将一个已经建立的TCP连接与HTTP会话相关联。HTTPSessionController类是proxygen的一个重要组件，用于管理HTTP会话的生命周期，并提供一些HTTP会话的控制方法。

具体来说，当proxygen接收到一个客户端发来的HTTP请求时，它会创建一个新的HTTPSession对象，并调用HTTPSessionController的attachSession方法将该HTTPSession对象与建立的TCP连接关联起来。通过这种方式，proxygen就能够知道这个HTTP会话对应的TCP连接是什么，从而在发送和接收HTTP请求时使用该连接进行通信。

attachSession方法接受一个TCPConnection::ConnectionCallback类型的参数，用于指定当TCP连接关闭时要执行的回调函数。开发者可以在这个回调函数中实现自定义的连接关闭处理逻辑，例如释放资源、记录日志等等。如果没有指定回调函数，则使用默认的TCPConnection::closeWhenIdle方法关闭TCP连接。

总之，attachSession方法是proxygen中用于将TCP连接与HTTP会话相关联的方法，它在HTTPSessionController中发挥了重要的作用，确保HTTP会话能够正确地使用已经建立的TCP连接进行通信。

#### onTransportReady

在proxygen中，onTransportReady是HTTPTransaction类的一个方法，它是HTTP事务的回调函数之一。HTTPTransaction是proxygen中表示单个HTTP事务的类，每个HTTP请求都由一个HTTPTransaction对象来表示，HTTPTransaction对象负责处理HTTP请求和响应的读写操作。

onTransportReady函数在HTTPTransaction对象与网络传输层的连接建立好之后被调用，它表示HTTPTransaction对象已经准备好从网络传输层中读取数据了。当TCP连接建立好之后，网络传输层会调用onTransportReady函数来通知HTTPTransaction对象开始读取网络数据。

开发者可以在onTransportReady函数中实现自定义的处理逻辑，例如读取请求数据、初始化响应等等。在处理HTTP请求和响应时，HTTPTransaction对象提供了许多便捷的方法，例如sendHeaders、sendBody、sendEOM等等，开发者可以通过调用这些方法来向客户端发送HTTP响应。

总之，onTransportReady函数是HTTPTransaction类中重要的回调函数之一，它表示HTTPTransaction对象已经准备好开始读取网络数据了，开发者可以在该函数中实现自定义的处理逻辑，以处理HTTP请求和响应。

#### H1QDownstreamSession

在proxygen中，H1QDownstreamSession是HTTPSession的一个子类，它是proxygen实现的基于HTTP/1.x和HTTP/2协议的客户端会话类。H1QDownstreamSession类用于处理客户端向服务器发送的HTTP请求，与服务器进行通信，并接收服务器返回的HTTP响应。

具体来说，当客户端向服务器发送HTTP请求时，H1QDownstreamSession类会负责将HTTP请求封装成二进制数据，并通过底层网络传输层发送到服务器。同时，它也会接收来自服务器的HTTP响应，并将响应数据解析成HTTP消息格式，供上层应用程序使用。

H1QDownstreamSession类实现了HTTPSession接口中定义的所有方法，并添加了一些特定于HTTP/1.x和HTTP/2协议的方法，例如readHeaders、readBody、sendHeaders、sendBody等等。通过这些方法，开发者可以方便地向服务器发送HTTP请求，并接收服务器返回的HTTP响应。

需要注意的是，H1QDownstreamSession类是proxygen中的一个客户端会话类，它只能用于向服务器发送HTTP请求。如果需要实现服务器端的HTTP会话，则需要使用H1QUpstreamSession或HTTP2UpstreamSession类。

#### HQDownstreamSession

在mvfst中，HQDownstreamSession是proxygen实现的HTTP/3客户端会话类，用于处理客户端向服务器发送的HTTP请求，与服务器进行通信，并接收服务器返回的HTTP响应。它是HTTP3DownstreamSession的一个别名。

HQDownstreamSession类的构造函数有以下参数：

1. eventBase：事件循环的指针，用于处理网络事件。
2. socket：一个已经建立连接的AsyncUDPSocket对象，用于发送和接收HTTP/3数据帧。
3. connId：一个ConnectionId对象，表示该会话的连接ID。
4. router：一个QuicTransportStatsCallback指针，用于收集与该会话相关的统计信息。
5. initialSettings：一个QuicSocket::TransportSettings类型的结构体，表示该会话的初始设置，例如初始流量控制窗口大小等。

其中，socket、connId和router参数都是必需的，因为它们定义了一个有效的HTTP/3会话。eventBase参数和initialSettings参数是可选的，如果没有提供，则使用默认值。

除了构造函数参数之外，HQDownstreamSession还有一些其他的重要属性和方法，例如getCodec()、onTransportReady()、onHeadersComplete()、onBody()、onEOM()、onTrailers()等等，用于处理HTTP/3请求和响应。同时，HQDownstreamSession还提供了一些统计信息，例如bytesReceived()、bytesSent()、totalBytesReceived()、totalBytesSent()等等，可以用于监控HTTP/3会话的性能和资源使用情况。

#### setHealthCheckToken()是proxygen中HTTPHealthCheckFilter类的一个方法，用于设置健康检查的令牌。

在proxygen中，HTTPHealthCheckFilter类用于实现健康检查功能，即检查服务器是否能够正常处理请求。在健康检查期间，HTTPHealthCheckFilter会向服务器发送一个特殊的HTTP请求，以检查服务器的健康状况。为了防止其他请求干扰健康检查，HTTPHealthCheckFilter会在HTTP请求中添加一个特殊的令牌。setHealthCheckToken()方法就是用于设置这个特殊的令牌。

setHealthCheckToken()方法有一个string类型的参数，表示健康检查令牌的值。在实现健康检查时，应该将健康检查令牌添加到HTTP请求头中，例如：

```
cCopy codeauto headers = req->getHeaders();
headers.set(HTTP_HEADER_USER_AGENT, "proxygen healthcheck");
headers.set(HTTP_HEADER_HOST, "www.example.com");
headers.set("X-Healthcheck-Token", "my_healthcheck_token");
req->setHeaders(std::move(headers));
```

在这个例子中，健康检查令牌的值是"my_healthcheck_token"，它被添加到了HTTP请求头的"X-Healthcheck-Token"字段中。这样，在服务器收到健康检查请求时，可以检查请求头中是否包含了正确的健康检查令牌，以判断是否为健康检查请求。

#### boundAddr

在proxygen中，boundAddr指的是服务器绑定的本地网络地址。当proxygen服务器启动时，它需要绑定一个本地网络地址，以便接受来自客户端的连接请求。boundAddr就是用于表示这个绑定的本地网络地址。

boundAddr通常是一个IP地址和端口号的组合，例如"127.0.0.1:8080"。在proxygen中，可以使用HTTPServerOptions类的setBindAddress()方法来设置服务器的绑定地址，例如：

```
arduinoCopy codeauto serverOptions = std::make_shared<HTTPServerOptions>();
serverOptions->setBindAddress("127.0.0.1", 8080);
```

在这个例子中，服务器的绑定地址被设置为"127.0.0.1:8080"。当服务器启动时，它会绑定到这个地址，并开始接受来自客户端的连接请求。

除了boundAddr之外，proxygen还有一些其他与网络地址相关的属性和方法，例如HTTPServerOptions类的setListenBacklog()方法（用于设置服务器的backlog大小）、SocketAddress类（用于表示一个网络地址）、AsyncServerSocket类（用于监听网络连接请求并创建TCP连接）等等。这些属性和方法一起构成了proxygen网络编程的基础。

#### 运行 Proxygen 的 sample 代码

在运行 Proxygen 的 sample 代码之前，需要先确保已经安装了 Proxygen，具体的安装步骤可以参考文献 [3](https://blog.csdn.net/amengbumeng/article/details/76820846) 中的说明。

在安装完成之后，可以通过以下步骤来运行 Proxygen 的 sample 代码：

1. 克隆 Proxygen 的源代码并进入 samples 目录：

```
git clone https://github.com/facebook/proxygen.git
cd proxygen/proxygen/examples/hq
```

1. 编译 sample 代码：

```
make hq_server
make hq_client
```

1. 启动 hq_server：

```
./hq_server
```

1. 在另一个终端中启动 hq_client：

```
./hq_client
```

注意，这只是一个简单的示例，实际使用中需要根据自己的需求进行相应的配置和修改。

gcc是一种常用的编译器，可以编译C、C++等语言的源代码，并生成可执行文件。gcc编译命令的基本语法如下：

```
gcc [options] source_file.c -o output_file
```

其中，source_file.c表示要编译的源文件，-o表示输出文件的选项，output_file表示生成的可执行文件的名称。在这个基本命令中，还可以添加一些选项来指定编译器的行为。以下是一些常用的gcc编译命令选项：

- -c：只编译源文件，生成目标文件（.o文件），不进行链接操作。
- -Wall：开启所有警告信息。
- -O：开启优化选项。
- -g：生成可调试的可执行文件。
- -I：添加头文件的搜索路径。
- -L：添加库文件的搜索路径。
- -l：链接指定的库文件。
- -std：指定使用的C++标准（如-std=c++11）。

例如，以下命令可以编译并生成可执行文件：

```
gcc -Wall -O2 -o hello_world hello_world.c
```

这个命令将编译名为hello_world.c的源文件，并生成可执行文件hello_world，同时开启所有警告信息和优化选项。

#### tc

`tc` 命令是 Linux 系统中的 traffic control 工具，它可以用来控制、限制和操纵网络流量，其中包括使用 `netem` 模块来模拟延迟、丢包、抖动等网络情况。在大多数 Linux 发行版中，`tc` 命令通常已经默认安装好了。如果需要使用 `netem` 模块，需要确保内核支持 `netem` 模块，也就是内核编译时需要打开 `CONFIG_NET_SCHED` 和 `CONFIG_NET_EMATCH` 选项。可以使用以下命令检查当前内核是否支持 `netem` 模块：

```
modprobe sch_netem
```

如果没有错误提示，则说明当前内核支持 `netem` 模块。

下面介绍一些使用 `tc` 命令和 `netem` 模块的基本操作：

1. 添加一个模拟延迟为 100ms 的 netem 规则：

```
tc qdisc add dev eth0 root netem delay 100ms
```

1. 删除一个 netem 规则：

```
tc qdisc del dev eth0 root netem
```

1. 查看当前 eth0 网卡上的 netem 规则：

```
tc qdisc show dev eth0
```

更多的 `tc` 命令和 `netem` 模块的使用，可以参考相关文档和教程。

如果想让网络恢复正常，只需要删除监控，或将设置的值相应归0即可。

 $ tc  qdisc add dev  eth0  root netem loss 1% 

#### PADDING 

是一种数据填充技术，通常用于计算机网络通信中。当数据包的长度不足时，为了满足一定的长度要求，可以通过添加一些额外的数据（填充）来达到要求。这些填充数据在接收端会被自动删除。

在网络通信中，PADDING 可以用于以下几种情况：

1. 为了达到特定的数据包长度要求，例如某些网络协议需要数据包的长度是固定的。
2. 为了防止信息泄露，例如使用加密算法加密数据时，为了隐藏实际数据的长度，可以在数据包中添加填充数据。
3. 为了增加数据包的随机性和安全性，例如某些网络安全协议要求数据包具有随机性，可以在数据包中添加填充数据来增加随机性。

需要注意的是，过多的 PADDING 数据可能会浪费网络带宽和系统资源，因此应该尽量减少不必要的 PADDING。同时，在使用 PADDING 时也需要考虑到网络安全和性能等方面的问题。

#### WaitReleaseHandler（等待释放处理程序）

是指一种网络编程中的技术，用于等待套接字的连接在被关闭或释放之前保持处于活动状态。

当一个客户端通过一个套接字与服务器建立连接后，通常需要等待客户端关闭套接字或服务器主动关闭套接字才能释放资源。在某些情况下，如果在套接字关闭之前还有其他任务需要完成，例如数据传输或其他操作，服务器需要保持套接字处于活动状态，并等待套接字关闭后再释放资源。

WaitReleaseHandler 就是用来处理这种情况的技术。它会在服务器上创建一个专门的线程或进程来处理所有需要等待套接字释放的操作，该线程或进程会在套接字关闭后自动释放相关资源。

使用 WaitReleaseHandler 可以有效避免资源泄露和其他问题，并确保程序的稳定性和可靠性。它在一些高并发和高可用性的网络编程中得到广泛应用，例如 Web 服务器和分布式系统等。

#### unordered_map

unordered_map是C++ STL中的一个关联容器，它以键值对的形式存储元素，键值是用于唯一标识元素的值，而映射值则是与键值相关联的内容。该容器使用哈希表实现，在插入、删除和查找元素时平均复杂度为常数级别，因此在大数据量场景下具有较高的效率[[1](https://en.cppreference.com/w/cpp/container/unordered_map)][[2](https://www.geeksforgeeks.org/unordered_map-in-cpp-stl/)][[3](https://cplusplus.com/reference/unordered_map/unordered_map/)]。

在unordered_map内部，元素通常是按照哈希值散列到不同的桶（bucket）中，而具体分配到哪个桶中则完全取决于其键值的哈希值。因此，在unordered_map中，元素的内部排序方式是无序的，而是以桶为单位进行组织[[1](https://en.cppreference.com/w/cpp/container/unordered_map)]。

unordered_map常用于需要快速检索元素的场景，如某些算法、数据结构或大型程序中[[2](https://www.geeksforgeeks.org/unordered_map-in-cpp-stl/)][[3](https://cplusplus.com/reference/unordered_map/unordered_map/)]。

#### Pragma

是编程语言中的一个关键字，用于让程序员在源代码中插入指令，控制编译器的行为和输出结果。具体而言，pragma指令可以访问编译器特定的预处理器扩展，其指令一般以“#pragma”开头。pragma指令的一个常见用法是#pragma once指令，该指令告诉编译器只将头文件包含一次，而不管它被导入多少次。此外，C++11中引入了标准的_Preprocessor Operator_ *Pragma*，与pragma指令的作用类似[[1](https://learn.microsoft.com/en-us/cpp/preprocessor/pragma-directives-and-the-pragma-keyword?view=msvc-170)][[3](https://www.cprogramming.com/reference/preprocessor/pragma.html)]。

#### supportedAlpns

 是Fizz C++库中的一个成员变量，用于在FizzServerContext.h和FizzClientContext.h中进行协议的选择。在FizzServerContext.h中，该变量用于返回支持的ALPN协议列表[[1](https://github.com/facebookincubator/fizz/blob/main/fizz/server/FizzServerContext.h)]。在FizzClientContext.h中，该变量用于设置客户端提供的ALPN协议的支持列表[[2](https://raw.githubusercontent.com/lijun401338/proxygen-document/master/classfizz_1_1client_1_1FizzClientContext.html)]。在Fizz库中，ALPN（Application-Layer Protocol Negotiation）协议用于在TLS握手期间选择客户端和服务器之间的应用层协议。 ALPN允许客户端和服务器根据其支持的协议列表进行协商，从而选择共同支持的协议进行通信。

#### 根据提供的搜索结果，关于C++中的"using"关键字有以下几种用法：

1. 命名空间的using指令：可以通过using指令引入其他命名空间的成员到当前命名空间或者块作用域中[[1](https://en.cppreference.com/w/cpp/keyword/using)]。
2. 类成员的using声明：可以通过using声明在派生类中引入基类的成员[[3](https://en.cppreference.com/w/cpp/language/using_declaration)]。
3. 类型别名和模板别名声明：可以使用using关键字定义类型别名和模板别名，其与typedef的语义相同[[2](https://stackoverflow.com/questions/20790932/what-is-the-logic-behind-the-using-keyword-in-c)]。

#### nodiscard

[1] "带有 nodiscard 声明的构造函数会在显式类型转换或 static_cast 时被调用，或者在显式类型转换或 static_cast 初始化枚举或类类型的对象时调用，编译器会鼓励发出警告。如果指定了字符串字面量，则通常会包含在警告中。" [[1](https://en.cppreference.com/w/cpp/language/attributes/nodiscard)]

[2] "C++17 引入了[[nodiscard]] 属性，允许程序员标记函数，从而使编译器在返回的对象被调用方丢弃时发出警告；这个属性也可以添加到整个类类型上。" [[2](https://softwareengineering.stackexchange.com/questions/363169/whats-the-reason-for-not-using-c17s-nodiscard-almost-everywhere-in-new-c)]

[3] "C++ 属性：nodiscard（自 C++17 起）。如果通过值返回的函数声明为 nodiscard，或者返回了一个声明为 nodiscard 的枚举或类类型的值，并且在丢弃值表达式中（不包括对 void 的强制转换）调用了该函数，则编译器会鼓励发出警告。" [[3](http://www.man6.org/docs/cppreference-doc/reference/en.cppreference.com/w/cpp/language/attributes/nodiscard.html)]

#### GSO

GSO (Generic Segmentation Offload)是一种网络协议栈的技术，用于推迟数据分段直到发送到网卡驱动之前[[2](https://blog.csdn.net/megan_free/article/details/84992350)]。GSO的基本思想是检查网卡是否支持分片功能（如TSO、UFO）,如果支持直接发送到网卡，如果不支持则进行分片后再发往网卡[[2](https://blog.csdn.net/megan_free/article/details/84992350)]。GSO是协议栈是否推迟分段，在发送到网卡之前判断网卡是否支持TSO，如果网卡支持TSO则让网卡分段，否则协议栈分完段再交给驱动[[3](https://www.cnblogs.com/codestack/p/13444734.html)]。如果TSO开启，GSO会自动开启[[3](https://www.cnblogs.com/codestack/p/13444734.html)]。

GSO技术提高了对VXLAN等封装报文的支持，对于GSO报文封装后报文的能够正确GSO分段，而不会产生IP分片报文。实现这个功能，需要用到skb_segment函数的支持，它能够复制外层报文头而不管有多长，因此只需要少量修改，内核就能够支持多层封装的GSO分段[[1](https://www.cnblogs.com/dream397/p/14500939.html)]。

总之，GSO技术可以通过推迟数据分段来提高网络传输效率，并且能够支持多层封装的GSO分段[[2](https://blog.csdn.net/megan_free/article/details/84992350)][[3](https://www.cnblogs.com/codestack/p/13444734.html)][[1](https://www.cnblogs.com/dream397/p/14500939.html)]。

#### UNLIKELY

C++中的UNLIKELY是一个关键字，可用于标识在程序中出现的概率较小的路径。C++20中引入了likely和unlikely这两个新属性，它们可以告诉编译器哪些代码路径更可能被执行，从而帮助编译器优化代码。likely和unlikely属性可以应用于if和switch语句，以及其他控制流语句。例如，likely属性可以用于标记某个if语句的代码路径，表示这个条件通常是真的，从而让编译器在生成机器码时更加偏向这条路径[[1](https://en.cppreference.com/w/cpp/language/attributes/likely)]。

在一些编译器中，如g++和clang，可以使用likely和unlikely属性来提高代码的执行效率[[2](https://stackoverflow.com/questions/51797959/how-to-use-c20s-likely-unlikely-attribute-in-if-else-statement)]。而在最新的MSVC中，也支持使用[[likely]]和[[unlikely]]属性[[3](https://stackoverflow.com/questions/1440570/likely-unlikely-equivalent-for-msvc)]。

因此，UNLIKELY关键字通常用于帮助编译器进行代码优化，提高程序的性能和效率