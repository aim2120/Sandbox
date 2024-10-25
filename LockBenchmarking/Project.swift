import ProjectDescription

let project = Project(
    name: "LockBenchmarking",
    targets: [
        .target(
            name: "LockBenchmarking",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.LockBenchmarking",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["LockBenchmarking/Sources/**"],
            resources: ["LockBenchmarking/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "LockBenchmarkingTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.LockBenchmarkingTests",
            infoPlist: .default,
            sources: ["LockBenchmarking/Tests/**"],
            resources: [],
            dependencies: [.target(name: "LockBenchmarking")]
        ),
    ]
)
