//
//  CatPages.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 31/05/2026.
//

struct Page: Hashable {
    let totalPages: Int
    let cats: [Cat]
}
