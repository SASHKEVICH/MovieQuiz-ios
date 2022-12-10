//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 10.12.2022.
//

import UIKit

final class MovieQuizPresenter {
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private(set) var correctAnswers: Int = 0
    
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
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
    
    func prepareView(question: QuizQuestion) {
        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.resetImageBorder()
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        viewController?.toggleButtons(state: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.toggleButtons(state: true)
            
            guard self.isLastQuestion else {
                self.viewController?.showNextQuestion()
                return
            }
            self.viewController?.showResults()
        }
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
    }
    
    func noButtonClicked() {
        verifyCorrectness(isYes: false)
    }
    
    private func verifyCorrectness(isYes: Bool) {
        let isCorrect = currentQuestion?.correctAnswer == isYes
        if isCorrect { correctAnswers += 1 }
        viewController?.showQuestionResultOnImageView(isCorrect: isCorrect)
        showNextQuestionOrResults()
    }
}
