import Foundation
import EventKit
import FirebaseCore
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var upcomingEvents: [EKEvent] = []
    private var eventStore = EKEventStore()
    private let db = Firestore.firestore()
    
    init() {
        requestAccessToCalendar()
        subscribeToEventChanges()
    }
    
    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.fetchUpcomingWeekEvents()
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

    private func subscribeToEventChanges() {
        // Subscribe to notifications about changes to the event store
        NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged), name: .EKEventStoreChanged, object: eventStore)
    }

    @objc private func eventStoreChanged(_ notification: Notification) {
        // Fetch and sync events when a change occurs in the calendar
        fetchUpcomingWeekEvents()
    }

    func fetchUpcomingWeekEvents() {
        let calendar = Calendar.current
        let today = Date()
        guard let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: today, end: nextWeek, calendars: nil)
        let events = eventStore.events(matching: predicate)
        DispatchQueue.main.async {
            self.upcomingEvents = events
            self.syncEventsWithFirestore(events: events) // Sync events to Firestore
        }
    }
    
    func syncEventsWithFirestore(events: [EKEvent]) {
        let userId = "testUser" // Replace with dynamic user ID if available
        let userEventsCollection = db.collection("users").document(userId).collection("events")
        
        Task {
            do {
                // Fetch existing events from Firestore to compare
                let snapshot = try await userEventsCollection.getDocuments()
                let firestoreEventIds = snapshot.documents.map { $0.documentID }
                
                // Find the event IDs from the Apple Calendar
                let calendarEventIds = events.map { $0.eventIdentifier ?? UUID().uuidString }
                
                // Delete events from Firestore that no longer exist in the calendar
                for firestoreEventId in firestoreEventIds {
                    if !calendarEventIds.contains(firestoreEventId) {
                        try await userEventsCollection.document(firestoreEventId).delete()
                        print("Deleted event with ID: \(firestoreEventId)")
                    }
                }
                
                // Add or update events in Firestore
                for event in events {
                    let eventData: [String: Any] = [
                        "eventId": event.eventIdentifier ?? UUID().uuidString,
                        "title": event.title ?? "No Title",
                        "startDate": event.startDate,
                        "endDate": event.endDate,
                        "location": event.location ?? "No Location",
                        "description": event.notes ?? "",
                        "organizer": event.organizer?.name ?? "Unknown Organizer",
                        "attendees": event.attendees?.compactMap { $0.name } ?? [],
                        "calendarId": event.calendar.calendarIdentifier
                    ]
                    
                    let docId = event.eventIdentifier ?? UUID().uuidString
                    try await userEventsCollection.document(docId).setData(eventData, merge: true)
                }
                
                print("Events successfully synced!")
            } catch {
                print("Error syncing events: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        // Remove observer when the ViewModel is deinitialized
        NotificationCenter.default.removeObserver(self, name: .EKEventStoreChanged, object: eventStore)
    }
}
