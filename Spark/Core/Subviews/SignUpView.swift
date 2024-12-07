//
//  SignInView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI
struct SignUpView: View {
    
    @StateObject private var viewModel = SignInViewModel()
    @ObservedObject var profileViewModel: ProfileViewModel
    @Binding var showSignUpView: Bool
    @Binding var showSignInView: Bool
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var userName: String = ""
    @State private var isPasswordVisible: Bool = false
    
    private let maxPasswordLength = 15
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
                CustomTextField(placeholder: "User Name", text: $userName)
                CustomTextField(placeholder: "Email", text: $viewModel.email)
            }
            
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
            
            // Sign Up Button
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignUpView = false
                        showSignInView = false
                        profileViewModel.firstName = firstName
                        profileViewModel.lastName = lastName
                        profileViewModel.userName = userName
                        profileViewModel.email = viewModel.email
                        try await profileViewModel.saveUserProfile()
                        return
                    } catch {
                        print("Unable to sign up \(error)")
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .frame(width: 200, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.white)
            }
            
            NavigationLink(destination: SignInView(showSignInView: $showSignUpView, showSignUpView: $showSignUpView)) {
                Text("Already have an account? Sign in")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .padding(.top, 20)
        .navigationBarBackButtonHidden(true)
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 2)
            )
            .padding(.horizontal, 10)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let mockProfileViewModel = ProfileViewModel()
        NavigationStack {
            SignUpView(profileViewModel: mockProfileViewModel, showSignUpView: .constant(false), showSignInView: .constant(false))
        }
    }
}
