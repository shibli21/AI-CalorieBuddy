//
//  Coach.swift
//  CalorieBuddy
//
//  Persisted AI-coach chat history. CloudKit-safe (defaults on all stored props).
//

import Foundation
import SwiftData

enum ChatRole: String, Codable {
    case user, assistant
}

@Model
final class CoachMessage {
    var id: UUID = UUID()
    var roleRaw: String = ChatRole.user.rawValue
    var content: String = ""
    var createdAt: Date = Date.now

    init(role: ChatRole = .user, content: String = "", createdAt: Date = .now) {
        self.roleRaw = role.rawValue
        self.content = content
        self.createdAt = createdAt
    }

    var role: ChatRole {
        get { ChatRole(rawValue: roleRaw) ?? .user }
        set { roleRaw = newValue.rawValue }
    }
}
