import Foundation

public struct Size: Equatable, Hashable
{
    private var _width: Double
    private var _height: Double

    public static var Zero: Size
    {
        Size(width: 0.0, height: 0.0)
    }

    public init(width: Double = 0.0, height: Double = 0.0)
    {
        if width.isNaN
        {
            fatalError("NaN is not a valid value for width")
        }
        if height.isNaN
        {
            fatalError("NaN is not a valid value for height")
        }
        self._width = width
        self._height = height
    }

    public var isZero: Bool
    {
        return (_width == 0.0) && (_height == 0.0)
    }

    public var Width: Double
    {
        get
        {
            _width
        }
        set
        {
            if newValue.isNaN
            {
                fatalError("NaN is not a valid value for Width")
            }; _width = newValue
        }
    }

    public var Height: Double
    {
        get
        {
            _height
        }
        set
        {
            if newValue.isNaN
            {
                fatalError("NaN is not a valid value for Height")
            }; _height = newValue
        }
    }

    public static func +(lhs: Size, rhs: Size) -> Size
    {
        Size(width: lhs._width + rhs._width, height: lhs._height + rhs._height)
    }

    public static func -(lhs: Size, rhs: Size) -> Size
    {
        Size(width: lhs._width - rhs._width, height: lhs._height - rhs._height)
    }

    public static func *(lhs: Size, value: Double) -> Size
    {
        Size(width: lhs._width * value, height: lhs._height * value)
    }

    public func equals(_ other: Size) -> Bool
    {
        return _width == other._width && _height == other._height
    }

    public func toString() -> String
    {
        return "{Width=\(_width) Height=\(_height)}"
    }

    public func toPoint() -> Point
    {
        Point(x: Width, y: Height)
    }
}
