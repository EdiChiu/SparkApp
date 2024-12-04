import Foundation
import FirebaseFirestore

class AddUserViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var filteredUsers: [AppUser] = []
    private let db = Firestore.firestore()
    
    // Fetch all users from Firestore
    func fetchAllUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                let users = documents.compactMap { document -> AppUser? in
                    guard let email = document.data()["email"] as? String else { return nil }
                    return AppUser(uid: document.documentID, email: email)
                }
                
                DispatchQueue.main.async {
                    self.users = users
                    self.filteredUsers = users // Initialize filtered users
                }
            }
        }
    }
    
    // Filter users by search text
    func filterUsers(by searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0.email.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Send a friend request
    func sendFriendRequest(to uid: String) {
        guard let currentUserId = getCurrentUserId(), currentUserId != uid else { return }
        
        let targetUserRef = db.collection("users").document(uid)
        
        targetUserRef.updateData([
            "friendRequests": FieldValue.arrayUnion([currentUserId])
        ]) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
            } else {
                print("Friend request sent to \(uid)")
            }
        }
    }
    
    // Mock function to get the current user ID
    private func getCurrentUserId() -> String? {
        // Replace with your actual implementation
        return "currentUserId"
    }
}

// Model for AppUser
struct AppUser: Identifiable {
    let uid: String
    let email: String
    
    var id: String { uid }
}
