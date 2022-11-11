//
//  MovieLoader.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 11.11.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - Network Client
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_2ndc501f") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
                print(error)
            case .success(let data):
                guard let movies = try? JSONDecoder().decode(MostPopularMovies.self, from: data) else { return }
                handler(.success(movies))
            }
        }
    }
}
