//
//  EventsModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/9/24.
//

import Foundation

struct UserEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let location: String
    let description: String
    let duration: Int // Duration in seconds
    let creatorUID: String
    let participantsUIDs: [String]
    var acceptedUIDs: [String]
    var deniedUIDs: [String]
    var pendingUIDs: [String]
    var status: EventStatus

    init(id: String, title: String, location: String, description: String, duration: Int, creatorUID: String, participantsUIDs: [String], status: EventStatus) {
        self.id = id
        self.title = title
        self.location = location
        self.description = description
        self.duration = duration
        self.creatorUID = creatorUID
        self.participantsUIDs = participantsUIDs
        self.acceptedUIDs = []
        self.deniedUIDs = []
        self.pendingUIDs = participantsUIDs
        self.status = status
    }
}

enum EventStatus: String {
    case pending
    case accepted
    case denied
}
