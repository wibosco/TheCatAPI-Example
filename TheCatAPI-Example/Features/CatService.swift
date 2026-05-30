//
//  CatService.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 29/05/2026.
//

import Foundation
import Combine

actor CatService {
    enum CatServiceError: Error {
        case loadFailed
    }

    enum State: Equatable {
        case idle
        case loading
        case loaded([Cat])
        case paginating
        case failed(CatServiceError)
    }

    nonisolated var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    nonisolated private let stateSubject = CurrentValueSubject<State, Never>(.idle)

    private var cats: [Cat] = []
    private var nextPage = 0
    private var totalCount = 0

    private let repository: CatRepository
    
    // MARK: - Init
    
    init(repository: CatRepository) {
        self.repository = repository
    }
    
    // MARK: - Load
    
    func loadNextPage() async {
//        guard canLoadMore else { return }
        guard !stateSubject.value.isFetching else { return }

        stateSubject.send(cats.isEmpty ? .loading : .paginating)

        do {
            let cats = try await repository.retrieveCats(nextPage)
            self.cats.append(contentsOf: cats)
            totalCount = cats.count
            nextPage += 1
            
            stateSubject.send(.loaded(cats))
        } catch {
            stateSubject.send(.failed(.loadFailed))
        }
    }
    
    private var canLoadMore: Bool {
        // TODO: Implement pagination stopping mechanism
        cats.isEmpty || cats.count < totalCount
    }
}

private extension CatService.State {
    nonisolated var isFetching: Bool {
        switch self {
        case .loading,
                .paginating:
            return true
        case .idle,
                .loaded,
                .failed:
            return false
        }
    }
}
