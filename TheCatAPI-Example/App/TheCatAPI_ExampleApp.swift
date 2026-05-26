//
//  TheCatAPI_ExampleApp.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import SwiftUI

@main
struct TheCatAPI_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            CatsGridView(repository: CatRepository())
        }
    }
}
