//
//  ApiManager.swift
//  WeatherApp
//
//  Created by mysmac_admin on 09/05/21.
//

import UIKit
import Alamofire
import ObjectMapper
import SwiftyJSON


public enum Result<T, U> {
    case Success(T)
    case Failure(U)
}


public class ApiManager {
    
 
    private init(){}
    public typealias ResultCallback = (Result<Any, Error>) -> Void
    public typealias notificationcallback = (String, String) -> Void
    
    
     class func executeRequest1(_ urlString: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, _ headers :HTTPHeaders? = nil, onCompletion: @escaping ResultCallback) {
        
            
             DispatchQueue.main.async {
                Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding)
                    .validate(statusCode: 200..<300)
                    .responseJSON { (response) in
                        print(response)
                       
                        switch response.result {
                        case .success( _):
                            handleApiSuccessResponse(response: response, onCompletion: onCompletion)
                        case .failure( _):
                            print("Some Error Occured")
                        }
                    }
                }
       }
    
    
    
    
    static func handleApiSuccessResponse(response: DataResponse<Any>, onCompletion:  @escaping ResultCallback) {
        
        do {
            
            if let object = response.result.value as?  NSInteger{
                print(object)
                onCompletion( .Success(object))
            }
            if let object = response.result.value as?  String{
                print(object)
                onCompletion( .Success(object))
            }
            if let object = response.result.value as?  [String]{
                print(object)
                if object.count > 0 {
                    onCompletion( .Success(object))
                }
            }
            
            if let object = response.response?.allHeaderFields["Location"] as? String
            {
                print(object)
                onCompletion(  .Success(object))
            }
            let  json = try JSON(data: response.data!)
            
            if let _: Int = response.response?.statusCode{
                
                onCompletion( .Success(json.rawString()!))
            } else {
                print("Some error Occured.")
            }
        } catch let error  as NSError {
            print("\(error)")
        }
    }
}
    
