//
//  WeatherApiManager.swift
//  WeatherApp
//
//  Created by mysmac_admin on 09/05/21.
//


import Foundation
import ObjectMapper

class WeatherApiManager : ApiManager
{
    typealias getWeatherDetailsCallback = (DataModel?, Error?) -> Void
    class func getWeatherDetails(city:String, onCompletion: @escaping getWeatherDetailsCallback) {
        
        let url = "https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=b3e2e0e77b70aae7591f5f85d1beba7e"
        executeRequest1(url) { (response) in
            switch response {
            case .Success(let json):
                print("Success")
                if let Response = Mapper<DataModel>().map(JSONString: json as! String){
                    onCompletion(Response, nil)
                }
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
}
