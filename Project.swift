import ProjectDescription

let project = Project(
    name: "Clue",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .singleScheme,
            codeCoverageEnabled: false,
            testingOptions: []
        ),
        developmentRegion: "ko"
    ),
    settings: .settings(
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        .target(
            name: "Clue",
            destinations: .iOS,
            product: .app,
            bundleId: "com.krwd.Clue",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "com.krwd.Clue",
                            "CFBundleURLSchemes": [
                                "clue"
                            ]
                        ]
                    ]
                ]
            ),
            sources: ["Clue/Sources/**"],
            resources: ["Clue/Resources/**"],
            dependencies: [
                .external(name: "Supabase")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "$(DEVELOPMENT_TEAM)",
                    "CODE_SIGN_STYLE": "Automatic",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.krwd.Clue"
                ],
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "CODE_SIGN_IDENTITY": "iPhone Developer"
                        ]
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "CODE_SIGN_IDENTITY": "iPhone Distribution"
                        ]
                    )
                ]
            )
        ),
        .target(
            name: "ClueTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.krwd.ClueTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Clue/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Clue")]
        ),
    ]
)
