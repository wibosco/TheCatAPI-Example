//
//  AppCoordinator.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 26/05/2026.
//

import SwiftUI

enum Route: Hashable {
    case grid
    case detail(Cat)
}

@Observable
final class AppCoordinator {
    var path = [Route]()

    // MARK: - Show

    func push(route: Route) {
        path.append(route)
    }
}
