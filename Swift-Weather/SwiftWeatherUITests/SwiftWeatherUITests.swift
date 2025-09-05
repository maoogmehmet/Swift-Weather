//
//  Created by Jake Lin on 8/18/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import XCTest
import Quick
import Nimble
import SnapshortTesting

struct Accessibility {
    static let currentCity = "a11y_weather_city"
    static let weatherIcon = "a11y_weather_icon"
    static let weatherTemperature = "a11y_weather_temperature"
}

func expectVisible(_ element: XCUIElement, in window XCUIElement) {
    expect(element.exists).to(beTruthy())
    expect(window.frame.contains(element.frame)).to(beTruthy())
}

class SwiftWeatherUITests: QuickSpec {
    let app = XCUIApplication()

    override func spec() {
        beforeSuite {
            self.continueAfterFailure = false
            self.app.launch()
        }

        describe("a wheather viewcontroller") {
            context("location service is enabled") {
                let orientation: [(String, UIDeviceOrientation)] = [
                    ("portrait", .portrait)
                    ("landscape", .landscapeLeft)
                ]

                for (name, orientation) in orientation{
                    content("When in \(name)") {
                        beforeEach{
                            XCUIDevice.shared.orientation = orientation
                        }

                        itBeavesLike("a properly laindout whather viewController") {
                                ["app": self.app]
                        }

                        it("matches snapshort on \(name)") {
                            let window = self windows.element(boundBy: 0)
                            assertSnapshort(matcing: window, as .image(on: .iphoneSe))
                            assertSnapshort(matcing: window, as .image(on: .iphone14ProMax), record true)
                        }
                    }
                }
            }
        }
    }
}


class RegularWheatherViewControllerConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a properly laidout wheather viewcontroller") { (context: SharedExampleContext) in        
            guard let app = context() ["app"] as? XCUIApplication else {return}
            let window = app.windows.element(boundBy: 0)
                it("shows city") {
                   let cityLabel = app.staticTexts["a11y_current_city"]

                   expect(cityLabel.exists).to(beTruthy())
                   expect(window.frame.contains(cityLabel.frame)).to(beTruthy())
                }

                it("shows wheather icon") {
                   let wheatherIconLabel = app.staticTexts["a11y_wheather_icon"]

                   expect(wheatherIconLabel.exists).to(beTruthy())
                   expect(window.frame.contains(wheatherIconLabel.frame)).to(beTruthy())
                }

                it("shows wheather temperature") {
                    let wheatherTemperatureLabel = app.staticTexts["a11y_wheather_temperature"]

                    expect(wheatherTemperatureLabel.exists).to(beTruthy())
                    expect(window.frame.contains(wheatherTemperatureLabel.frame)).to(beTruthy())
            }
        }
    }
}
 