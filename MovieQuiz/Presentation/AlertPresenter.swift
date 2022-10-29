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
    
    func requestPresentAlert(_ alertModel: AlertModel) {
        show(result: alertModel)
    }
    
    private func show(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: result.buttonText,
                                        style: .default,
                                        handler: result.completion)
        alert.addAction(alertAction)
        delegate?.didRecieveAlert(alert: alert)
    }
}
