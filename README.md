# Gosocket-Swift
Gosocket swift client. Gosocket is A simple, lightweight, session, heartbeat socket library.


## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

XcodeProject -> File -> Swift Packages -> Add package dependency -> Paste `https://github.com/thiinbit/Gosocket-Swift.git` -> Next -> Branch: master -> Next -> Finish



## Usage
```Swift
do {
    // Create TCPClient
    let tcpCli: TCPClient = try TCPClient(
    host: "127.0.0.1", port: 8888,
        codec: StringCodec(),
        listener: StringMessageListener(
        // Handle received String message
            messageHandler: { message in
                debugLog(message)
        }))
        // Will print debug log if turn on debugMode
        .debugMode(on: true)
        // Dial to server
        .dial()
    
    // Send Message
    tcpCli.sendMessage(message: "Hello, Gosocket!")
    
    // Hangup
    tcpCli.hangup()
    
} catch {
    debugLog(error)
}
```

## Gosocket Server
see: [gosocket](https://github.com/thiinbit/gosocket)

