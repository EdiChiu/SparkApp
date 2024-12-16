//
//  UserModel.swift
//  Spark
//
//  Created by Edison Chiu on 11/29/24.
//
//  Description:
//  This file defines the data models used across the Spark application, including the
//  UserProfile, CalendarEvent, and Friend structures. These models represent the
//  user data, events, and friend-related information for Firestore storage and retrieval.
//

import Foundation

// MARK: - UserProfile Model

/// Represents a user's profile data.
///
/// This model conforms to `Codable` to facilitate easy encoding and decoding
/// when interacting with Firestore or other data sources.
struct UserProfile: Codable {
    /// User's first name
    var firstName: String
    
    /// User's last name
    var lastName: String
    
    /// User's chosen username
    var userName: String
    
    /// User's email address
    var email: String
    
    /// User's current status (e.g., "Available" or "Busy")
    var status: String
    
    /// Indicates if the user has enabled "Do Not Disturb" mode
    var dnd: Bool
    
    /// List of calendar events associated with the user
    var calendarEvents: [CalendarEvent] = []
    
    /// List of friend UIDs associated with the user
    var friends: [String] = []
}

// MARK: - CalendarEvent Model

/// Represents an event in a user's calendar.
///
/// This model conforms to `Codable` to allow seamless storage and retrieval
/// of calendar events from Firestore or other sources.
struct CalendarEvent: Codable {
    /// Unique identifier for the calendar event
    var eventId: String
    
    /// Title or name of the event
    var title: String
    
    /// Start date and time of the event
    var startDate: Date
    
    /// End date and time of the event
    var endDate: Date
}

// MARK: - Friend Model

/// Represents a friend's details.
///
/// This model is used to display a friend's information, including their status.
struct Friend {
    /// Unique identifier for the friend
    let uid: String
    
    /// Full name of the friend
    let name: String
    
    /// Current status of the friend (e.g., "Available", "Busy")
    let status: String
}
