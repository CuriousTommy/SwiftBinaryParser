// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt


import Foundation


public class IndexedData {
    public var index: Data.Index {
        didSet {
            if index > self.data.count {
                index = self.data.count
            } else if index < 0 {
                index = 0
            }
        }
    }

    public var data: Data

    public init(data: Data) {
        self.data = data
        self.index = 0
    }

    func getRange(_ stride: Int) -> Range<Data.Index> {
        return self.index..<self.index+stride
    }
    
    func isRangeWithInBoundsForRead(_ range: Range<Data.Index>) -> Bool {
        return (range.upperBound <= data.count && range.upperBound >= 0) &&
        (range.lowerBound <= data.count && range.lowerBound >= 0)
    }
    
    
    public func read<T>(value: inout T){
        let stride = MemoryLayout<T>.stride
        let range = getRange(stride)

        readWithinSubrange(range, forValue: &value)
        self.index += stride
    }
    
    public func readUInt8Array(value: inout [UInt8], count customCount: Int? = nil) {
        let count = customCount ?? value.count
        
        let range = getRange(count)
        readArrayWithinSubrange(range, forValue: &value, withSize: count)
        self.index += count
    }
    
    public func readString(value: inout String, count: Int?) {
        var stringArray: [UInt8] = Array(repeating: 0, count: count ?? value.count)
        
        self.readUInt8Array(value: &stringArray, count: count)
        
        if let newValue = String(bytes: stringArray, encoding: .utf8) {
            value = newValue
        }
    }
    
    
    public func write<T>(value: T){
        let stride = MemoryLayout<T>.stride
        let range = getRange(stride)

        self.writeWithinSubrange(range, forValue: value, withSize: stride)
        self.index += stride
    }
    
    public func writeUInt8Array(value: [UInt8], count customCount: Int? = nil) {
        let count = customCount ?? value.count
        
        let range = getRange(count)
        self.writeArrayWithinSubrange(range, forValue: value, withSize: count)
        self.index += count
    }
    
    public func writeString(value: String, count: Int?) {
        self.writeUInt8Array(
            value: Array(value.utf8),
            count: count
        )
    }
}




// Internal Binary Managment Function
extension IndexedData {
    func writeWithinSubrange<T>(_ subrange: Range<Data.Index>, forValue value: T, withSize size: Int) {
        var tempData = Data()
        
        withUnsafePointer(to: value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: size) { unsafeTempPointer in
                tempData.append(unsafeTempPointer, count: size)
            }
        }
        
        isRangeWithInBoundsForWrite(subrange)
        data.replaceSubrange(subrange, with: tempData)
    }
    
    func writeArrayWithinSubrange(_ subrange: Range<Data.Index>, forValue value: [UInt8], withSize size: Int) {
        var tempData = Data()
        
        tempData.append(contentsOf: value)
        
        isRangeWithInBoundsForWrite(subrange)
        data.replaceSubrange(subrange, with: tempData)
    }
    
    func isRangeWithInBoundsForWrite(_ subrange: Range<Data.Index>) {
        if subrange.upperBound > data.count {
            let requiredSize = subrange.upperBound - data.count
            data.append(Array(repeating: 0, count: requiredSize), count: requiredSize)
        } else if subrange.upperBound < 0 || subrange.lowerBound < 0 {
            print("TODO: Add support for exceptions")
            return
        }
    }
    
    
    
    func readWithinSubrange<T>(_ range: Range<Data.Index>, forValue value: inout T) {
        let unsafeTemp = UnsafeMutableBufferPointer<T>.allocate(capacity: 1)
        defer {
            unsafeTemp.deallocate()
        }
        
        // Error Checking
        if isRangeWithInBoundsForRead(range) {
            data.copyBytes(to: unsafeTemp, from: range)
            value = unsafeTemp.first!
        } else {
            print("TODO: Add support for exceptions")
            return
        }
    }
    
    func readArrayWithinSubrange(_ range: Range<Data.Index>, forValue value: inout [UInt8], withSize size: Int) {
        
        if isRangeWithInBoundsForRead(range) {
            data.copyBytes(to: &value, from: range)
        } else {
            print("TODO: Add support for exceptions")
            return
        }
    }
}
