//
//  HomePageViewController.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/3/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {

    
    var locations: [LocationData]? = []
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    var inProgress = false
    var current: LocationData? = nil
    
    @IBOutlet weak var tripLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        inProgress = false
        
        locations = loadData()
        if let loc = locations {
            locations = locations as! [LocationData]
            print(locations)
            for location in locations! {
                print(location.done)
                if (!location.done) {
                    inProgress = true
                    current = location
                }
            }
        }
        
        if (inProgress) {
            tripLabel.text = "Continue Trip"
        } else {
            tripLabel.text = "Start A Trip"
        }
        startButton.layer.cornerRadius = 5
        viewButton.layer.cornerRadius = 5
    }
    
    @IBAction func start(_ sender: UIButton) {
        if (inProgress) {
            selectedCityName = current!.city
            selectedCityLat = current!.lat
            selectedCityLng = current!.lng
            selectedCityCompleted = current!.completed
            self.performSegue(withIdentifier: "map", sender: nil)
        } else {
            self.performSegue(withIdentifier: "startTrip", sender: nil)
        }
    }
    
    private func loadData() -> [LocationData]? {
        print(LocationData.ArchiveURL.path)
        return NSKeyedUnarchiver.unarchiveObject(withFile: LocationData.ArchiveURL.path) as? [LocationData]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
