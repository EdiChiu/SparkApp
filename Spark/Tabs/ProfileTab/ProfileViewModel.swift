import Foundation
import EventKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var upcomingEvents: [EKEvent] = []
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var friends: [String] = []
    @Published var dnd: Bool = false
    private var eventStore = EKEventStore()
    private let db = Firestore.firestore()
    
    init() {
        requestAccessToCalendar()
        registerForCalendarChanges()
    }
    
    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.fetchUpcomingMonthEvents()  // Fetch events for a month after permission is granted
                } else {
                    print("Calendar access denied: \(error?.localizedDescription ?? "No error")")
                }
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completionHandler)
        } else {
            eventStore.requestAccess(to: .event, completion: completionHandler)
        }
    }

    // Listen for changes in the Apple Calendar
    private func registerForCalendarChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCalendarChange),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    @objc private func handleCalendarChange() {
        print("Apple Calendar changed, syncing with Firestore...")
        fetchUpcomingMonthEvents()
    }

    // Fetch events for the upcoming month
    func fetchUpcomingMonthEvents() {
        let calendar = Calendar.current
        let today = Date()
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: today) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: today, end: nextMonth, calendars: nil)
        let events = eventStore.events(matching: predicate)
        DispatchQueue.main.async {
            self.upcomingEvents = events
            self.syncEventsWithFirestore(events: events) // Sync events to Firestore
        }
    }
    
    func syncEventsWithFirestore(events: [EKEvent]) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User is not logged in. Events will not be synced.")
            return
        }
        
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        Task {
            do {
                // Fetch the existing calendarEvents map from Firestore
                let snapshot = try await userDocRef.getDocument()
                var existingCalendarEvents = snapshot.data()?["calendarEvents"] as? [String: [String: Any]] ?? [:]
                
                // Convert Apple Calendar events into a map
                var updatedCalendarEvents: [String: [String: Any]] = [:]
                
                for event in events {
                    let eventId = event.eventIdentifier ?? UUID().uuidString
                    updatedCalendarEvents[eventId] = [
                        "title": event.title ?? "No Title",
                        "startDate": event.startDate,
                        "endDate": event.endDate,
                    ]
                }
                
                // Remove events from the existing map that are not in the updated calendarEvents
                for eventId in existingCalendarEvents.keys {
                    if updatedCalendarEvents[eventId] == nil {
                        existingCalendarEvents.removeValue(forKey: eventId)
                    }
                }
                
                // Add or update the new events in the map
                for (eventId, eventData) in updatedCalendarEvents {
                    existingCalendarEvents[eventId] = eventData
                }
                
                // Save the merged calendarEvents map back to Firestore
                try await userDocRef.setData(["calendarEvents": existingCalendarEvents], merge: true)
                
                print("Events successfully synced!")
            } catch {
                print("Error syncing events: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteProfileAndCleanup(userId: String) async throws {
        // Reference to Firestore
        let userDocRef = db.collection("users").document(userId)
        
        // Delete the user's profile
        try await userDocRef.delete()
        
        // Remove references from other users' friend lists
        let usersSnapshot = try await db.collection("users").getDocuments()
        for document in usersSnapshot.documents {
            var friends = document.data()["friends"] as? [String] ?? []
            if friends.contains(userId) {
                friends.removeAll { $0 == userId }
                try await db.collection("users").document(document.documentID).updateData(["friends": friends])
            }
        }
    }
    
    func saveUserProfile() async throws {
        // Save the user's basic profile data
        try await db.collection("users").document(Auth.auth().currentUser!.uid).setData([
            "firstName": firstName,
            "lastName": lastName,
            "userName": userName,
            "email": email,
            "status": "Available",
            "friends": friends,
        ], merge: true)
        
        // Fetch and save calendar events
        fetchUpcomingMonthEvents()  // Fetch events for a month when the profile is saved
    }
    
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
            self.dnd = data["dnd"] as? Bool ?? false // Fetch DND
        }
    }

    // Update DND status in Firestore
    func updateDNDStatus(isDND: Bool) async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(currentUser.uid)
        try await userDocRef.updateData(["dnd": isDND])
        print("DND status updated to \(isDND)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .EKEventStoreChanged, object: eventStore)
    }
}
