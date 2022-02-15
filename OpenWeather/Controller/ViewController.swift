//
//  ViewController.swift
//  OpenWeather
//
//  Created by Viktor Mauzer on 31.01.2022..
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var weatherDescLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var visibilityLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var infoStackView: UIStackView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        
        // StackView Styling
        infoStackView.layer.cornerRadius = 12
        
        // Config
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        checkLocationAvailablility()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
        activityIndicator.startAnimating()
    }
}

//MARK: - TextFieldDelegate

extension ViewController: UITextFieldDelegate {
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Enter city name..."
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            Task {
                await weatherManager.fetchWeatherData(cityName: city)
            }
        }
        
        searchTextField.text = ""
        activityIndicator.startAnimating()
    }
}

//MARK: - WeatherManagerDelegate

extension ViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        
        DispatchQueue.main.async {
            self.tempLabel.text = weather.temperatureString
            self.cityNameLabel.text = weather.name
            self.weatherDescLabel.text = weather.descriptionString
            self.feelsLikeLabel.text = weather.feelsLikeString
            self.pressureLabel.text = weather.pressureString
            self.humidityLabel.text = weather.humidityString
            self.visibilityLabel.text = weather.visibilityString
            self.backgroundImage.image = weather.backgroundImage
            self.windSpeedLabel.text = weather.windSpeedString
            self.windDirectionLabel.text = weather.windDirectionString
            
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func didFailWithError(error: NetworkingError) {
        switch error {
        case .badUrl:
            displaySimpleAlert(title: "Oops 😔", message: "We can't find this city. Please try again.")
        case .badParsing:
            displaySimpleAlert(title: "Error", message: "Oops 😔 something went wrong. Please try again.")
        }
    }
}

//MARK: - LocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            Task {
                await weatherManager.fetchWeatherData(latitude: lat, longitude: lon)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAvailablility()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displaySimpleAlert(title: "Error", message: "Oops 😔 something went wrong finding your location. Please try again.")
    }
}

//MARK: - Additional methods

extension ViewController {
    func displaySimpleAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkLocationAvailablility() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            @unknown default:
                break
            }
        } else {
            displaySimpleAlert(title: "Error", message: "Seems like your location services are off. Please turn them on to enable this feature.")
        }
    }
}
