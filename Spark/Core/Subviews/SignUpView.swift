//
//  SignInView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI
struct SignUpView: View {
    
    @StateObject private var viewModel = SignInViewModel()
    @Binding var showSignUpView: Bool
    @State private var fullName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var passwordError: String? = nil
    
    private let maxPasswordLength = 15
    
    var body: some View {
        VStack(spacing: 30) {
            TextField("Full Name", text: $fullName)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            TextField("Last Name", text: $lastName)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            TextField("Email...", text: $email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            HStack {
                if isPasswordVisible {
                    TextField("Password...", text: Binding(
                        get: { password },
                        set: { newValue in
                            if newValue.count <= maxPasswordLength {
                                password = newValue
                                validatePassword(newValue)
                            }
                        }
                    ))
                    .padding()
                } else {
                    SecureField("Password...", text: Binding(
                        get: { password },
                        set: { newValue in
                            if newValue.count <= maxPasswordLength {
                                password = newValue
                                validatePassword(newValue)
                            }
                        }
                    ))
                    .padding()
                }
                
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
            
            if let error = passwordError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Sign Up Button
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignUpView = false
                        return
                    } catch {
                        print("Unable to sign up\(error)")
                    }
                }
            } label: {
                Text("Sign Up")
                    .bold()
                    .frame(width: 200, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.white)
                    .padding()
            }
            
            NavigationLink(destination: SignInView(showSignInView: $showSignUpView)) {
                Text("Already have an account? Sign in")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding()
        .padding(.top, 100)
        .navigationTitle("Sign Up")
        .navigationBarBackButtonHidden(true)
    }
    
    private func validatePassword(_ password: String) {
        if password.count > maxPasswordLength {
            passwordError = "Password cannot exceed \(maxPasswordLength) characters."
        } else {
            passwordError = nil
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView(showSignUpView: .constant(false))
        }
    }
}
