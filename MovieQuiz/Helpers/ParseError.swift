//
//  ParseError.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 29.10.2022.
//

import Foundation

enum ParseError: Error {
    case yearFailure
    case runtimeMinsFailure
    case imDbRatingFailure
    case imDbRatingCountFailure
}
