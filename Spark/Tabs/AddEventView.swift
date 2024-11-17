//
//  AddEventView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

struct FriendsAvailabilityView: View {
    @ObservedObject var viewModel = AvailabilityViewModel()

    var body: some View {
        List {
            Section(header: Text("Free Now")) {
                ForEach(viewModel.friendsAvailability.filter { $0.status == .free }) { friend in
                    AvailabilityRow(friend: friend)
                }
            }
            Section(header: Text("Almost Busy")) {
                ForEach(viewModel.friendsAvailability.filter { $0.status == .almostBusy }) { friend in
                    AvailabilityRow(friend: friend)
                }
            }
            Section(header: Text("Busy Now")) {
                ForEach(viewModel.friendsAvailability.filter { $0.status == .busy }) { friend in
                    AvailabilityRow(friend: friend)
                }
            }
        }
        .navigationTitle("Friends' Availability")
        .onAppear {
            viewModel.updateAvailabilityStatus() // Fetch and update on view load
        }
    }
}

struct AvailabilityRow: View {
    let friend: UserAvailability
    
    var body: some View {
        HStack {
            Circle()
                .fill(colorForStatus(friend.status))
                .frame(width: 10, height: 10)
            
            Text(friend.userId)
            Spacer()
            
            if friend.status != .free {
                Text("Free at \(formattedTime(friend.nextAvailableAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func colorForStatus(_ status: AvailabilityStatus) -> Color {
        switch status {
        case .free: return .green
        case .almostBusy: return .yellow
        case .busy: return .red
        }
    }
    
    private func formattedTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
