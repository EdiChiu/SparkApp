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
//
//class EventsViewModel: ObservableObject {
//    @Published var userEvents: [UserEvent] = []
//    @Published var pendingEvents: [UserEvent] = []
//
//    private let db = Firestore.firestore()
//
//    func fetchEvents() {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let userDocRef = db.collection("users").document(currentUser.uid)
//        userDocRef.addSnapshotListener { [weak self] snapshot, error in
//            if let error = error {
//                print("Error fetching events: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = snapshot?.data() else { return }
//
//            // Parse events from Firestore
//            self?.userEvents = self?.parseEvents(from: data["userEvents"]) ?? []
//            self?.pendingEvents = self?.parseEvents(from: data["pendingEvents"]) ?? []
//        }
//    }
//
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
//                let statusRaw = dict["status"] as? String,
//                let status = EventStatus(rawValue: statusRaw)
//            else {
//                return nil
//            }
//
//            return UserEvent(
//                id: id,
//                title: title,
//                location: location,
//                description: description,
//                duration: duration,
//                creatorUID: creatorUID,
//                participantsUIDs: participantsUIDs,
//                status: status
//            )
//        }
//    }
//
//    func addEvent(event: UserEvent) {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let userDocRef = db.collection("users").document(currentUser.uid)
//        let eventData = createEventData(from: event)
//
//        userDocRef.getDocument { snapshot, error in
//            if let error = error {
//                print("Error fetching user document: \(error.localizedDescription)")
//                return
//            }
//
//            if let data = snapshot?.data(), data["userEvents"] != nil {
//                // If the `userEvents` field exists, update it
//                userDocRef.updateData([
//                    "userEvents": FieldValue.arrayUnion([eventData])
//                ]) { error in
//                    if let error = error {
//                        print("Error adding event to existing userEvents: \(error.localizedDescription)")
//                    } else {
//                        print("Event successfully added to existing userEvents.")
//                    }
//                }
//            } else {
//                // If the `userEvents` field doesn't exist, create it
//                userDocRef.setData([
//                    "userEvents": [eventData]
//                ], merge: true) { error in
//                    if let error = error {
//                        print("Error initializing userEvents and adding event: \(error.localizedDescription)")
//                    } else {
//                        print("userEvents initialized and event successfully added.")
//                    }
//                }
//            }
//        }
//    }
//
//    func addPendingEvent(event: UserEvent, toUserID userID: String) {
//        let userDocRef = db.collection("users").document(userID)
//        let eventData = createEventData(from: event)
//
//        userDocRef.updateData([
//            "pendingEvents": FieldValue.arrayUnion([eventData])
//        ]) { error in
//            if let error = error {
//                print("Error adding event to pendingEvents: \(error.localizedDescription)")
//            } else {
//                print("Event successfully added to pendingEvents.")
//            }
//        }
//    }
//
//    func acceptEvent(event: UserEvent) {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let userDocRef = db.collection("users").document(currentUser.uid)
//        let eventData = createEventData(from: event)
//
//        userDocRef.updateData([
//            "pendingEvents": FieldValue.arrayRemove([eventData]),
//            "userEvents": FieldValue.arrayUnion([eventData])
//        ]) { error in
//            if let error = error {
//                print("Error accepting event: \(error.localizedDescription)")
//            } else {
//                print("Event accepted and moved to userEvents.")
//            }
//        }
//    }
//
//    func denyEvent(event: UserEvent) {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let userDocRef = db.collection("users").document(currentUser.uid)
//        let eventData = createEventData(from: event)
//
//        userDocRef.updateData([
//            "pendingEvents": FieldValue.arrayRemove([eventData])
//        ]) { error in
//            if let error = error {
//                print("Error denying event: \(error.localizedDescription)")
//            } else {
//                print("Event denied and removed from pendingEvents.")
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
//            "status": event.status.rawValue
//        ]
//    }
//}
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
                // Fetch userEvents and pendingEvents
                self?.userEvents = self?.parseEvents(from: data["userEvents"]) ?? []
                self?.pendingEvents = self?.parseEvents(from: data["pendingEvents"]) ?? []
            }
        }
    }

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
                let statusRaw = dict["status"] as? String,
                let status = EventStatus(rawValue: statusRaw)
            else {
                return nil
            }

            return UserEvent(
                id: id,
                title: title,
                location: location,
                description: description,
                duration: duration,
                creatorUID: creatorUID,
                participantsUIDs: participantsUIDs,
                status: status
            )
        }
    }

    func addEvent(event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let eventData = createEventData(from: event)

        // Add event to creator's Firestore data
        db.collection("users").document(currentUser.uid).updateData([
            "userEvents": FieldValue.arrayUnion([eventData])
        ]) { error in
            if let error = error {
                print("Error adding event for creator: \(error.localizedDescription)")
            } else {
                print("Event added for creator.")
            }
        }

        // Add event to participants' Firestore data
        for participantUID in event.participantsUIDs where participantUID != currentUser.uid {
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

        let eventData = createEventData(from: event)

        // Move event from pending to accepted for participant
        db.collection("users").document(currentUser.uid).updateData([
            "pendingEvents": FieldValue.arrayRemove([eventData]),
            "userEvents": FieldValue.arrayUnion([eventData])
        ]) { error in
            if let error = error {
                print("Error accepting event: \(error.localizedDescription)")
            }
        }
    }

    func denyEvent(event: UserEvent) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let eventData = createEventData(from: event)

        // Remove event from pending for participant
        db.collection("users").document(currentUser.uid).updateData([
            "pendingEvents": FieldValue.arrayRemove([eventData])
        ]) { error in
            if let error = error {
                print("Error denying event: \(error.localizedDescription)")
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
            "status": event.status.rawValue
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
    
    func updateEventStatus(for event: UserEvent) {
        let creatorDocRef = db.collection("users").document(event.creatorUID)
        
        creatorDocRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), var userEvents = data["userEvents"] as? [[String: Any]] else { return }

            if let index = userEvents.firstIndex(where: { $0["id"] as? String == event.id }) {
                // Update status if all participants have accepted
                if event.participantsUIDs.allSatisfy({ uid in
                    self.checkParticipantAcceptance(eventID: event.id, uid: uid)
                }) {
                    userEvents[index]["status"] = EventStatus.accepted.rawValue
                } else {
                    userEvents[index]["status"] = EventStatus.pending.rawValue
                }

                creatorDocRef.updateData(["userEvents": userEvents])
            }
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
}
