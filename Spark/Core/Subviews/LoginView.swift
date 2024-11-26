//
//  LoginView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//
import SwiftUI
struct LoginView: View {
    
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            NavigationLink {
                SignInView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView(showSignInView: .constant(false))
        }
    }
}



