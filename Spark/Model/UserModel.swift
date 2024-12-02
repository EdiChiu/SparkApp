//
//  UserModel.swift
//  Spark
//
//  Created by Edison Chiu on 11/29/24.
//

import Foundation

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var status: String
    var calendarEvents: [CalendarEvent] = []
}

struct CalendarEvent: Codable {
    var eventId: String
    var title: String
    var startDate: Date
    var endDate: Date
}
