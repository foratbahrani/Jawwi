//
//  CitiesViewController.swift
//  Jawwi
//
//  Created by Forat Bahrani on 12/7/19.
//  Copyright © 2019 Forat Bahrani. All rights reserved.
//

import UIKit

func cities() -> [String] {
    let defaults = UserDefaults.standard
    let myarray = defaults.stringArray(forKey: "SavedStringArray") ?? [String]()
    return myarray
}

func addCity(name: String) {
    var c = cities()
    c.append(name)
    let defaults = UserDefaults.standard
    defaults.set(c, forKey: "SavedStringArray")
}

func removeCity(name: String) {
    var c = cities()
    for i in 0..<c.count {
        if c[i].lowercased().contains(name.components(separatedBy: " ")[0].lowercased()) {
            c.remove(at: i)
            break
        }
    }
    let defaults = UserDefaults.standard
    defaults.set(c, forKey: "SavedStringArray")
}

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.contentView.longPress { (g) in
            if g.state == .began {
                let sheet = UIAlertController(title: "Delete?", message: "Do you want to delete this city?", preferredStyle: UIAlertController.Style.actionSheet)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    removeCity(name: (cell.contentView.viewWithTag(1) as! UILabel).text!)
                    self.tableView.reloadData()
                }
                sheet.addAction(delete)
                sheet.addAction(cancel)
                
                self.present(sheet, animated: true, completion: nil)
            }
        }
        
        let req = APIRequest()
        req.target = Target.city(name: cities()[indexPath.row])
        req.onSuccess = {
            let degree = Int(req.response.main?.temp ?? 0) - 273
            let max = Int(req.response.main?.temp_max ?? 0) - 273
            let min = Int(req.response.main?.temp_min ?? 0) - 273

            (cell.contentView.viewWithTag(3) as! UILabel).text = "\(degree)°C"
            
            (cell.contentView.viewWithTag(4) as! UILabel).text = "\(min)°C / \(max)°C"

            (cell.contentView.viewWithTag(2) as! UILabel).text = Date().dateString(format: "EEE, MMM d, yyyy, HH:mm")
            (cell.contentView.viewWithTag(1) as! UILabel).text = req.response.name ?? "Unkown Location"
            switch req.response.weather?[0].main ?? "Clear" {
            case "Clouds":
                (cell.contentView.viewWithTag(6) as! UIButton).setImage(UIImage(systemName: "cloud.fill"), for: .normal)
                (cell.contentView.viewWithTag(-1) as! UIImageView).image = UIImage(named: night ? "cloud.night" : "cloud.day")
                break
            case "Rain", "Drizzle", "Thunderstorm":
                (cell.contentView.viewWithTag(6) as! UIButton).setImage(UIImage(systemName: "cloud.rain.fill"), for: .normal)
                (cell.contentView.viewWithTag(-1) as! UIImageView).image = UIImage(named: night ? "rain.night" : "rain.day")

                break
            case "Snow":
                (cell.contentView.viewWithTag(6) as! UIButton).setImage(UIImage(systemName: "snow"), for: .normal)
                (cell.contentView.viewWithTag(-1) as! UIImageView).image = UIImage(named: night ? "snow.night" : "snow.day")

                break
            default:
                if Date().hour > 6 && Date().hour < 18 {
                    (cell.contentView.viewWithTag(6) as! UIButton).setImage(UIImage(systemName: "sun.max.fill"), for: .normal)

                } else {
                    (cell.contentView.viewWithTag(6) as! UIButton).setImage(UIImage(systemName: "moon.fill"), for: .normal)
                }
                (cell.contentView.viewWithTag(-1) as! UIImageView).image = UIImage(named: night ? "def.night" : "def.day")

            }
            let hum = Int(req.response.main?.humidity ?? 0)
            (cell.contentView.viewWithTag(5) as! UILabel).text = "\(hum)%"
        }
        req.onFail = {
            req.popErrorUp(on: self)
        }
        req.start()
        return cell
    }

    @IBAction func btnAddAction(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add a City", message: "Please Enter the City Name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "City Name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Country Name"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let city = alert!.textFields![0].text
            let country = alert!.textFields![1].text
            if city?.count == 0 || country?.count == 0 {
                return
            }
            let name = "\(city!),\(country!)"
            print(name)
            addCity(name: name)
            self.tableView.reloadData()
        }))
        

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
}
