import Foundation
import EventKit
import FirebaseCore
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var upcomingEvents: [EKEvent] = []
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    private var eventStore = EKEventStore()
    private let db = Firestore.firestore()
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
        requestAccessToCalendar()
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
        let userDocRef = db.collection("users").document(userId)
        
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
    
    func saveUserProfile() async throws {
        // Save the user's basic profile data
        try await db.collection("users").document(userId).setData([
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "status": "active"
        ], merge: true)
        
        // Fetch and save calendar events
        fetchUpcomingMonthEvents()  // Fetch events for a month when the profile is saved
    }
    
    deinit {
        // No need for observer removal, as we don't subscribe to event changes anymore
    }
    
    
}
