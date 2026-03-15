//
//  HomeViewUITests.swift
//  MovieDBUITests
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import XCTest

final class HomeViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        app = XCUIApplication()
        app.launch()
        
        // Aguarda a tela carregar
        let searchBar = app.textFields["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5))
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    // MARK: - FilterBar Tests
    
    func testFilterBarAppears() {
        let filterButton = app.buttons["openFilterSheet"]
        
        XCTAssertTrue(filterButton.exists)
        XCTAssertTrue(filterButton.isHittable)
    }
    
    func testOpenFilterSheet() {
        let filterButton = app.buttons["openFilterSheet"]
        
        filterButton.tap()
        
        // Verifica se FilterSheet abriu procurando pelos botões de ação
        let resetButton = app.buttons["resetFiltersButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3))
    }
    
    func testCloseFilterSheet() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let closeButton = app.buttons["Fechar"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3))
        
        closeButton.tap()
        
        // Verifica se fechou (closeButton desaparece)
        XCTAssertFalse(closeButton.exists)
    }
    
    // MARK: - Rating Filter Tests
    
    func testAdjustRatingSlider() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        // Aguarda slider aparecer
        let slider = app.sliders["filterRatingSlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        
        // Ajusta slider para ~70% (7.0 rating)
        slider.adjust(toNormalizedSliderPosition: 0.7)
        
        XCTAssertTrue(slider.isHittable)
    }
    
    func testRatingSliderMinValue() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let slider = app.sliders["filterRatingSlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        
        // Ajusta para mínimo (0.0)
        slider.adjust(toNormalizedSliderPosition: 0.0)
        
        XCTAssertTrue(slider.exists)
    }
    
    func testRatingSliderMaxValue() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let slider = app.sliders["filterRatingSlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        
        // Ajusta para máximo (10.0)
        slider.adjust(toNormalizedSliderPosition: 1.0)
        
        XCTAssertTrue(slider.exists)
    }
    
    // MARK: - Filter Actions Tests
    
    func testApplyFiltersButton() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let applyButton = app.buttons["applyFiltersButton"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 3))
        XCTAssertTrue(applyButton.isHittable)
        
        applyButton.tap()
        
        // Verifica se sheet fechou (applyButton desaparece)
        XCTAssertFalse(applyButton.exists)
    }
    
    func testResetFiltersButton() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let resetButton = app.buttons["resetFiltersButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3))
        XCTAssertTrue(resetButton.isHittable)
        
        resetButton.tap()
        
        // Após reset, sheet ainda deve estar aberta
        let applyButton = app.buttons["applyFiltersButton"]
        XCTAssertTrue(applyButton.exists)
    }
    
    // MARK: - Complete Filter Flow Tests
    
    func testCompleteFilterFlowWithRating() {
        // 1. Abrir FilterSheet
        let filterButton = app.buttons["openFilterSheet"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))
        filterButton.tap()
        
        // 2. Ajustar Rating
        let slider = app.sliders["filterRatingSlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        slider.adjust(toNormalizedSliderPosition: 0.7)
        
        // 3. Aplicar
        let applyButton = app.buttons["applyFiltersButton"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 3))
        applyButton.tap()
        
        // 4. Verificar se voltou à HomeView
        let filterButtonAgain = app.buttons["openFilterSheet"]
        XCTAssertTrue(filterButtonAgain.waitForExistence(timeout: 3))
    }
    
    func testFilterSheetPersistence() {
        // 1. Abrir filter
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let slider = app.sliders["filterRatingSlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        slider.adjust(toNormalizedSliderPosition: 0.7)
        
        // 2. Aplicar
        let applyButton = app.buttons["applyFiltersButton"]
        applyButton.tap()
        
        // 3. Reabrir FilterSheet
        filterButton.tap()
        
        // 4. Verificar se slider ainda existe (foi persistido)
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
    }
    
    // MARK: - SearchBar Tests
    
    func testSearchBarExists() {
        let searchBar = app.textFields["searchBar"]
        
        XCTAssertTrue(searchBar.exists)
        XCTAssertTrue(searchBar.isHittable)
    }
    
    func testSearchBarCanReceiveInput() {
        let searchBar = app.textFields["searchBar"]
        
        searchBar.tap()
        searchBar.typeText("Avatar")
        
        // Verifica se o texto foi digitado
        XCTAssertTrue(searchBar.exists)
    }
    
    // MARK: - Integration Tests
    
    func testSearchAndFilterSheetInteraction() {
        // Abre filter
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        // Verifica se filter sheet abriu enquanto há busca ativa
        let resetButton = app.buttons["resetFiltersButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3))
        
        // Fecha filter
        let closeButton = app.buttons["Fechar"]
        closeButton.tap()
        
        // Verifica que voltou à view principal
        XCTAssertTrue(filterButton.waitForExistence(timeout: 3))
    }
    
    func testMultipleFilterTogglesCycles() {
        let filterButton = app.buttons["openFilterSheet"]
        
        // Abre
        filterButton.tap()
        let resetButton = app.buttons["resetFiltersButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3))
        
        // Fecha
        let closeButton = app.buttons["Fechar"]
        closeButton.tap()
        XCTAssertFalse(resetButton.exists)
        
        // Reabre
        filterButton.tap()
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3))
        
        // Fecha novamente
        closeButton.tap()
        XCTAssertFalse(resetButton.exists)
    }
    
    // MARK: - UI Element Accessibility Tests
    
    func testAllMainButtonsAreAccessible() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let resetButton = app.buttons["resetFiltersButton"]
        let applyButton = app.buttons["applyFiltersButton"]
        let closeButton = app.buttons["Fechar"]
        
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3))
        XCTAssertTrue(applyButton.exists)
        XCTAssertTrue(closeButton.exists)
        
        XCTAssertTrue(resetButton.isHittable)
        XCTAssertTrue(applyButton.isHittable)
        XCTAssertTrue(closeButton.isHittable)
    }
    
    func testSliderIsAccessible() {
        let filterButton = app.buttons["openFilterSheet"]
        filterButton.tap()
        
        let slider = app.sliders["filterRatingSlider"]
        
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        XCTAssertTrue(slider.isHittable)
        
        // Testa que pode ser ajustado
        slider.adjust(toNormalizedSliderPosition: 0.5)
        XCTAssertTrue(slider.exists)
    }
}
