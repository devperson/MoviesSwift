import Foundation

public struct Rect: Equatable, Hashable
{
    public var X: Double
    public var Y: Double
    public var Width: Double
    public var Height: Double

    public init(X: Double = 0.0, Y: Double = 0.0, Width: Double = 0.0, Height: Double = 0.0)
    {
        self.X = X
        self.Y = Y
        self.Width = Width
        self.Height = Height
    }

    public init(loc: Point, sz: Size)
    {
        self.X = loc.X
        self.Y = loc.Y
        self.Width = sz.Width
        self.Height = sz.Height
    }

    public var Top: Double
    {
        Y
    }
    public var Bottom: Double
    {
        Y + Height
    }
    public var Right: Double
    {
        X + Width
    }
    public var Left: Double
    {
        X
    }

    public var IsEmpty: Bool
    {
        (Width <= 0) || (Height <= 0)
    }

    public var Size: Size
    {
        get
        {
            moviesSwift.Size(width: Width, height: Height)
        }
        set
        {
            Width = newValue.Width; Height = newValue.Height
        }
    }

    public var Location: Point
    {
        get
        {
            Point(x: X, y: Y)
        }
        set
        {
            X = newValue.X; Y = newValue.Y
        }
    }

    public var Center: Point
    {
        Point(x: X + Width / 2, y: Y + Height / 2)
    }

    public func Equals(_ other: Rect) -> Bool
    {
        X == other.X && Y == other.Y && Width == other.Width && Height == other.Height
    }

    public func equals(_ other: Any?) -> Bool
    {
        guard let other = other
        else
        {
            return false
        }
        if let r = other as? Rect
        {
            return Equals(r)
        }
        if let r = other as? Rectangle
        {
            return X == r.X && Y == r.Y && Width == r.Width && Height == r.Height
        }
        return false
    }

    public func hashCode() -> Int
    {
        var result = X.hashValue
        result = (result &* 397) ^ Y.hashValue
        result = (result &* 397) ^ Width.hashValue
        result = (result &* 397) ^ Height.hashValue
        return result
    }

    // Hit Testing / Intersection / Union
    public func Contains(rect: Rect) -> Bool
    {
        X <= rect.X && Right >= rect.Right && Y <= rect.Y && Bottom >= rect.Bottom
    }

    public func Contains(pt: Point) -> Bool
    {
        Contains(x: pt.X, y: pt.Y)
    }

    public func Contains(x: Double, y: Double) -> Bool
    {
        (x >= Left) && (x < Right) && (y >= Top) && (y < Bottom)
    }

    public func IntersectsWith(r: Rect) -> Bool
    {
        !((Left >= r.Right) || (Right <= r.Left) || (Top >= r.Bottom) || (Bottom <= r.Top))
    }

    public static func FromLTRB(left: Double, top: Double, right: Double, bottom: Double) -> Rect
    {
        return Rect(X: left, Y: top, Width: right - left, Height: bottom - top)
    }

    public static func Union(_ r1: Rect, _ r2: Rect) -> Rect
    {
        return FromLTRB(left: min(r1.Left, r2.Left), top: min(r1.Top, r2.Top), right: max(r1.Right, r2.Right), bottom: max(r1.Bottom, r2.Bottom))
    }

    public static func Intersect(_ r1: Rect, _ r2: Rect) -> Rect
    {
        let x = max(r1.X, r2.X)
        let y = max(r1.Y, r2.Y)
        let width = min(r1.Right, r2.Right) - x
        let height = min(r1.Bottom, r2.Bottom) - y
        if width < 0 || height < 0
        {
            return Rect()
        }
        return Rect(X: x, Y: y, Width: width, Height: height)
    }

    // Inflate and Offset
    public func Inflate(sz: Size) -> Rect
    {
        Inflate(width: sz.Width, height: sz.Height)
    }

    public func Inflate(width: Double, height: Double) -> Rect
    {
        var r = self
        r.X -= width
        r.Y -= height
        r.Width += width * 2
        r.Height += height * 2
        return r
    }

    public func Offset(dx: Double, dy: Double) -> Rect
    {
        var r = self; r.X += dx; r.Y += dy; return r
    }

    public func Offset(dr: Point) -> Rect
    {
        Offset(dx: dr.X, dy: dr.Y)
    }

    public func Round() -> Rect
    {
        Rect(X: Foundation.round(X), Y: Foundation.round(Y), Width: Foundation.round(Width), Height: Foundation.round(Height))
    }

    public func Deconstruct() -> DeconstructedRect
    {
        DeconstructedRect(x: X, y: Y, width: Width, height: Height)
    }

    public func toString() -> String
    {
        return "{X=\(X) Y=\(Y) Width=\(Width) Height=\(Height)}"
    }
}

public struct DeconstructedRect
{
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
}
