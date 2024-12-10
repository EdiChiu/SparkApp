//
//  SettingsViewModel.swift
//  Spark
//
//  Created by 10 GO Participant on 11/25/24.
//
import Foundation
import FirebaseAuth

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        let userId = Auth.auth().currentUser?.uid ?? ""
        try await ProfileViewModel().deleteProfileAndCleanup(userId: userId) // Clean up Firestore
        try await AuthenticationManager.shared.delete() // Delete Firebase Authentication account
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail () async throws {
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hello123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}
