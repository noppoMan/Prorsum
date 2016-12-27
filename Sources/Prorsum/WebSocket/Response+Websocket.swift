//
//  Response+Websocket.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/28.
//
//

extension Response {
    public typealias UpgradeConnection = (Request, DuplexStream) throws -> Void
    
    public var upgradeConnection: UpgradeConnection? {
        return storage["response-connection-upgrade"] as? UpgradeConnection
    }
    
    public mutating func upgradeConnection(_ upgrade: @escaping UpgradeConnection)  {
        storage["response-connection-upgrade"] = upgrade
    }
}
