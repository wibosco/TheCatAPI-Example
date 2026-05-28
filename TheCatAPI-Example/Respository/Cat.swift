//
//  Cat.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import Foundation

struct Cat: Decodable, Hashable {
    let id: String
    let url: URL
}
