//
//  WebSocketClient.swift
//  SwiftMeteor
//
//  Created by Yuki Takei on 2016/12/30.
//
//

import Foundation

public enum WebSocketClientError: Error {
    case responseNotWebsocket
}

public class WebSocketClient {
    
    let client: HTTPClient
    let didConnect: (WebSocket) throws -> Void
    let connectionTimeout: Double?
    
    public init(url:  URL, connectionTimeout: Double? = nil, didConnect: @escaping (WebSocket) throws -> Void) throws {
        self.client = try HTTPClient(url: url)
        self.didConnect = didConnect
        self.connectionTimeout = connectionTimeout
    }
    
    public func connect() throws {
        let key = Data(bytes: Array(URandom().bytes(16))).base64EncodedString(options: [])
        
        let headers: Headers = [
            "Connection": "Upgrade",
            "Upgrade": "websocket",
            "Sec-WebSocket-Version": "13",
            "Sec-WebSocket-Key": key,
            ]
        
        try client.open()
        
        let upgradeConnection = { [weak self] (response: Response, stream: DuplexStream) in
            guard let strongSelf = self else { return }
            
            guard response.status == .switchingProtocols && response.isWebSocket else {
                throw WebSocketClientError.responseNotWebsocket
            }
            
            guard let accept = response.webSocketAccept, accept == WebSocket.accept(key) else {
                throw WebSocketClientError.responseNotWebsocket
            }
            
            let webSocket = WebSocket(stream: stream, mode: .client, connectionTimeout: strongSelf.connectionTimeout ?? 0)
            try strongSelf.didConnect(webSocket)
            try webSocket.start()
        }
        
        _ = try client.request(headers: headers, upgradeConnection: upgradeConnection)
    }
}

