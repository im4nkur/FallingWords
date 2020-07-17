//
//  WordsRepo.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation
import RxSwift

protocol WordsRepo {
    func getAllWords() -> Single<[Word]>
}
