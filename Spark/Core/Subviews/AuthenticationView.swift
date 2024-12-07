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
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 40) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.top, 50)
            
            VStack(spacing: 20) {
               
                NavigationLink {
                    SignInView(showSignInView: $showSignInView, showSignUpView: $showSignUpView)
                } label: {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                NavigationLink {
                    SignUpView(profileViewModel: profileViewModel,showSignUpView: $showSignUpView, showSignInView: $showSignInView)
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
            }

            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false), showSignUpView: .constant(false))
        }
    }
}




