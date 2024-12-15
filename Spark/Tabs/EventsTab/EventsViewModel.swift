////
////  EventsViewModel.swift
////  Spark
////
////  Created by Edison Chiu on 12/9/24.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//import EventKit
//import EventKitUI
//
//class EventsViewModel: NSObject, ObservableObject, EKEventEditViewDelegate {
//    @Published var userEvents: [UserEvent] = []
//    private let db = Firestore.firestore()
//    private let eventStore = EKEventStore()
//
//    // Fetch events from Firestore and local calendar
//    func fetchEvents() {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        // Fetch Firestore events
//        let userDocRef = db.collection("users").document(currentUser.uid)
//        userDocRef.addSnapshotListener { [weak self] snapshot, error in
//            if let error = error {
//                print("Error fetching events from Firestore: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = snapshot?.data() else { return }
//
//            let firestoreEvents = self?.parseEvents(from: data["userEvents"]) ?? []
//
//            // Fetch events from the local calendar
//            self?.fetchLocalCalendarEvents { calendarEvents in
//                DispatchQueue.main.async {
//                    self?.userEvents = (firestoreEvents + calendarEvents).sorted {
//                        $0.creationTime > $1.creationTime
//                    }
//                }
//            }
//        }
//    }
//
//    // Fetch events from the local calendar
//    private func fetchLocalCalendarEvents(completion: @escaping ([UserEvent]) -> Void) {
//        let calendars = eventStore.calendars(for: .event)
//        let startDate = Date()
//        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
//
//        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
//        let events = eventStore.events(matching: predicate)
//
//        let userEvents = events.map { event in
//            UserEvent(
//                id: event.eventIdentifier,
//                title: event.title ?? "Untitled Event",
//                location: event.location ?? "",
//                description: event.notes ?? "",
//                duration: Int(event.endDate.timeIntervalSince(event.startDate)),
//                creatorUID: Auth.auth().currentUser?.uid ?? "",
//                creationTime: event.startDate,
//                participantsUIDs: [] // Extend logic to fetch attendees if necessary
//            )
//        }
//
//        completion(userEvents)
//    }
//
//    // Parse events from Firestore
//    private func parseEvents(from data: Any?) -> [UserEvent] {
//        guard let eventDictionaries = data as? [[String: Any]] else { return [] }
//
//        return eventDictionaries.compactMap { dict in
//            guard
//                let id = dict["id"] as? String,
//                let title = dict["title"] as? String,
//                let location = dict["location"] as? String,
//                let description = dict["description"] as? String,
//                let duration = dict["duration"] as? Int,
//                let creatorUID = dict["creatorUID"] as? String,
//                let participantsUIDs = dict["participantsUIDs"] as? [String],
//                let creationTimestamp = dict["creationTime"] as? Timestamp
//            else { return nil }
//
//            let creationTime = creationTimestamp.dateValue()
//            return UserEvent(
//                id: id,
//                title: title,
//                location: location,
//                description: description,
//                duration: duration,
//                creatorUID: creatorUID,
//                creationTime: creationTime,
//                participantsUIDs: participantsUIDs
//            )
//        }
//    }
//
//    // Add event to Firestore
//    func addEvent(event: UserEvent) {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let eventData = createEventData(from: event)
//        db.collection("users").document(currentUser.uid).updateData([
//            "userEvents": FieldValue.arrayUnion([eventData])
//        ]) { error in
//            if let error = error {
//                print("Error adding event to Firestore: \(error.localizedDescription)")
//            } else {
//                print("Event added to Firestore.")
//            }
//        }
//    }
//
//    private func createEventData(from event: UserEvent) -> [String: Any] {
//        return [
//            "id": event.id,
//            "title": event.title,
//            "location": event.location,
//            "description": event.description,
//            "duration": event.duration,
//            "creatorUID": event.creatorUID,
//            "participantsUIDs": event.participantsUIDs,
//            "creationTime": Timestamp(date: event.creationTime)
//        ]
//    }
//
//    // MARK: - EKEventEditViewDelegate
//    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
//        defer {
//            controller.dismiss(animated: true)
//        }
//
//        switch action {
//        case .saved:
//            guard let savedEvent = controller.event else { return }
//            let newEvent = UserEvent(
//                id: savedEvent.eventIdentifier,
//                title: savedEvent.title ?? "Untitled Event",
//                location: savedEvent.location ?? "",
//                description: savedEvent.notes ?? "",
//                duration: Int(savedEvent.endDate.timeIntervalSince(savedEvent.startDate)),
//                creatorUID: Auth.auth().currentUser?.uid ?? "",
//                creationTime: Date(),
//                participantsUIDs: [] // Attendees logic can be extended here
//            )
//            addEvent(event: newEvent)
//
//        case .canceled:
//            print("Event creation canceled.")
//
//        case .deleted:
//            print("Event deleted.")
//
//        @unknown default:
//            print("Unknown action occurred.")
//        }
//    }
//
//    func fetchUserFullName(uid: String, completion: @escaping (String?) -> Void) {
//        db.collection("users").document(uid).getDocument { snapshot, error in
//            if let error = error {
//                print("Error fetching user full name: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            if let data = snapshot?.data(),
//               let firstName = data["firstName"] as? String,
//               let lastName = data["lastName"] as? String {
//                completion("\(firstName) \(lastName)")
//            } else {
//                completion(nil)
//            }
//        }
//    }
//
//    func fetchParticipantsNames(uids: [String], completion: @escaping ([String: String]) -> Void) {
//        var namesDictionary: [String: String] = [:]
//        let dispatchGroup = DispatchGroup()
//
//        for uid in uids {
//            dispatchGroup.enter()
//            fetchUserFullName(uid: uid) { name in
//                if let name = name {
//                    namesDictionary[uid] = name
//                }
//                dispatchGroup.leave()
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            completion(namesDictionary)
//        }
//    }
//}

//
//  EventsViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import EventKit
import EventKitUI

class EventsViewModel: NSObject, ObservableObject, EKEventEditViewDelegate {
    @Published var userEvents: [UserEvent] = []
    private let db = Firestore.firestore()
    private let eventStore = EKEventStore()

    // Fetch events from Firestore
    func fetchEvents() {
        guard let currentUser = Auth.auth().currentUser else { return }

        let userDocRef = db.collection("users").document(currentUser.uid)
        userDocRef.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else { return }

            DispatchQueue.main.async {
                let parsedEvents = self?.parseEvents(from: data["userEvents"]) ?? []
                // Sort events by creationTime in descending order (latest first)
                self?.userEvents = parsedEvents.sorted { $0.creationTime > $1.creationTime }
            }
        }
    }
    // Parse events from Firestore
    private func parseEvents(from data: Any?) -> [UserEvent] {
        guard let eventDictionaries = data as? [[String: Any]] else { return [] }

        return eventDictionaries.compactMap { dict in
            guard
                let id = dict["id"] as? String,
                let title = dict["title"] as? String,
                let location = dict["location"] as? String,
                let description = dict["description"] as? String,
                let duration = dict["duration"] as? Int,
                let creatorUID = dict["creatorUID"] as? String,
                let participantsUIDs = dict["participantsUIDs"] as? [String],
                let creationTimestamp = dict["creationTime"] as? Timestamp
            else { return nil }

            let creationTime = creationTimestamp.dateValue()
            return UserEvent(
                id: id,
                title: title,
                location: location,
                description: description,
                duration: duration,
                creatorUID: creatorUID,
                creationTime: creationTime,
                participantsUIDs: participantsUIDs
            )
        }
    }

    // Add event to Firestore
    func addEventToFirestore(event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let eventData = createEventData(from: event)

        // Add the event to the creator's Firestore document
        db.collection("users").document(currentUser.uid).updateData([
            "userEvents": FieldValue.arrayUnion([eventData])
        ]) { error in
            if let error = error {
                print("Error adding event to Firestore for creator: \(error.localizedDescription)")
            } else {
                print("Event successfully added to creator's Firestore.")
            }
        }

        // Add the event to the participants' Firestore documents
        for participantUID in event.participantsUIDs {
            db.collection("users").document(participantUID).updateData([
                "pendingEvents": FieldValue.arrayUnion([eventData]) // Assuming a `pendingEvents` field
            ]) { error in
                if let error = error {
                    print("Error adding event to Firestore for participant \(participantUID): \(error.localizedDescription)")
                } else {
                    print("Event successfully added to participant \(participantUID)'s Firestore.")
                }
            }
        }
    }

    private func createEventData(from event: UserEvent) -> [String: Any] {
        return [
            "id": event.id,
            "title": event.title,
            "location": event.location,
            "description": event.description,
            "duration": event.duration,
            "creatorUID": event.creatorUID,
            "participantsUIDs": event.participantsUIDs,
            "creationTime": Timestamp(date: event.creationTime)
        ]
    }

    // MARK: - EKEventEditViewDelegate
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        defer {
            controller.dismiss(animated: true)
        }

        switch action {
        case .saved:
            guard let savedEvent = controller.event else { return }

            // Create a UserEvent object from the saved EKEvent
            let newEvent = UserEvent(
                id: savedEvent.eventIdentifier,
                title: savedEvent.title ?? "Untitled Event",
                location: savedEvent.location ?? "",
                description: savedEvent.notes ?? "",
                duration: Int(savedEvent.endDate.timeIntervalSince(savedEvent.startDate)),
                creatorUID: Auth.auth().currentUser?.uid ?? "",
                creationTime: Date(),
                participantsUIDs: [] // Update logic for participants if needed
            )

            // Save event to Firestore
            addEventToFirestore(event: newEvent)

            // Fetch updated events from Firestore
            fetchEvents()

        case .canceled:
            print("Event creation canceled.")

        case .deleted:
            print("Event deleted.")

        @unknown default:
            print("Unknown action occurred.")
        }
    }

    func fetchUserFullName(uid: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user full name: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = snapshot?.data(),
               let firstName = data["firstName"] as? String,
               let lastName = data["lastName"] as? String {
                completion("\(firstName) \(lastName)")
            } else {
                completion(nil)
            }
        }
    }

    func fetchParticipantsNames(uids: [String], completion: @escaping ([String: String]) -> Void) {
        var namesDictionary: [String: String] = [:]
        let dispatchGroup = DispatchGroup()

        for uid in uids {
            dispatchGroup.enter()
            fetchUserFullName(uid: uid) { name in
                if let name = name {
                    namesDictionary[uid] = name
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(namesDictionary)
        }
    }
}
