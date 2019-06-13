import XCTest
@testable import LegoKit

final class LegoKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LegoKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
