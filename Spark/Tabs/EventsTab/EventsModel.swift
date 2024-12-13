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
    let creatorUID: String
    let startTime: Date
    let endTime: Date
    let creationTime: Date
    let participantsUIDs: [String] // UIDs of the selected friends
}
