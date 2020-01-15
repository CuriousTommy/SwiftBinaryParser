// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt

import Foundation

public class ParseInt<T: BinaryInteger>: ParserGeneric<T> {
    public convenience init() {
        self.init(0)
    }
}

public class ParseFloat<T: BinaryFloatingPoint>: ParserGeneric<T> {
    public convenience init() {
        self.init(0.0)
    }
}

public class ParseStaticStringUTF8: ParserGeneric<String> {
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
