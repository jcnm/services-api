// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "APIServices",
  products: [
    .library(name: "APIServices", targets: ["APIServices"]),
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(name:"Vapor", url: "https://github.com/vapor/vapor.git", from: "3.3.1"),
    .package(name: "Paginator", url: "https://github.com/nodes-vapor/paginator.git", from: "3.0.0-rc"),
    // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
    .package(name: "FluentPostgreSQL", url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
    .package(name: "Multipart", url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
    // Authentication
    .package(name: "Auth", url: "https://github.com/vapor/auth.git", from: "2.0.4"),
    // Html parser
    .package(name: "Fuzi", url: "https://github.com/cezheng/Fuzi", from: "3.1.2"),
    .package(name: "SwiftSoup", url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2")
  ],
  targets: [
    .target(
	name: "APIServices",
	dependencies: [.product(name: "Authentication", package: "Auth"), "Multipart", "FluentPostgreSQL", "Paginator", "Fuzi", "SwiftSoup", "Vapor"]
	),
    .testTarget(name: "APIServicesTests", dependencies: ["APIServices"])
  ]
)
