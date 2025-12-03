import Foundation

public struct XfColor: Equatable, Hashable {
    private enum Mode { case `default`, rgb, hsl }

    private let _mode: Mode
    private let _a: Double
    private let _r: Double
    private let _g: Double
    private let _b: Double
    private let _hue: Double
    private let _saturation: Double
    private let _luminosity: Double

    public var IsDefault: Bool { _mode == .default }
    public var A: Double { _a }
    public var R: Double { _r }
    public var G: Double { _g }
    public var B: Double { _b }
    public var Hue: Double { _hue }
    public var Saturation: Double { _saturation }
    public var Luminosity: Double { _luminosity }

    public init() {
        _mode = .default
        _a = -1
        _r = -1
        _g = -1
        _b = -1
        _hue = -1
        _saturation = -1
        _luminosity = -1
    }

    public init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        func clamp(_ v: Double, minValue: Double = 0.0, maxValue: Double = 1.0) -> Double { Swift.max(minValue, Swift.min(maxValue, v)) }
        _mode = .rgb
        _r = clamp(r)
        _g = clamp(g)
        _b = clamp(b)
        _a = clamp(a)
        let hsl = XfColor.rgbToHsl(r: _r, g: _g, b: _b)
        _hue = hsl.h
        _saturation = hsl.s
        _luminosity = hsl.l
    }

    public init(value: Double) {
        self.init(r: value, g: value, b: value, a: 1.0)
    }

    public func MultiplyAlpha(_ alpha: Double) -> XfColor {
        switch _mode {
        case .default: fatalError("Invalid on Color.Default")
        case .rgb: return XfColor(r: _r, g: _g, b: _b, a: _a * alpha)
        case .hsl: return XfColor(h: _hue, s: _saturation, l: _luminosity, a: _a * alpha)
        }
    }

    public func AddLuminosity(_ delta: Double) -> XfColor {
        guard _mode != .default else { fatalError("Invalid on Color.Default") }
        return XfColor(h: _hue, s: _saturation, l: _luminosity + delta, a: _a)
    }

    public func WithHue(_ hue: Double) -> XfColor {
        guard _mode != .default else { fatalError("Invalid on Color.Default") }
        return XfColor(h: hue, s: _saturation, l: _luminosity, a: _a)
    }

    public func WithSaturation(_ saturation: Double) -> XfColor {
        guard _mode != .default else { fatalError("Invalid on Color.Default") }
        return XfColor(h: _hue, s: saturation, l: _luminosity, a: _a)
    }

    public func WithLuminosity(_ luminosity: Double) -> XfColor {
        guard _mode != .default else { fatalError("Invalid on Color.Default") }
        return XfColor(h: _hue, s: _saturation, l: luminosity, a: _a)
    }

    // HSL-based initializer
    private init(h: Double, s: Double, l: Double, a: Double) {
        func clamp(_ v: Double, minValue: Double = 0.0, maxValue: Double = 1.0) -> Double { Swift.max(minValue, Swift.min(maxValue, v)) }
        _mode = .hsl
        _hue = clamp(h)
        _saturation = clamp(s)
        _luminosity = clamp(l)
        _a = clamp(a)
        let rgb = XfColor.hslToRgb(h: _hue, s: _saturation, l: _luminosity)
        _r = rgb.r
        _g = rgb.g
        _b = rgb.b
    }

    // Helpers
    private static func rgbToHsl(r: Double, g: Double, b: Double) -> (h: Double, s: Double, l: Double) {
        let maxV = max(r, max(g, b))
        let minV = min(r, min(g, b))
        let l = (maxV + minV) / 2.0
        var h: Double = 0.0
        var s: Double = 0.0
        if maxV != minV {
            let d = maxV - minV
            s = l > 0.5 ? d / (2.0 - maxV - minV) : d / (maxV + minV)
            if maxV == r { h = (g - b) / d + (g < b ? 6.0 : 0.0) }
            else if maxV == g { h = (b - r) / d + 2.0 }
            else { h = (r - g) / d + 4.0 }
            h /= 6.0
        }
        return (h: h, s: s, l: l)
    }

    private static func hslToRgb(h: Double, s: Double, l: Double) -> (r: Double, g: Double, b: Double) {
        if s == 0 { return (r: l, g: l, b: l) }
        func hue2rgb(p: Double, q: Double, t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        let r = hue2rgb(p: p, q: q, t: h + 1.0/3.0)
        let g = hue2rgb(p: p, q: q, t: h)
        let b = hue2rgb(p: p, q: q, t: h - 1.0/3.0)
        return (r: r, g: g, b: b)
    }

    // ToHex
    public func ToHex() -> String {
        if _mode == .default { return "#000000" }
        let ri = Int(round(_r * 255))
        let gi = Int(round(_g * 255))
        let bi = Int(round(_b * 255))
        let ai = Int(round(_a * 255))
        if ai < 255 { return String(format: "#%02X%02X%02X%02X", ai, ri, gi, bi) }
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }

    public static func ==(lhs: XfColor, rhs: XfColor) -> Bool {
        if lhs._mode == .default && rhs._mode == .default { return true }
        if lhs._mode == .default || rhs._mode == .default { return false }
        if lhs._mode == .hsl && rhs._mode == .hsl {
            return lhs._hue == rhs._hue && lhs._saturation == rhs._saturation && lhs._luminosity == rhs._luminosity && lhs._a == rhs._a
        }
        return lhs._r == rhs._r && lhs._g == rhs._g && lhs._b == rhs._b && lhs._a == rhs._a
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_r)
        hasher.combine(_g)
        hasher.combine(_b)
        hasher.combine(_a)
    }
}
