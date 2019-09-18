//
//  Note+Extenstion.swift
//  Notes
//
//  Created by Sami Youssef on 9/15/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import Foundation

extension Note {
    var updatedAtAsDate: Date {
        guard let updatedAt = updatedAt else { return Date() }
        return Date(timeIntervalSince1970: updatedAt.timeIntervalSince1970)
    }
    var createdAtAsDate: Date {
        guard let createdAt = createdAt else { return Date() }
        return Date(timeIntervalSince1970: createdAt.timeIntervalSince1970)
    }
}
