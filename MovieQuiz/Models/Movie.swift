//
//  Movie.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 29.10.2022.
//

import Foundation

struct Movie: Codable {
    let id: String
    let title: String
    let fullTitle: String
    let year: String
    let image: String
    let crew: String
    let imDbRating: String
    let imDbRatingCount: String
}

struct Top: Decodable {
    let items: [Movie]
}
