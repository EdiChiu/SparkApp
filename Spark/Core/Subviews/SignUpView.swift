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
    @State private var email: String = ""
    @State private var school: String = ""

    var body: some View {
        VStack(spacing: 20) {
           
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)

          
            VStack(spacing: 15) {
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
                CustomTextField(placeholder: "Email", text: $email)
                CustomTextField(placeholder: "School", text: $school)
            }
            .padding(.horizontal)

            
            Button {
                Task {
                    do {
                      
                        try await viewModel.signUp()
                        
                       
                        profileViewModel.firstName = firstName
                        profileViewModel.lastName = lastName
                        profileViewModel.email = email
                        try await profileViewModel.saveUserProfile()
                        
                        showSignUpView = false
                        showSignInView = false
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
            }
            .padding(.horizontal)

           
            Button {
                showSignInView = true
                showSignUpView = false
            } label: {
                Text("Already Have An Account? Log In")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding(.top, 40)
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
                    .stroke(Color.red, lineWidth: 1)
            )
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let mockProfileViewModel = ProfileViewModel(userId: "mockUserId")
        NavigationStack {
            SignUpView(profileViewModel: mockProfileViewModel,
                       showSignUpView: .constant(true),
                       showSignInView: .constant(false))
        }
    }
}
