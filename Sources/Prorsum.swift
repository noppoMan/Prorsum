import Foundation
import Dispatch

let _operationQ = OperationQueue()

func swiftPanic(error: Error){
    fatalError("\(error)")
}

public func go(_ task: @autoclosure @escaping (Void) -> Void){
    _go(task)
}

public func go(_ task: @escaping (Void) -> Void){
    _go(task)
}

private func _go(_ task: @escaping (Void) -> Void){
    let operation = BlockOperation()
    
    operation.addExecutionBlock {
        task()
    }
    
    _operationQ.addOperation(operation)
}

public func runLoop(){
    RunLoop.main.run()
}
