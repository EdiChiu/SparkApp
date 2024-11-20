//
//  SignUpView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var email = "";
    @State private var password = "";
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.system(size: 40, weight: .bold))
                .offset(x: -90, y: -200)
            
            TextField("Email", text: $email)
                .foregroundColor(.black)
                .textFieldStyle(.plain)
                .placeholder(when: email.isEmpty) {
                    Text("Email")
                        .foregroundColor(.black)
                        .bold()
                }
            
            Rectangle()
                .frame(width: 350, height:1)
                .foregroundColor(.black)
            
            SecureField("Password", text: $password)
                .foregroundColor(.black)
                .textFieldStyle(.plain)
                .placeholder(when: password.isEmpty) {
                    Text("Password")
                        .foregroundColor(.black)
                        .bold()
                }
            
            Rectangle()
                .frame(width: 350, height:1)
                .foregroundColor(.black)
            
            Button {
                register()
            } label: {
                    Text("Sign up")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottomTrailing))
                        )
                        .foregroundColor(.white)
                }
            .padding(.top)
            .offset(y: 100)
            Button {
                login()
            } label: {
                Text("Already have an account? Login")
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding(.top)
            .offset(y: 110)

        }
        .frame(width: 350)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                isLoggedIn = true
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                isLoggedIn = true
            }
        }
    }
}


#Preview {
    SignUpView()
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
