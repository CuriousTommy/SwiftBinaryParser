# BinaryReader

A WIP Binary Extractor for swift.

## How To Use

You create the class that represents the structure of the data you want to parse. Make sure you inherit from ParseClass
```
class TemplateStruct: ParseClass {
    var magic = ParseStaticStringUTF8(size: 4)
    var header = ParseInt<UInt8>()
    var age = ParseInt<UInt8>()
    var height = ParseFloat<Float32>()
}
```

How to read/write data.
```
// The data object will be put in the helper object,
// IndexedData, will keeps track of the current index.
let myIndexedData = IndexedData(data: <Insert Data Object>)
let baseClass = TemplateStruct()

// If you want to write to the data object
baseClass.writeBinary(toData: myIndexedData)

// If you want to read from the data object
 writeClass.readBinary(fromData: myIndexedData)
```

You can change the current index by using the `index` property.
```
myIndexedData.index = 32
```

How to generate an array from a contiguous group of nodes
```
class Node: ParseClass {
    var rating = ParseFloat<Float32>()
    var age = ParseInt<UInt8>()
}

var nodes: [Node] = []
var count: UInt8 = 8

// Generate an array from a group of node
nodes = getArrayFromNode(indexedData, count: Int(count)) {
    // Closure that initalizes the element
    Node()
}

// Save the array as a group of nodes
setNodeFromArray(indexedData, array: nodes)
```

## How does it work

It takes advantage of Apple's [Mirror class](https://developer.apple.com/documentation/swift/mirror). It iterates through all of the properties in the class. `readBinary` or `writeBinary` will be called if the item conforms to the `ParserCommon` protocol.

## Future Plans

* Big Endian Support
* More helper classes
* Safety Checking
