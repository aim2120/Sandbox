import XCTest
@testable import Sandbox

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
final class SandboxTests: XCTestCase {
    func testExample() async throws {
        var test = false

        await Outer().run {
            test = true
        }

        XCTAssertTrue(test)
    }
}
