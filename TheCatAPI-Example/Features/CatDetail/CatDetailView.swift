//
//  CatDetailView.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 29/05/2026.
//

import SwiftUI

struct CatDetailView: View {
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
    }
}

//#Preview {
//    CatDetailView()
//}
