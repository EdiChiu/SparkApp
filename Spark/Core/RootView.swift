//
//  RootView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI

struct RootView: View {
    enum AuthFlow {
        case authentication
        case signIn
        case signUp
        case mainApp
    }
    @State private var authFlow: AuthFlow = .authentication
    
    var body: some View {
        ZStack {
            switch authFlow {
            case .authentication:
                NavigationStack {
                    AuthenticationView(onAuthFlowChange: { flow in
                        authFlow = flow
                    })
                }
            case .signIn:
                NavigationStack {
                    SignInView(onAuthFlowChange: { flow in
                        authFlow = flow
                    })
                }
            case .signUp:
                NavigationStack {
                    SignUpView(
                        profileViewModel: ProfileViewModel(),
                        onAuthFlowChange: { flow in
                        authFlow = flow
                    })
                }
            case .mainApp:
                    CustomTabBar(authFlow: $authFlow)
                }
        }
        .onAppear {
            // Check if the user is authenticated
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.authFlow = authUser == nil ? .authentication : .mainApp
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}



