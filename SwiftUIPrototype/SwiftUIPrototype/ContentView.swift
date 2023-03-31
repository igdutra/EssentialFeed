//
//  ContentView.swift
//  SwiftUIPrototype
//
//  Created by Ivo on 30/03/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(FeedImageViewModel.prototypeFeed) { model in
                    Cell(model: model)
                        .padding(.bottom)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("MY Feed")
        }
    }
}

struct Cell: View {
    let model: FeedImageViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomLabel(text: model.location ?? "",
                        icon: "mappin.circle.fill")
            Image(model.imageName)
                .resizable()
            Text(model.description ?? "")
        }
    }
}

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

//struct Cell_Previews: PreviewProvider {
//    static var previews: some View {
//        Cell(model: FeedImageViewModel.prototypeFeed.first!)
//            .previewLayout(.sizeThatFits)
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
