import PackageDescription

let package = Package(
    name: "Annecy",
    dependencies: [
        .Package(url: "https://github.com/swiftx/c7.git", majorVersion: 0, minor: 1)
    ]
)
