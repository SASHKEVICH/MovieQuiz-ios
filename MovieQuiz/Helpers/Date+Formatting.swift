//
//  Date+Formatting.swift
//  MovieQuiz
//
//  Created by Александр Бекренев on 30.10.2022.
//

import Foundation

extension Date {
    func formatTo(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
