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
    private var userId: String // Unique user ID
    
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
                        // don't need this information for now
//                        "location": event.location ?? "No Location",
//                        "description": event.notes ?? "",
//                        "organizer": event.organizer?.name ?? "Unknown Organizer",
//                        "attendees": event.attendees?.compactMap { $0.name } ?? [],
//                        "calendarId": event.calendar.calendarIdentifier
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
//import Foundation
//import EventKit
//import FirebaseCore
//import FirebaseFirestore
//
//class ProfileViewModel: ObservableObject {
//    @Published var upcomingEvents: [EKEvent] = []
//    @Published var firstName: String = ""
//    @Published var lastName: String = ""
//    @Published var email: String = ""
//    private var eventStore = EKEventStore()
//    private let db = Firestore.firestore()
//    
//    init() {
//        requestAccessToCalendar()
//        subscribeToEventChanges()
//    }
//    
//    private func requestAccessToCalendar() {
//        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                if granted {
//                    self.fetchUpcomingWeekEvents()
//                } else {
//                    print("Calendar access denied: \(error?.localizedDescription ?? "No error")")
//                }
//            }
//        }
//
//        if #available(iOS 17.0, *) {
//            eventStore.requestFullAccessToEvents(completion: completionHandler)
//        } else {
//            eventStore.requestAccess(to: .event, completion: completionHandler)
//        }
//    }
//
//    private func subscribeToEventChanges() {
//        NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged), name: .EKEventStoreChanged, object: eventStore)
//    }
//
//    @objc private func eventStoreChanged(_ notification: Notification) {
//        fetchUpcomingWeekEvents()
//    }
//
//    func fetchUpcomingWeekEvents() {
//        let calendar = Calendar.current
//        let today = Date()
//        guard let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) else { return }
//        
//        let predicate = eventStore.predicateForEvents(withStart: today, end: nextWeek, calendars: nil)
//        let events = eventStore.events(matching: predicate)
//        DispatchQueue.main.async {
//            self.upcomingEvents = events
//            self.syncEventsWithFirestore(events: events)
//        }
//    }
//    
//    func syncEventsWithFirestore(events: [EKEvent]) {
//        let userId = "testUser" // Replace with dynamic user ID if available
//        
//        // Prepare event data to store as a Firestore map
//        let eventsMap: [String: [String: Any]] = events.reduce(into: [:]) { result, event in
//            result[event.eventIdentifier ?? UUID().uuidString] = [
//                "title": event.title ?? "No Title",
//                "startDate": event.startDate,
//                "endDate": event.endDate,
//                "location": event.location ?? "No Location",
//                "description": event.notes ?? "",
//                "organizer": event.organizer?.name ?? "Unknown Organizer",
//                "attendees": event.attendees?.compactMap { $0.name } ?? [],
//                "calendarId": event.calendar.calendarIdentifier
//            ]
//        }
//        
//        // Update only the `calendarEvents` field in Firestore
//        Task {
//            do {
//                try await db.collection("users").document(userId).setData([
//                    "calendarEvents": eventsMap
//                ], merge: true)
//                print("Calendar events updated successfully!")
//            } catch {
//                print("Error updating calendar events: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func saveUserProfile(userId: String) async throws {
//        // Save the user's basic profile data
//        try await db.collection("users").document(userId).setData([
//            "firstName": firstName,
//            "lastName": lastName,
//            "email": email,
//            "status": "active"
//        ], merge: true)
//        
//        // Fetch and save calendar events
//        fetchUpcomingWeekEvents()
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .EKEventStoreChanged, object: eventStore)
//    }
//}
