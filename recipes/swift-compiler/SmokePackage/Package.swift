// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "SmokePackage",
  targets: [
    .target(name: "CHelper"),
    .executableTarget(name: "SmokePackage", dependencies: ["CHelper"]),
  ]
)
