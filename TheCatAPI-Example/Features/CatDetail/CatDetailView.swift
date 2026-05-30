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
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo")
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
