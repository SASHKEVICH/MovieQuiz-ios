//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Александр Бекренев on 10.12.2022.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func toggleButtons(state: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func resetImageBorder() {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func showResults() {
        
    }
    
    func show(quiz step: QuizStepViewModel) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
