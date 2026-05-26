//
//  CatCell.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import SwiftUI

struct CatCell: View {
    let viewModel: CatViewModel
    
    var body: some View {
        AsyncImage(url: viewModel.url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .padding()
            @unknown default:
                EmptyView()
            }
        }
        .aspectRatioContainer(1)
    }
}

private extension View {
    func aspectRatioContainer(_ ratio: CGFloat,
                              contentMode: ContentMode = .fit) -> some View {
        Color.clear
            .aspectRatio(ratio, contentMode: contentMode)
            .overlay { self }
            .clipped()
    }
}

//#Preview {
//    CatCell()
//}
