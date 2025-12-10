import SwiftUI


struct MoviesPage: View
{
    @Environment(\.pageViewModel) var emviromentViewModel
    var Vm: MoviesPageViewModel { emviromentViewModel as! MoviesPageViewModel }

    /// Used so `.onReceive` can filter events for THIS page only.
    private let vmName: String
    
    @State private var isMenuOpen = false
    private let menuWidth: CGFloat = 250
    
    init()
    {
       self.vmName = String(describing: MoviesPageViewModel.self)
    }

    var body: some View
    {
        ZStack(alignment: .leading)
        {
            // Main content
            content
                .offset(x: isMenuOpen ? menuWidth : 0)
                .disabled(isMenuOpen) // Disable taps when menu is open
            
            // Dimmed background
            if isMenuOpen
            {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture
                {
                    withAnimation(.easeInOut)
                    {
                        isMenuOpen = false
                    }
                }
            }
            
            // Slide menu
            SideMenuView(
                onShareLogs: {
                    isMenuOpen = false
                    
                    let navigationService: IPageNavigationService = ContainerLocator.Resolve()
                    let vm = navigationService.GetCurrentPageModel() as? MoviesPageViewModel
                    
                    let item = MenuItem()
                    item.ItemType = .ShareLogs
                    vm?.MenuTappedCommand.Execute(item)
                },
                onLogout: {
                    
                    isMenuOpen = false
                    let navigationService: IPageNavigationService = ContainerLocator.Resolve()
                    let vm = navigationService.GetCurrentPageModel() as? MoviesPageViewModel
                    
                    let item = MenuItem()
                    item.ItemType = .Logout
                    vm?.MenuTappedCommand.Execute(item)
                }
            )
            .frame(width: menuWidth)
            .offset(x: isMenuOpen ? 0 : -menuWidth)
        }
        .animation(.easeInOut, value: isMenuOpen)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 50 {
                        withAnimation { isMenuOpen = true }
                    }
                    if value.translation.width < -50 {
                        withAnimation { isMenuOpen = false }
                    }
                })
    }
    
    var content: some View
    {
        VStack(spacing: 0)
        {
            // HEADER
            Sui_PageHeaderView(
                title: "Movies",
                leftIcon: "threeline.svg",
                rightIcon: "plus.svg",
                onLeftTap: { isMenuOpen = true },
                onRightTap: { Vm.AddCommand.Execute() }
            )
            
            // LIST
            List(Vm.MovieItems, id: \.Id) { item in
                MovieCell(model: item) {
                    Vm.ItemTappedCommand.Execute($0)
                }
                .listRowInsets(EdgeInsets())      // REMOVE padding
                .alignmentGuide(.listRowSeparatorLeading) //make separator full width
                { _ in
                    return 0
                }
            }
            .listStyle(.plain)
            .refreshable {
                Vm.RefreshCommand.Execute()
            }
        }
    }
    
    
//    func onCollectionSet()
//    {
//        if let collection = moviesCollection
//        {
//            collection.CollectionChanged.RemoveListener(listener_: MoviesItems_CollectionChanged)
//        }
//        
//        moviesCollection = Vm.MovieItems
//        moviesCollection?.CollectionChanged.AddListener(listener_: MoviesItems_CollectionChanged)
//    }
//    
//    private func MoviesItems_CollectionChanged(e: ObservableCollectionChange?)
//    {        
//        //Movies items changed so force to re-render whole view
//        vmObs.objectWillChange.send()
//    }
}

//extension ObservableCollection where T == MovieItemViewModel
//{
//    //converts [Any] to [MovieItemViewModel]
//    var typedItems: [MovieItemViewModel]
//    {
//        return self.Items as? [MovieItemViewModel] ?? []
//    }
//}
