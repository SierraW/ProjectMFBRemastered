//
//  LandingView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.timestamp, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @State var user: User? = nil
    @State var showWelcomeView = true
    
    private var isInitialSetup: Bool {
        return users.isEmpty
    }
    
    var body: some View {
        if showWelcomeView {
            welcomeView
        } else if isInitialSetup {
            initialSetup
        } else if let user = user {
            getMainView(with: user)
        } else {
            loginView
        }
    }
    
    var welcomeView: some View {
        VStack {
            Spacer()
            Text("Welcome to MFB Cashier @ iOS")
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showWelcomeView = false
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showWelcomeView = false
            }
        }
    }
    
    var initialSetup: some View {
        RegisterView(isSettingUpRootUser: true) { _ in
        }
    }
    
    var loginView: some View {
        LoginView { signedInUser in
            if let signedInUser = signedInUser {
                self.user = signedInUser
            }
        }
    }
    
    func getMainView(with user: User) -> some View {
        return MainView()
            .environmentObject(UserData(user, onLogout: {
                self.user = nil
            }))
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
