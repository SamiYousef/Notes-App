//
//  String+Extenstions.swift
//  Notes
//
//  Created by Sami Youssef on 9/20/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
