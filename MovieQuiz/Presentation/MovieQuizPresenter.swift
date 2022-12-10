//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 10.12.2022.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private(set) var correctAnswers: Int = 0
    
    weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol?
    
    let questionsAmount: Int = 10
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        prepareView(question: question)
        viewController?.hideLoadingIndicator()
    }
    
    private func prepareView(question: QuizQuestion) {
        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.resetImageBorder()
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func proceedToNextQuestionOrResults() {
        viewController?.toggleButtons(state: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.toggleButtons(state: true)
            
            guard self.isLastQuestion else {
                self.switchToNextQuestion()
                self.requestNextQuestion()
                self.viewController?.showLoadingIndicator()
                return
            }
            self.viewController?.showResults()
        }
    }
    
    func makeResultsMessage() -> String {
        guard let statisticService = statisticService else { return "" }

        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)" + "(\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func restartGame() {
        resetQuestionIndex()
        resetCorrectAnswers()
        questionFactory?.requestNextQuestion()
    }
    
    func reloadData() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
    }
    
    private func verifyCorrectness(isYes: Bool) {
        let isCorrectAnswer = currentQuestion?.correctAnswer == isYes
        didAnswer(isCorrectAnswer: isCorrectAnswer)
        viewController?.highlightImageBorder(isCorrect: isCorrectAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func resetCorrectAnswers() {
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        verifyCorrectness(isYes: true)
        proceedToNextQuestionOrResults()
    }
    
    func noButtonClicked() {
        verifyCorrectness(isYes: false)
        proceedToNextQuestionOrResults()
    }
}
