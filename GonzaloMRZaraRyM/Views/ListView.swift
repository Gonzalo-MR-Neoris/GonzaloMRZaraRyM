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
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(searchResults, id: \.id) { character in
                        NavigationLink(value: character) {
                            CharacterGridItemView(character: character)
                                .onAppear {
                                    if searchResults.last?.id == character.id, searchText.isEmpty {
                                        Task {
                                            await viewModel.getNextPage()
                                        }
                                    }
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
            }.background(Color("background"))
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

struct CharacterGridItemView: View {
    @State var character: RyMResult!

    var body: some View {
        CachedAsyncImage(url: URL(string: character.image)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(height: 80)
            case .success(let image):
                ZStack(alignment: .bottom) {
                    image.resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .overlay(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 100, height: 30)
                                .padding([.trailing, .top], 8)
                                .foregroundStyle(.ultraThinMaterial)
                                .opacity(0.8)
                                .overlay {
                                    HStack {
                                        Text(character.status.rawValue)
                                            .foregroundColor(Color("text"))

                                        switch character.status {
                                        case .alive:
                                            Circle()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.green)
                                        case .dead:
                                            Circle()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.red)
                                        case .unknown:
                                            Circle()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.brown)
                                        }
                                    }
                                    .padding([.trailing, .top], 8)
                                }
                        }

                    RoundedRectangle(cornerRadius: 8)
                        .frame(height: 60)
                        .padding(.bottom, 6)
                        .padding(.horizontal, 8)
                        .foregroundStyle(.ultraThinMaterial)
                        .opacity(0.8)
                        .overlay {
                            Text(character.name)
                                .foregroundColor(Color("text"))
                                .padding(.bottom, 6)
                        }
                }
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
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
