import Foundation

struct NavPageInfoUiKit
{
    let vmName: String
    let createPageFactory: () -> IPage
    let createVmFactory: () -> PageViewModel
}
