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
    
    weak var viewContoller: MovieQuizViewController?
    
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
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
        viewContoller?.showAnswerResults(isCorrect: isCorrect)
    }
}
