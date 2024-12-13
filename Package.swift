// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VideoTrimmingSliderBar",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "VideoTrimmingSliderBar",
            targets: ["VideoTrimmingSliderBar"]
        )
    ],
    dependencies: [
      .package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit.git", .exactItem("5.0.1"))
    ],
    targets: [
      .target(
        name: "VideoTrimmingSliderBar",
        dependencies: [
          .byName(name: "SnapKit")
        ]
      ),
    ]
)
