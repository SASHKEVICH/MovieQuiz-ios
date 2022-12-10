//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Александр Бекренев on 08.12.2022.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["No"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testAlertExists() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Alert"]
        XCTAssert(alert.exists)
        XCTAssert(alert.label == "Этот раунд окончен!")
        XCTAssert(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }
    
    func testAlertDissapear() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Alert"]
        alert.buttons["Сыграть еще раз"].tap()
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        sleep(1)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
