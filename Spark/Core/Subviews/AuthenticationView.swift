//
//  AuthenticationView.swift
//  Spark
//
//  Created by Diego Lagunas on 11/15/24.
//
import SwiftUI

struct AuthenticationView: View {
    var onAuthFlowChange: (RootView.AuthFlow) -> Void
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 40) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            VStack(spacing: 25) {
               
                Button {
                    onAuthFlowChange(.signIn)
                } label: {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                Button {
                    onAuthFlowChange(.signUp)
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
            }

            Spacer()
        }
        .padding()
        .padding(.top, 135)
        .navigationBarHidden(true)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(onAuthFlowChange: { _ in })
        }
    }
}




