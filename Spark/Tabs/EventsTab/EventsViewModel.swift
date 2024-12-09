//
//  EventsViewModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/9/24.
//

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

            self?.userEvents = self?.parseEvents(from: data["userEvents"]) ?? []
            self?.pendingEvents = self?.parseEvents(from: data["pendingEvents"]) ?? []
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

        let userDocRef = db.collection("users").document(currentUser.uid)
        do {
            let eventData: [String: Any] = [
                "id": event.id,
                "title": event.title,
                "location": event.location,
                "description": event.description,
                "duration": event.duration,
                "creatorUID": event.creatorUID,
                "participantsUIDs": event.participantsUIDs,
                "status": event.status.rawValue
            ]
            
            try userDocRef.updateData([
                "userEvents": FieldValue.arrayUnion([eventData])
            ])
        } catch {
            print("Error adding event: \(error.localizedDescription)")
        }
    }
}
