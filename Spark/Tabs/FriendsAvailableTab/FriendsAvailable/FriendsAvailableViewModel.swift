//
//  FriendsAvailableViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/6/24.
//
//  This file defines the FriendsAvailableViewModel, responsible for fetching friends,
//  determining their availability, handling search queries, and managing Firestore updates.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsAvailableViewModel: ObservableObject {
    
    // MARK: - Published Properties (For UI Binding)
    
    /// List of friends fetched from Firestore
    @Published var friends: [Friend] = []
    
    /// Loading indicator for data fetching
    @Published var isLoading: Bool = false
    
    /// Search query input for filtering friends
    @Published var searchQuery: String = ""
    
    /// Selected friends (for event invitations or other purposes)
    @Published var selectedFriends: [String] = []

    // MARK: - Private Properties
    
    /// Firestore database reference
    private var db = Firestore.firestore()
    
    /// Current user's ID
    private var currentUserID: String

    // MARK: - Initialization
    
    /// Initializes the view model and retrieves the current user's ID.
    init() {
        self.currentUserID = Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Fetching Friends
    
    /// Fetches the list of friends for the current user.
    func fetchFriends() {
        guard !currentUserID.isEmpty else {
            self.isLoading = false
            return
        }

        self.isLoading = true

        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                if let rawData = document.data(), let friendIDs = rawData["friends"] as? [String] {
                    self?.updateFriendsStatus(friendIDs: friendIDs)
                } else {
                    DispatchQueue.main.async {
                        self?.friends = []
                        self?.isLoading = false
                    }
                }
            } else {
                self?.isLoading = false
            }
        }
    }
    
    /// Updates the status of each friend based on their events or DND setting.
    private func updateFriendsStatus(friendIDs: [String]) {
        guard !friendIDs.isEmpty else {
            DispatchQueue.main.async {
                self.friends = []
                self.isLoading = false
            }
            return
        }

        let group = DispatchGroup()

        for friendID in friendIDs {
            group.enter()
            db.collection("users").document(friendID).getDocument { [weak self] document, _ in
                if let document = document, document.exists {
                    if let data = document.data(),
                       let events = data["calendarEvents"] as? [String: [String: Any]] {
                        let status = self?.determineStatus(events: events) ?? "Available"
                        self?.db.collection("users").document(friendID).updateData(["status": status])
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.fetchFriendsDetails(friendIDs: friendIDs)
        }
    }

    /// Determines a friend's status based on calendar events or DND settings.
    private func determineStatus(events: [String: [String: Any]]) -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        for (_, eventData) in events {
            if let startDate = (eventData["startDate"] as? Timestamp)?.dateValue(),
               let endDate = (eventData["endDate"] as? Timestamp)?.dateValue() {
                if startDate <= currentDate && currentDate <= endDate {
                    return "Busy"
                } else if let freeSoonDate = calendar.date(byAdding: .minute, value: -30, to: startDate),
                          freeSoonDate <= currentDate && currentDate < startDate {
                    return "Free Soon"
                }
            }
        }
        return "Available"
    }

    /// Fetches detailed information (name and status) for the list of friend IDs.
    private func fetchFriendsDetails(friendIDs: [String]) {
        var fetchedFriends: [Friend] = []
        let group = DispatchGroup()

        for friendID in friendIDs {
            group.enter()
            db.collection("users").document(friendID).getDocument { document, _ in
                if let document = document, document.exists {
                    if let data = document.data(),
                       let firstName = data["firstName"] as? String,
                       let lastName = data["lastName"] as? String,
                       let status = data["status"] as? String {
                        let fullName = "\(firstName) \(lastName)"
                        fetchedFriends.append(Friend(uid: friendID, name: fullName, status: status))
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.friends = fetchedFriends.sorted(by: { $0.name < $1.name })
            self.isLoading = false
        }
    }

    // MARK: - Search and Filter Functions
    
    /// Filters friends by a specific status (e.g., "Available" or "Busy").
    func filterFriends(by status: String) -> [Friend] {
        return friends.filter { $0.status.lowercased() == status.lowercased() }
    }
    
    /// Filters friends based on the search query input.
    func filteredFriends() -> [Friend] {
        if searchQuery.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    // MARK: - Managing Friends List
    
    /// Removes a friend from the current user's friend list.
    func removeFriend(friend: Friend) {
        guard let index = friends.firstIndex(where: { $0.uid == friend.uid }) else { return }

        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayRemove([friend.uid])
        ]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.friends.remove(at: index)
                }
            }
        }
    }
    
    /// Resolves a list of friend UIDs into full names.
    func resolveFriendNames(from uids: [String], completion: @escaping ([String]) -> Void) {
        guard !uids.isEmpty else {
            completion([])
            return
        }

        let group = DispatchGroup()
        var resolvedNames: [String] = []

        for uid in uids {
            group.enter()
            db.collection("users").document(uid).getDocument { document, _ in
                if let document = document, document.exists,
                   let data = document.data(),
                   let firstName = data["firstName"] as? String,
                   let lastName = data["lastName"] as? String {
                    resolvedNames.append("\(firstName) \(lastName)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(resolvedNames)
        }
    }
    
    /// Clears the list of selected friends.
    func resetSelectedFriends() {
        selectedFriends.removeAll()
    }
}
