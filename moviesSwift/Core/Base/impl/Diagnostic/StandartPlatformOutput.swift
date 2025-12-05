import Foundation

class StandartPlatformOutput: IPlatformOutput
{
    func Info(_ message: String)
    {
        print(message)
    }

    func Warn(_ message: String)
    {
        print(message)
    }

    func Error(_ message: String)
    {
        print(message)
    }
}
