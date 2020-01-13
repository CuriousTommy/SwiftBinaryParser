import XCTest
import BinaryParser

class IndexedDataTest: XCTestCase {
    func testReadAndWrite() {
        struct TestStruct: Equatable {
            var identifier: String = "NOPE"
            var header: UInt8 = 50
            var age: UInt8 = 50
            var height: Float32 = 100
            
            static func ==(lhs: TestStruct, rhs: TestStruct) -> Bool {
                lhs.identifier == rhs.identifier &&
                    lhs.header == rhs.header &&
                    lhs.age == rhs.age &&
                    lhs.height == rhs.height
            }
        }
        
        var myBaseStruct = TestStruct()
        myBaseStruct.identifier = "TEST"
        myBaseStruct.header = 10
        myBaseStruct.age = 20
        myBaseStruct.height = 5.9
        
        let myIndexedData = IndexedData(data: Data())
        myIndexedData.writeString(value: myBaseStruct.identifier, count: 4)
        myIndexedData.write(value: myBaseStruct.header)
        myIndexedData.write(value: myBaseStruct.age)
        myIndexedData.write(value: myBaseStruct.height)
        
        myIndexedData.index = 0
        var myReadStruct = TestStruct()
        myIndexedData.readString(value: &myReadStruct.identifier, count: 4)
        myIndexedData.read(value: &myReadStruct.header)
        myIndexedData.read(value: &myReadStruct.age)
        myIndexedData.read(value: &myReadStruct.height)
        
        XCTAssertTrue(myBaseStruct == myReadStruct, "Structs are not equal")
    }
}
