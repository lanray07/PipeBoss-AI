import AppKit
import Foundation

enum ScreenshotError: Error {
    case invalid(String)
}

func validate(_ url: URL) throws {
    guard let bitmap = NSBitmapImageRep(data: try Data(contentsOf: url)),
          bitmap.pixelsWide > 500, bitmap.pixelsHigh > 500 else {
        throw ScreenshotError.invalid("Unreadable screenshot: \(url.path)")
    }
    var samples = 0
    var light = 0
    var dark = 0
    // Exclude the system status bar and screen edges, which can disguise an empty view.
    for y in stride(from: bitmap.pixelsHigh / 8, to: bitmap.pixelsHigh * 9 / 10, by: 12) {
        for x in stride(from: bitmap.pixelsWide / 10, to: bitmap.pixelsWide * 9 / 10, by: 12) {
            guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.sRGB) else { continue }
            let brightness = (color.redComponent + color.greenComponent + color.blueComponent) / 3
            samples += 1
            if brightness > 0.75 { light += 1 }
            if brightness < 0.35 { dark += 1 }
        }
    }
    guard samples > 0, Double(light) / Double(samples) > 0.10,
          Double(dark) / Double(samples) > 0.002 else {
        throw ScreenshotError.invalid("Blank or unrendered app screen: \(url.path)")
    }
    print("Rendered screen verified: \(url.deletingLastPathComponent().lastPathComponent)/\(url.lastPathComponent)")
}

do {
    guard CommandLine.arguments.count == 2 else { throw ScreenshotError.invalid("Pass the screenshot directory") }
    let root = URL(fileURLWithPath: CommandLine.arguments[1])
    guard let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else {
        throw ScreenshotError.invalid("Screenshot directory missing")
    }
    let screenshots = files.compactMap { $0 as? URL }.filter { $0.pathExtension == "png" }
    guard screenshots.count == 12 else { throw ScreenshotError.invalid("Expected 12 screenshots, found \(screenshots.count)") }
    for url in screenshots { try validate(url) }
} catch {
    fputs("Screenshot validation failed: \(error)\n", stderr)
    exit(1)
}
