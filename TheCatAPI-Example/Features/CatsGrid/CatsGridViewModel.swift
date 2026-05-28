//
//  CatsGridViewModel.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import Foundation

@Observable
final class CatsGridViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case paginating
        case failed
    }

    private(set) var state: State = .idle
    private(set) var items: [CatViewModel] = []

    @ObservationIgnored private var cats: [String: Cat] = [:]
    @ObservationIgnored private let prefetchDistance = 5
    @ObservationIgnored private var prefetchTriggerIDs: Set<CatViewModel.ID> = []
    @ObservationIgnored private var page = 0

    @ObservationIgnored private let repository: CatRepository
    @ObservationIgnored private let coordinator: AppCoordinator
    
    // MARK: - Init
    
    init(coordinator: AppCoordinator,
         repository: CatRepository) {
        self.coordinator = coordinator
        self.repository = repository
        
        Task {
            await retrieveCats()
        }
    }

    // MARK: - Retrieval

    func retrieveCats() async {
        state = .loading
        page = 1
        items = []
        cats.removeAll()
        prefetchTriggerIDs = []

        await retrieve()
    }
    
    private func retrieve() async {
        do {
            let cats = try await repository.retrieveCats(page)
            
            for cat in cats {
                let viewModel = CatViewModel(cat: cat)
                items.append(viewModel)
                
                self.cats[cat.id] = cat
            }

            state = .loaded

            let triggerSlice = items.suffix(prefetchDistance)
            prefetchTriggerIDs = Set(triggerSlice.map(\.id))
        } catch {
            state = .failed
        }
    }
    
    // MARK: - Item
    
    func itemDidAppear(_ item: CatViewModel) {
        guard state != .paginating else { return }
        guard prefetchTriggerIDs.contains(item.id) else { return }
        
        state = .paginating
        page += 1
        
        Task {
            await retrieve()
        }
    }
    
    func itemTapped(_ item: CatViewModel) {
        guard let cat = cats[item.id] else {
            return
        }
        
        coordinator.push(route: .detail(cat))
    }
}

@Observable
final class CatViewModel: Identifiable {
    let id: String
    let url: URL
    
    // MARK: - Init
    
    init(cat: Cat) {
        self.id = cat.id
        self.url = cat.url
    }
}
