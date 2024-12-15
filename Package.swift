// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VideoTrimmingSliderBar",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "VideoTrimmingSliderBar",
            targets: ["VideoTrimmingSliderBar"]
        )
    ],
    targets: [
      .target(name: "VideoTrimmingSliderBar"),
    ],
    swiftLanguageVersions: [.v5]
)
