//
//  DataModel.swift
//  WeatherApp
//
//  Created by mysmac_admin on 09/05/21.
//

import Foundation
import ObjectMapper

class DataModel: NSObject, Mappable
{
    var weather : [weather]?
    var main : main?

    required init?(map: Map)
    {super.init()}

    func mapping(map: Map)
    {
        weather <- map["weather"]
        main <- map["main"]
    }
}
class weather: NSObject, Mappable
{
    var main : String?
    var id : Int?
    var desc : String?

    required init?(map: Map)
    {super.init()}

    func mapping(map: Map)
    {
        main <- map["main"]
        id <- map["id"]
        desc <- map["description"]
    }
}
class main: NSObject, Mappable
{
    var temp : Double?
    var temp_min : Double?
    var temp_max : Double?
    var humidity : Double?
    

    required init?(map: Map)
    {super.init()}

    func mapping(map: Map)
    {
        temp <- map["temp"]
        temp_min <- map["temp_min"]
        temp_max <- map["temp_max"]
        humidity <- map["humidity"]
    }
}
