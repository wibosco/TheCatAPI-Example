//
//  CatsGridView.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import SwiftUI

struct CatsGridView: View {
    @State private var viewModel: CatsGridViewModel

    init(repository: CatRepository) {
        _viewModel = State(wrappedValue: CatsGridViewModel(repository: repository))
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case .idle:
                emptyView
            case .loading:
                loadingView
            case .loaded, .paginating:
                loadedView
            case .failed:
                failedView
            }
        }
        .task {
            await viewModel.retrieveCats()
        }
    }

    private var emptyView: some View {
        Text("We have no cats to show you! 🙀")
    }

    private var loadingView: some View {
        ProgressView("Getting you some cats! 😺")
            .progressViewStyle(.circular)
            .controlSize(.large)
    }

    private var loadedView: some View {
        ScrollView {
            LazyVGrid(columns: GridItem.threeColumnLayout(), spacing: 8) {
                ForEach(viewModel.items) { itemViewModel in
                    CatCell(viewModel: itemViewModel)
                        .onAppear {
                            viewModel.itemDidAppear(itemViewModel)
                        }
                }
            }

            if viewModel.state == .paginating {
                VStack {
                    ProgressView()
                    Text("Getting you more cats! 😽")
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private var failedView: some View {
        Text("Got no cats to show you! 😿")
    }
}

private extension GridItem {
    static func threeColumnLayout() -> [GridItem] {
        let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]
        
        return columns
    }
}

//#Preview {
//    CatsGridView()
//}
