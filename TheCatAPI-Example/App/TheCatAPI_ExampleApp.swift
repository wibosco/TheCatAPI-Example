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
    private let service: CatService
    
    // MARK: - Init
    
    init() {
        let coordinator = AppCoordinator()
        _coordinator = State(initialValue: coordinator)
        
        let repository = CatRepository()
            
        self.service = CatService(repository: repository)
    }
    
    // MARK: - App
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator,
                     service: service)
        }
    }
}
