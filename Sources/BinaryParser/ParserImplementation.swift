// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt

import Foundation

public class ParseInt<T: BinaryInteger>: ParserMutableGeneric<T> {
    public convenience init() {
        self.init(0)
    }
}

public class ParseFloat<T: BinaryFloatingPoint>: ParserMutableGeneric<T> {
    public convenience init() {
        self.init(0.0)
    }
}

public class ParseStaticStringUTF8: ParserMutableGeneric<String> {
    private let internalSize: Int
    public override var size: Int {
        get {
            internalSize
        }
    }
    
    public init(_ value: String, size: Int) {
        self.internalSize = size
        super.init(value)
    }
    
    public convenience init(size: Int) {
        self.init("", size: size)
    }
    
    public override func readBinary(fromData data: IndexedData) {
        data.readString(
            value: &self.value,
            count: self.size
        )
    }
    
    public override func writeBinary(toData data: IndexedData) {
        data.writeString(
            value: self.value,
            count: self.size
        )
    }
}

public class ParseByteOrder: ParserCommonProtocol {
    public enum UTF: Equatable {
        case UTF16
        case UTF32
    }
    
    public enum Endian {
        case big
        case little
    }
    
    public var size: Int {
        switch utf {
            case .UTF16:
                return 2
            case .UTF32:
                return 4
        }
    }
    
    public let utf: UTF
    public var endian: Endian?
    
    public init(_ utf: ParseByteOrder.UTF, endian: ParseByteOrder.Endian? = nil) {
        self.utf = utf
        self.endian = endian
    }
    
    
    public func readBinary(fromData: IndexedData) {
        let switchEndian: ([UInt8], [UInt8], [UInt8]) -> Void = {current,big,little in
            if current == big {
                self.endian = .big
            } else if current == little {
                self.endian = .little
            } else {
                self.endian = .none
            }
        }
        
        let switchUTF: ([UInt8]) -> Void = { current in
            let big: [UInt8]
            let little: [UInt8]
            
            switch self.utf {
                case .UTF16:
                    big = [0xFE, 0xFF]
                    little = [0xFF, 0xFE]
                    break;
                case .UTF32:
                    big = [0x00, 0x00, 0xFE, 0xFF]
                    little = [0xFF, 0xFE, 0x00, 0x00]
                    break;
            }
            
            switchEndian(current,big,little)
        }

        var rawValue: [UInt8] = Array(repeating: 0, count: size)
        fromData.readUInt8Array(value: &rawValue)
        switchUTF(rawValue)
    }
    
    
    public func writeBinary(toData: IndexedData) {
        let switchEndian: ([UInt8], [UInt8]) -> [UInt8]? = {big,little in
            switch self.endian {
                case .big:
                    return big
                case .little:
                    return little
                case .none:
                    return nil
            }
        }
        
        let switchUTF: () -> [UInt8]? = {
            let big: [UInt8]
            let little: [UInt8]
            
            switch self.utf {
                case .UTF16:
                    big = [0xFE, 0xFF]
                    little = [0xFF, 0xFE]
                case .UTF32:
                    big = [0x00, 0x00, 0xFE, 0xFF]
                    little = [0xFF, 0xFE, 0x00, 0x00]
            }
            
            return switchEndian(big,little)
        }
        
        if let rawValue: [UInt8] = switchUTF() {
            toData.writeUInt8Array(value: rawValue)
        }
    }
}
