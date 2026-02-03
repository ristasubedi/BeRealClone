//
//  Posts.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.
//

import Foundation
import ParseSwift
import CoreLocation

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var caption: String?
    var location: String?
    var user: User?
    var imageFile: ParseFile?
//
}
