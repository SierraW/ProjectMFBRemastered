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
    
    @State var viewState: ViewState? = .register
    
    enum ViewState: String, CaseIterable {
        case register = "Registeration"
//        case Deposit
//        case Withdraw
//        case Management
//        case User
//        case Report
//        case Transactions
        case tag
        case currency = "Currencies"
        case paymentMethod = "Payment Method"
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
            default:
                return ContentWrapperView(title: "Welcome") {
                    AnyView(
                        WelcomeView()
                    )
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            menuView
        }
    }
    
    var menuView: some View {
        VStack {
            ForEach(ViewState.allCases, id: \.rawValue) { state in
                NavigationLink("", tag: state, selection: $viewState) {
                    state.view
                }
                .hidden()
                
                NavigationButton(title: state.rawValue, selected: viewState == state) {
                    viewState = state
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
