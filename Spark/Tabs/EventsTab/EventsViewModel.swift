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
                // Parse and sort events by creationTime descending
                self?.userEvents = (self?.parseEvents(from: data["userEvents"]) ?? [])
                    .sorted { $0.creationTime > $1.creationTime }
            }
        }
    }

    private func parseEvents(from data: Any?) -> [UserEvent] {
        guard let eventDictionaries = data as? [[String: Any]] else {
            return []
        }

        return eventDictionaries.compactMap { dict in
            guard
                let id = dict["id"] as? String,
                let title = dict["title"] as? String,
                let location = dict["location"] as? String,
                let description = dict["description"] as? String,
                let creatorUID = dict["creatorUID"] as? String,
                let participantsUIDs = dict["participantsUIDs"] as? [String],
                let startTime = (dict["startTime"] as? Timestamp)?.dateValue(),
                let endTime = (dict["endTime"] as? Timestamp)?.dateValue(),
                let creationTime = (dict["creationTime"] as? Timestamp)?.dateValue()
            else {
                return nil
            }

            return UserEvent(
                id: id,
                title: title,
                location: location,
                description: description,
                creatorUID: creatorUID,
                startTime: startTime,
                endTime: endTime,
                creationTime: creationTime,
                participantsUIDs: participantsUIDs
            )
        }
    }

    func addEvent(event: UserEvent, viewController: UIViewController) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No current user is logged in.")
            return
        }

        // Ensure participantsUIDs is not empty
        guard !event.participantsUIDs.isEmpty else {
            print("Error: participantsUIDs is empty.")
            return
        }

        // Construct event data for Firestore
        let eventData: [String: Any] = [
            "id": event.id,
            "title": event.title,
            "location": event.location,
            "description": event.description,
            "creatorUID": event.creatorUID,
            "startTime": Timestamp(date: event.startTime),
            "endTime": Timestamp(date: event.endTime),
            "creationTime": Timestamp(date: event.creationTime),
            "participantsUIDs": event.participantsUIDs
        ]

        // Add event to creator's Firestore document
        db.collection("users").document(currentUser.uid).updateData([
            "userEvents": FieldValue.arrayUnion([eventData])
        ]) { error in
            if let error = error {
                print("Error adding event for creator: \(error.localizedDescription)")
            } else {
                print("Event successfully added to creator's Firestore document.")
            }
        }

        // Add event to each participant's Firestore document
        for participantUID in event.participantsUIDs {
            db.collection("users").document(participantUID).updateData([
                "userEvents": FieldValue.arrayUnion([eventData])
            ]) { error in
                if let error = error {
                    print("Error adding event for participant \(participantUID): \(error.localizedDescription)")
                } else {
                    print("Event successfully added to participant \(participantUID)'s Firestore document.")
                }
            }
        }

        // Present the Apple Calendar event editor
        createAppleCalendarEvent(event: event, viewController: viewController)
    }
    private func createAppleCalendarEvent(event: UserEvent, viewController: UIViewController) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { granted, error in
            if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    let calendarEvent = EKEvent(eventStore: eventStore)
                    calendarEvent.title = event.title
                    calendarEvent.location = event.location
                    calendarEvent.startDate = event.startTime
                    calendarEvent.endDate = event.endTime
                    calendarEvent.notes = event.description
                    calendarEvent.calendar = eventStore.defaultCalendarForNewEvents

                    let eventEditVC = EKEventEditViewController()
                    eventEditVC.event = calendarEvent
                    eventEditVC.eventStore = eventStore
                    eventEditVC.editViewDelegate = self

                    viewController.present(eventEditVC, animated: true)
                }
            } else {
                print("Calendar access not granted.")
            }
        }
    }

    // MARK: - EKEventEditViewDelegate
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        defer {
            controller.dismiss(animated: true)
        }

        switch action {
        case .saved:
            if let savedEvent = controller.event {
                print("Event saved: \(savedEvent.title ?? "No Title")")

                // Create a UserEvent object to sync with Firestore
                let newUserEvent = UserEvent(
                    id: UUID().uuidString,
                    title: savedEvent.title ?? "Untitled Event",
                    location: savedEvent.location ?? "",
                    description: savedEvent.notes ?? "",
                    creatorUID: Auth.auth().currentUser?.uid ?? "",
                    startTime: savedEvent.startDate,
                    endTime: savedEvent.endDate,
                    creationTime: Date(),
                    participantsUIDs: [] // You can handle invitees separately
                )

                addEventToFirestore(newUserEvent)
            }
        case .canceled:
            print("Event editing canceled")
        case .deleted:
            print("Event deleted")
        @unknown default:
            print("Unknown action occurred in event editor")
        }
    }

    private func addEventToFirestore(_ event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let eventData: [String: Any] = [
            "id": event.id,
            "title": event.title,
            "location": event.location,
            "description": event.description,
            "creatorUID": event.creatorUID,
            "startTime": Timestamp(date: event.startTime),
            "endTime": Timestamp(date: event.endTime),
            "creationTime": Timestamp(date: event.creationTime),
            "participantsUIDs": event.participantsUIDs
        ]

        // Save event to Firestore
        db.collection("users").document(currentUser.uid).updateData([
            "userEvents": FieldValue.arrayUnion([eventData])
        ]) { error in
            if let error = error {
                print("Error saving event to Firestore: \(error.localizedDescription)")
            } else {
                print("Event saved to Firestore successfully.")
            }
        }
    }
    
    func fetchUserFullName(uid: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user full name for UID \(uid): \(error.localizedDescription)")
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
