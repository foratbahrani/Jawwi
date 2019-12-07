//
//  APIRequest.swift
//  Base
//
//  Created by Forat Bahrani on 7/1/18.
//  Copyright © 2018 Forat Bahrani. All rights reserved.
//

import Foundation
import UIKit


struct Target {
    static var me : String {
        return "weather?q=Kuwait&APPID=082decce5ae0b6d92995264757f9d780"
        //forecast/hourly?q=
    }
    static var hourlyMe : String {
        return "forecast/hourly?city=Kuwait&key=574e7ef938264d6b94f9bb1632eeca7d&hours=12"
    }
    static func city(name: String) -> String {
        return "weather?q=\(name)&APPID=082decce5ae0b6d92995264757f9d780"
    }
    static var dailyMe : String {
        return "forecast/daily?city=Kuwait&key=574e7ef938264d6b94f9bb1632eeca7d"
    }
}

// you get this from APIRequest.response
struct APIResponse: Decodable {
    var weather : [Weather]?
    var main : Main?
    var wind : Wind?
    var name : String?
    var list : [LIST]?
    var data : [WData]?
}

struct WData : Decodable {
    var timestamp_utc : String?
    var datetime : String
    var high_temp : Double?
    var temp : Double
    var low_temp : Double?
    var rh : Double?
    var pop : Double?
    var weather : WWeather?
}

struct WWeather : Decodable {
    var description : String
}
struct Weather: Decodable {
    var main: String
}
struct Main: Decodable {
    var temp: Double // kelvin
    var humidity : Int
    var temp_min : Double
    var temp_max : Double
}
struct Wind: Decodable {
    var speed: Double
}

struct LIST: Decodable {
    var dt : Int
    var main : Main
    var weather : [Weather]?
    var wind : Wind?
}

// the base request, handles required info
class BaseRequest: NSObject {

//    static let baseUrl = "http://api.rezamotlagh.com/eslah/".toURL!
    static let baseUrl = "http://api.openweathermap.org/data/2.5/"
    static let baseUrl2 = "https://api.weatherbit.io/v2.0/"

    var target: String = ""
    var parameters: JSON = JSON([])
    var rawResponse: Data? = nil

    var onSuccess: (() -> ())? = nil
    var onFail: (() -> ())? = nil

    fileprivate var urlSession = URLSession()
}

class APIRequest: BaseRequest {
    var delay: Double = 0
    fileprivate var urlRequest: URLRequest? = nil
    var response: APIResponse = APIResponse(weather: nil, main: nil, wind: nil)
    var processJson = true

    convenience init(withTarget target: String) {
        self.init()
        self.target = target
    }

    func popErrorUp(on viewController: UIViewController) {
        viewController.present(title: "Error", message: "Something Went Wrong", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
    }

    var uparams: [String] = []
    private func getUParams() -> String {
        var u = ""
        var first = true
        for p in uparams {
            u.append(first ? "\(p)" : "&\(p)")
            if first { first = false }
        }
        return u
    }

    var calledUrl: URL? = nil
    var newAPI = false
    func start() {

        let url = ( (newAPI ? BaseRequest.baseUrl2 : BaseRequest.baseUrl) + target).toURL!

        urlRequest = URLRequest(url: url)
        calledUrl = url
        print(url.absoluteString)

        URLSession.shared.dataTask(with: urlRequest!, completionHandler: { (data, urlResponse, error) in

            self.rawResponse = data
            if error != nil { self.onFail?(); return}

            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                if (error == nil) {
                    if self.processJson {
                        do {
                            self.response = try JSONDecoder().decode(APIResponse.self, from: data ?? Data())
                            self.onSuccess?()
                        } catch let error as NSError {
                            print("API JSON Conversion Failed at \(url.absoluteString) with error: " + error.description)
                            self.onFail?()
                        }
                    } else {
                        self.onSuccess?()
                    }
                } else {
                    self.onFail?()
                }
            }
        }).resume()
    }
}


extension String {
    var toURL : URL? {
        guard let str = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: str)
    }
}



extension UIViewController {
    func present(title: String, message: String, actions: [UIAlertAction], alertType: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertType)
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    class func visibleViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return visibleViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return visibleViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return visibleViewController(controller: presented)
        }
        return controller
    }
    public func alert(_ title: String) {
        self.present(title: title, message: "", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)], alertType: .alert)
    }
}
