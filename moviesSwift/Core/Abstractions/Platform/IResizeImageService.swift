import Foundation

protocol IResizeImageService
{
    func ResizeImage(imageData: Data, originalContentType: String, maxWidth: Int, maxHeight: Int, quality: Float, rotation: Int, shouldSetUniqueName: Bool) -> ImageResizeResult
    func ResizeNativeImage(image: Any, originalContentType: String, maxWidth: Int, maxHeight: Int, rotation: Int, quality: Float, shouldSetUniqueName: Bool) -> ImageResizeResult
    func GetRequiredRotation(fileResult: Any) -> Int
    func GetRequiredRotation(filePath: String) -> Int
}

public struct ImageResizeResult
{
    public var IsResized: Bool = true
    public var NativeImage: Any? = nil
    public var Image: Data? = nil
    public var ContentType: String = ""
    public var ImageSize: Size = Size()
    public var FilePath: String? = nil

    public var FileExtension: String
    {
        return ContentType.lowercased().contains("png") ? ".png" : ".jpg"
    }

    public var IsPortrait: Bool
    {
        return ImageSize == Size() || ImageSize.Height > ImageSize.Width
    }
}
