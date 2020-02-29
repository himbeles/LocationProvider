import XCTest
@testable import LocationProvider

final class LocationProviderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LocationProvider().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
