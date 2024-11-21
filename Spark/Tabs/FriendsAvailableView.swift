//
//  FriendsAvailableView.swift
//  Spark
//
//  Created by 3 GO Participant on 11/18/24.
//

import SwiftUI

struct FriendsAvailableScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            
                HStack {
                    Spacer()
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Spacer()
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.white)

             
                Text("Friends Available")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 10)

            
                HStack(spacing: 15) {
                    NavigationLink(destination: FilteredFriendsListView(title: "Available Friends", statusColor: .green)) {
                        AvailabilityFilterButton(label: "Available", color: .green)
                    }
                    NavigationLink(destination: FilteredFriendsListView(title: "Free Soon Friends", statusColor: .yellow)) {
                        AvailabilityFilterButton(label: "Free Soon", color: .yellow)
                    }
                    NavigationLink(destination: FilteredFriendsListView(title: "Busy Friends", statusColor: .red)) {
                        AvailabilityFilterButton(label: "Busy", color: .red)
                    }
                }
                .padding()

            
                ScrollView {
                    VStack(spacing: 15) {
                        FriendRow(name: "Edison Chiu", statusColor: .green)
                        FriendRow(name: "Diego Lagunas", statusColor: .green)
                        FriendRow(name: "Frank Blackman Jr.", statusColor: .green)
                    }
                    .padding(.horizontal)
                }

                // Create Event Button
                NavigationLink(destination: CreateEventScreen()) {
                    HStack {
                        Text("Create Event")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "plus")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(25)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

// Filtered Friends List View
struct FilteredFriendsListView: View {
    let title: String
    let statusColor: Color

    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            ScrollView {
                VStack(spacing: 15) {
                    FriendRow(name: "Frank Blackman Jr.", statusColor: statusColor)
                    FriendRow(name: "Diego Lagunas", statusColor: statusColor)
                    FriendRow(name: "Edison Chiu", statusColor: statusColor)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(title) // Dynamic title based on the availability
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Create Event Screen
struct CreateEventScreen: View {
    @State private var eventName: String = ""
    @State private var eventDate = Date()
    @State private var location: String = ""
    @State private var description: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Event")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Event Name
            TextField("Event Name", text: $eventName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .textInputAutocapitalization(.words)

            // Event Date
            VStack(alignment: .leading) {
                Text("Event Date:")
                    .font(.headline)
                DatePicker("Select Date", selection: $eventDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
            }

            // Location
            TextField("Location", text: $location)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .textInputAutocapitalization(.words)

            // Description
            TextField("Description", text: $description, axis: .vertical)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .lineLimit(4)

            // Submit Button
            Button(action: {
                // Handle the event creation logic here
                print("Event Created: \(eventName), \(eventDate), \(location), \(description)")
            }) {
                Text("Create Event")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)
            }

            Spacer() // Push content to the top
        }
        .padding()
        .navigationTitle("Create Event") // Title for navigation bar
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Availability Filter Button
struct AvailabilityFilterButton: View {
    var label: String
    var color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

// Friend Row
struct FriendRow: View {
    var name: String
    var statusColor: Color

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: 16, height: 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
    }
}

// Navigation Icon
struct NavigationIcon: View {
    var icon: String

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(.black)
    }
}

// Preview
struct FriendsAvailableScreen_Previews: PreviewProvider {
    static var previews: some View {
        FriendsAvailableScreen()
    }
}

