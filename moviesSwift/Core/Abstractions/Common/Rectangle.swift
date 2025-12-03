import Foundation

public struct Rectangle: Equatable, Hashable {
    public var X: Double
    public var Y: Double
    public var Width: Double
    public var Height: Double

    public static var Zero: Rectangle { Rectangle() }

    public init(X: Double = 0.0, Y: Double = 0.0, Width: Double = 0.0, Height: Double = 0.0) {
        self.X = X
        self.Y = Y
        self.Width = Width
        self.Height = Height
    }

    public static func FromLTRB(left: Double, top: Double, right: Double, bottom: Double) -> Rectangle {
        return Rectangle(X: left, Y: top, Width: right - left, Height: bottom - top)
    }

    public static func Union(_ r1: Rectangle, _ r2: Rectangle) -> Rectangle {
        return FromLTRB(left: min(r1.Left, r2.Left), top: min(r1.Top, r2.Top), right: max(r1.Right, r2.Right), bottom: max(r1.Bottom, r2.Bottom))
    }

    public static func Intersect(_ r1: Rectangle, _ r2: Rectangle) -> Rectangle {
        let x = max(r1.X, r2.X)
        let y = max(r1.Y, r2.Y)
        let width = min(r1.Right, r2.Right) - x
        let height = min(r1.Bottom, r2.Bottom) - y

        if width < 0 || height < 0 {
            return Rectangle.Zero
        }
        return Rectangle(X: x, Y: y, Width: width, Height: height)
    }

    // Additional constructor
    public init(loc: Point, sz: Size) {
        self.X = loc.X
        self.Y = loc.Y
        self.Width = sz.Width
        self.Height = sz.Height
    }

    // toString (preserve casing)
    public func toString() -> String {
        return "{X=\(X) Y=\(Y) Width=\(Width) Height=\(Height)}"
    }

    public func Equals(_ other: Rectangle) -> Bool {
        return X == other.X && Y == other.Y && Width == other.Width && Height == other.Height
    }

    // Kotlin's equals(other: Any?) equivalent (preserve lowercase 'equals')
    public func equals(_ other: Any?) -> Bool {
        guard let other = other else { return false }

        if let r = other as? Rectangle {
            return Equals(r)
        }
        if let r = other as? Rect {
            return X == r.X && Y == r.Y && Width == r.Width && Height == r.Height
        }
        return false
    }

    // Provide a Kotlin-like hashCode() method and Hashable conformance
    public func hashCode() -> Int {
        var result = X.hashValue
        result = (result &* 397) ^ Y.hashValue
        result = (result &* 397) ^ Width.hashValue
        result = (result &* 397) ^ Height.hashValue
        return result
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(X)
        hasher.combine(Y)
        hasher.combine(Width)
        hasher.combine(Height)
    }

    // Hit Testing / Intersection / Union
    public func Contains(rect: Rectangle) -> Bool {
        return X <= rect.X && Right >= rect.Right && Y <= rect.Y && Bottom >= rect.Bottom
    }

    public func Contains(pt: Point) -> Bool {
        return Contains(x: pt.X, y: pt.Y)
    }

    public func Contains(x: Double, y: Double) -> Bool {
        return (x >= Left) && (x < Right) && (y >= Top) && (y < Bottom)
    }

    public func IntersectsWith(r: Rectangle) -> Bool {
        return !((Left >= r.Right) || (Right <= r.Left) || (Top >= r.Bottom) || (Bottom <= r.Top))
    }

    public func Union(r: Rectangle) -> Rectangle {
        return Rectangle.Union(self, r)
    }

    public func Intersect(r: Rectangle) -> Rectangle {
        return Rectangle.Intersect(self, r)
    }

    // Position/Size computed properties (preserve casing)
    public var Top: Double {
        get { Y }
        set { Y = newValue }
    }

    public var Bottom: Double {
        get { Y + Height }
        set { Height = newValue - Y }
    }

    public var Right: Double {
        get { X + Width }
        set { Width = newValue - X }
    }

    public var Left: Double {
        get { X }
        set { X = newValue }
    }

    public var IsEmpty: Bool {
        return (Width <= 0) || (Height <= 0)
    }

    public var Size: Size {
        get { moviesSwift.Size(width: Width, height: Height) }
        set { Width = newValue.Width; Height = newValue.Height }
    }

    public var Location: Point {
        get { Point(x: X, y: Y) }
        set { X = newValue.X; Y = newValue.Y }
    }

    public var Center: Point {
        get { Point(x: X + Width / 2, y: Y + Height / 2) }
    }

    // Inflate and Offset
    public func Inflate(_ sz: Size) -> Rectangle {
        return Inflate(width: sz.Width, height: sz.Height)
    }

    public func Inflate(width: Double, height: Double) -> Rectangle {
        var r = self
        r.X -= width
        r.Y -= height
        r.Width += width * 2
        r.Height += height * 2
        return r
    }

    public func Offset(dx: Double, dy: Double) -> Rectangle {
        var r = self
        r.X += dx
        r.Y += dy
        return r
    }

    public func Offset(dr: Point) -> Rectangle {
        return Offset(dx: dr.X, dy: dr.Y)
    }

    public func Round() -> Rectangle {
        return Rectangle(X: Foundation.round(X), Y: Foundation.round(Y), Width: Foundation.round(Width), Height: Foundation.round(Height))
    }

    // Convert to Rect (preserve method name toRect)
    public func toRect() -> Rect { Rect(X: X, Y: Y, Width: Width, Height: Height) }
}

// Extension on Rect to convert to Rectangle (preserve method name toRectangle)
public extension Rect {
    func toRectangle() -> Rectangle { Rectangle(X: X, Y: Y, Width: Width, Height: Height) }
}
