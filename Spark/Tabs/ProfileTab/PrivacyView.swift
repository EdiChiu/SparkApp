//
//  PrivacyView.swift
//  Spark
//
//  Created by Diego Lagunas on 12/11/24.
//
//  Description:
//  This file defines the PrivacyView, a SwiftUI view that presents the app's privacy policy,
//  data usage, permissions, and contact information in a clean and readable layout.
//

import SwiftUI

// MARK: - PrivacyView

/// A view that displays the privacy policy, permissions, and contact information for the Spark app.
struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title Section
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                
                // Data Usage Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Data Usage")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("At Spark, we value your privacy and are committed to protecting your personal information. To provide you with the best experience, we collect the following data:")
                        .font(.body)
                    
                    Text("1. **Calendar Information**: We collect calendar information to help you schedule events seamlessly.")
                        .font(.body)
                        .padding(.leading)
                    
                    Text("2. **Email Address**: Your email address is collected for account creation and communication purposes.")
                        .font(.body)
                        .padding(.leading)
                }
                
                // Permissions Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Permissions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("To ensure the app functions as intended, we request the following permissions:")
                        .font(.body)
                    
                    Text("1. **Calendar Access**: Granting calendar access ensures Spark can integrate your schedule for seamless event planning.")
                        .font(.body)
                        .padding(.leading)
                }
                
                // Contact Information Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Contact Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("If you have any questions, concerns, or feedback regarding our privacy policies, please feel free to contact us at:")
                        .font(.body)
                    
                    Text("📧 **general@sparkapp.com**")
                        .font(.body)
                        .foregroundColor(.blue)
                }
                
                Spacer() // Pushes content up
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline) // Keeps navigation title inline for better UI
    }
}

// MARK: - Preview

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrivacyView()
        }
    }
}
