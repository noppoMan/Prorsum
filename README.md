# Prorsum
A Go like concurrent system + networking/http libraries for Swif

⚠️ Prorsum is in early development and pretty experimental.

## Features

- [x] GCD based Concurrent System
- [x] WaitGroup
- [x] Once
- [x] Channels
- [ ] Channel Iteration
- [x] Select
- [ ] Timers
- [x] TCP Server/Client
- [x] HTTP Server
- [ ] HTTP Client

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


## Networking

### HTTP Server

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

### TCP

```swift
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let server = try! TCPServer { clientSocket in
    while !clientSocket.isClosed {
        let bytes = try! clientSocket.read()
        try! clientSocket.write(bytes)
        clientSocket.close()
    }
}

// setup client
go {
    sleep(1)
    let client = try! TCP()
    try! client.connect(host: "0.0.0.0", port: 3000)
    while !client.isClosed {
        try! client.write(Array("hello".utf8))
        let bytes = try! client.read()
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
