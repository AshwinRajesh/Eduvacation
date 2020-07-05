//
//  DestinationViewController.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/3/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import UIKit

var selectedCityName = ""
var selectedCityLat: Float = 0.0
var selectedCityLng: Float = 0.0
var selectedCityCompleted: [String] = []
var selectedCity: City? = nil

class DestinationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var back: UIButton!
    var cities: [City] = []
    var names: [String] = []
    var filtered: [String] = []
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var table: UITableView!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = searchText.isEmpty ? names : names.filter({(dataString: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "City") as! CityTableViewCell
        
        let cityName = filtered[indexPath.row]
        cell.name.text = cityName
        
        
        return cell
    }
    
    
    let rest = RestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        cities = retrieveCities()!
        for city in cities {
            print(city.lat)
            names.append(city.name as! String)
        }
        filtered = names
        search.delegate = self
        table.delegate = self
        table.dataSource = self
        back.layer.cornerRadius = 5
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = filtered[indexPath.row]
        for city in cities {
            if (name == city.name as! String) {
                
                selectedCityName = city.name as! String
                selectedCityLat = city.lat as! Float
                selectedCityLng = city.lng as! Float
                selectedCityCompleted = []
                print(selectedCityLat)
                selectedCity = city
                
                self.performSegue(withIdentifier: "map", sender: nil)
            }
        }
    }
    
    func retrieveCities() -> [City]? {
        guard let url = URL(string: "http://127.0.0.1:5000/cities") else {
            print("Error creating URL.")
            return nil
        }
        
        let queue = DispatchQueue(label: "Queue")
        let group  = DispatchGroup()
        
        var output: [City]? = nil
        
        queue.sync {
            group.enter()
            rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
                if let data = results.data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    guard let response = try? decoder.decode(Cities.self, from: data) else { return }
                    output = response.cities as! [City]
                    group.leave()
                }
                
            }
            group.wait(timeout: .distantFuture)
        }
        return output
        
    }

}
