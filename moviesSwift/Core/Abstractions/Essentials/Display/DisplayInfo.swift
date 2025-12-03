import Foundation

/// Display information for a screen/device.
/// Property names/casing preserved from the original Kotlin definition.
public struct DisplayInfo {
    public let Width: Double
    public let Height: Double
    public let Density: Double
    public let Orientation: DisplayOrientation
    public let Rotation: DisplayRotation
    public let RefreshRate: Float

    public init(Width: Double, Height: Double, Density: Double, Orientation: DisplayOrientation, Rotation: DisplayRotation, RefreshRate: Float) {
        self.Width = Width
        self.Height = Height
        self.Density = Density
        self.Orientation = Orientation
        self.Rotation = Rotation
        self.RefreshRate = RefreshRate
    }
}
