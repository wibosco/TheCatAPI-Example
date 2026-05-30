//
//  RootView.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 26/05/2026.
//

import SwiftUI

struct RootView: View {
    @Bindable var coordinator: AppCoordinator
    let service: CatService

    // MARK: - View

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            routeView(for: .grid)
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
                }
        }
    }

    // MARK: - Route

    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .grid:
            CatGridView(coordinator: coordinator,
                        service: service)
        case .detail:
            EmptyView()
        }
    }
}
