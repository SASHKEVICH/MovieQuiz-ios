//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 29.10.2022.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private enum Keys: String {
        case correct
        case total
        case accuracy
        case gamesCount
        case bestGame
    }
    
    private let userDefaults = UserDefaults.standard
    
    private(set) var totalQuestions: Int {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.total.rawValue),
                let record = try? JSONDecoder().decode(Int.self, from: data) else { return -1 }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить общее количество вопросов")
                return
            }
                
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    private(set) var totalCorrect: Int {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.correct.rawValue),
                let record = try? JSONDecoder().decode(Int.self, from: data) else { return -1 }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить общее количество правильных ответов")
                return
            }
            
            userDefaults.set(data, forKey: Keys.correct.rawValue)
        }
    }
    
    private(set) var totalAccuracy: Double {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.accuracy.rawValue),
                let record = try? JSONDecoder().decode(Double.self, from: data) else { return -1.0 }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить общую точность")
                return
            }
            
            userDefaults.set(data, forKey: Keys.accuracy.rawValue)
        }
    }
    
    private(set) var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                  return -1
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить количество игр")
                return
            }
            
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                  return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let possibleBestGame = GameRecord(correct: count, total: amount, date: Date())
        if possibleBestGame >= bestGame {
            bestGame = possibleBestGame
        }
        gamesCount += 1
        totalCorrect += count
        totalQuestions += amount
        totalAccuracy = Double(totalCorrect) / Double(totalQuestions)
    }
}
