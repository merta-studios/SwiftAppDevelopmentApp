// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "AppBuilder",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "AppBuilder",
            targets: ["AppBuilder"],
            bundleIdentifier: "com.arena.appbuilder",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .magicWand),
            accentColor: .presetColor(.purple),
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
            name: "AppBuilder",
            path: "Sources/AppBuilder"
        )
    ]
)
