//
//  WordsMockRepo.swift
//  FallingWordsTests
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation
import RxSwift
@testable import FallingWords

class WordsMockRepo: WordsRepo {

    func getAllWords() -> Single<[Word]> {
        let words = [Word(english: "holidays", spanish: "vacaciones"),
        Word(english: "class", spanish: "curso"),
        Word(english: "bell", spanish: "timbre"),
        Word(english: "pair", spanish: "pareja")]
        return .just(words)
    }
}
