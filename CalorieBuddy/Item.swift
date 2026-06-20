//
//  Item.swift
//  CalorieBuddy
//
//  Created by syed shibli mahmud on 20/6/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
