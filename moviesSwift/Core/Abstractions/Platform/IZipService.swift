import Foundation

protocol IZipService
{
    func CreateFromDirectoryAsync(fileDir: String, zipPath: String) async
    func ExtractToDirectoryAsync(filePath: String, dir: String, overwrite: Bool) async
    func CreateFromFileAsync(filePath: String, zipPath: String) async
}
