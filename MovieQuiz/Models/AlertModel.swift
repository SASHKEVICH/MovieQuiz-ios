//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 28.10.2022.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (UIAlertAction) -> Void
}
