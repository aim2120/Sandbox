// The Swift Programming Language
// https://docs.swift.org/swift-book

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public class Outer {
    public func run(operation: () async -> Void) async {
        await withMainSerialExecutor {
            await operation()
        }
    }
}
