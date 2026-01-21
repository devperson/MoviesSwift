import Foundation

class AsyncCommand
{
    static var DisableDoubleClickCheck: Bool = false
    static var loggingService: ILoggingService? = nil

    let doubleClickChecker: ClickUtil = ClickUtil()
    let CanExecuteChanged: BaseEvent = BaseEvent()

    private let executeFunc: @MainActor (Any?) async -> Void
    private let canExecuteFunc: ((Any?) -> Bool)?

    init(_ executeFunc: @escaping @MainActor (Any?) async -> Void,
        canExecuteFunc: ((Any?) -> Bool)? = { _ in true })
    {
        self.executeFunc = executeFunc
        self.canExecuteFunc = canExecuteFunc
    }


    func CanExecute(_ param: Any?) -> Bool
    {
        return canExecuteFunc?(param) ?? true
    }

    func ExecuteAsync(_ param: Any? = nil) async
    {
        if !AsyncCommand.DisableDoubleClickCheck
        {
            if !doubleClickChecker.isOneClick()
            {
                let warning = "AsyncCommand.ExecuteAsync() is ignored because it is not permitted to execute second click within ${ClickUtil.OneClickDelay}mls"
                AsyncCommand.loggingService?.LogWarning(warning)
                print(warning)
                return
            }
        }
        await executeFunc(param)
    }

    func RaiseCanExecuteChanged()
    {
        CanExecuteChanged.Invoke()
    }

    func Execute(_ param: Any?)
    {
        Task
        {
            await self.ExecuteAsync(param)
        }
    }

    func Execute()
    {
        Execute(nil)
    }
}
