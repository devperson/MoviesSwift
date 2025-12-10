import Foundation

protocol IZipService
{
    func CreateFromDirectoryAsync(fileDir: String, zipPath: String) async throws
    func ExtractToDirectoryAsync(filePath: String, dir: String, overwrite: Bool) async throws
    func CreateFromFileAsync(filePath: String, zipPath: String) async throws
}
