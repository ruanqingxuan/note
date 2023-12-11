# quic go +caddy部署思路

[TOC]

## 安装go环境

https://golang.google.cn/doc/install

要下载最新版的 Go 环境，您可以按照以下步骤进行操作：

1. **访问官方网站下载：**
   您可以访问 Go 官方网站的下载页面，选择适合您系统的版本进行下载。您可以在这个网址找到各个平台的下载链接：https://studygolang.com/dl

   根据您的操作系统和体系架构，选择适当的下载链接。下载的文件格式可能是 `.tar.gz`、`.zip` 或 `.msi`，具体取决于您的操作系统。

2. **使用命令行下载和安装（Linux 示例）：**
   如果您使用的是 Linux 系统，您可以使用命令行下载和安装最新版的 Go 环境。以下是一个示例命令：

   ```bash
   wget https://dl.google.com/go/go1.21.0.linux-amd64.tar.gz
   tar -C /usr/local -zxvf go1.21.0.linux-amd64.tar.gz
   ```

   这将下载 Go 的压缩包，并将其解压到 `/usr/local` 目录下。这是官方推荐的安装位置。

3. **配置环境变量：**
   为了能够在任何地方使用 Go 命令，您需要将 Go 的二进制路径添加到系统的 PATH 环境变量中。您可以通过编辑 `/etc/profile` 或 `$HOME/.profile` 文件来添加。

   ```bash
   vim /etc/profile  # 或者使用其他文本编辑器如 nano 或 gedit
   ```

   在文件的末尾添加以下内容：

   ```bash
   export GOROOT=/usr/local/go
   export PATH=$PATH:$GOROOT/bin
   ```

   保存并退出编辑器后，使用以下命令使环境变量生效：

   ```bash
   source /etc/profile
   ```

4. **验证安装：**
   输入以下命令来验证是否成功安装了 Go：

   ```bash
   go version
   ```

   如果成功安装，将会显示 Go 的版本信息。

## quic go

https://github.com/quic-go/quic-go

### 编译quic-go

下载quic-go

```bash
#下载quic-go
git clone https://github.com/lucas-clemente/quic-go.git
cd quic-go/example
```

服务端

```bash
#server
go build main.go
```

客户端

```bash
#client
cd client
go build main.go
```

### 测试quic-go

使用ubuntu默认浏览器。firefox 浏览器打开`about:config`修改`HTTP3`值为`TRUE`

#### 开启服务端

```bash
cd quic-go/example
./main -qlog -v -tcp
```

**访问`https://localhost:6121/demo/tile`**

发现协议已经使用`HTTP3`协议

#### 客户端

```javascript
cd quic-go/example/client
./main -v -insecure -keylog ssl.log https://quic.rocks:4433/
```

## quic-go源码分析

### go语言语法

#### interface：类似于struct

在Go语言中，`interface`（接口）是一种类型，它定义了一组方法的签名，但并不提供这些方法的具体实现。接口允许您声明某个类型拥有一定的行为，而不必关心具体的数据结构。其他类型可以通过实现接口中定义的方法来满足该接口的要求。这使得在Go中实现多态性（Polymorphism）变得更加灵活。

接口的定义类似于方法签名的集合，其中包含了方法的名称、参数列表和返回类型，但不包含实际的方法体。当一个类型实现了一个接口所定义的方法集合，它就被认为是该接口的实现。

通过使用接口，您可以编写更通用、可复用的代码，因为您可以针对接口类型而不是具体的数据类型来编写代码。这也使得代码的可测试性更强，因为您可以轻松地用模拟对象实现接口以进行单元测试。

以下是一个简单的示例，展示了在Go中如何定义接口以及如何实现接口：

```go
package main

import (
	"fmt"
)

// 定义一个接口
type Shape interface {
	Area() float64
}

// 定义一个结构体类型 Circle，实现 Shape 接口
type Circle struct {
	Radius float64
}

// 实现 Shape 接口中的方法
func (c Circle) Area() float64 {
	return 3.14 * c.Radius * c.Radius
}

func main() {
	// 创建 Circle 实例
	circle := Circle{Radius: 5.0}

	// 将 Circle 实例赋值给 Shape 接口类型
	var shape Shape
	shape = circle

	// 调用接口方法，计算面积
	area := shape.Area()
	fmt.Println("圆的面积:", area)
}
```

在这个示例中，我们定义了一个名为 `Shape` 的接口，它包含了一个 `Area` 方法的签名。然后，我们创建了一个名为 `Circle` 的结构体类型，并实现了 `Shape` 接口的 `Area` 方法。最后，我们在 `main` 函数中通过将 `Circle` 类型的实例赋值给 `Shape` 接口类型来演示了接口的用法。

#### var：变量

在 Go 语言中，`var` 是一个关键字，用于声明变量。使用 `var` 关键字可以创建一个新的变量，并指定其名称和数据类型。例如：

```go
var x int // 声明一个名为 x 的整数类型变量
var name string // 声明一个名为 name 的字符串类型变量
```

你还可以通过在声明时为变量赋初值：

```go
var age int = 25 // 声明一个名为 age 的整数类型变量，并赋值为 25
var message string = "Hello, world!" // 声明一个名为 message 的字符串类型变量，并赋值为 "Hello, world!"
```

需要注意的是，Go 语言也支持类型推断，这意味着你可以省略变量的类型，让编译器根据赋值表达式来推断出变量的类型：

```go
var score = 95 // 根据赋值表达式推断出 score 的类型为 int
var greeting = "Hi there!" // 根据赋值表达式推断出 greeting 的类型为 string
```

总之，`var` 是 Go 语言中用于声明变量的关键字，它可以与数据类型一起使用来创建新的变量，并可以选择性地赋予初始值。

#### rawconn：原始连接实体

在 Go 语言中，`rawConn` 是指一个原始连接（Raw Connection），它是在网络编程中常见的概念之一。原始连接是指程序直接操作的底层网络连接，通常位于更高级别的抽象之下，比如套接字（Socket）。

在 Go 语言中，`rawConn` 可能是指一个 `net` 包中的类型 `net.RawConn`，它允许程序员直接操作底层的网络连接，包括读取和写入原始数据，控制连接的各种参数等。使用 `net.RawConn`，开发人员可以更灵活地控制网络连接，实现一些自定义的网络通信逻辑。

需要注意的是，直接操作原始连接可能会涉及到更多的网络细节和复杂性，通常在特定的网络应用场景下使用，例如实现自定义的网络协议或者进行底层网络性能优化。对于一般的网络通信，使用标准的高级抽象会更加方便和安全。

#### chan：通道

在Go语言中，`chan` 是指通道（channel）的意思。通道是一种用来在不同的 Go 协程（goroutine）之间进行通信和数据传递的机制。通道允许一个协程将数据发送到通道中，而另一个协程则可以从通道中接收这些数据。这种通信机制可以协调并发执行的协程，避免竞争条件和数据竞争问题。

通过创建通道，你可以实现协程之间的数据同步和数据传递，从而确保并发程序的正确性。在 Go 中，使用`make`函数来创建一个通道，然后使用`<-`操作符来发送和接收数据。通道可以是带缓冲的（buffered）或无缓冲的（unbuffered），这取决于你的需求。

以下是一个简单的示例，展示了如何在 Go 中使用通道进行数据传递：

```go
package main

import "fmt"

func main() {
    // 创建一个无缓冲通道
    ch := make(chan int)

    // 启动一个协程发送数据到通道
    go func() {
        ch <- 42
    }()

    // 主协程从通道中接收数据
    value := <-ch
    fmt.Println("Received:", value)
}
```

在这个示例中，协程通过通道发送了值 42，然后主协程从通道中接收到这个值并进行打印。

总之，`chan`（通道）是 Go 语言中用于实现协程之间通信的一种重要机制，有助于处理并发编程时的数据共享和同步问题。

#### map：类似于pair

在Go语言中，"map" 是一种数据结构，用于存储键-值对（key-value pairs）。它类似于其他编程语言中的字典或关联数组。"map" 允许你通过指定的键来访问对应的值，这使得你可以高效地根据特定的键来检索、插入和删除值。在 Go 语言中，"map" 是一种引用类型，意味着当你将它传递给函数或赋值给另一个变量时，实际上是传递了对底层数据的引用，而不是拷贝整个 map。

以下是一个简单的示例，展示了如何在 Go 语言中使用 map：

```go
package main

import "fmt"

func main() {
    // 创建一个空的 map，键是字符串类型，值是整数类型
    var scores map[string]int
    scores = make(map[string]int)

    // 添加键值对到 map
    scores["Alice"] = 90
    scores["Bob"] = 85

    // 根据键访问值
    fmt.Println("Alice's score:", scores["Alice"])
    fmt.Println("Bob's score:", scores["Bob"])

    // 删除键值对
    delete(scores, "Bob")

    // 检查键是否存在
    if _, exists := scores["Bob"]; !exists {
        fmt.Println("Bob's score not found")
    }
}
```

在上面的示例中，我们首先创建了一个空的 map，并向其添加了一些键值对。然后，我们通过键来访问相应的值，还演示了如何删除键值对以及检查键是否存在。

需要注意的是，map 在 Go 中是无序的，这意味着遍历键值对的顺序可能不同于它们添加到 map 中的顺序。此外，map 的键必须是可以进行相等性比较的类型，例如字符串、整数、浮点数等，但切片、函数以及包含切片的结构体等类型不可以作为键。

#### defer：后执行代码块

在Go语言中，`defer` 是一个关键字，用于在函数执行完成后执行一段代码块。无论函数是通过正常返回还是发生了错误而返回，`defer` 语句都会在函数退出时被执行。

通常情况下，`defer` 语句被用于释放资源、关闭文件、解锁互斥体等操作，以确保在函数执行结束时这些操作都能被执行，避免资源泄漏。`defer` 语句的执行顺序是后进先出（LIFO），也就是说，最后一个被定义的 `defer` 语句会最先执行，然后依次逆序执行前面的 `defer` 语句。

以下是一个示例，展示了 `defer` 的用法：

```go
package main

import "fmt"

func main() {
    defer fmt.Println("这句话会在函数结束时被执行")
    fmt.Println("主要的函数逻辑")
}
```

在上述代码中，"主要的函数逻辑" 会首先被执行，然后在函数结束时，"这句话会在函数结束时被执行" 会被打印出来，尽管它在代码中的位置在前面。这就是 `defer` 的作用方式。

#### select：处理并发操作

在 Go 语言中，`select` 是用于处理并发操作的关键字之一。它通常与通道（Channel）一起使用，用于在多个通道的发送和接收操作中进行选择，以实现非阻塞的并发控制。

`select` 语句允许在多个通道操作之间进行选择，当其中任何一个通道已经准备好发送或接收数据时，`select` 语句将执行与之相关的分支。如果多个通道同时准备就绪，Go 语言的运行时系统会随机选择一个分支来执行。

以下是一个简单的示例代码，展示了 `select` 语句的基本用法：

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go func() {
		time.Sleep(time.Second)
		ch1 <- 1
	}()

	go func() {
		time.Sleep(2 * time.Second)
		ch2 <- 2
	}()

	select {
	case val := <-ch1:
		fmt.Println("从通道 ch1 中接收到值:", val)
	case val := <-ch2:
		fmt.Println("从通道 ch2 中接收到值:", val)
	}
}
```

在这个示例中，程序会同时等待 `ch1` 和 `ch2` 这两个通道中的数据。由于 `ch1` 的数据会在 1 秒后发送，而 `ch2` 的数据会在 2 秒后发送，所以 `select` 会先选择接收 `ch1` 中的值，然后输出相应的结果。

总之，`select` 在 Go 语言中用于实现多路复用的通道操作，使得在并发编程中能够更加灵活地处理不同的通道事件。

#### wire：代码生成工具

在 Go 语言中，"wire" 通常是指一个名为 "Wire" 的代码生成工具，用于依赖注入（Dependency Injection）的辅助工具。它可以帮助开发者自动生成依赖注入相关的代码，从而简化代码编写过程。

通过使用 Wire，开发者可以定义依赖关系和对象之间的关联，然后运行 Wire 工具来生成相应的代码。这可以减少手动编写大量重复的依赖注入代码，提高开发效率，并且可以在项目结构发生变化时更容易地保持代码的一致性。

总之，"wire" 在 Go 语言中是一个用于生成依赖注入代码的工具，有助于简化和优化代码结构。

#### defer

在Go语言中，`defer`是一个关键字，用于延迟（或推迟）函数的执行，使函数在当前函数执行完毕后才会运行。`defer`通常用于确保某些操作在函数执行结束后一定会被执行，无论函数执行是否正常结束或中途发生错误。

主要用途和特点如下：

1. **延迟执行操作**：`defer`用于将函数推迟到当前函数返回之前执行。这可以确保在函数结束时执行特定操作，如关闭文件、释放资源、解锁互斥锁等。

2. **执行顺序**：多个`defer`语句会按照后进先出（LIFO）的顺序执行。也就是说，最后一个推迟的函数将会在第一个推迟的函数之前执行。

3. **参数求值**：`defer`语句中的函数参数在执行`defer`语句时就会被求值。这意味着如果`defer`语句使用了外部变量，它们将在`defer`语句执行时得到固定的值。

4. **错误处理**：`defer`通常用于处理错误，确保在函数执行出错时资源被释放，而不需要在每个可能的错误路径上重复相同的清理代码。

示例：

```go
func example() {
    file := openFile()
    defer file.Close() // 确保在函数结束时关闭文件

    // 其他操作，可能发生错误
    if somethingWentWrong {
        // 函数退出，defer语句会执行Close操作
        return
    }
    // 其他操作
}
```

在上面的示例中，`defer file.Close()`确保了`file.Close()`会在`example`函数退出时执行，无论是正常退出还是因错误而退出。

`defer`是Go语言中的一个强大工具，用于简化资源管理和错误处理。

#### peek（）

在Go语言中，`peek()` 不是标准库中的函数或方法。通常，`peek()` 是一个常见的命名约定，用于查看数据结构（如通道、切片、队列等）的下一个元素，但不移除它。这对于快速查看数据结构中的下一个元素而不改变其状态非常有用。

例如，如果你有一个通道（channel）并希望查看下一个将被接收的元素，你可以使用`peek()`来检查，而不会实际接收它。这在某些情况下可以避免不必要的数据修改。

以下是一个伪代码示例：

```go
// 创建一个整数通道
ch := make(chan int)

// 向通道发送数据
ch <- 42

// 使用peek()查看下一个将被接收的元素
nextValue := peek(ch) // 这不是Go标准库的函数，而是示例中的概念

// 实际接收元素
receivedValue := <-ch

// 打印结果
fmt.Println("Peeked Value:", nextValue)
fmt.Println("Received Value:", receivedValue)
```

在示例中，`peek()`不是Go标准库中的函数，而是一个概念性函数，用于查看通道中下一个将被接收的值。实际上，Go标准库没有内置的`peek()`函数，而是通过接收操作来查看通道中的下一个元素。但你可以自己实现`peek()`函数，以达到上述目的。

### 读写数据包

将使用ReadMsgUDP和WriteMsgUDP代替ReadFrom和WriteTo来读/写数据包。

### GSO

GSO（Generic Segmentation Offload）在计算机网络中是一项网络传输优化技术，通常与网络接口卡（NIC）和操作系统协同工作。它的主要目标是减轻CPU的负担，提高网络数据包的传输效率。

具体来说，GSO的主要功能包括将大型网络数据包分割成较小的片段以进行传输，然后在接收端重新组装这些片段。这有助于减少在发送端和接收端的CPU处理工作，因为数据包的分割和重组由网络接口卡（NIC）负责，而不是由主机的CPU执行。这使得网络传输更加高效，可以提高网络性能和吞吐量。

总的来说，GSO是一项旨在优化网络数据包传输的技术，通过减轻主机CPU的负担来提高网络性能。它在高速网络和大数据传输场景中特别有用。然而，要使用GSO，需要适当的硬件支持和操作系统配置。

### packer

`packer` 在quic-go中可能用于执行以下操作：

- 将数据分组成适当的大小的数据包。
- 添加必要的协议头和元数据，以便在QUIC协议中正确传输和解析数据。
- 处理数据包的序列号和顺序，以确保数据包按正确的顺序到达和被处理。

### ShortHeaderPacket和LongHeaderPacket有什么区别

ShortHeaderPacket和LongHeaderPacket是两种不同类型的数据包，通常用于QUIC（Quick UDP Internet Connections）协议中。它们的主要区别在于以下方面：

1. **头部结构**:
   - ShortHeaderPacket：短头部数据包通常包含一个紧凑的头部结构，用于传输已经建立的QUIC连接上的数据。这种头部结构较小，适用于已建立的连接，可以快速传输数据。
   - LongHeaderPacket：长头部数据包通常包含更多的头部信息，用于建立新的QUIC连接或进行连接重新建立。这种头部结构包括版本号、连接ID等详细信息，适用于连接的建立和管理。
2. **用途**:
   - ShortHeaderPacket：主要用于已建立的QUIC连接上，用于快速传输数据。
   - LongHeaderPacket：主要用于连接的建立和重新建立，以及传输连接相关的信息。
3. **性能**:
   - ShortHeaderPacket通常更轻量，因此在已建立的连接上传输数据时性能更高。
   - LongHeaderPacket包含更多的信息，适用于连接的建立，但可能会增加头部的大小，导致一些额外的开销。

总之，ShortHeaderPacket和LongHeaderPacket是QUIC协议中两种不同类型的数据包，它们在头部结构、用途和性能方面有所不同，以适应不同的连接阶段和需求。

### panic

在quic-go中，`panic` 是一种类似异常的机制，用于处理代码中出现的严重错误或异常条件。当某个不可恢复的错误发生时，程序可以使用 `panic` 来中止当前的执行流程，并在堆栈中追踪错误信息以便调试。

具体来说，在quic-go中，`panic` 可能用于以下情况：

- 当某个内部错误导致无法继续运行QUIC连接时，可以触发 `panic` 来中止连接。
- 在自定义代码中，如果发现某些不可预期的条件或错误，也可以使用 `panic` 来中止执行并报告问题。

需要注意的是，`panic` 应该谨慎使用，因为它会中止程序的执行，如果不妥善处理，可能导致不稳定的应用程序行为。在go中，通常建议使用 `recover` 来捕获和处理 `panic`，以确保程序可以优雅地处理错误情况。

总之，`panic` 在quic-go中是一种用于处理严重错误或异常条件的机制，它可以用来中止执行并记录错误信息。

## caddy

git clone "https://github.com/caddyserver/caddy.git"

cd caddy/cmd/caddy/

go build

caddy upgrade
 
caddy run --config /home/admin/qnwang/caddy/ARtestserver/caddyfile
