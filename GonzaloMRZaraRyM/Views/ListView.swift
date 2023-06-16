//
//  ListView.swift
//  GonzaloMRZaraRyM
//
//  Created by neoris on 15/6/23.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: RyMViewModel = RyMViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { proxy in
                    ScrollView {
                        ForEach(searchResults, id: \.id) { character in
                            GeometryReader { geometry in
                                NavigationLink(value: character) {
                                    ListCellView(character: character)
                                        .onChange(of: geometry.frame(in: .global).minY) { y in
                                            let threshold: CGFloat = 12
                                            let screenBottom = proxy.size.height
                                            if y > screenBottom - threshold && y < screenBottom + threshold {
                                                if searchResults.last?.id == character.id, searchText.isEmpty {
                                                    Task {
                                                        await viewModel.getNextPage()
                                                    }
                                                }
                                            }
                                        }
                                }
                            }.frame(height: 120)
                        }
                        
                        if viewModel.error {
                            Text("Error in call, drag to retry")
                        }
                    }
                }
            }
            .padding(.horizontal, 12.0)
            .padding(.top, 12.0)
            .navigationDestination(for: RyMResult.self) { character in
                DetailView(character: character)
            }
            .navigationTitle("Rick y Morty")
            .onAppear {
                Task {
                    await viewModel.initialize()
                }
            }
        }
        .searchable(text: $searchText)
    }
    
    var searchResults: [RyMResult] {
        if searchText.isEmpty {
            return viewModel.rymResults
        } else {
            return viewModel.rymResults.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct ListCellView: View {
    @State var character: RyMResult!
    
    var randomColor : [Color] = [
        Color("gradiant-1"),
        Color("gradiant-2"),
        Color("gradiant-3")
    ]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: randomColor.shuffled(), startPoint: .leading, endPoint: .top))
            
            HStack {
                if let url = URL(string: character.image) {
                    CacheAsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                        case .failure:
                            Image("error")
                                .resizable()
                                .scaledToFit()
                        @unknown default:
                            Image("error")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } else {
                    Image("error")
                        .resizable()
                        .scaledToFit()
                }
                
                VStack {
                    Text(character.name)
                        .font(.title)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        switch character.status {
                        case .alive:
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                        case .dead:
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                        case .unknown:
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.brown)
                        }
                        Text(character.status.rawValue)
                            .foregroundColor(Color.white)
                        Text(" - ")
                            .foregroundColor(Color.white)
                        Text(character.species)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.0)
            }
            .frame(height: 120)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
