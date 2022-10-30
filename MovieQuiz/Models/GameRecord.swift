//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 29.10.2022.
//

import Foundation

struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
}
