import Foundation

protocol IPlatformOutput {
    func Info(_ message: String)
    func Warn(_ message: String)
    func Error(_ message: String)
}
