//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 27.10.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private enum QuestionFactoryError: Error, LocalizedError {
        case loadImage
        
        public var errorDescription: String? {
            switch self {
            case .loadImage:
                return NSLocalizedString("Failed to load image", comment: "")
            }
        }
    }
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: QuestionFactoryError.loadImage)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRatingBound = Float((3...9).randomElement() ?? 0)
            let text = "Рейтинг этого фильма больше чем \(String(format: "%.0f", randomRatingBound))?"
            let correctAnswer = rating > randomRatingBound
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
