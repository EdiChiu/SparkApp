import Foundation
import FirebaseAuth
import FirebaseFirestore

class AddUserViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var filteredUsers: [AppUser] = []
    @Published var addedUsers: [String: Bool] = [:]
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
                    guard let email = document.data()["email"] as? String,
                          let userName = document.data()["userName"] as? String,
                          let firstName = document.data()["firstName"] as? String,
                          let lastName = document.data()["lastName"] as? String else { return nil }
                    return AppUser(uid: document.documentID, userName: userName, firstName: firstName, lastName: lastName, email: email)
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
            filteredUsers = users.filter { $0.userName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Add a friend
    func addFriend(to uid: String) {
        print("addFriend called with UID: \(uid)")
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        
        guard currentUserId != uid else {
            print("Cannot add yourself as a friend.")
            return
        }
        
        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(uid)
        guard addedUsers[uid] != true else {
            return
        }
        addedUsers[uid] = true
        // Update the current user's "friends" array
        currentUserRef.updateData([
            "friends": FieldValue.arrayUnion([uid])
        ]) { error in
            if let error = error {
                print("Error adding friend to current user: \(error.localizedDescription)")
            } else {
                print("Added \(uid) to current user's friends list")
            }
        }
    }
}

