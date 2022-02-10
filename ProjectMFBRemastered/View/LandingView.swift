//
//  LandingView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI
import CoreData

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.timestamp, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @State var data: AppData? = nil
    @State var showWelcomeView = true
    @State var showMajorCurrencyWidzard = false
    
    private var isInitialSetup: Bool {
        users.isEmpty
    }
    
    var body: some View {
        if showWelcomeView {
            welcomeView
        } else if isInitialSetup {
            initialSetup
        } else if let appData = data {
            getMainView(with: appData)
        } else if showMajorCurrencyWidzard {
            currencySetup
        } else {
            loginView
        }
    }
    
    var welcomeView: some View {
        WelcomeView()
        .contentShape(Rectangle())
        .onTapGesture {
            showWelcomeView = false
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                showWelcomeView = false
            }
        }
    }
    
    var initialSetup: some View {
        RegisterationView(isSettingUpRootUser: true) { _ in
        }
    }
    
    var currencySetup: some View {
        MajorCurrencyWidzardView {
            withAnimation {
                showMajorCurrencyWidzard = false
            }
        }
    }
    
    var loginView: some View {
        LoginView { signedInUser in
            if let signedInUser = signedInUser {
                if let appData = AppData(signedInUser, viewContext: viewContext, onLogout: {
                    self.data = nil
                }) {
                    withAnimation {
                        self.data = appData
                    }
                } else {
                    showMajorCurrencyWidzard = true
                }
            }
        }
    }
    
    func getMainView(with data: AppData) -> some View {
        MainView()
            .environmentObject(data)
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
