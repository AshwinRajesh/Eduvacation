//
//  ViewController.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/2/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import MapKit
import UIKit
import NotificationCenter

var cityPlaces: [Place] = []
var placeTitle: String = ""
var complete: [String] = []
var per: Float = 0.0
var placeCoordinate: CLLocationCoordinate2D? = nil
var tripEnded = false

class ViewController: UIViewController, MKMapViewDelegate {
    
    let rest = RestManager()
    
    @IBOutlet weak var numLocations: UILabel!
    @IBOutlet weak var end: UIButton!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var back: UIButton!
    
    var locations: [LocationData]? = []
    
    func update() {
        per = Float(complete.count) / Float(cityPlaces.count) * 100
        percent.text = String(Int(per)) + "%"
        progress.frame = CGRect(x: progress.frame.minX, y: progress.frame.minY, width: CGFloat(per * 3.05), height: progress.frame.height)
    }
    
    @objc func updateProgress(_ notification: Notification) {
        update()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        map.delegate = self
        
        map.showsUserLocation = true
        
        locations = loadData()
        
        progress.layer.masksToBounds = true
        total.layer.masksToBounds = true
        total.layer.cornerRadius = 10
        progress.layer.cornerRadius = 10
        back.layer.cornerRadius = 5
        end.layer.cornerRadius = 5
    
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name: NSNotification.Name(rawValue: "notificationName"), object: nil)
        
        let cityName = selectedCityName
        name.text = cityName
        
        cityPlaces = []
        
        
        let pl = places(city: cityName) as? [Place]
        print(pl!.count)
        if let pl = pl {
            for place in pl {
                let name = place.name as! String
                let ratings = place.userRatingsTotal as! Int
                let tags = place.types as! [String]
                let lng = place.geometry?.location!.lng as! Float
                let lat = place.geometry?.location!.lat as! Float
                
                if ((ratings > 3000 || (tags.contains("museum") && ratings > 500)) && !tags.contains("amusement_park") && !tags.contains("restaurant")) {
                    cityPlaces.append(place)
                    let marker = MKPointAnnotation()
                    marker.title = name
                    marker.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
                    map.addAnnotation(marker)
                }
            }
        }
        
        complete = selectedCityCompleted
        update()
        
        numLocations.text = String(cityPlaces.count) + " locations"
        
        let userCenter = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: selectedCityLat)!, longitude: CLLocationDegrees(exactly: selectedCityLng)!)
        
        let region = MKCoordinateRegion(center: userCenter, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        map.setRegion(region, animated: true)
    
        
        /*question(place: "Space Center Houston", completion: {question in
            if let question = question {
                print(question.question as! String)
                print(question.answer as! String)
            }
        })*/
        
    }
    
    @IBAction func endTrip(_ sender: UIButton) {
        let b = updateLocations(done: true)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: LocationData.ArchiveURL.path)
        
        if isSuccessfulSave {
            print("Locations successfully saved.")
        } else {
            print("Failed to save locations.")
        }
        
        tripEnded = true
        let pop = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopupViewController
        self.addChild(pop)
        pop.view.frame = self.view.frame
        self.view.addSubview(pop.view)
        pop.didMove(toParent: self)
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        placeTitle = annotation!.title as! String
        placeCoordinate = annotation!.coordinate as! CLLocationCoordinate2D
        let pop = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopupViewController
        self.addChild(pop)
        pop.view.frame = self.view.frame
        self.view.addSubview(pop.view)
        pop.didMove(toParent: self)
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        let b = updateLocations(done: false)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: LocationData.ArchiveURL.path)
        
        if isSuccessfulSave {
            print("Locations successfully saved.")
        } else {
            print("Failed to save locations.")
        }
        self.performSegue(withIdentifier: "home", sender: nil)
    }
    
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (complete.contains(annotation.title as! String)) {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "demo") as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "demo")
            }
            else {
                annotationView!.annotation = annotation
            }
        
            let image = resizeImage(image: UIImage(named: "checkmark.png")!, targetSize: CGSize(width: 40, height: 40))
        
            annotationView!.image = image
        
        /*let annotationLabel = UITextView(frame: CGRect(x: -55, y: 32, width: 150, height: 100))
        annotationLabel.backgroundColor = nil
        //annotationLabel.textColor = UIColor.gray
        annotationLabel.textAlignment = .center
        annotationLabel.layer.shadowRadius = 3.0
        annotationLabel.layer.shadowOpacity = 0.3
        annotationLabel.font = UIFont(name: "Avenir-Heavy", size: 14)
        annotationLabel.text = annotation.title!
        annotationView!.addSubview(annotationLabel)*/
        
            return annotationView
        } else {
            return nil
        }
    }*/
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.camera.altitude < 2500 {
            mapView.camera.altitude = 2500
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func places(city: String) -> [Place]? {
        let newStr = city.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=attractions+in+" + newStr + "&key=AIzaSyAlAeY7uOTtucpKq1XzNo2Od2BHkOh130U") else {
            print("Error creating URL.")
            return nil
        }
        
        let queue = DispatchQueue(label: "Queue")
        let group  = DispatchGroup()
        
        // The following will make RestManager create the following URL:
        // https://reqres.in/api/users?page=2
        // rest.urlQueryParameters.add(value: "2", forKey: "page")
        
        var output: [Place]? = nil
        
        queue.sync {
            group.enter()
            self.rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
                if let data = results.data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    guard let response = try? decoder.decode(Result.self, from: data) else { return }
                    /*DispatchQueue.main.async {
                     self.bookData.text = String(userData.result!)
                     }*/
                    output = response.results!
                    group.leave()
                }
                
                /*print("\n\nResponse HTTP Headers:\n")
                
                if let response = results.response {
                    for (key, value) in response.headers.allValues() {
                        print(key, value)
                    }
                }*/
            }
            group.wait(timeout: .distantFuture)
        }
        return output
    }
    
    func updateLocations(done: Bool) -> Bool {
        print(selectedCityName)
        for location in locations! {
            print(location.city)
            if (selectedCityName == location.city) {
                location.completed = complete
                location.percent = Int(per)
                location.done = done
                return true
            }
        }
        let newLocation = LocationData(city: selectedCityName, completed: complete, percent: Int(per), done: false, lat: selectedCityLat, lng: selectedCityLng)
        locations!.append(newLocation!)
        return true
    }
    
    private func loadData() -> [LocationData]? {
        print(LocationData.ArchiveURL.path)
        return NSKeyedUnarchiver.unarchiveObject(withFile: LocationData.ArchiveURL.path) as? [LocationData]
    }

}

