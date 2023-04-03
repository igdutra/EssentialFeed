//
//  ContentView.swift
//  SwiftUIPrototype
//
//  Created by Ivo on 30/03/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var service = ImageService()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(service.feed) { model in
                    Cell(model: model)
                        .padding(.bottom)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("MY Feed")
            .task {
                await service.downloadItems()
            }
            .refreshable {
                await service.downloadItems()
            }
        }
    }
    
    
}

// TODO: Make this architecture better!
class ImageService: ObservableObject {
    @MainActor @Published var feed: [FeedImageViewModel] = []
    
    func downloadItems() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            if feed.isEmpty {
                feed.append(contentsOf: FeedImageViewModel.prototypeFeed)
            }
        }
    }
}

// MARK: - Cell

struct Cell: View {
    let model: FeedImageViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if let location = model.location {
                CustomLabel(text: location,
                            icon: "mappin.circle.fill")
            }
            Image(model.imageName)
                .resizable() // Fill entire screen
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
            // TODO: make a better shimmer effect in swiftUI
                .shimmer()
            if let description = model.description {
                Text(description)
            }
        }
    }
}

// MARK: - Custom Label

/// Having more than one line, native Label would not center the icon with the Text
struct CustomLabel: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            Text(text)
        }
    }
}

// MARK: - Previews

struct Cell_Previews: PreviewProvider {
    static var previews: some View {
        Cell(model: FeedImageViewModel.prototypeFeed.first!)
            .previewLayout(.sizeThatFits)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
