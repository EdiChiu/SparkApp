//
//  AuthenticationView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/15/24.
//
import SwiftUI
struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    @Binding var showSignUpView: Bool
    var body: some View {
        VStack (spacing: 40){
            NavigationLink {
                SignInView(showSignInView: $showSignInView, showSignUpView: $showSignUpView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            NavigationLink {
                SignUpView(showSignUpView: $showSignUpView, showSignInView: $showSignInView)
            } label: {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Welcome")
    }
}
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false), showSignUpView: .constant(false))
        }
    }
}




