import Foundation

protocol IDeviceThreadService {
    func BeginInvokeOnMainThread(_ action: @escaping () -> Void)
}
