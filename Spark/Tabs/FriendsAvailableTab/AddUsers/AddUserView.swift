//
//  AddUserView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/29/24.
//

import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    let name: String
}

struct AddUserView: View {
    @State private var searchText: String = ""
    @State private var users: [Person] = [
        Person(name: "Alice Johnson"),
        Person(name: "Bob Smith"),
        Person(name: "Charlie Brown"),
        Person(name: "Diana Prince"),
        Person(name: "Ethan Hunt"),
        Person(name: "Fiona Gallagher"),
        Person(name: "George Costanza"),
        Person(name: "Hannah Montana"),
        Person(name: "Isaac Newton"),
        Person(name: "Jessica Jones")
    ]
    
    var filteredUsers: [Person] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredUsers) { user in
                Text(user.name)
            }
            .searchable(text: $searchText, prompt: "Search users...")
            .navigationTitle("Add User")
        }
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
    }
}
