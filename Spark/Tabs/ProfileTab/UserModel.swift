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
    var userName: String
    var email: String
    var status: String
    var dnd: Bool
    var calendarEvents: [CalendarEvent] = []
    var friends: [String] = []
}

struct CalendarEvent: Codable {
    var eventId: String
    var title: String
    var startDate: Date
    var endDate: Date
}
