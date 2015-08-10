//
//  WeatherManagerTests.swift
//  weatherTests
//
//  Created by Stinson, Justin on 8/8/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import XCTest
@testable import weather

class WeatherManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCurrentWeather() {
        guard let manager = WeatherManager() else {
            XCTFail("Could not create WeatherManager")
            return
        }
        let currentWeatherExpectation = self.expectationWithDescription("Current weather parsed")
        manager.requestCurrentWeatherForLocation("35.959908", longitude: "-86.816636") {
            (currentWeather: CurrentWeather) in
            currentWeatherExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

}
