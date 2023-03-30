//
//  ContentView.swift
//  SwiftUIPrototype
//
//  Created by Ivo on 30/03/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            ForEach(FeedImageViewModel.prototypeFeed) { model in
                Image(model.imageName)
            }
        }
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
