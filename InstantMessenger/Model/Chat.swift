//
//  Chat.swift
//  InstantMessenger
//
//  Created by Shilpa Joy on 2021-07-11.
//

import UIKit

struct Chat {
    var users: [String]
    var displayName : [String]
    var email : [String]
    var dictionary: [String: Any] {
        return ["users": users,
                "display name" : displayName,
                "email" : email
        ]
    }
}

extension Chat : Equatable {
    init?(dictionary: [String:Any]) {
        guard let chatUsersId = dictionary["users"] as? [String],
              let displayName = dictionary["display name"] as? [String],
              let email = dictionary["email"] as? [String]
        
        else {return nil}
        self.init(users: chatUsersId, displayName: displayName, email: email)
    }
}


