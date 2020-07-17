//
//  WordsLocalRepo.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation
import RxSwift

class WordsLocalRepo: WordsRepo {
    func getAllWords() -> Single<[Word]> {
        if let url = Bundle.main.url(forResource: "words", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let jsonData = try JSONDecoder().decode([Word].self, from: data)
                return jsonData.isEmpty ? .error(DataError.noElements) : .just(jsonData)
            } catch {
                return .error(DataError.unableToDecode)
            }
        } else {
            return .error(DataError.dataNotFound)
        }
    }
}
