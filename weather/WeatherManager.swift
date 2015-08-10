//
//  WeatherManager.swift
//  weather
//
//  Created by Stinson, Justin on 8/8/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import Foundation
import UIKit

/**
    Manager responsible for getting weather forecasts and associated icons from OpenWeatherMap
*/
class WeatherManager {

    private let apiKey: String

    static private var iconCache = Cache<UIImage>(maximumNumberOfItems: 10)

    init?() {
        guard let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist") else {
            apiKey = ""
            return nil
        }
        guard let settingsDictionary = NSDictionary(contentsOfFile: path) else {
            apiKey = ""
            return nil
        }
        guard let key = settingsDictionary["OPEN_WEATHER_MAP_API_KEY"] as? String else {
            apiKey = ""
            return nil
        }
        apiKey = key
    }

    /**
        Requests current weather data for a location defined by a latitude and longitude from
        OpenWeatherMap. Imperial units are requested.
        - Parameter latitude: The latitude of the location as a string
        - Parameter longitude: The longitude of the location as a string
    */
    func requestCurrentWeatherForLocation(latitude: String, longitude: String, completion: (CurrentWeather) -> Void) {
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&APPID=\(self.apiKey)&units=imperial")!
        let task = self.getJson(url) {
            (jsonObject: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void in

            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let dictionary = jsonObject as? NSDictionary else {
                print("Error parsing JSON response")
                return
            }

            if let currentWeather = CurrentWeather(jsonDictionary: dictionary) {
                completion(currentWeather)
            }
        }
        task?.resume()
    }

    /**
        Requests the icon for a given current weather instance. Completion will be called once
        the icon has been fetched. A nil value passed to completion indicates a failure
        fetching the icon. Icon data may be cached.
        - Parameter weather: Weather model to request an icon for
        - Parameter completion: Completion handler to execute after the image fetch is complete
    */
    func requestIconForWeather(weather: CurrentWeather, completion: (UIImage?) -> Void) {
        guard let iconName = weather.weather.icon else {
            completion(nil)
            return
        }

        if let icon = WeatherManager.iconCache[iconName] {
            // Icon is cached, just return the image
            completion(icon.0)
        } else {
            // Icon is not cached, try to fetch and cache for later
            guard let iconURL = weather.weather.iconURL else {
                completion(nil)
                return
            }
            let task = self.getData(iconURL, completion: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if let data = data, image = UIImage(data: data) {
                    WeatherManager.iconCache[iconName] = image
                    completion(image)
                }
            })
            task?.resume()
        }
    }

    private func getData(url: NSURL, completion: (NSData?, NSURLResponse?, NSError?) -> Void)
        -> NSURLSessionTask? {

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

            if error != nil {
                completion(nil, response, error)
            }

            if let data = data {
                completion(data, response, nil)
            } else {
                completion(nil, nil, error)
            }

        }
        return task
    }

    private func getJson(url: NSURL, completion: (AnyObject?, NSURLResponse?, NSError?) -> Void)
        -> NSURLSessionTask? {

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

            if error != nil {
                completion(nil, response, error)
            }

            if let data = data {
                do {
                    guard let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(
                        data, options: .AllowFragments) where jsonObject != nil else {
                            return
                    }
                    completion(jsonObject, response, nil)
                } catch let caught as NSError {
                    completion(nil, response, caught)
                } catch {
                    // Something else happened.
                    let error: NSError = NSError(domain: "com.github.jestinson", code: 1, userInfo: nil)
                    completion(nil, nil, error)
                }
            } else {
                completion(nil, response, error)
            }
        }
        
        return task
    }

}
