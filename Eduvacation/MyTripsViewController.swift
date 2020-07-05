//
//  MyTripsViewController.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/3/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import UIKit

class MyTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var back: UIButton!
    
    var locations: [LocationData]? = []
    
    //var myTrips = ["London": 56, "Paris": 100, "New York": 0]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trip") as! TripTableViewCell
        //let keys = Array(myTrips.keys)
        cell.name.text = locations![indexPath.row].city
        cell.name.layer.zPosition = 1
        cell.percent.text = String(locations![indexPath.row].percent) + "%"
        let width = CGFloat(3.34 * Float(locations![indexPath.row].percent) + 80.0)
        cell.graphic.frame = CGRect(x: cell.graphic.frame.maxX - width, y: cell.graphic.frame.minY, width: width, height: cell.graphic.frame.height)
        
        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locations = loadData()
        
        if let locations = locations {
            
        } else {
            locations = []
        }
        
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
    
    private func loadData() -> [LocationData]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: LocationData.ArchiveURL.path) as? [LocationData]
    }

}
