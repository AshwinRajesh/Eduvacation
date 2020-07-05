//
//  PopupViewController.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/3/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import CoreLocation
import UIKit

var correct = false

class PopupViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let rest = RestManager()
    
    var q: Question? = nil
    
    var userLocation: CLLocationCoordinate2D? = nil

    @IBOutlet weak var home: UIButton!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var quizButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var question: UITextView!
    @IBOutlet weak var response: UITextField!
    @IBOutlet weak var sub: UIButton!
    @IBAction func submit(_ sender: UIButton) {
        question.font = UIFont(name: question.font!.fontName, size: 24)
        if (response.text == q!.answer) {
            question.text = "Correct!"
            complete.append(placeTitle)
        } else {
            question.text = "Incorrect. Try again!"
        }
        sub.isHidden = true
        mapButton.isHidden = false
        response.isHidden = true
    }
    
    @IBAction func end(_ sender: UIButton) {
        tripEnded = false
        self.performSegue(withIdentifier: "home", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        question.font = UIFont(name: question.font!.fontName, size: 16)
        popupView.layer.cornerRadius = 5
        mapButton.layer.cornerRadius = 5
        quizButton.layer.cornerRadius = 5
        sub.layer.cornerRadius = 5
        home.layer.cornerRadius = 5
        response.isHidden = true
        sub.isHidden = true
        if (tripEnded) {
            home.isHidden = false
            mapButton.isHidden = true
            response.isHidden = true
            quizButton.isHidden = true
            question.font = UIFont(name: question.font!.fontName, size: 24)
            question.isHidden = false
            if (per < 30.0) {
                question.text = "Hope you visit us more next time!"
            } else if (per < 60.0) {
                question.text = "Nice work!"
            } else if (per < 100.0) {
                question.text = "Amazing!"
            } else {
                question.text = "WOW! You're an explorer!"
            }
            name.text = selectedCityName
        } else {
            if (complete.contains(placeTitle)) {
                quizButton.isHidden = true
                question.isHidden = false
                question.font = UIFont(name: question.font!.fontName, size: 24)
                question.text = "Complete!"
            } else {
                quizButton.isHidden = false
                question.isHidden = true
            }
            home.isHidden = true
            name.text = placeTitle
            mapButton.isHidden = false
        }
        
        locationManager.requestAlwaysAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
            print("Yee")
        }
        
    }
    
    @IBAction func openQuestion(_ sender: UIButton) {
        print(placeCoordinate!)
        print(distance(point1: userLocation!, point2: placeCoordinate!))
        if (distance(point1: userLocation!, point2: placeCoordinate!) < 0.002) {
            print("In position")
            q = retrieveQuestion(place: placeTitle, city: selectedCityName as! String) as? Question
            mapButton.isHidden = true
            quizButton.isHidden = true
            question.isHidden = false
            response.isHidden = false
            sub.isHidden = false
            question.text = q!.question
        } else {
            print("Out of position")
            quizButton.isHidden = true
            question.isHidden = false
            question.font = UIFont(name: question.font!.fontName, size: 24)
            question.text = "Move closer to this location first!"
        }
        
        
        
    }
    
    func distance(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
        let lng2 = point1.longitude
        let lng1 = point2.longitude
        let lat1 = point1.latitude
        let lat2 = point2.latitude
        return sqrt(pow(lng2 - lng1, 2) + pow(lat2 - lat1, 2))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location.coordinate
            print(userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func updateProgress() {
        //let parent = self.parent! as! ViewController
        (self.parent! as! ViewController).percent.text = String(Int(per)) + "%"
        (self.parent! as! ViewController).progress.frame = CGRect(x: (self.parent! as! ViewController).progress.frame.minX, y: (self.parent! as! ViewController).progress.frame.minY, width: CGFloat(per * 3.05), height: (self.parent! as! ViewController).progress.frame.height)
    }
    
    
    @IBAction func closePopup(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: nil)
        self.view.removeFromSuperview()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func retrieveQuestion(place: String, city: String) -> Question? {
        let newStr = place.replacingOccurrences(of: " ", with: "+")
        let newStr2 = city.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "http://127.0.0.1:5000/questions?name=" + newStr + "&city=" + newStr2) else {
            print("Error creating URL.")
            return nil
        }
        
        let queue = DispatchQueue(label: "Queue")
        let group  = DispatchGroup()
        
        var output: Question? = nil
        
        queue.sync {
            group.enter()
            rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
                if let data = results.data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    guard let response = try? decoder.decode(Question.self, from: data) else { return }
                    output = response
                    group.leave()
                }
                
            }
            group.wait(timeout: .distantFuture)
        }
        return output
        
    }

}
