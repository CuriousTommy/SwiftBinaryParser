// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt


import Foundation


public class ParserMutableGeneric<T>: ParserGenericProtocol {    
    public var value: T
    public var size: Int { MemoryLayout<T>.stride }

    public init(_ value: T) {
        self.value = value
    }

    public func readBinary(fromData file: IndexedData) {
        file.read(value: &self.value)
    }

    public func writeBinary(toData file: IndexedData) {
        file.write(value: self.value)
    }
}


open class ParseClass : ParserCommonProtocol {
    public var size: Int {
        Mirror(reflecting: self).children.reduce(0) { (result, arg1) -> Int in
            
            if let value = arg1.value as? ParserCommonProtocol {
                return result + value.size
            }
            
            return result
        }
    }
    
    public init() {
        
    }
    
    private func mirrorLoop(function: (Any) -> Void) {
        for (_,value) in Mirror(reflecting: self).children {
            function(value)
        }
    }
    
    public func readBinary(fromData data: IndexedData) {
        mirrorLoop {
            ($0 as? ParserCommonProtocol)?.readBinary(fromData: data)
        }
    }
    
    public func writeBinary(toData data: IndexedData) {
        mirrorLoop {
            ($0 as? ParserCommonProtocol)?.writeBinary(toData: data)
        }
    }
}

public func getArrayFromNode<T: ParserCommonProtocol>(_ data: IndexedData, count: Int, initalizer: () -> T) -> [T] {
    var newArray: [T] = []
    
    for _ in 0..<count {
        let newItem: T = initalizer()
        newItem.readBinary(fromData: data)
        newArray.append(newItem)
    }
    
    return newArray
}

public func setNodeFromArray<T: ParserCommonProtocol>(_ data: IndexedData, array: [T]) {
    for item in array {
        item.writeBinary(toData: data)
    }
}
