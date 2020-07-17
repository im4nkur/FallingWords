//
//  Word.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation

struct Word: Decodable {
    let english: String
    let spanish: String

    private enum CodingKeys : String, CodingKey {
        case english = "text_eng"
        case spanish = "text_spa"
    }
}
