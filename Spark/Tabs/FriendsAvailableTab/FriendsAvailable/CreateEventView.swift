////
////  CreateEventView.swift
////  Spark
////
////  Created by Edison Chiu on 12/7/24.
////
//
//import SwiftUI
//import FirebaseAuth
//
//struct CreateEventScreen: View {
//    @State private var eventName: String = ""
//    @State private var location: String = ""
//    @State private var description: String = ""
//    @State private var startTime: Date = Date() // Default to current time
//    @State private var endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())! // Default to 1 hour later
//    var selectedFriends: [String] // Array of selected friend UIDs
//    @EnvironmentObject var viewModel: FriendsAvailableViewModel
//    @EnvironmentObject var eventsViewModel: EventsViewModel
//
//    @Environment(\.presentationMode) var presentationMode
//
//    @State private var currentViewController: UIViewController?
//
//    private var isFormComplete: Bool {
//        !eventName.isEmpty &&
//        !location.isEmpty &&
//        !description.isEmpty &&
//        !selectedFriends.isEmpty &&
//        startTime < endTime // Ensure start time is before end time
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 25) {
//                Text("Create New Event")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .padding(.top)
//                    .padding(.horizontal, 20)
//
//                // Event Name
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Event Name")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                    TextField("Enter event name", text: $eventName)
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                        )
//                        .textInputAutocapitalization(.words)
//                }
//
//                // Location
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Location")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                    TextField("Enter location", text: $location)
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                        )
//                        .textInputAutocapitalization(.words)
//                }
//
//                // Description
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Description")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                    TextField("Enter description", text: $description, axis: .vertical)
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                        )
//                        .lineLimit(4)
//                }
//
//                // Start and End Time
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Start Time")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                    DatePicker("Select Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
//                        .labelsHidden()
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(12)
//
//                    Text("End Time")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                    DatePicker("Select End Time", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
//                        .labelsHidden()
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(12)
//                }
//
//                // Selected Friends List
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Selected Friends")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//
//                    if selectedFriends.isEmpty {
//                        Text("No friends selected.")
//                            .foregroundColor(.secondary)
//                            .padding()
//                            .background(Color.gray.opacity(0.15))
//                            .cornerRadius(12)
//                    } else {
//                        ScrollView {
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(selectedFriends, id: \.self) { friendUID in
//                                    if let friend = viewModel.friends.first(where: { $0.uid == friendUID }) {
//                                        HStack {
//                                            Text(friend.name)
//                                                .font(.body)
//                                            Spacer()
//                                        }
//                                        .padding()
//                                        .background(Color.orange.opacity(0.15))
//                                        .cornerRadius(12)
//                                    }
//                                }
//                            }
//                        }
//                        .frame(maxHeight: 150)
//                    }
//                }
//
//                // Submit Button
//                Button(action: {
//                    createEvent()
//                }) {
//                    Text("Create Event")
//                        .foregroundColor(.white)
//                        .fontWeight(.bold)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(isFormComplete ? Color.orange : Color.gray.opacity(0.4))
//                        .cornerRadius(12)
//                        .shadow(radius: isFormComplete ? 4 : 0)
//                }
//                .disabled(!isFormComplete)
//                .padding(.bottom, 20)
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 10)
//            .padding(.bottom, 80)
//
//            // Embed the view controller resolver to capture the UIViewController
//            ViewControllerResolver { viewController in
//                self.currentViewController = viewController
//            }
//        }
//        .background(Color(.systemGroupedBackground))
//        .edgesIgnoringSafeArea(.bottom)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    private func createEvent() {
//        guard let currentViewController = currentViewController else {
//            print("ViewController not available")
//            return
//        }
//
//        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
//
//        let newEvent = UserEvent(
//            id: UUID().uuidString,
//            title: eventName,
//            location: location,
//            description: description,
//            creatorUID: currentUserUID,
//            startTime: startTime,
//            endTime: endTime,
//            creationTime: Date(),
//            participantsUIDs: selectedFriends
//        )
//
//        eventsViewModel.addEvent(event: newEvent, viewController: currentViewController)
//        resetForm()
//        viewModel.resetSelectedFriends() // Reset the friends selection
//        presentationMode.wrappedValue.dismiss()
//    }
//
//    private func resetForm() {
//        eventName = ""
//        location = ""
//        description = ""
//        startTime = Date()
//        endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
//    }
//}
//struct ViewControllerResolver: UIViewControllerRepresentable {
//    var onResolve: (UIViewController) -> Void
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        DispatchQueue.main.async {
//            self.onResolve(viewController)
//        }
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}
