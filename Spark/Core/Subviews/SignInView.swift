//
//  SignInView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var isPasswordVisible: Bool = false
    @StateObject private var profileViewModel = ProfileViewModel()
    var onAuthFlowChange: (RootView.AuthFlow) -> Void

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
                .frame(height: 100)
            
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

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
            
            //Forgot Password Button
            Button(action: {
     
            }) {
                Text("Forgot Password?")
                    .font(.system(size: 14))
                    .foregroundColor(.purple)
            }
            .padding(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            //Log In Button
            Button(action: {
                Task {
                    do {
                        try await viewModel.signIn()
                        onAuthFlowChange(.mainApp)
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
            
            //Navigate to SignUp Page
            Button(action: {
                onAuthFlowChange(.signUp) // Navigate to Sign Up view
            }) {
                Text("Don’t Have An Account? Sign Up")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct SignInViews_: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInView(onAuthFlowChange: { _ in })
        }
    }
}


