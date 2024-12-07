//
//  AddUserView.swift
//  Spark
//
//  Created by Edison Chiu on 12/3/24.
//

import SwiftUI
import FirebaseFirestore

struct AddUserView: View {
    @StateObject private var viewModel = AddUserViewModel()
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Add Friends")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Search Bar
                TextField("Search by User Name...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: searchText) { _ in
                        viewModel.filterUsers(by: searchText)
                    }
                
                // Filtered List of Users
                List(viewModel.filteredUsers, id: \.uid) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.userName)
                                .font(.headline)
                                .bold()
                            
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                        
                        Spacer()
                        Button(action: {
                            viewModel.addFriend(to: user.uid)
                        }) {
                            Text("Add Friend")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Spacer()
            }
            .onAppear {
                viewModel.fetchAllUsers()
            }
        }
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
    }
}
