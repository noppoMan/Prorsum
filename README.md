# Prorsum
A Go like concurrent system + networking/http libraries for Swif.

### Why Prorsum?
The reason why I started this project is because I felt it was very difficult to handle asynchronous io with Swift in the project called Slimane which I had previously made. In the Asynchronous paradigm in Swift, We need to often use the capture list well for closures and sometimes retain the object(Connection etc..) to avoid to release by ARC.
Then I thought Go's concurrent/parallel and synchronous mecanism is suitable model for the present stage of Swift(If you want to write any Server..).
Swift has Grand Centaral Dispatch(GCD), I thought that if I could successfully accomplish the memory barrier, I could bring the Go Style synchronous model(Connects GCDs to each other) to Swift that provided by Goroutine+Channel.

(Prorsum is not Goroutine. Context Switch is done on the OS side, Prorsum doesn't have Corotuine. It just has thread safe shared memory mechanism(It works on the GCD) that is heavily inspired by Go.)

### VS C10K Problem
Prorsum's HTTP Server architecure is Event Driven master + Multithreading Request Handler.
In a DispatchQueue, you can write asynchronous I/O with synchronous syntax with `go()` + `Channel<Element>`.  
No more callback hell.
```
                                                 +-----------------+
                                             |-- | Request Handler |
                                             |   +-----------------+
               +--------+                    |   +-----------------+
----- TCP ---- | master |---Dispatch Queue---|-- | Request Handler |
               +--------+                    |   +-----------------+               
                                             |   +-----------------+
                                             |-- | Request Handler |
                                                 +-----------------+
```

## Features

#### Go like equipments
- [x] GCD based Concurrent System
- [x] WaitGroup
- [x] Once
- [x] Channels
- [ ] Channel Iteration
- [x] Select
- [ ] Timers

#### Networking/HTTP
- [x] DNS ipv6/v4
- [x] TCP Server
- [x] TCP Client
- [x] HTTP Server
- [x] HTTP Client
- [x] HTTPS Client

## Installation

Currenty Prorsum supports only SPM.

### SPM

```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .Package(url: "https://github.com/noppoMan/Prorsum.git", majorVersion: 0, minor: 1),
    ]
)
```

### Cocoapods

Not supported yet

### Carthage

Not supported yet

## Usage

### `go`
go is an alias of `DispatchQueue().async { }`

```swift
func asyncTask(){
    print(Thread.current)
}

go(asyncTask())

go {
    print(Thread.current)
}

gomain {
    print(Thread.current) // back to the main thread
}
```


### `WaitGroup`

A WaitGroup waits for a collection of GCD operations to finish. The main GCD operation calls Add to set the number of GCD operations to wait for. Then each of the GCD operations runs and calls Done when finished. At the same time, Wait can be used to block until all GCD operations have finished.


```swift
let wg = WaitGrpup()

wg.add(1)
go {
    sleep(1)
    print("wg: 1")
    wg.done()
}

wg.add(1)
go {
    sleep(1)
    print("wg: 2")
    wg.done()
}

wg.wait() // block unitle twice wg.done() is called.

print("wg done")
```


### `Channel<Element>`

Channels are the pipes that connect concurrent operation. You can send values into channels from one GCD operation and receive those values into another GCD operation.

```swift
let ch = Channel<String>.make(capacity: 1)

func asyncSend(){
    try! ch.send("Expecto patronum!")
}

go(asyncSend()) // => Expecto patronum!

go {
    try! ch.send("Accio!")
}

try! ch.receive() // => Accio!

ch.close()
```


### `select`

The select statement lets a `BlockOperation` wait on multiple communication operations.

```swift
let magicCh = Channel<String>.make(capacity: 1)

go {
  try! magicCh.send("Obliviate")
}

select {
    when(magicCh) {
        print($0)
    }

    otherwise {
        print("otherwise")
    }
}
```


### `forSelect`

Generally You need to wrap the select inside a while loop. To make it easier to work with this pattern You can use `forSelect`. forSelect will loop until `done()` is called.

```swift
let magicCh = Channel<String>.make(capacity: 1)
let doneCh = Channel<String>.make(capacity: 1)

go {
    try! magicCh.send("Crucio")
    try! magicCh.send("Imperio")
}

go {
    try! doneCh.send("Avada Kedavra!")
}

forSelect { done in
    when(magicCh) {
        print($0)
    }

    when(doneCh) {
        done() // break current loop
    }

    otherwise {
        print("otherwise")
    }
}
```


# Networking

## HTTP Server

```swift
let server = try! HTTPServer { (request, writer) in
    do {
        let response = Response(
            headers: ["Server": "Prorsum Micro HTTP Server"],
            body: .buffer("hello".data)
        )

        try writer.serialize(response)

        writer.close()
    } catch {
        fatalError("\(error)")
    }
}

try! server.bind(host: "0.0.0.0", port: 3000)
print("Server listening at 0.0.0.0:3000")
try! server.listen() //start run loop
```

## HTTP/HTTPS Client

```swift
let url = URL(string: "https://google.com")
let client = try! HTTPClient(url: url!)
try! client.open()
let response = try! client.request()

print(response)
// HTTP/1.1 200 OK
// Set-Cookie: NID=91=CPfJo7FsoC_HXmq7kLrs-e0DhR0lAaHcYc8GFxhazE5OXdc3uPvs22oz_UP3Bcd2mZDczDgtW80OrjC6JigVCGIhyhXSD7e1RA7rkinF3zxUNsDnAtagvs5pbZSjXuZE; expires=Sun, 04-Jun-2017 16:21:39 GMT; path=/; domain=.google.co.jp; HttpOnly
// Transfer-Encoding: chunked
// Accept-Ranges: none
// Date: Sat, 03 Dec 2016 16:21:39 GMT
// Content-Type: text/html; charset=Shift_JIS
// Expires: -1
// Alt-Svc: quic=":443"; ma=2592000; v="36,35,34"
// Cache-Control: private, max-age=0
// Server: gws
// X-XSS-Protection: 1; mode=block
// Vary: Accept-Encoding
// X-Frame-Options: SAMEORIGIN
// P3P: CP="This is not a P3P policy! See https://www.google.com/support/accounts/answer/151657?hl=en for more info."
```

## TCP

```swift
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let server = try! TCPServer { clientStream in
    while !clientStream.isClosed {
        let bytes = try! clientStream.read()
        try! clientStream.write(bytes)
        clientStream.close()
    }
}

// setup client
go {
    sleep(1)
    let client = try! TCPSocket()
    try! client.connect(host: "0.0.0.0", port: 3000)
    while !client.isClosed {
        try! client.write(Array("hello".utf8))
        let bytes = try! client.recv()
        if !bytes.isEmpty {
            print(String(bytes: bytes, encoding: .utf8))
        }
    }
    server.terminate() // terminate server
}

try! server.bind(host: "0.0.0.0", port: 3000)
try! server.listen() //start run loop
```

## License
Prorsum is released under the MIT license. See LICENSE for details.
