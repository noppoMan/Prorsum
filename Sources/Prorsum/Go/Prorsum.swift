import Foundation
import Dispatch

let schedulerQ = DispatchQueue(label: "prorsum.scheduler.queue", attributes: .concurrent)

public func go(_ routine: @autoclosure @escaping (Void) -> Void){
    schedulerQ.async(execute: routine)
}

public func go(_ routine: @escaping (Void) -> Void){
    schedulerQ.async(execute: routine)
}

public func gomain(_ routine: @autoclosure @escaping (Void) -> Void) {
    DispatchQueue.main.async(execute: routine)
}

public func gomain(_ routine: @escaping (Void) -> Void) {
    DispatchQueue.main.async(execute: routine)
}

func swiftPanic(error: Error){
    fatalError("\(error)")
}
