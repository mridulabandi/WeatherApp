//
//  ViewController.swift
//  WeatherApp
//
//  Created by mysmac_admin on 09/05/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var currentlocation: UITextField!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet var cityBtns: [UIButton]!
    
    
    var kelTemp = 0.0
    var kelTempmin = 0.0
    var kelTempmax = 0.0
    
    //using static data since i am not able to fetch with API key
    var dayArr : [String ] = ["Mon","Tues","Wed","Thur","Fri","Sat","Sun"]
    var tempArr = [297.1,300.1,287.1,299.1,294.1,290.1,293.1]
    
    var locationManager : CLLocationManager!
    var city = ""
    let mf = MeasurementFormatter()
    var celsium = true
    var farhenit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.SetLayout()
        // Do any additional setup after loading the view.
    }
    
    func SetLayout()
    {
        let width = 50
       
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0,left: 0,bottom: 10,right: 0)
        layout.itemSize = CGSize(width: width, height: 150)
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView.collectionViewLayout = layout
    }
    
    enum Citys : String{
        case boston = "Boston"
        case chicago = "Chicago"
        case seattle = "Seattle"
    }
    @IBAction func cityTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let city = Citys(rawValue: title) else {return }
        switch city {
        case .boston:
            self.currentlocation.text = "Boston"
            self.fetchWeatherDetails(city: "Boston")
            locationManager.stopUpdatingLocation()
        case .chicago:
            self.currentlocation.text = "Chicago"
            self.fetchWeatherDetails(city: "Chicago")
            locationManager.stopUpdatingLocation()
        case .seattle:
            self.currentlocation.text = "Seattle"
            self.fetchWeatherDetails(city: "Seattle")
            locationManager.stopUpdatingLocation()
        default:
            print("Can Fetch details for this city.")
        }
                
    }
    
    @IBAction func handleSelection(_ sender: UIButton) {
        cityBtns.forEach {(button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    
    @IBAction func celsiusAction(_ sender: Any) {
        self.convertToCelsius()
        self.collectionView.reloadData()
    }
    
    @IBAction func fahenreitAction(_ sender: Any) {
        self.convertInFaherheit()
        self.collectionView.reloadData()
    }
    
    func convertToCelsius()
    {
        self.celsium = true
        self.farhenit = false
        self.temp.text =  self.convertTemp(temp: self.kelTemp, from: .kelvin, to: .celsius)
        self.minTemp.text = "Min - " + self.convertTemp(temp: self.kelTempmin, from: .kelvin, to: .celsius)
        self.maxTemp.text = "Max - " + self.convertTemp(temp: self.kelTempmax, from: .kelvin, to: .celsius)
    }
    
    func convertInFaherheit()
    {
        self.celsium = false
        self.farhenit = true
        self.temp.text = self.convertTemp(temp: self.kelTemp, from: .kelvin, to: .fahrenheit)
        self.minTemp.text = "Min - " + self.convertTemp(temp: self.kelTempmin, from: .kelvin, to: .fahrenheit)
        self.maxTemp.text = "Max - " + self.convertTemp(temp: self.kelTempmax, from: .kelvin, to: .fahrenheit)
    }
    
    func checkLocationPermessions()
    {
        switch CLLocationManager.authorizationStatus(){
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(withTitle: "Erro", message: "Location access restricted")
        case .denied:
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let settingAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            }
            showAlert(withTitle: "Error", message: "Location access denied. Please allow it from settins",andActions:  [settingAction,cancelAction])
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            showAlert(withTitle: "Error", message: "Something went Wrong")
            
        }
    }
    
    func showAlert(withTitle title : String?, message : String?, andActions actions : [UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)])
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach({alert.addAction($0)})
        present(alert, animated: true, completion: nil)
    }
    
    func getAddress(fromlocation: CLLocation)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(fromlocation) {(placemarks,error) in
            if let error = error
            {
                self.showAlert(withTitle: "Error", message: error.localizedDescription)
            }
            else if let placemarks = placemarks
            {
                for i in placemarks{
                    self.city = i.locality ?? ""
                    let address = [i.name,
                    i.subThoroughfare,
                    i.thoroughfare,
                    i.locality,
                    i.country,
                    i.postalCode].compactMap({$0}).joined(separator: ", ")
                    print(address)
                    
                }
                if self.city != ""
                {
                    self.currentlocation.text = self.city
                    self.fetchWeatherDetails(city: self.city)
                }
                
            }
        }
    }
    
    func fetchWeatherDetails(city : String)
    {
        WeatherApiManager.getWeatherDetails(city: city){(Response , Error) in
            guard let response = Response else { return }
//            let temperature = 291.0
            self.kelTemp = response.main?.temp ?? 0.0
            self.kelTempmin = response.main?.temp_min ?? 0.0
            self.kelTempmax = response.main?.temp_max ?? 0.0
            self.convertToCelsius()
        
            
        }
    }
    
    func convertTemp(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
      mf.numberFormatter.maximumFractionDigits = 0
      mf.unitOptions = .providedUnit
      let input = Measurement(value: temp, unit: inputTempType)
      let output = input.converted(to: outputTempType)
      return mf.string(from: output)
    }
    
    
    
}
extension ViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last
        {
            locationManager.stopUpdatingLocation()
            getAddress(fromlocation: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(withTitle: "Error", message: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationPermessions()
    }
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayWeather", for: indexPath) as! WeatherDayCollectionViewCell
        if celsium
        {
            cell.day.text = self.dayArr[indexPath.row]
            cell.temp.text = self.convertTemp(temp: self.tempArr[indexPath.row], from: .kelvin, to: .celsius)
            
        }
        else
        {
            cell.day.text = self.dayArr[indexPath.row]
            cell.temp.text = self.convertTemp(temp: self.tempArr[indexPath.row], from: .kelvin, to: .fahrenheit)
        }
        
        return cell
    }
}

