//
//  Models.swift
//  weather
//
//  Created by Stinson, Justin on 8/8/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import Foundation

/**
    Model structure for all data returned from OpenWeatherMap current weather request.
    Full API documentation: http://openweathermap.org/current
    Example URL: api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=imperial
    Example response:
        {"coord":{"lon":139,"lat":35},
        "sys":{"country":"JP","sunrise":1369769524,"sunset":1369821049},
        "weather":[{"id":804,"main":"clouds","description":"overcast clouds","icon":"04n"}],
        "main":{"temp":289.5,"humidity":89,"pressure":1013,"temp_min":287.04,"temp_max":292.04},
        "wind":{"speed":7.31,"deg":187.002},
        "rain":{"3h":0},
        "clouds":{"all":92},
        "dt":1369824698,
        "id":1851632,
        "name":"Shuzenji",
        "cod":200}

    For full documentation see: http://openweathermap.org/current#current_JSON
*/
struct CurrentWeather {
    var weather: Weather
    var main: Main
    var wind: Wind

    init?(jsonDictionary: NSDictionary) {
        guard let weatherArray = jsonDictionary["weather"] as? [[String: AnyObject]] else {
            print("Error parsing JSON response: weather")
            return nil
        }
        self.weather = Weather(jsonData: weatherArray[0])

        guard let mainDictionary = jsonDictionary["main"] as? [String: AnyObject] else {
            print("Error parsing JSON response: main")
            return nil
        }
        self.main = Main(jsonData: mainDictionary)

        guard let windDictionary = jsonDictionary["wind"] as? [String: AnyObject] else {
            print("Error parsing JSON response: wind")
            return nil
        }
        self.wind = Wind(jsonData: windDictionary)
    }
}

/**
    Model structure for the "weather" parameter in current weather response. Note that an unset
    optional indicates that the value was not observed/calculated for the given time and location.
    Atmospheric pressure values are currently ignored.

    For full documentation see: http://openweathermap.org/current#current_JSON
*/
struct Weather {

    /// Weather condition id
    var id: Int?

    /// Group of weather parameters (Rain, Snow, Extreme etc.)
    var main: String?

    /// Weather condition within the group
    var conditionDescription: String?

    /// Weather icon id
    var icon: String?

    /// The URL where the icon file can be fetched
    var iconURL: NSURL? {
        get {
            if self.icon == nil {
                return nil
            }
            return NSURL(string: "http://openweathermap.org/img/w/\(icon!).png")
        }
    }

    init(jsonData: [String: AnyObject]) {
        self.id = jsonData["id"] as? Int
        self.main = jsonData["main"] as? String
        self.conditionDescription = jsonData["description"] as? String
        self.icon = jsonData["icon"] as? String
    }

}

/**
    Model structure for the "main" parameter in current weather response. Note that an unset
    optional indicates that the value was not observed/calculated for the given time and location.
    Atmospheric pressure values are currently ignored.

    For full documentation see: http://openweathermap.org/current#current_JSON
*/
struct Main {

    /// Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
    var temp: Int?

    /// Atmospheric pressure (on the sea level, if there is no sea_level or grnd_level data), hPa
    var pressure: Int?

    /// Humidity, % [0, 100]
    var humidity: UInt?

    /// Minimum temperature at the moment. This is deviation from current temp that is possible for large cities and megalopolises geographically expanded (use these parameter optionally). Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
    var tempMin: Int?

    /// Maximum temperature at the moment. This is deviation from current temp that is possible for large cities and megalopolises geographically expanded (use these parameter optionally). Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
    var tempMax: Int?

    init(jsonData: [String: AnyObject]) {
        self.temp = jsonData["temp"] as? Int
        self.pressure = jsonData["pressure"] as? Int
        self.humidity = jsonData["humidity"] as? UInt
        self.tempMin = jsonData["temp_min"] as? Int
        self.tempMax = jsonData["temp_max"] as? Int
    }
}

/**
    Model structure for the "wind" parameter in current weather response. Note that an unset
    optional indicates that the value was not observed/calculated for the given time and location.

    For full documentation see: http://openweathermap.org/current#current_JSON
*/
struct Wind {

    /// Wind speed. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour.
    var speed: UInt?

    /// Wind direction, degrees (meteorological)
    var degrees: Int?

    init(jsonData: [String: AnyObject]) {
        speed = jsonData["speed"] as? UInt
        degrees = jsonData["deg"] as? Int
    }
}
