//
//  AsyncImageView.swift
//  Weather
//
//  Created by Praveen on 4/16/23.
//

import SwiftUI

class AsyncImageViewModel: ObservableObject {
    @Published var image: String = ""
}

struct AsyncImageView: View {
    @ObservedObject var viewModel: AsyncImageViewModel
    var body: some View {
        AsyncImage(url: URL(string: viewModel.image))
    }
}
