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
    @EnvironmentObject var userData: UserData
    
    @State var viewState: ViewState? = .Room
    
    enum ViewState: String {
        case Register = "Registeration"
        case Deposit
        case Withdraw
        case Management
        case User
        case Report
        case Transactions
        case Tag
        case Currency = "Currencies"
        case PaymentMethod
        case Payable
        case Bill
        case BillHistory
        case Room
    }
    
    var body: some View {
        NavigationView {
            menuView
        }
    }
    
    var menuView: some View {
        VStack {
            NavigationLink("Register new user", tag: ViewState.Register, selection: $viewState) {
                ContentWrapperView(title: viewState?.rawValue ?? "") {
                    AnyView(
                        RegisterView { _ in
                        
                    })
                }
            }
            NavigationLink("Currency Management", tag: ViewState.Currency, selection: $viewState) {
                ContentWrapperView(title: viewState?.rawValue ?? "") {
                    AnyView(
                        CurrencyManagementView()
                    )
                }
            }
            
            NavigationLink("Tag Management", tag: ViewState.Tag, selection: $viewState) {
                ContentWrapperView(title: viewState?.rawValue ?? "") {
                    AnyView(
                        TagManagementView()
                    )
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
