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
            bundleId: "com.krwd.clue",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIAppFonts": [
                        "NotoSansKR-Thin.ttf",
                        "NotoSansKR-ExtraLight.ttf",
                        "NotoSansKR-Light.ttf",
                        "NotoSansKR-Regular.ttf",
                        "NotoSansKR-Medium.ttf",
                        "NotoSansKR-SemiBold.ttf",
                        "NotoSansKR-Bold.ttf",
                        "NotoSansKR-ExtraBold.ttf",
                        "NotoSansKR-Black.ttf"
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "com.krwd.clue",
                            "CFBundleURLSchemes": [
                                "clue"
                            ]
                        ],
                        [
                            "CFBundleURLName": "com.krwd.clue.web",
                            "CFBundleURLSchemes": [
                                "com.krwd.clue.web"
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
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.krwd.clue"
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
            bundleId: "com.krwd.clueTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Clue/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Clue")]
        ),
    ]
)
