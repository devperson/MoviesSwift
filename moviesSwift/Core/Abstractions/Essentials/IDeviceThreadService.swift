import Foundation

protocol IDeviceThreadService
{
    func RunOnMainThread(_ action: @escaping () -> Void)
    func RunOnMainThreadAsync(_ action: @escaping @MainActor () -> Void) async
    func RunOnMainThreadWithAnimationAsync(_ action: @escaping @MainActor () -> Void) async    
}
