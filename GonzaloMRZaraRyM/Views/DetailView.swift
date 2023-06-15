//
//  DetailView.swift
//  GonzaloMRZaraRyM
//
//  Created by neoris on 15/6/23.
//

import SwiftUI

struct DetailView: View {
    @State var character: RyMResult!
    
    var body: some View {
        VStack {
            HeaderView
            LocationView
            OriginView
            Spacer()
        }
        .padding(.all, 12.0)
    }
    
    var HeaderView: some View {
        HStack(alignment: .center) {
            if let url = URL(string: character.image) {
                CacheAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .overlay {
                                switch character.status {
                                case .alive:
                                    Circle()
                                        .stroke(
                                            Color(.green)
                                        )
                                        .padding(.all, -3)
                                case .dead:
                                    Circle()
                                        .stroke(
                                            Color(.red)
                                        )
                                        .padding(.all, -3)
                                case .unknown:
                                    Circle()
                                        .stroke(
                                            Color(.brown)
                                        )
                                        .padding(.all, -3)
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
            } else {
                Image("error")
                    .resizable()
                    .scaledToFit()
            }
            
            Divider().foregroundColor(.black)
            VStack {
                Text(character.name)
                    .font(.title)
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text(character.status.rawValue)
                        .foregroundColor(Color.black)
                    Text(" - ")
                        .foregroundColor(Color.black)
                    Text(character.species)
                        .foregroundColor(Color.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.all, 12.0)
        .frame(maxWidth: .infinity, maxHeight: 120, alignment: .top)
        .overlay {
            Capsule(style: .continuous)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 2))
        }
    }
    
    var OriginView: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(red: 0.578, green: 0.544, blue: 0.748))
                VStack {
                    Text("Origin:")
                        .font(.title2)
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 1)
                    Text(character.origin.name)
                        .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12.0)
            }
            .frame(height: 75)
        }
    }
    
    var LocationView: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(red: 0.578, green: 0.544, blue: 0.748))
                VStack {
                    Text("Location:")
                        .font(.title2)
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 1)
                    Text(character.location.name)
                        .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12.0)
            }
            .frame(height: 75)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(character: RyMResult(id: 1, name: "Rick Sanchez", species: "Human", type: "", status: .alive, gender: "Male", origin: Location(name: "Earth (C-137)", url: "https://rickandmortyapi.com/api/location/1"), location: Location(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"), image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg", episode: ["https://rickandmortyapi.com/api/episode/1", "https://rickandmortyapi.com/api/episode/2"], url: "https://rickandmortyapi.com/api/character/1", created: "2017-11-04T18:48:46.250Z"))
    }
}
