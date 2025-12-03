import Foundation

struct NavPageInfo
{
    let vmName: String
    let createPageFactory: () -> IPage
    let createVmFactory: () -> PageViewModel
}
