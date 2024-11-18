//
//  Model.swift
//  Twine
//
//  Created by Edison Chiu on 11/13/24.
//

import Foundation

struct UserAvailability: Identifiable, Codable {
    let id: String          // Unique identifier for ForEach
    let userId: String      // Unique identifier for the user
    let status: AvailabilityStatus
    let nextAvailableAt: Date?

    init(userId: String, status: AvailabilityStatus, nextAvailableAt: Date?) {
        self.id = userId           // Set id to userId to satisfy Identifiable
        self.userId = userId
        self.status = status
        self.nextAvailableAt = nextAvailableAt
    }
}

enum AvailabilityStatus: String, Codable {
    case free
    case almostBusy
    case busy
}
