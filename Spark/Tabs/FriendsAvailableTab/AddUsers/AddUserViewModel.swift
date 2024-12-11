import Foundation
import FirebaseAuth
import FirebaseFirestore

class AddUserViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var filteredUsers: [AppUser] = []
    @Published var currentUserFriends: [String] = [] // Track current user's friends
    private let db = Firestore.firestore()

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

    func fetchCurrentUserFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching current user's friends: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data(), let friends = data["friends"] as? [String] {
                DispatchQueue.main.async {
                    self.currentUserFriends = friends
                }
            }
        }
    }

    func filterUsers(by searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0.userName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func addFriend(to uid: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }

        guard currentUserId != uid else {
            print("Cannot add yourself as a friend.")
            return
        }

        let currentUserRef = db.collection("users").document(currentUserId)

        currentUserRef.updateData([
            "friends": FieldValue.arrayUnion([uid])
        ]) { error in
            if let error = error {
                print("Error adding friend to current user: \(error.localizedDescription)")
            } else {
                print("Added \(uid) to current user's friends list")
                DispatchQueue.main.async {
                    self.currentUserFriends.append(uid)
                }
            }
        }
    }
}

