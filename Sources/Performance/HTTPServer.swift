//
//  HTTPServer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2017/02/08.
//
//

import Foundation
import Prorsum
import Foundation

func httpServerTest(){
    let server = try! HTTPServer { (request, writer) in
        do {
            let response = Response(
                headers: ["Server": "Prorsum Micro HTTP Server"],
                body: .buffer("hello".data)
            )
            
            try writer.serialize(response)
            
            //writer.close()
        } catch {
            fatalError("\(error)")
        }
    }
    
    try! server.bind(host: "0.0.0.0", port: 8888)
    print("Server listening at 0.0.0.0:8888")
    try! server.listen()
    
    RunLoop.main.run()
}
