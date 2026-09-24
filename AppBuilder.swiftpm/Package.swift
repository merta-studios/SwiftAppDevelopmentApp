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
            targets: ["AppModule"],
            bundleIdentifier: "com.arena.appbuilder",
            teamIdentifier: "",
            displayVersion: "2.0",
            bundleVersion: "2",
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
            ],
            capabilities: []
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
