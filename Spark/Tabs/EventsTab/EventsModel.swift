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
    let creationTime: Date // Add this property
    let participantsUIDs: [String] // All participants
}
