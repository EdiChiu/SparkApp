//
//  EventsViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/9/24.

import Foundation
import FirebaseFirestore
import FirebaseAuth

class EventsViewModel: ObservableObject {
    @Published var userEvents: [UserEvent] = []
    @Published var pendingEvents: [UserEvent] = []
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
                self?.pendingEvents = (self?.parseEvents(from: data["pendingEvents"]) ?? [])
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
                let duration = dict["duration"] as? Int,
                let creatorUID = dict["creatorUID"] as? String,
                let participantsUIDs = dict["participantsUIDs"] as? [String],
                let acceptedParticipants = dict["acceptedParticipants"] as? [String],
                let deniedParticipants = dict["deniedParticipants"] as? [String],
                let pendingParticipants = dict["pendingParticipants"] as? [String],
                let creationTimestamp = dict["creationTime"] as? Timestamp
            else {
                return nil
            }
            
            let creationTime = creationTimestamp.dateValue()

            return UserEvent(
                id: id,
                title: title,
                location: location,
                description: description,
                duration: duration,
                creatorUID: creatorUID,
                creationTime: creationTime,
                participantsUIDs: participantsUIDs,
                acceptedParticipants: acceptedParticipants,
                deniedParticipants: deniedParticipants,
                pendingParticipants: pendingParticipants
            )
        }
    }

    func addEvent(event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        var updatedEvent = event
        updatedEvent.pendingParticipants = event.participantsUIDs.filter { $0 != currentUser.uid }
        updatedEvent.acceptedParticipants = []
        updatedEvent.deniedParticipants = []

        let eventData = createEventData(from: updatedEvent)

        // Add event to creator's Firestore data
        db.collection("users").document(currentUser.uid).updateData([
            "userEvents": FieldValue.arrayUnion([eventData])
        ]) { error in
            if let error = error {
                print("Error adding event for creator: \(error.localizedDescription)")
            }
        }

        // Add event to participants' Firestore data
        for participantUID in updatedEvent.pendingParticipants {
            db.collection("users").document(participantUID).updateData([
                "pendingEvents": FieldValue.arrayUnion([eventData])
            ]) { error in
                if let error = error {
                    print("Error adding event for participant \(participantUID): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func acceptEvent(event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        var updatedEvent = event
        updatedEvent.pendingParticipants.removeAll { $0 == currentUser.uid }
        updatedEvent.acceptedParticipants.append(currentUser.uid)

        let eventData = createEventData(from: updatedEvent)

        db.collection("users").document(currentUser.uid).updateData([
            "pendingEvents": FieldValue.arrayRemove([createEventData(from: event)])
        ]) { error in
            if let error = error {
                print("Error removing from pendingEvents: \(error.localizedDescription)")
            } else {
                self.db.collection("users").document(currentUser.uid).updateData([
                    "userEvents": FieldValue.arrayUnion([eventData])
                ]) { error in
                    if let error = error {
                        print("Error adding to userEvents: \(error.localizedDescription)")
                    }
                }
            }
        }

        db.collection("users").document(event.creatorUID).updateData([
            "userEvents": FieldValue.arrayRemove([createEventData(from: event)])
        ]) { error in
            if let error = error {
                print("Error removing from creator's userEvents: \(error.localizedDescription)")
            } else {
                self.db.collection("users").document(event.creatorUID).updateData([
                    "userEvents": FieldValue.arrayUnion([eventData])
                ]) { error in
                    if let error = error {
                        print("Error updating creator's userEvents: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func denyEvent(event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        var updatedEvent = event
        updatedEvent.pendingParticipants.removeAll { $0 == currentUser.uid }
        updatedEvent.deniedParticipants.append(currentUser.uid)

        let eventData = createEventData(from: updatedEvent)

        db.collection("users").document(currentUser.uid).updateData([
            "pendingEvents": FieldValue.arrayRemove([createEventData(from: event)])
        ]) { error in
            if let error = error {
                print("Error removing from pendingEvents: \(error.localizedDescription)")
            } else {
                self.db.collection("users").document(currentUser.uid).updateData([
                    "userEvents": FieldValue.arrayUnion([eventData])
                ]) { error in
                    if let error = error {
                        print("Error adding to userEvents: \(error.localizedDescription)")
                    }
                }
            }
        }

        db.collection("users").document(event.creatorUID).updateData([
            "userEvents": FieldValue.arrayRemove([createEventData(from: event)])
        ]) { error in
            if let error = error {
                print("Error removing from creator's userEvents: \(error.localizedDescription)")
            } else {
                self.db.collection("users").document(event.creatorUID).updateData([
                    "userEvents": FieldValue.arrayUnion([eventData])
                ]) { error in
                    if let error = error {
                        print("Error updating creator's userEvents: \(error.localizedDescription)")
                    }
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
            "creationTime": Timestamp(date: event.creationTime),
            "pendingParticipants": event.pendingParticipants,
            "acceptedParticipants": event.acceptedParticipants,
            "deniedParticipants": event.deniedParticipants
        ]
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

    private func checkParticipantAcceptance(eventID: String, uid: String) -> Bool {
        let userDocRef = db.collection("users").document(uid)
        var isAccepted = false

        let semaphore = DispatchSemaphore(value: 0)
        userDocRef.getDocument { snapshot, _ in
            guard let data = snapshot?.data(), let userEvents = data["userEvents"] as? [[String: Any]] else {
                semaphore.signal()
                return
            }

            isAccepted = userEvents.contains { $0["id"] as? String == eventID }
            semaphore.signal()
        }

        semaphore.wait()
        return isAccepted
    }
    
    func respondToEvent(event: UserEvent, accepted: Bool) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let eventData = createEventData(from: event)

        // Update pendingEvents and userEvents for the participant
        db.collection("users").document(currentUser.uid).updateData([
            "pendingEvents": FieldValue.arrayRemove([eventData]),
            "userEvents": accepted ? FieldValue.arrayUnion([eventData]) : FieldValue.arrayUnion([])
        ]) { error in
            if let error = error {
                print("Error responding to event: \(error.localizedDescription)")
            } else {
                print(accepted ? "Event accepted." : "Event denied.")
            }
        }
    }
    
    func fetchParticipantsByStatus(
        acceptedUIDs: [String],
        deniedUIDs: [String],
        pendingUIDs: [String],
        completion: @escaping ([String], [String], [String]) -> Void
    ) {
        var acceptedNames: [String] = []
        var deniedNames: [String] = []
        var pendingNames: [String] = []
        let dispatchGroup = DispatchGroup()

        for uid in acceptedUIDs {
            dispatchGroup.enter()
            fetchUserFullName(uid: uid) { name in
                if let name = name {
                    acceptedNames.append(name)
                }
                dispatchGroup.leave()
            }
        }

        for uid in deniedUIDs {
            dispatchGroup.enter()
            fetchUserFullName(uid: uid) { name in
                if let name = name {
                    deniedNames.append(name)
                }
                dispatchGroup.leave()
            }
        }

        for uid in pendingUIDs {
            dispatchGroup.enter()
            fetchUserFullName(uid: uid) { name in
                if let name = name {
                    pendingNames.append(name)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(acceptedNames, deniedNames, pendingNames)
        }
    }
}
