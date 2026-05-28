//
//  CatsGridView.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import SwiftUI

struct CatsGridView: View {
    @State private var viewModel: CatsGridViewModel

    init(coordinator: AppCoordinator,
         repository: CatRepository) {
        let viewModel = CatsGridViewModel(coordinator: coordinator,
                                          repository: repository)
        _viewModel = State(wrappedValue: viewModel)
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
//        .task {
//            await viewModel.retrieveCats()
//        }
        .navigationTitle("Cats")
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
                    Button {
                        viewModel.itemTapped(itemViewModel)
                    } label : {
                        CatCell(viewModel: itemViewModel)
                            .onAppear {
                                viewModel.itemDidAppear(itemViewModel)
                            }
                    }
                    .buttonStyle(ScaleButtonStyle())
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

private struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

//#Preview {
//    CatsGridView()
//}
