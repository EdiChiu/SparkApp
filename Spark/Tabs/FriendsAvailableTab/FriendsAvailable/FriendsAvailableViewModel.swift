//
//  FriendsAvailableViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/6/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsAvailableViewModel: ObservableObject {
    struct Friend {
        let uid: String
        let name: String
        let status: String
    }

    @Published var friends: [Friend] = [] // Store friends as structs containing uid, name, and status
    @Published var isLoading: Bool = false
    @Published var searchQuery: String = ""
    @Published var selectedFriends: [String] = []

    private var db = Firestore.firestore()
    private var currentUserID: String

    init() {
        self.currentUserID = Auth.auth().currentUser?.uid ?? ""
    }

    func fetchFriends() {
        guard !currentUserID.isEmpty else {
            print("No current user ID available.")
            self.isLoading = false
            return
        }

        self.isLoading = true
        print("Fetching friends for user ID: \(currentUserID)")

        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                self?.isLoading = false
            } else if let document = document, document.exists {
                print("User document fetched successfully. Data: \(document.data() ?? [:])")
                if let rawData = document.data(), let friendIDs = rawData["friends"] as? [String] {
                    print("Friend IDs: \(friendIDs)")
                    self?.updateFriendsStatus(friendIDs: friendIDs)
                } else {
                    print("No friends to fetch.")
                    DispatchQueue.main.async {
                        self?.friends = []
                        self?.isLoading = false
                    }
                }
            } else {
                print("User document does not exist.")
                self?.isLoading = false
            }
        }
    }

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
            db.collection("users").document(friendID).getDocument { [weak self] document, error in
                if let error = error {
                    print("Error fetching friend \(friendID): \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    if let data = document.data(),
                       let events = data["calendarEvents"] as? [String: [String: Any]] {
                        
                        let status = self?.determineStatus(events: events) ?? "Available"
                        
                        // Update the friend's status in Firestore
                        self?.db.collection("users").document(friendID).updateData(["status": status]) { error in
                            if let error = error {
                                print("Error updating status for \(friendID): \(error.localizedDescription)")
                            } else {
                                print("Status updated for \(friendID): \(status)")
                            }
                        }
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.fetchFriendsDetails(friendIDs: friendIDs)
        }
    }

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

    private func fetchFriendsDetails(friendIDs: [String]) {
        guard !friendIDs.isEmpty else {
            DispatchQueue.main.async {
                self.friends = []
                self.isLoading = false
            }
            return
        }

        var fetchedFriends: [Friend] = []
        let group = DispatchGroup()

        for friendID in friendIDs {
            group.enter()
            db.collection("users").document(friendID).getDocument { document, error in
                if let error = error {
                    print("Error fetching friend \(friendID): \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    if let data = document.data(),
                       let firstName = data["firstName"] as? String,
                       let lastName = data["lastName"] as? String,
                       let status = data["status"] as? String {
                        let fullName = "\(firstName) \(lastName)"
                        fetchedFriends.append(Friend(uid: friendID, name: fullName, status: status))
                    } else {
                        print("Friend \(friendID) is missing firstName, lastName, or status.")
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.friends = fetchedFriends.sorted(by: { $0.name < $1.name }) // Optional: Sort by name
            self.isLoading = false
            print("All friends fetched: \(self.friends)")
        }
    }

    func filterFriends(by status: String) -> [Friend] {
        return friends.filter { $0.status.lowercased() == status.lowercased() }
    }
    
    func filteredFriends() -> [Friend] {
            if searchQuery.isEmpty {
                return friends // Return all friends if the search query is empty
            } else {
                return friends.filter { $0.name.lowercased().contains(searchQuery.lowercased()) }
            }
    }
    
    func resetSelectedFriends() {
        selectedFriends.removeAll() // Clear the selected friends
    }
}
