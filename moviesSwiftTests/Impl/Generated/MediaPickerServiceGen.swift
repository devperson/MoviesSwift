
import Mockable
@testable import moviesSwift

@Mockable
protocol MediaPickerServiceGen : IMediaPickerService
{
    func GetPhotoAsync(options: MediaOptions) async throws -> MediaFile?
    func TakePhotoAsync(options: MediaOptions) async throws-> MediaFile?
}

