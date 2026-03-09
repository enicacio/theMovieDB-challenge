//
//  MovieDBUITests.swift
//  MovieDBUITests
//
//  Created by Eliane Regina Nicácio Mendes on 03/03/26.
//

import XCTest

final class MovieDBUITests: XCTestCase {

    var app: XCUIApplication!
    static var appInstance: XCUIApplication?
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        
        if let existingApp = Self.appInstance, existingApp.state == .runningForeground {
            self.app = existingApp
        } else {
            self.app = XCUIApplication()
            self.app.launchArguments = ["testing"]
            self.app.launch()
            sleep(2)
            Self.appInstance = self.app
        }
    }

    override func tearDownWithError() throws {
        // App continua rodando para próximo teste
    }
    
    override class func tearDown() {
        super.tearDown()
        if let app = appInstance {
            app.terminate()
            appInstance = nil
        }
    }

    // MARK: - Home Screen Tests
    
    @MainActor
    func testBackButtonFromMovieDetails() throws {
        let scrollView = app.scrollViews["moviesTable"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 10))
        
        let movieButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'movieCell'"))
        let firstMovieCell = movieButtons.element(boundBy: 0)
        firstMovieCell.tap()
        
        let detailTitle = app.staticTexts["movieDetailTitle"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 10))
        
        sleep(1)
        
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()
        
        sleep(1)
        
        XCTAssertTrue(
            scrollView.waitForExistence(timeout: 10),
            "Deve voltar para home"
        )
    }
    
    @MainActor
    func testClearSearchAndShowPopular() throws {
        let searchField = app.textFields["searchBar"]
        XCTAssertTrue(searchField.exists)
        
        searchField.tap()
        sleep(1)
        searchField.typeText("Avatar")
        sleep(2)
        
        for _ in 0..<10 {
            app.keys["delete"].press(forDuration: 1)
        }
        
        sleep(2)
        
        let scrollView = app.scrollViews["moviesTable"]
        XCTAssertTrue(scrollView.exists)
    }
}
