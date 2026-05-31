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

    @ObservationIgnored private var itemIDs: Set<CatViewModel.ID> = []
    
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
    
    private func subscribe() {
        service.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] serviceState in
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
                var newViewModels = [CatViewModel]()
                
                for cat in cats {
                    let viewModel = CatViewModel(cat: cat)
                    
                    guard !itemIDs.contains(viewModel.id) else {
                        continue
                    }
                    
                    itemIDs.insert(viewModel.id)
                    newViewModels.append(viewModel)
                }
                
                self.items.append(contentsOf: newViewModels)
                
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
    
    // MARK: - Load
    
    func loadFirstPageIfNeeded() async {
        guard state == .idle else { return }
        await service.loadNextPage()
    }
    
    // MARK: - Item
    
    func itemDidAppear(_ item: CatViewModel) async {
        guard state != .paginating else { return }
        guard prefetchTriggerIDs.contains(item.id) else { return }
        
        await service.loadNextPage()
    }
    
    func itemTapped(_ item: CatViewModel) {
        coordinator.push(route: .detail(item))
    }
}
