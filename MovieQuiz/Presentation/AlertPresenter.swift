//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 28.10.2022.
//

import Foundation
import UIKit

class AlertPresenter {
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func requestPresentAlert(_ resultModel: QuizResultViewModel, completion: @escaping (UIAlertAction) -> Void) {
        let alertModel = AlertModel(
            title: resultModel.title,
            message: resultModel.text,
            buttonText: resultModel.buttonText,
            completion: completion)
        let alert = prepareAlert(for: alertModel)
        delegate?.didRecieveAlert(alert: alert)
    }
    
    private func prepareAlert(for result: AlertModel) -> UIAlertController {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: result.buttonText,
                                        style: .default,
                                        handler: result.completion)
        alert.addAction(alertAction)
        return alert
    }
}
