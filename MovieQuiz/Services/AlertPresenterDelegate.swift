//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 28.10.2022.
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didRecieveAlert(alert: UIAlertController)
}
