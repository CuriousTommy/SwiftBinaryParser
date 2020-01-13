// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt


import Foundation

public class ParserGeneric<T>: ParserCommon {
    public var identifier: String
    public var value: T
    public var size: Int { MemoryLayout<T>.stride }

    public init(_ identifier: String, _ value: T) {
        self.identifier = identifier
        self.value = value
    }

    public func readData(fromFile file: IndexedData) {
        file.read(value: &self.value)
    }

    public func writeData(toFile file: IndexedData) {
        file.write(value: self.value)
    }
}

public class ParseStruct : ParserCommon {
    private let orderedElements: [ParserCommon]
    public let elements: [String: ParserCommon]
    public var identifier: String
    public var size: Int {
        orderedElements.reduce(0) { (totalSize, item) -> Int in
            totalSize + item.size
        }
    }
    
    public init(_ identifier: String, _ elements: ParserCommon...) {
        var mutableElements: [String: ParserCommon] = [:]
        var mutableOrderedElements: [ParserCommon] = []
        for element in elements {
            mutableElements[element.identifier] = element
            mutableOrderedElements.append(element)
        }
        
        self.identifier = identifier
        self.elements = mutableElements
        self.orderedElements = mutableOrderedElements
    }
    
    public func readData(fromFile data: IndexedData) {
        for currentItem in orderedElements {
            currentItem.readData(fromFile: data)
        }
    }
    
    public func writeData(toFile data: IndexedData) {
        for currentItem in orderedElements {
            currentItem.writeData(toFile: data)
        }
    }
    
    public subscript(elementString: String) -> ParserCommon? {
        elements[elementString]
    }
    
    public subscript<T: RawRepresentable>(enumElement: T) -> ParserCommon? {
        elements[enumElement.rawValue as! String]
    }
}

//
// Specific Implementation
//

public class ParseInt<T: BinaryInteger>: ParserGeneric<T> {
    public convenience init(_ identifier: String) {
        self.init(identifier, 0)
    }
}

public class ParseFloat<T: BinaryFloatingPoint>: ParserGeneric<T> {
    public convenience init(_ identifier: String) {
        self.init(identifier, 0.0)
    }
}

public class ParseStaticStringUTF8: ParserGeneric<String> {
    private let internalSize: Int
    public override var size: Int {
        get {
            internalSize
        }
    }
    
    public init(_ identifier: String, _ value: String, size: Int) {
        self.internalSize = size
        super.init(identifier, value)
    }
    
    public convenience init(_ identifier: String, size: Int) {
        self.init(identifier, "", size: size)
    }
    
    public override func readData(fromFile data: IndexedData) {
        data.readString(
            value: &self.value,
            count: self.size
        )
    }
    
    public override func writeData(toFile data: IndexedData) {
        data.writeString(
            value: self.value,
            count: self.size
        )
    }
}
