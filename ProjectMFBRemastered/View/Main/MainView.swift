//
//  MainView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI
import Combine

class UserData: ObservableObject {
    @Published var user: User
    var onLogout: () -> Void
    
    init(_ user: User, onLogout: @escaping () -> Void) {
        self.user = user
        self.onLogout = onLogout
    }
    
}

struct MainView: View {
    @EnvironmentObject var appData: AppData
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Bill.size, ascending: true)],
//        animation: .default)
//    private var fetchedObjects: FetchedResults<Bill>
    
    @State var viewState: ViewState? = .empty
    
    enum ViewState: String, CaseIterable {
        case empty = "Welcome"
        case register = "Registeration"
        case tag
        case roomManagement = "Room Management"
        case currency = "Curreny"
        case paymentMethod = "Payment Method"
        case payable = "Product & Fix Value Discount"
        case ratedPayable = "Tax & Service"
        case debugPayableList = "[DEBUG] payable list"
        case debugRatedPayableList = "[DEBUG] rated list"
        case debugBILV = "[DEBUG] bill item list view"
//        case Deposit
//        case Withdraw
//        case Management
//        case User
//        case Report
//        case Transactions
        
//        case Payable
//        case Bill
//        case BillHistory
//        case Room
        
        var view: ContentWrapperView {
            switch self {
            case .register:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        RegisterView { _ in
                            
                        }
                    )
                }
            case .roomManagement:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        RoomManagementView()
                    )
                }
            case .currency:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        CurrencyManagementView()
                    )
                }
            case .paymentMethod:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        PaymentMethodManagementView()
                    )
                }
            case .tag:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        TagManagementView()
                    )
                }
            case .payable:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        PayableManagementView()
                    )
                }
            case .ratedPayable:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        RatedPayableManagementView()
                    )
                }
            case .debugPayableList:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        PayableListView(onSelect: {_ in})
                    )
                }
            case .debugRatedPayableList:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        RatedPayableListView(onSelect: {_ in})
                    )
                }
            case .debugBILV:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        BillItemListView(onSubmit: { _, _ in
                            //
                        })
                    )
                }
            default:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        WelcomeView()
                    )
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                menuView
            }
        }
        .navigationViewStyle(.columns)
    }
    
    var menuView: some View {
        VStack {
            ForEach(ViewState.allCases, id: \.rawValue) { state in
                NavigationLink("", tag: state, selection: $viewState) {
                    state.view
                        .environmentObject(appData)
                }
                .hidden()
                
                NavigationButton(title: state.rawValue, selected: viewState == state) {
                    viewState = state
                }
            }
            RoomNavigationView()
                .padding()
            Button(role: .destructive) {
                appData.onLogout()
            } label: {
                Text("Log Out")
            }

        }
//        .onAppear {
//            for object in fetchedObjects {
//                viewContext.delete(object)
//            }
//            do {
//                try viewContext.save()
//            } catch {
//                print("save error")
//            }
//        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
