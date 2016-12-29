//
//  WebSocketServer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/27.
//
//

public enum WebsocketRequestError: Error {
    case requestDoesNotHaveValidWebsocketHeaders
}

extension Request {
    public typealias UpgradeConnection = (Response, DuplexStream) throws -> Void
    
    public var upgradeConnection: UpgradeConnection? {
        return storage["request-connection-upgrade"] as? UpgradeConnection
    }
    
    public mutating func upgradeConnection(_ upgrade: @escaping UpgradeConnection)  {
        storage["request-connection-upgrade"] = upgrade
    }
}

extension Request {
    
    public var webSocketVersion: String? {
        return headers["Sec-Websocket-Version"]
    }
    
    public var webSocketKey: String? {
        return headers["Sec-Websocket-Key"]
    }
    
    public var webSocketAccept: String? {
        return headers["Sec-WebSocket-Accept"]
    }
    
    public var isWebSocket: Bool {
        return connection?.lowercased() == "upgrade" && upgrade?.lowercased() == "websocket"
    }
    
    public func upgradeToWebSocket(didConnect: @escaping (Request, WebSocket) throws -> ()) throws -> Response {
        guard isWebSocket && webSocketVersion == "13", let key = webSocketKey else {
            throw WebsocketRequestError.requestDoesNotHaveValidWebsocketHeaders
        }
        
        guard let accept = WebSocket.accept(key) else {
            return Response(status: .internalServerError)
        }
        
        let headers: Headers = [
            "Connection": "Upgrade",
            "Upgrade": "websocket",
            "Sec-WebSocket-Accept": accept
        ]
        
        var response = Response(status: .switchingProtocols, headers: headers)
        response.upgradeConnection { request, stream in
            let webSocket = WebSocket(stream: stream, mode: .server)
            try didConnect(request, webSocket)
            try webSocket.start()
        }
        
        return response
    }
}
