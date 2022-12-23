//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 10.12.2022.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func toggleButtons(state: Bool)
    
    func resetImageBorder()
    func highlightImageBorder(isCorrect: Bool)
    
    func showNetworkError(message: String)
    func showResults()
    func show(quiz step: QuizStepViewModel)
}
