import ProjectDescription

let project = Project(
    name: "Clue",
    targets: [
        .target(
            name: "Clue",
            destinations: .iOS,
            product: .app,
            bundleId: "com.krwd.Clue",
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
            dependencies: [
                .external(name: "Supabase")
            ]
        ),
        .target(
            name: "ClueTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.krwd.ClueTests",
            infoPlist: .default,
            sources: ["Clue/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Clue")]
        ),
    ]
)
