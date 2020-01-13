import XCTest
import BinaryParser

class BinaryParserTest: XCTestCase {
    func testReadAndWrite() {
        class TemplateStruct: ParseStruct {
            static func compare(lhs: TemplateStruct, rhs: TemplateStruct) -> Bool {
                return
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
        
        let myIndexedData = IndexedData(data: Data())
        let baseClass = TemplateStruct()
        baseClass.magic = ParseStaticStringUTF8("TEST", size: 4)
        baseClass.header = ParseInt<UInt8>(10)
        baseClass.age = ParseInt<UInt8>(20)
        baseClass.height = ParseFloat<Float32>(5.9)
        baseClass.writeBinary(toData: myIndexedData)
        
        let writeClass = TemplateStruct()
        myIndexedData.index = 0
        writeClass.readBinary(fromData: myIndexedData)
        
        XCTAssert(TemplateStruct.compare(lhs: baseClass, rhs: writeClass), "The classes do not match")
    }
}

/*
 var identifier: String = "NOPE"
 var header: UInt8 = 50
 var age: UInt8 = 50
 var height: Float32 = 100
 
 myBaseStruct.identifier = "TEST"
 myBaseStruct.header = 10
 myBaseStruct.age = 20
 myBaseStruct.height = 5.9
 */
