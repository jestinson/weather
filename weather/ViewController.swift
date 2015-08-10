//
//  ViewController.swift
//  weather
//
//  Created by Stinson, Justin on 8/8/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsTableView: UITableView!

    private let weatherManager: WeatherManager! = WeatherManager()
    private var currentWeather: CurrentWeather?
    private var currentWeatherImage: UIImage?
    private var currentWeatherDetails = [(String, String)]()
    private var isLoading: Bool = false

    private var locationAuthorizationStatus: CLAuthorizationStatus = .NotDetermined
    private let locationManager: CLLocationManager! = CLLocationManager()
    private var location: CLLocation?

    private static let locationChangeThreshold: CLLocationDistance = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startLoading()

        locationManager.delegate = self
        self.requestLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func refresh(sender: UIBarButtonItem) {
        self.startLoading()
        self.location = nil
        self.locationManager.requestLocation()
    }

    private func requestLocation() {
        // Only need to basically know what city the user is currently in
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        // Make sure we have the authorization needed to get the location
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            self.locationManager.requestWhenInUseAuthorization()

        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationManager.requestLocation()

        case .Restricted, .Denied:
            let alertController = UIAlertController(title: "Location Access Disabled",
                message: "In order to get an acurate weather report your current location is needed, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title: "Open Settings", style: .Default) {
                (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    private func startLoading() {
        if self.isLoading {
            return
        }

        self.isLoading = true
        self.refreshButton.enabled = false
        self.activityIndicator.startAnimating()
        UIView.animateWithDuration(0.25) { () -> Void in
            self.statusLabel.alpha = 1.0
            self.dataView.alpha = 0.0
        }
    }

    private func stopLoading() {
        if !self.isLoading {
            return
        }

        self.isLoading = false
        self.refreshButton.enabled = true
        self.activityIndicator.stopAnimating()
        UIView.animateWithDuration(0.25) { () -> Void in
            self.statusLabel.alpha = 0.0
            self.dataView.alpha = 1.0
        }
    }

    private func updateWeatherDataDisplay() {
        if let temperature = self.currentWeather?.main.temp {
            let temperatureString = "\(temperature) °F"
            self.temperatureLabel.text = temperatureString
        }

        if let description = self.currentWeather?.weather.main {
            var descriptionString = description
            if let descriptionDetails = self.currentWeather?.weather.conditionDescription {
                descriptionString += " (\(descriptionDetails))"
            }
            self.descriptionLabel.text = descriptionString
        }

        self.currentWeatherDetails.removeAll(keepCapacity: true)
        if let windSpeed = self.currentWeather?.wind.speed {
            let item = ("Wind", "\(windSpeed) mph")
            self.currentWeatherDetails.append(item)
        }

        if let humidity = self.currentWeather?.main.humidity {
            let item = ("Humidity", "\(humidity) %")
            self.currentWeatherDetails.append(item)
        }

        if let pressure = self.currentWeather?.main.pressure {
            let item = ("Pressure", "\(pressure) hPa")
            self.currentWeatherDetails.append(item)
        }

        self.detailsTableView.reloadData()
    }

    private func updateWeatherIcon() {
        self.weatherIconImageView.image = self.currentWeatherImage
    }

}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentWeatherDetails.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("default", forIndexPath: indexPath)
        let detailItem = self.currentWeatherDetails[indexPath.row]
        cell.textLabel?.text = detailItem.0
        cell.detailTextLabel?.text = detailItem.1
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if self.locationAuthorizationStatus != status &&
            (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) {
            self.locationManager.requestLocation()
        }
        self.locationAuthorizationStatus = status
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        // Make sure we have a good location with a valid coordinate
        guard let locations = locations as? [CLLocation] else {
            return
        }
        if locations.count <= 0 {
            return
        }
        let newLocation = locations[0]
        if !CLLocationCoordinate2DIsValid(newLocation.coordinate) {
            return
        }

        // Save the location if it's the first we've received or if it's changed significantly
        if self.location == nil || self.location!.distanceFromLocation(newLocation)
            >= ViewController.locationChangeThreshold {
            self.location = newLocation
        } else {
            // The user's location hasn't changed enough since last time to merrit
            // requesting a weather update
            return
        }

        // Convert latitude and longitude to strings and request current conditions
        let latitudeString = "\(locations[0].coordinate.latitude)"
        let longitudeString = "\(locations[0].coordinate.longitude)"
        assert(self.weatherManager != nil)
        self.weatherManager.requestCurrentWeatherForLocation(latitudeString, longitude: longitudeString) {
            (currentWeather: CurrentWeather) in
            self.currentWeather = currentWeather

            dispatch_async(dispatch_get_main_queue(), {
                self.updateWeatherDataDisplay()
            })

            self.weatherManager.requestIconForWeather(self.currentWeather!, completion: {
                (image: UIImage?) -> Void in
                if let image = image {
                    self.currentWeatherImage = image

                    dispatch_async(dispatch_get_main_queue(), {
                        self.updateWeatherIcon()
                        self.stopLoading()
                    })
                }
            })
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alertController = UIAlertController(title: "Could Not Get Current Location",
            message: "Error getting current location.",
            preferredStyle: .Alert)

        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

