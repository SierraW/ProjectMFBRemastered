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
    
    @State var viewState: ViewState? = nil
    
    enum ViewState: String, CaseIterable {
        case payable = "Product & Fix Value Discount"
        case ratedPayable = "Tax, Service & Rated Discount"
        case register = "Registeration"
        case user = "Users"
        case paymentMethod = "Payment Method"
        case currency = "Curreny"
        case roomManagement = "Room Management"
        case tag = "Tag"
        
        var view: ContentWrapperView {
            switch self {
            case .user:
                return ContentWrapperView(title: self.rawValue) {
                    AnyView(
                        UserManagementView()
                    )
                }
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
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Hi, \(appData.user.toStringRepresentation).")
                        Spacer()
                        Button(role: .destructive) {
                            appData.onLogout()
                        } label: {
                            Text("Log Out")
                        }
                    }
                }
                
                RoomNavigationView()
                    .padding()
                BillNavigationView()
                    .padding()
                
                if appData.user.is_root {
                    RootNavigationView()
                }
                
                if appData.user.is_superuser || appData.user.is_root {
                    Section {
                        DisclosureGroup {
                            ForEach(ViewState.allCases, id: \.rawValue) { state in
                                NavigationLink(state.rawValue, tag: state, selection: $viewState) {
                                    state.view
                                        .environmentObject(appData)
                                }
                            }
                        } label: {
                            HStack {
                                Text("Settings")
                                    .bold()
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.columns)
    }
}
