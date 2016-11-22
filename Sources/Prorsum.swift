import Foundation
import Dispatch

let _operationQ = OperationQueue()

public func go(_ task: @escaping (Void) -> Void){
    let operation = BlockOperation() // TODO should be retain on memory to cancel by the Operation
    
    operation.addExecutionBlock {
        task()
    }
    
    _operationQ.addOperation(operation)
}


public func run(){
    RunLoop.main.run()
}
