
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Foundation
import Dispatch

private let serialSchedulerQ = DispatchQueue(label: "prorsum.scheduler.serial-queue")

private let concurrentSchedulerQ = DispatchQueue(label: "prorsum.scheduler.concurrent-queue", attributes: .concurrent)

public enum DispatchConcurrentType {
    case serial
    case concurrent
}

public func go(type: DispatchConcurrentType = .concurrent, _ routine: @autoclosure @escaping () -> Void){
    _go(type, routine)
}

public func go(type: DispatchConcurrentType = .concurrent, _ routine: @escaping () -> Void){
    _go(type, routine)
}

private func _go(_ type: DispatchConcurrentType, _ routine: @escaping () -> Void){
    switch type {
    case .concurrent:
        concurrentSchedulerQ.async(execute: routine)
    case .serial:
        serialSchedulerQ.async(execute: routine)
    }
}

public func gomain(_ routine: @autoclosure @escaping () -> Void) {
    DispatchQueue.main.async(execute: routine)
}

public func gomain(_ routine: @escaping () -> Void) {
    DispatchQueue.main.async(execute: routine)
}

func swiftPanic(error: Error){
    fatalError("\(error)")
}
