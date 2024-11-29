import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil
    
    private let maxPasswordLength = 15
    
    func signUp() async throws {
        guard validatePassword(password) else {
            throw SignInError.passwordTooLong
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "No email or password found."
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard validatePassword(password) else {
            throw SignInError.passwordTooLong
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "No email or password found."
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        if password.count > maxPasswordLength {
            errorMessage = "Password cannot exceed \(maxPasswordLength) characters."
            return false
        } else {
            errorMessage = nil
            return true
        }
    }
}

enum SignInError: Error {
    case passwordTooLong
}

