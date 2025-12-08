import Foundation

public struct Point: Equatable, Hashable
{
    public var X: Double
    public var Y: Double

    public static var Zero: Point
    {
        Point()
    }

    public init(x: Double = 0.0, y: Double = 0.0)
    {
        self.X = x
        self.Y = y
    }

    public func toString() -> String
    {
        return "{X=\(X) Y=\(Y)}"
    }

    public func Offset(dx: Double, dy: Double) -> Point
    {
        var p = self
        p.X += dx
        p.Y += dy
        return p
    }

    public func Round() -> Point
    {
        return Point(x: Foundation.round(X), y: Foundation.round(Y))
    }

    public var IsEmpty: Bool
    {
        return (X == 0.0) && (Y == 0.0)
    }

    public func toSize() -> Size
    {
        Size(width: X, height: Y)
    }

    public static func +(lhs: Point, rhs: Size) -> Point
    {
        return Point(x: lhs.X + rhs.Width, y: lhs.Y + rhs.Height)
    }

    public static func -(lhs: Point, rhs: Size) -> Point
    {
        return Point(x: lhs.X - rhs.Width, y: lhs.Y - rhs.Height)
    }

    public func Distance(_ other: Point) -> Double
    {
        return sqrt(pow(X - other.X, 2.0) + pow(Y - other.Y, 2.0))
    }
}
