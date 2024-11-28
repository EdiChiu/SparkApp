//
//  NewProfileView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/26/24.
//

import SwiftUI

@MainActor
final class NewProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AuthDataResultModel? = nil
    
    func loadCurrentUser() throws {
        self.user = try AuthenticationManager.shared.getAuthenticatedUser()
    }
    
}

struct NewProfileView: View {
    
    @StateObject private var viewModel = NewProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.uid)")
            }
        }
        .onAppear {
            try? viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                        .foregroundColor(Color.blue)
                }

            }
        }
    }
}

struct NewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewProfileView(showSignInView: .constant(false))
        }
    }
}
