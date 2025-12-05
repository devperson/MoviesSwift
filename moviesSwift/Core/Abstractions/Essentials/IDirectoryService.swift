import Foundation

protocol IDirectoryService
{
    func GetCacheDir() -> String
    func GetAppDataDir() -> String
    func IsExistDir(path: String) -> Bool
    func CreateDir(path: String)
}
