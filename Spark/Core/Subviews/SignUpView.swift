//
//  SignInView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//

import SwiftUI
struct SignUpView: View {
    @StateObject private var viewModel = SignInViewModel()
    @ObservedObject var profileViewModel: ProfileViewModel // Inject ProfileViewModel
    @Binding var showSignUpView: Bool
    @Binding var showSignInView: Bool
    @State private var fullName: String = ""
    @State private var lastName: String = ""
    @State private var isPasswordVisible: Bool = false
    
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
            
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            HStack {
                if isPasswordVisible {
                    TextField("Password...", text: $viewModel.password)
                        .padding()
                } else {
                    SecureField("Password...", text: $viewModel.password)
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
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }
            
            Button {
                Task {
                    do {
                        // Attempt sign-up with the current ViewModel
                        try await viewModel.signUp()
                        
                        // Save the profile with the ProfileViewModel
                        profileViewModel.firstName = fullName
                        profileViewModel.lastName = lastName
                        profileViewModel.email = viewModel.email
                        try await profileViewModel.saveUserProfile()
                        
                        showSignUpView = false
                        showSignInView = false
                    } catch {
                        print("Unable to sign up or save profile: \(error.localizedDescription)")
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
            
            NavigationLink(destination: SignInView(showSignInView: $showSignUpView, showSignUpView: $showSignUpView)) {
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
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock ProfileViewModel instance
        let mockProfileViewModel = ProfileViewModel(userId: "testUserId")
        
        // Provide the mock ProfileViewModel to the SignUpView
        NavigationStack {
            SignUpView(profileViewModel: mockProfileViewModel,
                       showSignUpView: .constant(false),
                       showSignInView: .constant(false))
        }
    }
}
