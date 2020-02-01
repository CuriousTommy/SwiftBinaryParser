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

public class ParseByteOrder: ParserMutableGeneric<ParseByteOrder.UTF> {
    override public var size: Int {
        switch value {
            case .UTF16(_):
                return 2
            case .UTF32(_):
                return 4
        }
    }
    
    public enum UTF: Equatable {
        public static func ==(lhs: UTF, rhs: UTF) -> Bool {
            switch lhs {
                case .UTF16(let left):
                    switch rhs {
                        case .UTF16(let right):
                            return left == right
                        default:
                            return false
                    }
                
                case .UTF32(let left):
                    switch rhs {
                        case .UTF32(let right):
                            return left == right
                        default:
                            return false
                    }
                
            }
        }
        
        public enum Endian {
            case big
            case little
        }
        
        case UTF16(Endian?)
        case UTF32(Endian?)
    }
    
    
    override public init(_ value: ParseByteOrder.UTF) {
        super.init(value)
    }
    
    
    override public func readBinary(fromData: IndexedData) {
        let switchEndian: ([UInt8], [UInt8], [UInt8]) -> UTF.Endian? = {current,big,little in
            if current == big {
                return .big
            } else if current == little {
                return .little
            } else {
                return .none
            }
        }
        
        let switchUTF: (UTF,[UInt8]) -> UTF = { utf,current in
            switch utf {
                case .UTF16(_):
                    return .UTF16(switchEndian(
                        current,
                        [0xFE, 0xFF],
                        [0xFF, 0xFE]
                    ))
                case .UTF32(_):
                    return .UTF32(switchEndian(
                        current,
                        [0x00, 0x00, 0xFE, 0xFF],
                        [0xFF, 0xFE, 0x00, 0x00]
                    ))
            }
        }

        var test: [UInt8] = Array(repeating: 0, count: size)
        fromData.readUInt8Array(value: &test)
        self.value = switchUTF(value, test)
    }
    
    
    override public func writeBinary(toData: IndexedData) {
        let switchEndian: (UTF.Endian?, [UInt8], [UInt8]) -> [UInt8]? = {endian,big,little in
            switch endian {
            case .big:
                return big
            case .little:
                return little
            case .none:
                return nil
            }
        }
        
        let switchUTF: (UTF) -> [UInt8]? = {utf in
            switch utf {
                case .UTF16(let endian):
                    return switchEndian(
                        endian,
                        [0xFE, 0xFF],
                        [0xFF, 0xFE]
                    )
                case .UTF32(let endian):
                    return switchEndian(
                        endian,
                        [0x00, 0x00, 0xFE, 0xFF],
                        [0xFF, 0xFE, 0x00, 0x00]
                    )
            }
        }
        
        if let rawValue: [UInt8] = switchUTF(self.value) {
            toData.writeUInt8Array(value: rawValue)
        }
    }
}
