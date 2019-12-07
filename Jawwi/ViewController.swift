//
//  ViewController.swift
//  Jawwi
//
//  Created by Forat Bahrani on 12/6/19.
//  Copyright © 2019 Forat Bahrani. All rights reserved.
//

import UIKit

var night: Bool {
    if Date().hour > 6 && Date().hour < 18 {
        return false
    } else {
        return true
    }
}
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cvHourly: UICollectionView!
    @IBOutlet weak var cvDaily: UICollectionView!

    @IBOutlet weak var blurView: DesignableVisualView!
    @IBOutlet weak var vibrancyView: UIVisualEffectView!

    @IBOutlet weak var blurView2: DesignableVisualView!
    @IBOutlet weak var vibrancyView2: UIVisualEffectView!

    @IBOutlet weak var blurView3: DesignableVisualView!
    @IBOutlet weak var vibrancyView3: UIVisualEffectView!

    @IBOutlet weak var imgBackground: UIImageView!

    @IBOutlet weak var lblDegree: UILabel!
    @IBOutlet weak var btnLocation: DesignableButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnIcon: UIButton!
    @IBOutlet weak var btnWeather: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var lblWindSpeed: UILabel!

    var hourly : APIResponse? = nil
    var daily : APIResponse? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMe()
        getHourly()
        getDaily()
    }


    func getHourly() {
        let req = APIRequest()
        req.newAPI = true
        req.target = Target.hourlyMe
        req.onSuccess = {
            self.hourly = req.response
            self.cvHourly.reloadData()
        }
        req.onFail = {
            let d = req.rawResponse!
            let st = String(data: d, encoding: .utf8)
            print(st!)
            req.popErrorUp(on: self)
        }
        req.start()
    }
    
    func getDaily() {
        let req = APIRequest()
        req.newAPI = true
        req.target = Target.dailyMe
        req.onSuccess = {
            self.daily = req.response
            self.cvDaily.reloadData()
        }
        req.onFail = {
            let d = req.rawResponse!
            let st = String(data: d, encoding: .utf8)
            print(st!)
            req.popErrorUp(on: self)
        }
        req.start()
    }

    func getMe() {
        let req = APIRequest()
        req.target = Target.me
        req.onSuccess = {
            let degree = Int(req.response.main?.temp ?? 0) - 273
            print(degree)
            self.lblDegree.text = "\(degree)°C"
            self.lblDate.text = Date().dateString(format: "EEE, MMM d, yyyy, HH:mm")
            self.lblLocation.text = req.response.name ?? "Unkown Location"
            self.btnLocation.setTitle(req.response.name ?? "Unkown Location", for: .normal)
            switch req.response.weather?[0].main ?? "Clear" {
            case "Clouds":
                self.btnIcon.setImage(UIImage(systemName: "cloud.fill"), for: .normal)
                self.imgBackground.image = UIImage(named: night ? "cloud.night" : "cloud.day")
                break
            case "Rain", "Drizzle", "Thunderstorm":
                self.btnIcon.setImage(UIImage(systemName: "cloud.rain.fill"), for: .normal)
                self.imgBackground.image = UIImage(named: night ? "rain.night" : "rain.day")

                break
            case "Snow":
                self.btnIcon.setImage(UIImage(systemName: "snow"), for: .normal)
                self.imgBackground.image = UIImage(named: night ? "snow.night" : "snow.day")

                break
            default:
                if Date().hour > 6 && Date().hour < 18 {
                    self.btnIcon.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)

                } else {
                    self.btnIcon.setImage(UIImage(systemName: "moon.fill"), for: .normal)
                }
                self.imgBackground.image = UIImage(named: night ? "def.night" : "def.day")

            }
            self.btnWeather.text = req.response.weather?[0].main ?? "Clear"
            let hum = Int(req.response.main?.humidity ?? 0)
            self.lblHumidity.text = "Humidity: \(hum)%"
            let speed = Int(req.response.wind?.speed ?? 0)
            self.lblWindSpeed.text = "Wind Speed: \(speed) KMpH"

            let effect = UIBlurEffect(style: night ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
            self.blurView.effect = effect
            self.vibrancyView.effect = UIVibrancyEffect(blurEffect: effect)

            self.blurView2.effect = effect
            self.vibrancyView2.effect = UIVibrancyEffect(blurEffect: effect)

            self.blurView3.effect = effect
            self.vibrancyView3.effect = UIVibrancyEffect(blurEffect: effect)
        }
        req.onFail = {
            req.popErrorUp(on: self)
        }
        req.start()
    }





    // MARK: COLLECTIONS

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvHourly {
            return 12
        }
        if collectionView == cvDaily {
            return 7
        }
        fatalError()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if collectionView == cvHourly {
            guard let hourly = hourly else {
                return cell
            }
            
            let res = hourly.data![indexPath.row]
            let deg = res.temp
            let pop = res.pop ?? 0
            let icon = cell.contentView.viewWithTag(1) as! UIButton
            let time = cell.contentView.viewWithTag(2) as! UILabel
            let degree = cell.contentView.viewWithTag(3) as! UILabel
            let popLBL = cell.contentView.viewWithTag(4) as! UILabel

            // create dateFormatter with UTC time format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let date = dateFormatter.date(from: res.timestamp_utc!)

            // change to a readable time format and change to local time zone
            dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
            dateFormatter.timeZone = NSTimeZone.local
            let timeStamp = dateFormatter.string(from: date!)
            
            time.text = date!.dateString(format: "HH:mm")
            degree.text = "\(deg)°C"
            popLBL.text = "\(pop)%"
            
            let w =  res.weather!.description.lowercased()
            
            if w.contains("clouds") {
                icon.setImage(UIImage(systemName: "cloud.fill"), for: .normal)
            } else if w.contains("clear") {
                if Date().hour > 6 && Date().hour < 18 {
                    icon.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)

                } else {
                    icon.setImage(UIImage(systemName: "moon.fill"), for: .normal)
                }
            }  else if w.contains("rain") {
                 icon.setImage(UIImage(systemName: "cloud.rain.fill"), for: .normal)
            }  else if w.contains("snow") {
                icon.setImage(UIImage(systemName: "snow"), for: .normal)
            }
        } else if collectionView == cvDaily {
            guard let daily = daily else {
                return cell
            }
            
            let res = daily.data![indexPath.row]
            let deg = res.temp
            let max = res.high_temp ?? deg
            let min = res.low_temp ?? deg
            let icon = cell.contentView.viewWithTag(1) as! UIButton
            let time = cell.contentView.viewWithTag(2) as! UILabel
            let degree = cell.contentView.viewWithTag(3) as! UILabel
            let maxMin = cell.contentView.viewWithTag(4) as! UILabel

            // create dateFormatter with UTC time format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let date = dateFormatter.date(from: res.datetime)

            // change to a readable time format and change to local time zone
            dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
            dateFormatter.timeZone = NSTimeZone.local
            let timeStamp = dateFormatter.string(from: date!)
            
            time.text = date!.dateString(format: "EEEE")
            degree.text = "\(deg)°C"
            maxMin.text = "\(min)°C / \(max)°C"
            
            let w = res.weather!.description.lowercased()
            
            if w.contains("clouds") {
                icon.setImage(UIImage(systemName: "cloud.fill"), for: .normal)
            } else if w.contains("clear") {
                if Date().hour > 6 && Date().hour < 18 {
                    icon.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)

                } else {
                    icon.setImage(UIImage(systemName: "moon.fill"), for: .normal)
                }
            }  else if w.contains("rain") {
                 icon.setImage(UIImage(systemName: "cloud.rain.fill"), for: .normal)
            }  else if w.contains("snow") {
                icon.setImage(UIImage(systemName: "snow"), for: .normal)
            }
        }
        return cell
    }




}

