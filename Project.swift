import ProjectDescription

let project = Project(
    name: "Clue",
    targets: [
        .target(
            name: "Clue",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Clue",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Clue/Sources/**"],
            resources: ["Clue/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "ClueTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ClueTests",
            infoPlist: .default,
            sources: ["Clue/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Clue")]
        ),
    ]
)
