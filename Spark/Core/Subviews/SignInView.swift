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
        VStack (spacing: 30) {
            //Used for email
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            //Used for password
            HStack {
                if isPasswordVisible {
                    TextField("Password...", text: $viewModel.password)
                        .padding()
                } else {
                    SecureField("Password...", text: $viewModel.password)
                        .padding()
                }
                // Eye button for toggling visibility
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 10)
            }
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }
            
            Button {
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
            
            NavigationLink(destination: SignUpView(profileViewModel: profileViewModel, showSignUpView: $showSignUpView, showSignInView: $showSignInView)) {
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
}

struct SignInViews_: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInView(showSignInView: .constant(false), showSignUpView: .constant(false))
        }
    }
}


