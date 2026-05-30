//
//  CatViewModel.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 30/05/2026.
//

import Foundation

@Observable
final class CatViewModel: Identifiable, Hashable {
    let id: String
    let url: URL
    
    // MARK: - Init
    
    init(cat: Cat) {
        self.id = cat.id
        self.url = cat.url
    }
    
    // MARK: - Equatable

    static func == (lhs: CatViewModel, rhs: CatViewModel) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
