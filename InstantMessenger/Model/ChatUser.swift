//
//  ChatUser.swift
//  InstantMessenger
//
//  Created by Shilpa Joy on 2021-07-11.
//

import Foundation
import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
