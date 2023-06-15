//
//  RyMViewModel.swift
//  GonzaloMRZaraRyM
//
//  Created by neoris on 14/6/23.
//

import Foundation

@MainActor
class RyMViewModel: ObservableObject {
    @Published var rymResults = [RyMResult]()
    @Published var error = false
    
    public var isCalling = false
    
    private var currentPage = 1
    private var maxPages = 42
    
    private let rymServices: RyMServiceable = RyMServices()
    
    func initialize() async {
        isCalling = true
        
        let rymResult = await rymServices.getCharacters()
        
        switch rymResult {
        case .success(let data):
            error = false
            maxPages = data.info.pages
            rymResults = data.results
        case .failure(let requestError):
            print("error: ", requestError)
            error = true
        }
        
        isCalling = false
    }
    
    func getNextPage() async {
        guard currentPage <= maxPages, !isCalling else { return }
        
        isCalling = true
        currentPage += 1
        
        let rymResult = await rymServices.getCharactersNewPage(newPage: String(currentPage))
        
        switch rymResult {
        case .success(let data):
            error = false
            maxPages = data.info.pages
            rymResults.append(contentsOf: data.results)
        case .failure(let requestError):
            print("error: ", requestError)
            error = true
        }
        
        isCalling = false
    }
}
