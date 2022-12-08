//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 11.11.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private enum LoadingError: Error, LocalizedError {
        case invalidAPIKey
        case invalidAPI
        
        public var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return NSLocalizedString("Invalid API Key", comment: "")
            case .invalidAPI:
                return NSLocalizedString("Maybe ImDb changed their api...", comment: "")
            }
        }
    }
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Network Client
    private let networkClient: NetworkRouting
    
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
                guard let movies = try? JSONDecoder().decode(MostPopularMovies.self, from: data) else {
                    handler(.failure(LoadingError.invalidAPI))
                    return
                }
                    
                guard !movies.items.isEmpty else {
                    handler(.failure(LoadingError.invalidAPIKey))
                    return
                }
                handler(.success(movies))
            }
        }
    }
}
