//
//  RootView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    @State private var showSignUpView: Bool = false
    
    var body: some View {
        ZStack {
            // Show the main app content if user is signed in
            if !showSignInView {
                NavigationStack {
                    CustomTabBar(showSignInView: $showSignInView, showSignUpView: $showSignUpView)
                }
            } else {
                // Show authentication view if user isn't signed in
                NavigationStack {
                    AuthenticationView(showSignInView: $showSignInView, showSignUpView: $showSignUpView)
                }
            }
        }
        .onAppear {
            // Check if the user is authenticated
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}



