//
//  Array+ST.swift
//  ScienTech
//
//  Created by 李晓宁 on 2019/4/19.
//  Copyright © 2019 李晓宁. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
    
}
