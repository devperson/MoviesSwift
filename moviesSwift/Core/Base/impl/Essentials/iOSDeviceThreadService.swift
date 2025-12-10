import Foundation
  

class iOSDeviceThreadService: IDeviceThreadService
{
    func BeginInvokeOnMainThread(_ action: @escaping () -> Void)
    {
        DispatchQueue.main.async
        {
            action()
        }
    }
}
