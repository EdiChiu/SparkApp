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
    @State private var isPasswordVisible: Bool = false
    @State private var passwordError: String? = nil
    
    var body: some View {
        VStack (spacing: 30) {
            //Used for email
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            //Used for password
            HStack {
                if isPasswordVisible {
                    TextField("Password...", text: Binding(
                        get: { viewModel.password },
                        set: { newValue in
                            //determines max password length
                            if newValue.count <= 15 {
                                viewModel.password = newValue
                                validatePassword(newValue)
                            }
                        }
                    ))
                    .padding()
                } else {
                    SecureField("Password...", text: Binding(
                        get: { viewModel.password },
                        set: { newValue in
                            //determines max password length
                            if newValue.count <= 15 {
                                viewModel.password = newValue
                                validatePassword(newValue)
                            }
                        }
                    ))
                    .padding()
                }
                //toggle used to indicate whether users can see password or not
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.black)
                        .padding(.trailing, 10)
                }
            }
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            if let error = passwordError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print("Unable to sign in\(error)")
                    }
                }
            } label: {
                Text("Log In")
                    .bold()
                    .frame(width: 200, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.white)
            }
            
            NavigationLink(destination: SignUpView(showSignUpView: $showSignInView)) {
                Text("Don't have an account? Sign up")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        
        .padding()
        .padding(.top, 175)
        .navigationTitle("Sign In")
        .navigationBarBackButtonHidden(true)
    }
    private func validatePassword(_ password: String) {
        if password.count > 15 {
            passwordError = "Password cannot exceed 15 characters."
        } else {
            passwordError = nil
        }
    }
}

struct SignInViews_: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInView(showSignInView: .constant(false))
        }
    }
}


