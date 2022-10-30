//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 29.10.2022.
//

import Foundation

protocol StatisticServiceProtocol {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var totalCorrect: Int { get }
    var totalQuestions: Int { get }
    var bestGame: GameRecord { get }
}
