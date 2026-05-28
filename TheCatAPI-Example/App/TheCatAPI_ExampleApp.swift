//
//  TheCatAPI_ExampleApp.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import SwiftUI

@main
struct TheCatAPI_ExampleApp: App {
    @State private var coordinator: AppCoordinator
    private let repository: CatRepository
    
    // MARK: - Init
    
    init() {
        let coordinator = AppCoordinator()
        _coordinator = State(initialValue: coordinator)
        
        self.repository = CatRepository()
    }
    
    // MARK: - App
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator,
                     repository: repository)
        }
    }
}
