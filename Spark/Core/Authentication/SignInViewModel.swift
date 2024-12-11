import Foundation
import FirebaseAuth

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
            return
        }
        do {
            try await AuthenticationManager.shared.createUser(email: email, password: password)
        } catch {
            let firebaseError = error as NSError
            await MainActor.run {
                switch firebaseError.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "This email is already in use. Please use a different email."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "The email address is invalid. Please try again."
                default:
                    errorMessage = "An unexpected error occurred. Please try again."
                }
            }
        }
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password fields cannot be empty."
            return
        }
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            print("User signed in: \(authResult.user.email ?? "No Email")")
            errorMessage = nil
        } catch {
            if let authError = AuthErrorCode(rawValue: error._code) {
                print(authError)
                // Map Firebase error codes to user-friendly messages
                switch authError {
                case .unverifiedEmail:
                    errorMessage = "No account found with this email address."
                case .wrongPassword:
                    errorMessage = "The password you entered is incorrect."
                case .invalidEmail:
                    errorMessage = "The email address is not valid."
                default:
                    errorMessage = "An error occurred. Please try again."
                }
            }
        }
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

