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
            NavigationStack {
                CustomTabBar(showSignInView: $showSignInView, showSignUpView: $showSignUpView)
            }
        }
        .onAppear() {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView : $showSignInView, showSignUpView: $showSignUpView)
            }
        }
    }
}
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}



