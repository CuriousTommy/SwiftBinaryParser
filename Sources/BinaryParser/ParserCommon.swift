// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt


import Foundation


public class ParserGeneric<T>: ParserCommon {
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


open class ParseStruct : ParserCommon {
    public var size: Int {
        Mirror(reflecting: self).children.reduce(0) { (result, arg1) -> Int in
            
            if let value = arg1.value as? ParserCommon {
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
            ($0 as? ParserCommon)?.readBinary(fromData: data)
        }
    }
    
    public func writeBinary(toData data: IndexedData) {
        mirrorLoop {
            ($0 as? ParserCommon)?.writeBinary(toData: data)
        }
    }
}
