//
//  WordsNetworkRepo.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation
import RxSwift

class WordsNetworkRepo: WordsRepo {
    let networkManager: NetworkManagerType

    init(networkManager: NetworkManagerType) {
        self.networkManager = networkManager
    }

    func getAllWords() -> Single<[Word]> {
        networkManager.getRequest(path: .words, parameters: [:])
    }
}
