//
//  CurrentEventsView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI
import EventKit
import CalendarKit
import EventKitUI

// Step 1: UIViewControllerRepresentable Wrapper
struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController()
    }
    
    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {}
}

// Step 2: CurrentEventsView
struct CurrentEventsView: View {
    var body: some View {
        VStack {
            Text("Calendar")
                .font(.largeTitle)
                .padding()
            
            CalendarViewControllerWrapper()
                .edgesIgnoringSafeArea(.all) // Display calendar view fullscreen
        }
    }
}
