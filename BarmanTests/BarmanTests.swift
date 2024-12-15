//
//  BarmanTests.swift
//  BarmanTests
//
//  Created by C4rl0s on 26/02/23.
//

import XCTest
@testable import Barman

final class BarmanTests: XCTestCase {
    
    let drinkDataManager = DrinkDataManager()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDrinkDataManagerIsNotNil() throws {
        XCTAssertNotNil(drinkDataManager)
    }
    
    func testDrinkDataManagerIsEmptyAtInstanciate() throws {
        XCTAssertTrue(drinkDataManager.drinks.count == 0)
    }
    
    func testLoadDrinksMethodIsMoreThanZero() throws {
        drinkDataManager.loadDrinks()
        XCTAssertTrue(drinkDataManager.drinks.count > 0)
    }
    
    func testIfLastDrinkIsNotNil() throws {
        drinkDataManager.loadDrinks()
        let drinks = drinkDataManager.drinks
        XCTAssertNotNil(drinkDataManager.drink(at: drinks.count-1))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
