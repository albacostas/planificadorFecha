import SwiftUI
import CoreGraphics

struct ColorOptions: Codable {
    static var all: [Color] = [
        .primary,
        .gray,
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .cyan,
        .indigo,
        .purple,
    ]
    
    static var `default` : Color = Color.primary
    
    static func random() -> Color {
        if let element = ColorOptions.all.randomElement() {
            return element
        } else {
            return .primary
        }
        
    }
}

struct RGBAColor: Codable, Hashable {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
}
// Cross-platform helpers: use `UIColor` on platforms that provide UIKit, `NSColor` on macOS.
#if canImport(UIKit)
import UIKit

extension Color {
    var r: CGFloat { UIColor(self).colorComponents.red }
    var g: CGFloat { UIColor(self).colorComponents.green }
    var b: CGFloat { UIColor(self).colorComponents.blue }
    var a: CGFloat { UIColor(self).colorComponents.alpha }

    var rgbaColor: RGBAColor {
        RGBAColor(r: self.r, g: self.g, b: self.b, a: self.a)
    }

    init(_ rgbaColor: RGBAColor) {
        self.init(red: rgbaColor.r, green: rgbaColor.g, blue: rgbaColor.b, opacity: rgbaColor.a)
    }
}

extension UIColor {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        // UIColor.getRed(_:green:blue:alpha:) works for RGB-based colors
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
#elseif canImport(AppKit)
import AppKit

extension Color {
    var r: CGFloat { NSColor(self).colorComponents.red }
    var g: CGFloat { NSColor(self).colorComponents.green }
    var b: CGFloat { NSColor(self).colorComponents.blue }
    var a: CGFloat { NSColor(self).colorComponents.alpha }

    var rgbaColor: RGBAColor {
        RGBAColor(r: self.r, g: self.g, b: self.b, a: self.a)
    }

    init(_ rgbaColor: RGBAColor) {
        self.init(red: rgbaColor.r, green: rgbaColor.g, blue: rgbaColor.b, opacity: rgbaColor.a)
    }
}

extension NSColor {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        // Ensure we are in an RGB color space before extracting components
        let rgb = usingColorSpace(.deviceRGB) ?? usingColorSpace(.sRGB) ?? self
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        rgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
#else
// Fallback implementations for other platforms — return zeros so code compiles.
extension Color {
    var r: CGFloat { 0 }
    var g: CGFloat { 0 }
    var b: CGFloat { 0 }
    var a: CGFloat { 1 }

    var rgbaColor: RGBAColor { RGBAColor(r: 0, g: 0, b: 0, a: 1) }

    init(_ rgbaColor: RGBAColor) {
        self.init(red: rgbaColor.r, green: rgbaColor.g, blue: rgbaColor.b, opacity: rgbaColor.a)
    }
}
#endif

