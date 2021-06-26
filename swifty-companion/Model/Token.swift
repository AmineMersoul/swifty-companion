//
//  Token.swift
//  swifty-companion
//
//  Created by Amine Mersoul on 6/25/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import Foundation

struct Token: Decodable {
    let access_token: String?
    let token_type: String?
    let expires_in: Int?
    let scope: String?
    let created_at: Int?
    let error: String?
    let error_description: String?
}

struct TokenInfo: Decodable {
    let expires_in_seconds: Int?
    let created_at: Int?
    let error: String?
}
