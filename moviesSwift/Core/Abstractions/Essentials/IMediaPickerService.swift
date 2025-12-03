import Foundation

protocol IMediaPickerService {
    func GetPhotoAsync(options: MediaOptions) async -> MediaFile?
    func TakePhotoAsync(options: MediaOptions) async -> MediaFile?
}

enum MediaSource {
    case camera
    case gallery
}

struct MediaOptions {
    var IncludeBytes: Bool = false
    var Compress: Bool = false
    var CompressionQuality: Int = 95
    var MaxWidth: Int? = nil
    var MaxHeight: Int? = nil
    var SaveToAppDirectory: Bool = true
}

struct MediaFile {
    let FilePath: String
    let MimeType: String?
    let ByteData: Data?
}
