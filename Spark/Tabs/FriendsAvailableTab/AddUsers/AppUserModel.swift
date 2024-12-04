//
//  AppUserModel.swift
//  Spark
//
//  Created by Edison Chiu on 12/4/24.
//

import Foundation

struct AppUser: Identifiable {
    let uid: String
    let userName: String
    let firstName: String
    let lastName: String
    let email: String
    
    var id: String { uid }
}
