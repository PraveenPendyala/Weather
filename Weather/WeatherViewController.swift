//
//  ViewController.swift
//  Weather
//
//  Created by Praveen on 4/12/23.
//

import UIKit
import SwiftUI

class WeatherViewController: UIViewController, WeatherViewModelDelegate {
    
    private var viewModel           : WeatherViewModel!
    private var imageViewModel      = AsyncImageViewModel()
    
    // MARK: -
    // MARK: IBOutlets
    
    @IBOutlet weak var imageContainerView   : UIView!
    @IBOutlet weak var citySearchbar        : UISearchBar!
    @IBOutlet weak var cityLabel            : UILabel!
    @IBOutlet weak var tempLabel            : UILabel!
    @IBOutlet weak var descriptionLabel     : UILabel!
    @IBOutlet weak var tempHighLabel        : UILabel!
    @IBOutlet weak var tempLowLabel         : UILabel!
    @IBOutlet weak var feelsLikeLabel       : UILabel!
    @IBOutlet weak var humidityLabel        : UILabel!
    @IBOutlet weak var visibilityLabel      : UILabel!
    @IBOutlet weak var cloudinessLabel      : UILabel!
    @IBOutlet weak var sunriseLabel         : UILabel!
    @IBOutlet weak var sunsetLabel          : UILabel!
    @IBOutlet weak var windLabel            : UILabel!
    
    // MARK: -
    // MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewModel                                      = WeatherViewModel()
        self.viewModel.delegate                             = self
        self.viewModel.loadDefaultLocation()
        // Set up the tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        // Adding async image to the view
        self.addAsyncImageView()
    }
    
    
    // MARK: -
    // MARK: Private Methods
    
    func addAsyncImageView() {
        let hostingController = UIHostingController(rootView: AsyncImageView(viewModel: imageViewModel))
        addChild(hostingController)
        /// Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainerView.addSubview(hostingController.view)
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: imageContainerView.leftAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            imageContainerView.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        /// Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)
    }
    
    @objc func viewTapped() {
        citySearchbar.resignFirstResponder()
    }
    
    func configureView() {
        self.cityLabel.text             = viewModel.cityName
        self.tempLabel.text             = viewModel.temperature
        self.descriptionLabel.text      = viewModel.weatherDescription
        self.tempHighLabel.text         = viewModel.tempHighest
        self.tempLowLabel.text          = viewModel.tempLowest
        self.feelsLikeLabel.text        = viewModel.tempFeelsLike
        self.humidityLabel.text         = viewModel.humidity
        self.visibilityLabel.text       = viewModel.visibility
        self.cloudinessLabel.text       = viewModel.cloudiness
        self.sunsetLabel.text           = viewModel.sunsetTime
        self.sunriseLabel.text          = viewModel.sunriseTime
        self.windLabel.text             = viewModel.windSpeed
        self.imageViewModel.image       = viewModel.imageName
    }
    
    // Present error alert
    func notifyUser(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}


// Delegate methods for the searchbar, this can be improved by showing results from a list of cities

extension WeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // adding percentage encoding to accept spaces in city name
        if let city = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !city.isEmpty {
            self.viewModel.fetchWeatherInfo(city)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Reset search bar and dismiss keyboard
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
