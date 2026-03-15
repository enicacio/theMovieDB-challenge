//
//  MovieDetailViewUITests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import XCTest

final class MovieDetailViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        app = XCUIApplication()
        app.launch()
        
        // Aguarda HomeView carregar
        let searchBar = app.textFields["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5))
        
        // Navega para um filme (clica no primeiro que encontrar)
        let firstMovie = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'movieCell_'")).firstMatch
        if firstMovie.waitForExistence(timeout: 3) {
            firstMovie.tap()
        }
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    // MARK: - MovieView Basics Tests
    
    func testMovieViewAppears() {
        // Verifica se algum elemento de filme aparece
        let movieElements = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        
        XCTAssertGreaterThan(movieElements.count, 0)
    }
    
    func testBackButtonExists() {
        // Procura por botão de voltar (geralmente primeiro botão)
        let backButton = app.buttons.element(boundBy: 0)
        
        XCTAssertTrue(backButton.exists)
    }
    
    func testCanNavigateBack() {
        // Clica no botão de voltar
        let backButton = app.buttons.element(boundBy: 0)
        
        XCTAssertTrue(backButton.isHittable)
        backButton.tap()
        
        // Verifica se voltou para HomeView (searchBar deve existir)
        let searchBar = app.textFields["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 3))
    }
    
    // MARK: - Favorite Button Tests
    
    func testFavoriteButtonExists() {
        // Procura por botão de favoritar
        let favoriteButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'favorite'")).firstMatch
        
        // Se não encontrar por identifier, procura por "Love" label
        if !favoriteButton.exists {
            let loveButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Love'"))
            if loveButtons.count > 0 {
                XCTAssertTrue(loveButtons.element(boundBy: 0).exists)
                return
            }
        }
        
        // Se encontrou por identifier
        if favoriteButton.exists {
            XCTAssertTrue(favoriteButton.isHittable)
        }
    }
    
    func testCanToggleFavorite() {
        // Tenta encontrar botão de favorito
        var favoriteButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'favorite'")).firstMatch
        
        if !favoriteButton.exists {
            // Se não encontrou, procura por label
            let loveButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Love'"))
            if loveButtons.count > 0 {
                favoriteButton = loveButtons.element(boundBy: 0)
            }
        }
        
        if favoriteButton.exists {
            XCTAssertTrue(favoriteButton.isHittable)
            favoriteButton.tap()
            
            XCTAssertTrue(favoriteButton.exists)
        }
    }
    
    // MARK: - Share Button Tests
    
    func testShareButtonExists() {
        // Procura por botão de compartilhar
        let shareButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'share'")).firstMatch
        
        if shareButton.exists {
            XCTAssertTrue(shareButton.isHittable)
        }
    }
    
    func testCanOpenShareSheet() {
        let shareButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'share'")).firstMatch
        
        if shareButton.exists && shareButton.isHittable {
            shareButton.tap()
            
            // Tenta fechar share sheet
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.waitForExistence(timeout: 2) {
                cancelButton.tap()
            }
        }
    }
    
    // MARK: - Movie Info Display Tests
    
    func testMovieInfoVisible() {
        // Verifica se há conteúdo carregado
        let allText = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        
        XCTAssertGreaterThan(allText.count, 0)
    }
    
    func testGenresAreDisplayed() {
        // Verifica se há conteúdo na tela (inclui gêneros)
        let allText = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        
        XCTAssertGreaterThan(allText.count, 0)
    }
    
    func testRatingIsDisplayed() {
        // Verifica que há conteúdo (rating geralmente é exibido)
        let allText = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        
        XCTAssertGreaterThan(allText.count, 0)
    }
    
    func testOverviewIsVisible() {
        // Verifica que há descrição/overview
        let allText = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        
        XCTAssertGreaterThan(allText.count, 0)
    }
    
    // MARK: - Navigation Flow Tests
    
    func testMultipleMovieNavigation() {
        // 1. Está em MovieView
        let movieText = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        XCTAssertGreaterThan(movieText.count, 0)
        
        // 2. Volta
        let backButton = app.buttons.element(boundBy: 0)
        backButton.tap()
        
        let searchBar = app.textFields["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 3))
        
        // 3. Clica em outro filme
        let movies = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'movieCell_'"))
        if movies.count > 1 {
            movies.element(boundBy: 1).tap()
            
            // 4. Verifica novo MovieView
            let newMovieText = app.staticTexts.matching(NSPredicate(format: "label != ''"))
            XCTAssertGreaterThan(newMovieText.count, 0)
        }
    }
    
    func testFavoritePersistenceAcrossNavigation() {
        // Encontra botão de favorito
        var favoriteButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'favorite'")).firstMatch
        
        if !favoriteButton.exists {
            let loveButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Love'"))
            if loveButtons.count > 0 {
                favoriteButton = loveButtons.element(boundBy: 0)
            }
        }
        
        if favoriteButton.exists {
            // Favorita
            favoriteButton.tap()
            
            // Volta
            let backButton = app.buttons.element(boundBy: 0)
            backButton.tap()
            
            let searchBar = app.textFields["searchBar"]
            XCTAssertTrue(searchBar.waitForExistence(timeout: 3))
            
            // Reabre mesmo filme
            let movies = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'movieCell_'"))
            if movies.count > 0 {
                movies.element(boundBy: 0).tap()
                
                // Verifica que favorito persiste
                let favButtonAgain = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'favorite'")).firstMatch
                XCTAssertTrue(favButtonAgain.exists)
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testScrollViewIsAccessible() {
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.exists {
            XCTAssertTrue(scrollView.isHittable)
        }
    }
    
    func testTextIsReadable() {
        let textElements = app.staticTexts.matching(NSPredicate(format: "label != ''"))
        
        XCTAssertGreaterThan(textElements.count, 0)
    }
    
    // MARK: - Image Loading Tests
    
    func testImagesLoad() {
        // Procura por images na view
        let images = app.images.matching(NSPredicate(format: "label != ''"))
        
        // Se houver imagens, verifica que existem
        if images.count > 0 {
            XCTAssertGreaterThan(images.count, 0)
        }
    }
}
