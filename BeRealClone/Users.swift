//
//  Users.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    var image: ParseFile?
    var profilePicture: ParseFile?
}
