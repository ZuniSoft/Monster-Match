// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Monster Match Puzzle",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Monster Match Puzzle",
            targets: ["AppModule"],
            bundleIdentifier: "com.zunisoft.ios.monstermatchpuzzle",
            teamIdentifier: "S63L4926ND",
            displayVersion: "1.0",
            bundleVersion: "4",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
