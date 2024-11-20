//
//  SignInView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI
@MainActor
final class SignInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    
}
struct SignInView: View {
    
    @StateObject private var viewModel = SignInViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack (spacing: 30) {
            
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
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
                    .offset(y:100)
            }
            
            Spacer().frame(height:50)
        }
        
        .padding()
        .navigationTitle("Welcome")
    }
}
struct SignInViews_: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInView(showSignInView: .constant(false))
        }
    }
}


