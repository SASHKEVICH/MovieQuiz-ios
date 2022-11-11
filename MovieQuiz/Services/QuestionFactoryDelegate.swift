//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 28.10.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
