//
//  SignInView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @Binding var showSignInView: Bool
    @Binding var showSignUpView: Bool
    @State private var isPasswordVisible: Bool = false
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 20) {
        
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottomTrailing))

            Spacer().frame(height: 20)

         
            TextField("Email or Phone", text: $viewModel.email)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 2)
                )
                .padding(.horizontal)

          
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $viewModel.password)
                        .padding()
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                }
             
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 2)
            )
            .padding(.horizontal)

         
            Button(action: {
     
            }) {
                Text("Forgot Password?")
                    .font(.system(size: 14))
                    .foregroundColor(.purple)
            }
            .padding(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Button(action: {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        showSignUpView = false
                        return
                    } catch {
                        print("Unable to sign in \(error)")
                    }
                }
            }) {
                Text("Log In")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            NavigationLink(destination: SignUpView(profileViewModel: profileViewModel, showSignUpView: $showSignUpView, showSignInView: $showSignInView)) {
                Text("Don’t Have An Account? Sign Up Instead")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct SignInViews_: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInView(showSignInView: .constant(false), showSignUpView: .constant(false))
        }
    }
}


