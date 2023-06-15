//
//  RyMServices.swift
//  GonzaloMRZaraRyM
//
//  Created by neoris on 14/6/23.
//

import Foundation

/// It conforms to the Serviceable protocol, which is critical for testing and dependency injection.
protocol RyMServiceable {
    func getCharacters() async -> Result<RyMResults, RequestError>
    func getCharactersNewPage(newPage: String) async -> Result<RyMResults, RequestError>
}

struct RyMServices: NetworkClient, RyMServiceable {
    func getCharacters() async -> Result<RyMResults, RequestError> {
        return await sendRequest(endPoint: RyMEndPoint.getCharacters, responseModel: RyMResults.self)
    }
    
    func getCharactersNewPage(newPage: String) async -> Result<RyMResults, RequestError> {
        return await sendRequest(endPoint: RyMEndPoint.getCharactersNewPage(newPage: newPage), responseModel: RyMResults.self)
    }
}
