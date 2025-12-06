import Foundation

final class XfColor: Equatable, Hashable, CustomStringConvertible {

    // MARK: - Mode

    private enum Mode {
        case Default
        case Rgb
        case Hsl
    }

    private let _mode: Mode

    var IsDefault: Bool {
        return _mode == .Default
    }

    private let _a: Float
    var A: Double { Double(_a) }

    private let _r: Float
    var R: Double { Double(_r) }

    private let _g: Float
    var G: Double { Double(_g) }

    private let _b: Float
    var B: Double { Double(_b) }

    private let _hue: Float
    var Hue: Double { Double(_hue) }

    private let _saturation: Float
    var Saturation: Double { Double(_saturation) }

    private let _luminosity: Float
    var Luminosity: Double { Double(_luminosity) }

    // MARK: - Designated initializer (private like Kotlin's w,x,y,z one)

    private init(_ w: Double, _ x: Double, _ y: Double, _ z: Double, _ mode: Mode) {
        _mode = mode

        switch mode {
        case .Default:
            _r = -1
            _g = -1
            _b = -1
            _a = -1
            _hue = -1
            _saturation = -1
            _luminosity = -1

        case .Rgb:
            _r = Float(XfColor.Clamp(w, 0.0, 1.0))
            _g = Float(XfColor.Clamp(x, 0.0, 1.0))
            _b = Float(XfColor.Clamp(y, 0.0, 1.0))
            _a = Float(XfColor.Clamp(z, 0.0, 1.0))

            let hslResult = XfColor.ConvertToHsl(_r, _g, _b, mode: mode)
            _hue = hslResult.h
            _saturation = hslResult.s
            _luminosity = hslResult.l

        case .Hsl:
            _hue = Float(XfColor.Clamp(w, 0.0, 1.0))
            _saturation = Float(XfColor.Clamp(x, 0.0, 1.0))
            _luminosity = Float(XfColor.Clamp(y, 0.0, 1.0))
            _a = Float(XfColor.Clamp(z, 0.0, 1.0))

            let rgbResult = XfColor.ConvertToRgb(_hue, _saturation, _luminosity, mode: mode)
            _r = rgbResult.r
            _g = rgbResult.g
            _b = rgbResult.b
        }
    }

    // Kotlin: constructor(r: Double, g: Double, b: Double, a: Double) : this(r, g, b, a, Mode.Rgb)
    convenience init(_ r: Double, _ g: Double, _ b: Double, _ a: Double) {
        self.init(r, g, b, a, .Rgb)
    }

    // Kotlin: private constructor(r: Int, g: Int, b: Int)
    private convenience init(r: Int, g: Int, b: Int) {
        self.init(
            Double(r) / 255.0,
            Double(g) / 255.0,
            Double(b) / 255.0,
            1.0,
            .Rgb
        )
    }

    // Kotlin: private constructor(r: Int, g: Int, b: Int, a: Int)
    private convenience init(r: Int, g: Int, b: Int, a: Int) {
        self.init(
            Double(r) / 255.0,
            Double(g) / 255.0,
            Double(b) / 255.0,
            Double(a) / 255.0,
            .Rgb
        )
    }

    // Kotlin: constructor(r: Double, g: Double, b: Double) : this(r, g, b, 1.0)
    convenience init(_ r: Double, _ g: Double, _ b: Double) {
        self.init(r, g, b, 1.0, .Rgb)
    }

    // Kotlin: constructor(value: Double) : this(value, value, value, 1.0)
    convenience init(_ value: Double) {
        self.init(value, value, value, 1.0, .Rgb)
    }

    // MARK: - Instance methods

    func MultiplyAlpha(_ alpha: Double) -> XfColor {
        switch _mode {
        case .Default:
            fatalError("Invalid on Color.Default")
        case .Rgb:
            return XfColor(
                Double(_r),
                Double(_g),
                Double(_b),
                Double(_a) * alpha,
                .Rgb
            )
        case .Hsl:
            return XfColor(
                Double(_hue),
                Double(_saturation),
                Double(_luminosity),
                Double(_a) * alpha,
                .Hsl
            )
        }
    }

    func AddLuminosity(_ delta: Double) -> XfColor {
        if _mode == .Default {
            fatalError("Invalid on Color.Default")
        }

        return XfColor(
            Double(_hue),
            Double(_saturation),
            Double(_luminosity) + delta,
            Double(_a),
            .Hsl
        )
    }

    func WithHue(_ hue: Double) -> XfColor {
        if _mode == .Default {
            fatalError("Invalid on Color.Default")
        }

        return XfColor(
            hue,
            Double(_saturation),
            Double(_luminosity),
            Double(_a),
            .Hsl
        )
    }

    func WithSaturation(_ saturation: Double) -> XfColor {
        if _mode == .Default {
            fatalError("Invalid on Color.Default")
        }

        return XfColor(
            Double(_hue),
            saturation,
            Double(_luminosity),
            Double(_a),
            .Hsl
        )
    }

    func WithLuminosity(_ luminosity: Double) -> XfColor {
        if _mode == .Default {
            fatalError("Invalid on Color.Default")
        }

        return XfColor(
            Double(_hue),
            Double(_saturation),
            luminosity,
            Double(_a),
            .Hsl
        )
    }

    // MARK: - Equatable / equality

    static func == (lhs: XfColor, rhs: XfColor) -> Bool {
        return EqualsInner(lhs, rhs)
    }

    private static func EqualsInner(_ color1: XfColor, _ color2: XfColor) -> Bool {
        if color1._mode == .Default && color2._mode == .Default {
            return true
        }
        if color1._mode == .Default || color2._mode == .Default {
            return false
        }
        if color1._mode == .Hsl && color2._mode == .Hsl {
            return color1._hue == color2._hue &&
                   color1._saturation == color2._saturation &&
                   color1._luminosity == color2._luminosity &&
                   color1._a == color2._a
        }

        return color1._r == color2._r &&
               color1._g == color2._g &&
               color1._b == color2._b &&
               color1._a == color2._a
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        // Match structure of Kotlin hashCode (not exact numeric value, but same fields)
        var hashcode = _r.hashValue
        hashcode = (hashcode &* 397) ^ _g.hashValue
        hashcode = (hashcode &* 397) ^ _b.hashValue
        hashcode = (hashcode &* 397) ^ _a.hashValue
        hasher.combine(hashcode)
    }

    // MARK: - ToString / description

    var description: String {
        return "[Color: A=\(A), R=\(R), G=\(G), B=\(B), Hue=\(Hue), Saturation=\(Saturation), Luminosity=\(Luminosity)]"
    }

    // MARK: - ToHex

    func ToHex() -> String {
        func toHexByte(_ value: Double) -> String {
            let intVal = Int((value * 255.0).rounded())
                .clamped(to: 0...255)
            var hex = String(intVal, radix: 16).uppercased()
            if hex.count == 1 {
                hex = "0" + hex
            }
            return hex
        }

        return "#\(toHexByte(A))\(toHexByte(R))\(toHexByte(G))\(toHexByte(B))"
    }

    // MARK: - Companion-like static members

    static var Default: XfColor {
        return XfColor(-1.0, -1.0, -1.0, -1.0, .Default)
    }

    static var Accent: XfColor = XfColor.Default

    static func SetAccent(_ value: XfColor) {
        Accent = value
    }

    // FromHex(hex: String)
    static func FromHex(_ hex: String) -> XfColor {
        if hex.count < 3 {
            return Default
        }

        var idx = hex.hasPrefix("#") ? 1 : 0
        let chars = Array(hex)
        let length = chars.count - idx

        switch length {
        case 3:
            // #rgb => ffrrggbb
            let t1 = ToHexD(chars[idx]);   idx += 1
            let t2 = ToHexD(chars[idx]);   idx += 1
            let t3 = ToHexD(chars[idx])
            return FromRgb(Int(t1), Int(t2), Int(t3))

        case 4:
            // #argb => aarrggbb
            let f1 = ToHexD(chars[idx]);   idx += 1
            let f2 = ToHexD(chars[idx]);   idx += 1
            let f3 = ToHexD(chars[idx]);   idx += 1
            let f4 = ToHexD(chars[idx])
            return FromRgba(Int(f2), Int(f3), Int(f4), Int(f1))

        case 6:
            // #rrggbb => ffrrggbb
            let r = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1]); idx += 2
            let g = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1]); idx += 2
            let b = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1])
            return FromRgb(Int(r), Int(g), Int(b))

        case 8:
            // #aarrggbb
            let a1 = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1]); idx += 2
            let r = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1]); idx += 2
            let g = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1]); idx += 2
            let b = (ToHex(chars[idx]) << 4) | ToHex(chars[idx + 1])
            return FromRgba(Int(r), Int(g), Int(b), Int(a1))

        default:
            return Default
        }
    }

    static func FromUint(_ argb: UInt32) -> XfColor {
        let r = Int((argb & 0x00ff0000) >> 16)
        let g = Int((argb & 0x0000ff00) >> 8)
        let b = Int(argb & 0x000000ff)
        let a = Int((argb & 0xff000000) >> 24)
        return FromRgba(r, g, b, a)
    }

    static func FromRgba(_ r: Int, _ g: Int, _ b: Int, _ a: Int) -> XfColor {
        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        let alpha = Double(a) / 255.0
        return XfColor(red, green, blue, alpha, .Rgb)
    }

    static func FromRgb(_ r: Int, _ g: Int, _ b: Int) -> XfColor {
        return FromRgba(r, g, b, 255)
    }

    static func FromRgba(_ r: Double, _ g: Double, _ b: Double, _ a: Double) -> XfColor {
        return XfColor(r, g, b, a, .Rgb)
    }

    static func FromRgb(_ r: Double, _ g: Double, _ b: Double) -> XfColor {
        return XfColor(r, g, b, 1.0, .Rgb)
    }

    static func FromHsla(_ h: Double, _ s: Double, _ l: Double, _ a: Double = 1.0) -> XfColor {
        return XfColor(h, s, l, a, .Hsl)
    }

    static func FromHsva(_ h: Double, _ s: Double, _ v: Double, _ a: Double) -> XfColor {
        let hClamped = Clamp(h, 0.0, 1.0)
        let sClamped = Clamp(s, 0.0, 1.0)
        let vClamped = Clamp(v, 0.0, 1.0)

        let range = Int(floor(hClamped * 6)) % 6
        let f = hClamped * 6 - floor(hClamped * 6)
        let p = vClamped * (1 - sClamped)
        let q = vClamped * (1 - f * sClamped)
        let t = vClamped * (1 - (1 - f) * sClamped)

        switch range {
        case 0: return FromRgba(vClamped, t,        p,        a)
        case 1: return FromRgba(q,        vClamped, p,        a)
        case 2: return FromRgba(p,        vClamped, t,        a)
        case 3: return FromRgba(p,        q,        vClamped, a)
        case 4: return FromRgba(t,        p,        vClamped, a)
        default:
            return FromRgba(vClamped, p, q, a)
        }
    }

    static func FromHsv(_ h: Double, _ s: Double, _ v: Double) -> XfColor {
        return FromHsva(h, s, v, 1.0)
    }

    static func FromHsva(_ h: Int, _ s: Int, _ v: Int, _ a: Int) -> XfColor {
        return FromHsva(
            Double(h) / 360.0,
            Double(s) / 100.0,
            Double(v) / 100.0,
            Double(a) / 100.0
        )
    }

    static func FromHsv(_ h: Int, _ s: Int, _ v: Int) -> XfColor {
        return FromHsva(
            Double(h) / 360.0,
            Double(s) / 100.0,
            Double(v) / 100.0,
            1.0
        )
    }

    // MARK: - Clamp

    static func Clamp(_ selfValue: Double, _ minValue: Double, _ maxValue: Double) -> Double {
        if maxValue < minValue {
            return maxValue
        } else if selfValue < minValue {
            return minValue
        } else if selfValue > maxValue {
            return maxValue
        }
        return selfValue
    }

    static func Clamp(_ selfValue: Int, _ minValue: Int, _ maxValue: Int) -> Int {
        if maxValue < minValue {
            return maxValue
        } else if selfValue < minValue {
            return minValue
        } else if selfValue > maxValue {
            return maxValue
        }
        return selfValue
    }

    // MARK: - Hex helpers

    private static func ToHex(_ c: Character) -> UInt {
        let scalarValue = c.unicodeScalars.first!.value

        if scalarValue >= UnicodeScalar("0").value &&
           scalarValue <= UnicodeScalar("9").value {
            return UInt(scalarValue - UnicodeScalar("0").value)
        }

        let lower = scalarValue | 0x20 // make it lowercase
        if lower >= UnicodeScalar("a").value &&
           lower <= UnicodeScalar("f").value {
            return UInt(lower - UnicodeScalar("a").value + 10)
        }

        return 0
    }

    private static func ToHexD(_ c: Character) -> UInt {
        let j = ToHex(c)
        return (j << 4) | j
    }

    // MARK: - HSL/RGB conversion

    private struct RgbResult {
        let r: Float
        let g: Float
        let b: Float
    }

    private struct HslResult {
        let h: Float
        let s: Float
        let l: Float
    }

    private static func ConvertToRgb(_ hue: Float, _ saturation: Float, _ luminosity: Float, mode: Mode) -> RgbResult {
        if mode != .Hsl {
            fatalError()
        }

        if luminosity == 0 {
            return RgbResult(r: 0, g: 0, b: 0)
        }

        if saturation == 0 {
            return RgbResult(r: luminosity, g: luminosity, b: luminosity)
        }

        let temp2: Float
        if luminosity <= 0.5 {
            temp2 = luminosity * (1.0 + saturation)
        } else {
            temp2 = luminosity + saturation - luminosity * saturation
        }
        let temp1 = 2.0 * luminosity - temp2

        var t3: [Float] = [hue + 1.0 / 3.0, hue, hue - 1.0 / 3.0]
        var clr: [Float] = [0, 0, 0]

        for i in 0..<3 {
            if t3[i] < 0 {
                t3[i] += 1.0
            }
            if t3[i] > 1 {
                t3[i] -= 1.0
            }
            if 6.0 * t3[i] < 1.0 {
                clr[i] = temp1 + (temp2 - temp1) * t3[i] * 6.0
            } else if 2.0 * t3[i] < 1.0 {
                clr[i] = temp2
            } else if 3.0 * t3[i] < 2.0 {
                clr[i] = temp1 + (temp2 - temp1) * (2.0 / 3.0 - t3[i]) * 6.0
            } else {
                clr[i] = temp1
            }
        }

        return RgbResult(r: clr[0], g: clr[1], b: clr[2])
    }

    private static func ConvertToHsl(_ r: Float, _ g: Float, _ b: Float, mode: Mode) -> HslResult {
        var v = max(r, g)
        v = max(v, b)

        var m = min(r, g)
        m = min(m, b)

        let l = (m + v) / 2.0
        if l <= 0.0 {
            return HslResult(h: 0, s: 0, l: 0)
        }

        let vm = v - m
        var s = vm

        if s > 0.0 {
            if l <= 0.5 {
                s /= v + m
            } else {
                s /= 2.0 - v - m
            }
        } else {
            return HslResult(h: 0, s: 0, l: l)
        }

        let r2 = (v - r) / vm
        let g2 = (v - g) / vm
        let b2 = (v - b) / vm

        let h: Float
        if r == v {
            h = (g == m) ? 5.0 + b2 : 1.0 - g2
        } else if g == v {
            h = (b == m) ? 1.0 + r2 : 3.0 - b2
        } else {
            h = (r == m) ? 3.0 + g2 : 5.0 - r2
        }

        return HslResult(h: h / 6.0, s: s, l: l)
    }

    // MARK: - Predefined colors

    static let Black = XfColor(r: 0,   g: 0,   b: 0)
    static let Red   = XfColor(r: 255, g: 0,   b: 0)
    static let White = XfColor(r: 255, g: 255, b: 255)
}

// MARK: - Small helpers

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        if self < range.lowerBound { return range.lowerBound }
        if self > range.upperBound { return range.upperBound }
        return self
    }
}
