import Foundation

protocol IVideoService
{
    func GetThumbnail(videoFilePath: String) async -> ThumbnailInfo
    func CompressVideo(inputPath: String) async -> String
}

public struct ThumbnailInfo
{
    public var ImageSize: Size = Size()
    public var FilePath: String? = nil

    public var Success: Bool
    {
        !(FilePath?.isEmpty ?? true)
    }
    public var IsPortrait: Bool
    {
        return ImageSize.Width > 0 ? (ImageSize.Height > ImageSize.Width) : true
    }
}
