//
//  DataErrors.swift
//  FallingWords
//
//  Created by Ankur Arya on 18/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation

enum DataError: Error {
    case unableToDecode
    case noElements
    case timeout
    case dataNotFound
}

extension DataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unableToDecode:
            return "Could not decode json data. Please check the json file."
        case .noElements:
            return "No elements available. Please add some words in the data source."
        case .timeout:
            return "Operation timed out. Please try again."
        case .dataNotFound:
            return "Data not found. Please check if the data is available at given URL."
        }
    }
}
