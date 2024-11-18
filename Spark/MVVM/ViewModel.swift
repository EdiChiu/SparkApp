//
//  ViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 11/18/24.
//

import Foundation
import FirebaseFirestore
import EventKit

final class AvailabilityViewModel: ObservableObject {
    private var eventStore = EKEventStore()
    @Published var friendsAvailability: [UserAvailability] = []
    private let db = Firestore.firestore()

    init() {
        requestCalendarAccess()
    }

    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { [weak self] granted, _ in
            if granted {
                self?.updateAvailabilityStatus()
            }
        }
    }

    // Fetches all events for a given date, checks statuses, and updates Firebase
    func updateAvailabilityStatus() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let predicate = eventStore.predicateForEvents(withStart: today, end: tomorrow, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        // Assume current user; extend this for friends' data as needed
        let availabilityStatus = determineAvailabilityStatus(events: events)
        
        let userAvailability = UserAvailability(
            userId: "currentUserId",
            status: availabilityStatus.status,
            nextAvailableAt: availabilityStatus.nextAvailableAt
        )
        
        // Store availability status in Firebase
        storeAvailabilityInFirebase(userAvailability)
    }
    
    private func determineAvailabilityStatus(events: [EKEvent]) -> (status: AvailabilityStatus, nextAvailableAt: Date?) {
        let now = Date()
        for event in events {
            if event.startDate <= now && event.endDate >= now {
                return (.busy, event.endDate) // Currently in an event
            } else if let almostBusyTime = Calendar.current.date(byAdding: .minute, value: -30, to: event.startDate), almostBusyTime <= now {
                return (.almostBusy, event.startDate) // Close to next event
            }
        }
        return (.free, nil) // No events soon, user is free
    }
    
    private func storeAvailabilityInFirebase(_ userAvailability: UserAvailability) {
        let data = [
            "userId": userAvailability.userId,
            "status": userAvailability.status.rawValue,
            "nextAvailableAt": userAvailability.nextAvailableAt?.timeIntervalSince1970 ?? NSNull()
        ] as [String : Any]
        
        db.collection("userAvailability").document(userAvailability.userId).setData(data) { error in
            if let error = error {
                print("Error saving availability data: \(error)")
            } else {
                print("Availability data successfully saved!")
            }
        }
    }
}
