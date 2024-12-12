//
//  ForgotPasswordView.swift
//  Spark
//
//  Created by Diego Lagunas on 12/11/24.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var message: String? = nil
    @State private var isError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 250)
            
            TextField("Email Address", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
            
            if let message = message {
                Text(message)
                    .foregroundColor(isError ? .red : .green)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    await resetPassword()
                }
            }) {
                Text("Reset Password ")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Forgot Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 400)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    private func resetPassword() async {
        guard !email.isEmpty else {
            message = "Please enter your email."
            isError = true
            return
        }
        
        do {
            try await AuthenticationManager.shared.resetPassword(email: email)
            message = "If an account is associated with this email, a reset link has been sent."
            isError = false
        } catch let error as NSError {
            handleFirebaseError(error: error)
        }
    }
    
    private func handleFirebaseError(error: NSError) {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            message = "An unexpected error occurred."
            isError = true
            return
        }
        
        switch errorCode {
        case .unverifiedEmail:
            message = "The email address is not associated with any account."
        case .invalidEmail:
            message = "The email address is not valid."
        default:
            message = "Error: \(error.localizedDescription)"
        }
        
        isError = true
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ForgotPasswordView()
        }
    }
}
