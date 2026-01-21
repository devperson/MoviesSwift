import Foundation
import SwiftUI

class iOSDeviceThreadService: IDeviceThreadService
{
    func RunOnMainThread(_ action: @escaping () -> Void)
    {
        Task
        { @MainActor in
            
            action()
        }
    }
    
    func RunOnMainThreadAsync(_ action: @escaping @MainActor () -> Void) async
    {
        await MainActor.run {
            action()
        }
    }
    
    func RunOnMainThreadWithAnimationAsync(_ action: @escaping @MainActor () -> Void) async
    {
        await MainActor.run
        {
            withAnimation {
                action()
            }
        }
    }
}
