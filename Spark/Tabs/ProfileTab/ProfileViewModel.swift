//
//  ProfileViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//
//  This file defines the ProfileViewModel class, responsible for managing user profile data,
//  syncing calendar events with Firestore, handling Do Not Disturb (DND) status, and cleaning up user data.
//

import Foundation
import EventKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties (For UI Binding)
    
    /// List of upcoming Apple Calendar events
    @Published var upcomingEvents: [EKEvent] = []
    
    /// User's first name
    @Published var firstName: String = ""
    
    /// User's last name
    @Published var lastName: String = ""
    
    /// User's username
    @Published var userName: String = ""
    
    /// User's email address
    @Published var email: String = ""
    
    /// List of user's friends (as UIDs)
    @Published var friends: [String] = []
    
    /// "Do Not Disturb" (DND) status
    @Published var dnd: Bool = false
    
    // MARK: - Private Properties
    
    /// Apple Calendar event store
    private var eventStore = EKEventStore()
    
    /// Firestore database reference
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    
    /// Initializes the view model by requesting calendar access and observing calendar changes.
    init() {
        requestAccessToCalendar()
        registerForCalendarChanges()
    }
    
    // MARK: - Apple Calendar Access
    
    /// Requests permission to access the Apple Calendar.
    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.fetchUpcomingMonthEvents()
                }
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completionHandler)
        } else {
            eventStore.requestAccess(to: .event, completion: completionHandler)
        }
    }
    
    /// Registers for notifications when changes occur in Apple Calendar.
    private func registerForCalendarChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCalendarChange),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    /// Handles calendar changes by fetching updated events.
    @objc private func handleCalendarChange() {
        fetchUpcomingMonthEvents()
    }
    
    // MARK: - Event Management
    
    /// Fetches Apple Calendar events for the upcoming month.
    func fetchUpcomingMonthEvents() {
        let calendar = Calendar.current
        let today = Date()
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: today) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: today, end: nextMonth, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.upcomingEvents = events
            self.syncEventsWithFirestore(events: events)
        }
    }
    
    /// Syncs Apple Calendar events with Firestore.
    /// - Parameter events: List of Apple Calendar events to sync.
    func syncEventsWithFirestore(events: [EKEvent]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        Task {
            do {
                let snapshot = try await userDocRef.getDocument()
                var existingCalendarEvents = snapshot.data()?["calendarEvents"] as? [String: [String: Any]] ?? [:]
                
                var updatedCalendarEvents: [String: [String: Any]] = [:]
                for event in events {
                    let eventId = event.eventIdentifier ?? UUID().uuidString
                    updatedCalendarEvents[eventId] = [
                        "title": event.title ?? "No Title",
                        "startDate": event.startDate,
                        "endDate": event.endDate
                    ]
                }
                
                for eventId in existingCalendarEvents.keys {
                    if updatedCalendarEvents[eventId] == nil {
                        existingCalendarEvents.removeValue(forKey: eventId)
                    }
                }
                
                for (eventId, eventData) in updatedCalendarEvents {
                    existingCalendarEvents[eventId] = eventData
                }
                
                try await userDocRef.setData(["calendarEvents": existingCalendarEvents], merge: true)
            } catch {
                print("Error syncing events: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Firestore User Management
    
    /// Fetches the user profile data from Firestore.
    func fetchUserProfile() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "No User Logged In", code: 401, userInfo: nil)
        }

        let userDocRef = db.collection("users").document(currentUser.uid)
        let snapshot = try await userDocRef.getDocument()
        guard let data = snapshot.data() else { return }

        DispatchQueue.main.async {
            self.userName = data["userName"] as? String ?? "Unknown"
            self.firstName = data["firstName"] as? String ?? "Unknown"
            self.lastName = data["lastName"] as? String ?? "Unknown"
            self.email = data["email"] as? String ?? "Unknown"
            self.dnd = data["dnd"] as? Bool ?? false
        }
    }
    
    /// Updates the "Do Not Disturb" (DND) status in Firestore.
    func updateDNDStatus(isDND: Bool) async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(currentUser.uid)
        try await userDocRef.updateData(["dnd": isDND])
    }
    
    /// Deletes the user profile and removes references from other users' friend lists.
    func deleteProfileAndCleanup(userId: String) async throws {
        let userDocRef = db.collection("users").document(userId)
        try await userDocRef.delete()
        
        let usersSnapshot = try await db.collection("users").getDocuments()
        for document in usersSnapshot.documents {
            var friends = document.data()["friends"] as? [String] ?? []
            if friends.contains(userId) {
                friends.removeAll { $0 == userId }
                try await db.collection("users").document(document.documentID).updateData(["friends": friends])
            }
        }
    }
    
    /// Saves the user profile data to Firestore.
    func saveUserProfile() async throws {
        try await db.collection("users").document(Auth.auth().currentUser!.uid).setData([
            "firstName": firstName,
            "lastName": lastName,
            "userName": userName,
            "email": email,
            "status": "Available",
            "friends": friends
        ], merge: true)
        
        fetchUpcomingMonthEvents()
    }
    
    // MARK: - Cleanup
    
    /// Removes observers when the object is deinitialized.
    deinit {
        NotificationCenter.default.removeObserver(self, name: .EKEventStoreChanged, object: eventStore)
    }
}
