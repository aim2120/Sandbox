//
//  Benchmarking.swift
//  LockBenchmarking
//
//  Created by Annalise Mariottini on 10/25/24.
//

import Foundation

final class Benchmarking {
    private let iterations = 100_000
    private let numberOfAttempts = 1000

    func benchmark() async -> [String] {
        let locked = Locked<Int>(0)
        let isolated = Isolated<Int>(0)

        let isolatedResults = await benchmarkAsync(name: "Isolated", getter: { await isolated.value }, setter: { await isolated.set($0) })
        let lockedResults = benchmark(name: "Locked", getter: { locked.value }, setter: { locked.value = $0 })

        return isolatedResults + lockedResults
    }

    private func benchmark(name: String, getter: @escaping () -> Int, setter: @escaping (Int) -> Void) -> [String] {
        let setBenchmark = averageBenchmark(iterations: iterations, numberOfAttempts: numberOfAttempts) { _ in
            setter(Int.random(in: 0...10))
        }
        let getBenchmark = averageBenchmark(iterations: iterations, numberOfAttempts: numberOfAttempts) { _ in
            self.noop(getter())
        }

        return [
            "\(name) set: \(setBenchmark)",
            "\(name) get: \(getBenchmark)",
        ]
    }

    private func benchmarkAsync(name: String, getter: @escaping () async -> Int, setter: @escaping (Int) async -> Void) async -> [String] {
        let setBenchmark = await averageBenchmark(iterations: iterations, numberOfAttempts: numberOfAttempts) { _ in
            await setter(Int.random(in: 0...10))
        }
        let getBenchmark = await averageBenchmark(iterations: iterations, numberOfAttempts: numberOfAttempts) { _ in
            await self.noop(getter())
        }

        return [
            "\(name) set: \(setBenchmark)",
            "\(name) get: \(getBenchmark)",
        ]
    }

    private func noop<T>(_: T) {}

    private func benchmark(block: () -> Void) -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        return totalTime
    }

    private func benchmark(block: () async -> Void) async -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        await block()
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        return totalTime
    }

    private func averageBenchmark(iterations: Int, numberOfAttempts: Int, block: (Int) -> Void) -> TimeInterval {
        var accumulatedResult: TimeInterval = 0

        for _ in 0..<numberOfAttempts {
            let result = benchmark {
                for i in 0..<iterations {
                    block(i)
                }
            }
            accumulatedResult += result
        }

        return accumulatedResult / TimeInterval(numberOfAttempts)
    }

    private func averageBenchmark(iterations: Int, numberOfAttempts: Int, block: (Int) async -> Void) async -> TimeInterval {
        var accumulatedResult: TimeInterval = 0

        for _ in 0..<numberOfAttempts {
            let result = await benchmark {
                for i in 0..<iterations {
                    await block(i)
                }
            }
            accumulatedResult += result
        }

        return accumulatedResult / TimeInterval(numberOfAttempts)
    }
}

final class Locked<Value>: @unchecked Sendable {
    init(_ _value: Value) {
        self._value = _value
    }

    deinit {
        lock.destruct()
    }

    var value: Value {
        get {
            lock.withLock {
                _value
            }
        }
        set {
            lock.withLock {
                _value = newValue
            }
        }
    }

    private var _value: Value
    private let lock: UnsafeLock = .createLock()

    private struct UnsafeLock {
        let inner: UnsafeMutablePointer<os_unfair_lock>

        static func createLock() -> Self {
            let lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
            lock.initialize(to: .init())
            return .init(inner: lock)
        }

        func destruct() {
            inner.deinitialize(count: 1)
            inner.deallocate()
        }

        func withLock<T>(_ action: () throws -> T) rethrows -> T {
            os_unfair_lock_lock(inner)
            defer { os_unfair_lock_unlock(inner) }
            return try action()
        }
    }
}

final actor Isolated<Value> {
    init(_ value: Value) {
        self.value = value
    }

    var value: Value
    func set(_ value: Value) {
        self.value = value
    }
}
