// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

// Set it to true to use local binary (for development)
let useLocalBinary = false

// URL and checksum of prebuilt rust Core
let binaryUrl = "https://github.com/tesseract-one/Tesseract.swift/releases/download/0.5.4/Tesseract-Core.bin.zip"
let binaryChecksum = "b410c809f3aab8adbc6e95f1610db15bced11988b65dc5e093ab42a312129987"

// Package description
let package = Package(
    name: "Tesseract",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "TesseractClient",
            targets: ["TesseractClient"]),
        .library(
            name: "TesseractService",
            targets: ["TesseractService"]),
        .library(
            name: "TesseractShared",
            targets: ["TesseractShared"]),
        .library(
            name: "TesseractTransportsClient",
            targets: ["TesseractTransportsClient"]),
        .library(
            name: "TesseractTransportsService",
            targets: ["TesseractTransportsService"]),
        .library(
            name: "TesseractTransportsShared",
            targets: ["TesseractTransportsShared"]),
        .library(
            name: "TesseractUtils",
            targets: ["TesseractUtils"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TesseractClient",
            dependencies: ["TesseractTransportsClient", "TesseractShared"]),
        .target(
            name: "TesseractService",
            dependencies: ["TesseractTransportsService", "TesseractShared"]),
        .target(
            name: "TesseractShared",
            dependencies: ["TesseractTransportsShared", "CTesseract"]),
        .target(
            name: "TesseractTransportsClient",
            dependencies: ["TesseractTransportsShared"]),
        .target(
            name: "TesseractTransportsService",
            dependencies: ["TesseractTransportsShared"]),
        .target(
            name: "TesseractTransportsShared",
            dependencies: ["TesseractUtils"]),
        .target(
            name: "TesseractUtils",
            dependencies: ["CTesseractShared"]),
        // Header only target. Headers generated by Rust/generate_headers.sh
        .target(name: "CTesseractShared", dependencies: []),
        // Binary target
        useLocalBinary
            ? .binaryTarget(name: "CTesseract", path: "CTesseract.xcframework")
            : .binaryTarget(name: "CTesseract", url: binaryUrl, checksum: binaryChecksum)
    ]
)
