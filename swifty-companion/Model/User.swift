//
//  User.swift
//  swifty-companion
//
//  Created by Amine Mersoul on 6/25/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: Int?
    let email: String?
    let login: String?
    let first_name: String?
    let last_name: String?
    let phone: String?
    let displayname: String?
    let image_url: String?
    let correction_point: Int?
    let wallet: Int?
    let cursus_users: [CursusUsers]?
    let campus: [Campus]?
    
    init() {
        self.id = 0
        self.email = ""
        self.login = ""
        self.first_name = ""
        self.last_name = ""
        self.phone = ""
        self.displayname = ""
        self.image_url = ""
        self.correction_point = 0
        self.wallet = 0
        self.cursus_users = nil
        self.campus = nil
    }
 }

struct CursusUsers: Codable {
    let grade: String?
    let level: Double?
    let skills: [Skills]?
    let cursus: Cursus?
}

struct Skills: Codable {
    let id: Int?
    let name: String?
    let level: Double?
}

struct Cursus: Codable {
    let id: Int?
    let created_at: String?
    let name: String?
    let slug: String?
}

struct Campus: Codable {
    let name: String?
    let country: String?
    let city: String?
}
