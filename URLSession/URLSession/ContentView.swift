//
//  ContentView.swift
//  URLSession
//
//  Created by Matthew Newill on 28/07/2023.
//

import SwiftUI

struct ContentView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var imageUrlStrings: [String] = ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSy6HGGMI67adHn7x7wSxTGtZu15GYBkC9PeJxYTC6MjA&s"]

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(imageUrlStrings, id: \.self) { imageUrlString in
                        if let imageUrl = URL(string: imageUrlString) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
                .padding()
            }
            Spacer()
            HStack(spacing: 40) {
                Button("Download") {
                    download()
                }

                Button("Session") {
                    downloadSession()
                }

                Button("Background") {
                    background()
                }
            }
        }
    }
    
    func download() {
        
    }
    
    func downloadSession() {
        
    }
    
    func background() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
