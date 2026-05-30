//
//  CatsGridViewModel.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import Foundation
import Combine

@Observable
final class CatGridViewModel {
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

    @ObservationIgnored private let coordinator: AppCoordinator
    @ObservationIgnored private let service: CatService
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(coordinator: AppCoordinator,
         service: CatService) {
        self.coordinator = coordinator
        self.service = service
        
        subscribe()
    }
    
    // MARK: - Subscribe
    
    func subscribe() {
        service.statePublisher.sink { [weak self] serviceState in
            guard let self else {
                return
            }
            
            switch serviceState {
            case .idle:
                self.state = .idle
            case .loading:
                self.state = .loading
            case .paginating:
                self.state = .paginating
            case let .loaded(cats):
                self.items.append(contentsOf: cats.map { CatViewModel(cat: $0) })
                
                let triggerSlice = self.items.suffix(self.prefetchDistance)
                self.prefetchTriggerIDs = Set(triggerSlice.map(\.id))
                
                self.state = .loaded
            case .failed:
                self.state = .failed
            }
        }
        .store(in: &cancellables)
        
        Task {
            await service.loadNextPage()
        }
    }
    
    // MARK: - Item
    
    func itemDidAppear(_ item: CatViewModel) {
        guard state != .paginating else { return }
        guard prefetchTriggerIDs.contains(item.id) else { return }
        
        Task {
            await service.loadNextPage()
        }
    }
    
    func itemTapped(_ item: CatViewModel) {
        coordinator.push(route: .detail(item))
    }
}

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
