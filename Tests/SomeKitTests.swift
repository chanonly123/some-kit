import XCTest
@testable import SomeKit

struct User: Codable, Equatable {
    var _id: String
    var userName: String
}

extension SomeDefaultsKey {
    static var user: SomeDefaultsKey<User> { SomeDefaultsKey<User>("user", defaultVal: nil) }
    static var array: SomeDefaultsKey<[Int]> { SomeDefaultsKey<[Int]>("array", defaultVal: nil) }
    static var value: SomeDefaultsKey<Int> { SomeDefaultsKey<Int>("value", defaultVal: nil) }
}

final class MyLibraryTests: XCTestCase {
    let defaults = SomeDefaults()
    
    func testSomeDefaults() throws {
        let user = User(_id: "abc", userName: "xyz")
        defaults[.user] = user
        XCTAssert(defaults[.user] == user, "User shoud be same")
        
        defaults[.value] = 10
        XCTAssert(defaults[.value] == 10, "value shoud be same")
        
        defaults[.array] = [1,2,3,4,5]
        XCTAssert(defaults[.array] == [1,2,3,4,5], "array shoud be same")
    }
}
