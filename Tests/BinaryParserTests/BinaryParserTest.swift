import XCTest
import BinaryParser

class BinaryParserTest: XCTestCase {
    func testReadAndWrite() {
        let myIndexedData = IndexedData(data: Data())
        let baseClass = TestReadWriteStruct()
        baseClass.magic = ParseStaticStringUTF8("TEST", size: 4)
        baseClass.header = ParseInt<UInt8>(10)
        baseClass.age = ParseInt<UInt8>(20)
        baseClass.height = ParseFloat<Float32>(5.9)
        baseClass.writeBinary(toData: myIndexedData)
        
        let writeClass = TestReadWriteStruct()
        myIndexedData.index = 0
        writeClass.readBinary(fromData: myIndexedData)
        
        XCTAssert(baseClass == writeClass, "The classes do not match")
    }
    
    func testCompareParserWithRawValue() {
        let array: [UInt8] = [
            0x54, 0x45, 0x53, 0x54,
            10,
            20,
            0xCD, 0xCC, 0xBC, 0x40
        ]
        
        
        let myIndexedData = IndexedData(data: Data())
        let baseClass = TestReadWriteStruct()
        baseClass.magic = ParseStaticStringUTF8("TEST", size: 4)
        baseClass.header = ParseInt<UInt8>(10)
        baseClass.age = ParseInt<UInt8>(20)
        baseClass.height = ParseFloat<Float32>(5.9)
        baseClass.writeBinary(toData: myIndexedData)
        
        XCTAssert(Data(array) == myIndexedData.data, "The data does not match the raw value")
    }
    
    func testArray() {
        let indexedData = IndexedData(data: Data())
        var inputArrayTest: [TestArrayNode] = []
        let inputHeader: TestArrayHeader = TestArrayHeader()
        
        do {
            let studentData = [
                (57.5, 12),
                (99.8, 36),
                (21.8, 2),
                (87.6, 20)
            ]
            
            for (rating, age) in studentData {
                    let newNode = TestArrayNode()
                    newNode.rating.value = Float32(rating)
                    newNode.age.value = UInt8(age)
                    inputArrayTest.append(newNode)
            }
            
            inputHeader.count.value = UInt32(inputArrayTest.count)
            
            inputHeader.writeBinary(toData: indexedData)
            setNodeFromArray(indexedData, array: inputArrayTest)
        }
        
        var outputArrayTest: [TestArrayNode] = []
        let outputHeader: TestArrayHeader = TestArrayHeader()
        indexedData.index = 0
        do {
            outputHeader.readBinary(fromData: indexedData)
            outputArrayTest = getArrayFromNode(indexedData, count: Int(inputHeader.count.value)) {
                TestArrayNode()
            }
            
            print(outputArrayTest)
        }
        
        
        XCTAssert(inputHeader.count.value == outputArrayTest.count, "The array size is not \(inputHeader.count.value)")
        XCTAssert(inputArrayTest == outputArrayTest, "Arrays are not equal")
    }
}


class TestArrayHeader: ParseClass {
    var count = ParseInt<UInt32>()
}

class TestArrayNode: ParseClass {
    var rating = ParseFloat<Float32>()
    var age = ParseInt<UInt8>()
}

extension TestArrayNode: Equatable {
    static func == (lhs: TestArrayNode, rhs: TestArrayNode) -> Bool {
        lhs.rating.value == rhs.rating.value &&
        lhs.age.value == rhs.age.value
    }
}

class TestReadWriteStruct: ParseClass, Equatable {
    static func == (lhs: TestReadWriteStruct, rhs: TestReadWriteStruct) -> Bool {
        (lhs.magic.value == rhs.magic.value) &&
        (lhs.header.value == rhs.header.value) &&
        (lhs.age.value == rhs.age.value) &&
        (lhs.height.value == rhs.height.value)
    }
                
    var magic = ParseStaticStringUTF8(size: 4)
    var header = ParseInt<UInt8>()
    var age = ParseInt<UInt8>()
    var height = ParseFloat<Float32>()
}
