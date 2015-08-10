//
//  ViewController.swift
//  weather
//
//  Created by Stinson, Justin on 8/8/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var weatherIconImageView: UIImageView!

    let weatherManager: WeatherManager! = WeatherManager()
    var currentWeather: CurrentWeather?

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(self.weatherManager != nil)
        self.weatherManager.requestCurrentWeatherForLocation("35.959908", longitude: "-86.816636") {
            (currentWeather: CurrentWeather) in
            self.currentWeather = currentWeather

            self.weatherManager.requestIconForWeather(self.currentWeather!, completion: {
                (image: UIImage?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.weatherIconImageView.image = image
                    self.weatherIconImageView.setNeedsDisplay()
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

