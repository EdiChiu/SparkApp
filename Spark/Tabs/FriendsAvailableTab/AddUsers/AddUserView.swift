//
//  AddUserView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/29/24.
//

import SwiftUI

struct AddUserView: View {
    @State private var searchText = ""
    @State private var users = ["john_doe", "jane_smith", "alex_brown"] // Example data

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter username", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    // Add search logic here later
                }) {
                    Text("Search")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                List(filteredUsers, id: \.self) { user in
                    HStack {
                        Text(user)
                        Spacer()
                        Button("Add") {
                            // Add user logic here later
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Add Users")
        }
    }

    // Filter users based on search text
    var filteredUsers: [String] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.contains(searchText) }
        }
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
    }
}
