//
//  SettingsView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/19/24.
//
import SwiftUI
struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
            List {
                Button {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Log out")
                        .foregroundColor(.blue)
                }
                
                Button(role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Delete Account")
                }


                
                emailSection
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings")
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false ))
    }
}
extension SettingsView {
    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET!")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Reset Password")
                    .foregroundColor(.blue)
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD RESET!")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Password")
                    .foregroundColor(.blue)
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED!")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Email")
                    .foregroundColor(.blue)
            }
        } header: {
            Text("Email Functions")
        }
    }
}




