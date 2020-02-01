// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt

import Foundation

public protocol ParseProtocol {
    func readBinary(fromData: IndexedData)
    func writeBinary(toData: IndexedData)
}

public protocol ParseSize {
    var size: Int { get }
}

public protocol ParseValue {
    associatedtype Value
    var value: Value { get }
}

public protocol ParserCommonProtocol: ParseProtocol, ParseSize {
}

public protocol ParserGenericProtocol: ParserCommonProtocol, ParseValue {
}
