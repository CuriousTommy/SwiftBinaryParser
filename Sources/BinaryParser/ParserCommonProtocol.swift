// Copyright (c) 2020 CuriousTommy (Thomas A)
//
// This source code is licensed under MIT, refer to
// License.txt

import Foundation

public protocol ParseIdentifier {
    var identifier: String { get set }
}

public protocol ParseProtocol {
    func readData(fromFile: IndexedData)
    func writeData(toFile: IndexedData)
}

public protocol ParseSize {
    var size: Int { get }
}

public protocol ParserCommon: ParseIdentifier, ParseProtocol, ParseSize {
}
