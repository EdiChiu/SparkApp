//
//  ProfileViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 11/27/24.
//

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
    }
    
    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.fetchUpcomingWeekEvents()
                }
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completionHandler)
        } else {
            eventStore.requestAccess(to: .event, completion: completionHandler)
        }
    }

    private func fetchUpcomingWeekEvents() {
        let calendar = Calendar.current
        let today = Date()
        guard let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: today, end: nextWeek, calendars: nil)
        let events = eventStore.events(matching: predicate)
        DispatchQueue.main.async {
            self.upcomingEvents = events
            self.saveEventsToFirestore(events: events) // Save events to Firestore
        }
    }
    
    func saveEventsToFirestore(events: [EKEvent]) {
        // Map EKEvent data into an array of dictionarie
        let eventDataArray: [[String: Any]] = events.map { event in
            [
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
        }
        
        Task {
            do {
                // Update the "events" document by appending the event data array
                try await db.collection("events").document("events").setData([
                    "upcomingEvents": FieldValue.arrayUnion(eventDataArray)
                ], merge: true)
                
                print("Events successfully saved!")
            } catch {
                print("Error saving events: \(error.localizedDescription)")
            }
        }
    }
}
