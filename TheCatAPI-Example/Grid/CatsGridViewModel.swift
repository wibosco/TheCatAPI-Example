//
//  CatsGridViewModel.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import Foundation

@MainActor
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

    @ObservationIgnored private let prefetchDistance = 5
    @ObservationIgnored private var prefetchTriggerIDs: Set<CatViewModel.ID> = []
    @ObservationIgnored private var page = 0

    @ObservationIgnored private let repository: CatRepository

    init(repository: CatRepository) {
        self.repository = repository
    }

    func retrieveCats() async {
        state = .loading
        page = 1
        items = []
        prefetchTriggerIDs = []

        await retrieve()
    }

    func itemDidAppear(_ item: CatViewModel) {
        guard state != .paginating else { return }
        guard prefetchTriggerIDs.contains(item.id) else { return }
        
        state = .paginating
        page += 1
        
        Task {
            await retrieve()
        }
    }
    
    private func retrieve() async {
        do {
            let cats = try await repository.retrieveCats(page)
            let viewModels = cats.map(CatViewModel.init(cat:))

            state = .loaded
            items.append(contentsOf: viewModels)

            let triggerSlice = items.suffix(prefetchDistance)
            prefetchTriggerIDs = Set(triggerSlice.map(\.id))
        } catch {
            state = .failed
        }
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
