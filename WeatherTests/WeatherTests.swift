//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by Praveen on 4/12/23.
//

import XCTest
@testable import Weather

final class WeatherTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        viewModel = WeatherViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Properties
    
    var viewModel: WeatherViewModel!

    // MARK: - Tests
    
    func testGetTempString() {
        XCTAssertEqual(viewModel.getTempString(68), "68°F")
        XCTAssertEqual(viewModel.getTempString(nil), "--°F")
    }
    
    func testLoadLastCityIfAvailable() {
        UserDefaults.standard.setValue("New York", forKey: "lastCity")
        XCTAssertTrue(viewModel.loadLastCityIfAvailable())
        XCTAssertEqual(viewModel.cityName, "New York")
    }
    
    func testFetchWeather() {
        let expectation = self.expectation(description: "Weather data is fetched successfully")
        
        viewModel.fetchWeather(40.7128, -74.0060)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.viewModel.weatherModel)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testFetchWeatherInfo() {
        let expectation = self.expectation(description: "Weather data is fetched successfully")
        
        viewModel.fetchWeatherInfo("New York")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.viewModel.weatherModel)
            XCTAssertEqual(self.viewModel.cityName, "New York")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
