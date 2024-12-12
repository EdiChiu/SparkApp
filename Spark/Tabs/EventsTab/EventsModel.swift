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
    let participantsUIDs: [String] // All participants
    var acceptedParticipants: [String] // UIDs of participants who accepted
    var deniedParticipants: [String] // UIDs of participants who denied
    var pendingParticipants: [String] // UIDs of participants who haven't responded
}
