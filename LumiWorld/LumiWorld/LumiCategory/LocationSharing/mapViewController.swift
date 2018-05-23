//
//  ViewController.swift
//  MapKitTutorial
//
//  Created by Robert Chen on 12/23/15.
//  Copyright © 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}
class locationTableViewCell: UITableViewCell {
    @IBOutlet var btnLocation: UIButton!

}

class mapViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var didFinishCapturingLocations: ((UIImage,Double,Double,String,String) -> Void)?
    static let shared = mapViewController()


    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    var currentLat : Double = 0
    var currentLong : Double = 0
    
    var liveLat : Double = 0
    var liveLong : Double = 0
    var strLocationAddress : String!
    let locationManager = CLLocationManager()
    let cellReuseIdentifier = "locationTableViewCell"
    var isFromChat = false

    @IBOutlet weak var mapBottomPadding: NSLayoutConstraint!
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let btnRefresh = self.navigationController?.navigationBar.viewWithTag(1000)
        if currentLat != 0 && currentLong != 0 {
           mapBottomPadding.constant = 0
            self.dropPinZoomIn(MKPlacemark.init(coordinate: CLLocationCoordinate2D.init(latitude: currentLat, longitude: currentLong)))
            tableView.isHidden = true
            btnRefresh?.isHidden = true
            self.navigationItem.title = strLocationAddress
        }
        else {
        mapBottomPadding.constant = 160
        btnRefresh?.isHidden = false
        tableView.isHidden = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
       // self.navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        navigationItem.title = "Select Location"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = resultSearchController
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = resultSearchController?.searchBar
        }
        }
        
        
    }
    
    @IBAction func onBtnCancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnRefreshTapped(_ sender: Any) {
        strLocationAddress = ""
        resultSearchController.searchBar.text = ""
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    @objc func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationTableViewCell", for: indexPath) as! locationTableViewCell

        if indexPath.row == 0 {
           cell.btnLocation.setTitle("Share Live Location", for: .normal)
            cell.btnLocation.setImage(UIImage(named: "CurrentLocation"), for: .normal)
        }
        else {
            cell.btnLocation.setTitle("Send Your Current Location", for: .normal)
            cell.btnLocation.setImage(UIImage(named: "Location"), for: .normal)

        }
        cell.btnLocation?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        cell.btnLocation.isEnabled = false
        cell.btnLocation.setTitleColor(UIColor.lumiGray, for: .normal)

        // set the text from the data model
        cell.btnLocation.titleLabel?.text = ""
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("You tapped cell number \(indexPath.row).")
        var staticMapUrl: String!
        var selectedLat : Double = 0
        var selectedLong : Double = 0

        if indexPath.row == 0 {
            staticMapUrl = "http://maps.google.com/maps/api/staticmap?markers=color:red|\(liveLat),\(liveLong)&\("zo om=13&size=\(2 * Int(100))x\(2 * Int(150))")&sensor=true"
            selectedLat = liveLat
            selectedLong = liveLong
        }
        else {
            staticMapUrl = "http://maps.google.com/maps/api/staticmap?markers=color:red|\(currentLat),\(currentLong)&\("zo om=13&size=\(2 * Int(100))x\(2 * Int(150))")&sensor=true"
            selectedLat = currentLat
            selectedLong = currentLong

        }
        
        let url = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        do {
            let data = try NSData(contentsOf: url!, options: NSData.ReadingOptions())
            let img = UIImage(data: data as Data) as! UIImage
            
            let objMessage = LumiMessage()

            if data.length > 0 {
                let strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName: "location.png")
                if isFromChat {

                    let firstName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName
                    let lastName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName
                    
                    var nSubjectID : Double? = nil
                    nSubjectID = GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubjectId
                    
                    let name = firstName! + " \(lastName as! String)"
                    let sentBy: String = GlobalShareData.sharedGlobal.userCellNumber + "-\(name)"
                    
                    let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                    hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
                    objMessage.sendLumiAttachmentMessage(param: ["newsFeedBody":strLocationAddress as AnyObject,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.name! as AnyObject,"enterpriseRegnNmbr":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber! as AnyObject,"messageCategory":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageCategory as AnyObject,"messageType":"1" as AnyObject,"sentBy":sentBy as AnyObject,"imageURL":"" as AnyObject,"longitude":selectedLong as AnyObject,"latitude":selectedLat as AnyObject,"messageSubject":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubject! as AnyObject,"messageSubjectId":nSubjectID as AnyObject],filePath:strFilePath, completionHandler: {(error) in
                        DispatchQueue.main.async {
                            hud.hide(animated: true)}
                        if error != nil  {
                            self.showCustomAlert(strTitle: "", strDetails: (error?.localizedDescription)!, completion: { (str) in
                            })
                        }
                        DispatchQueue.main.async {
                            GlobalShareData.sharedGlobal.removeFilefromDocumentDirectory(fileName: strFilePath)
                            self.navigationController?.popViewController(animated: false)
                        }
                    })
                }
                else {
                    self.didFinishCapturingLocations!(img,selectedLat,selectedLong,strFilePath,strLocationAddress)
                    self.navigationController?.popViewController(animated: true)
                }

            }
        } catch {
            let img = UIImage()
        }
    }

}

extension mapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        liveLat =  (location.coordinate.latitude)
        liveLong =  (location.coordinate.longitude)
        currentLat =  (location.coordinate.latitude)
        currentLong =  (location.coordinate.longitude)

        getAddressFrom(location: location) { (address) in
            print(address)
            self.strLocationAddress = address
        }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    func getAddressFrom(location: CLLocation, completion:@escaping ((String?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first,
                let subThoroughfare = placemark.subThoroughfare,
                let thoroughfare = placemark.thoroughfare,
                let locality = placemark.locality,
                let administrativeArea = placemark.administrativeArea {
                let address = subThoroughfare + " " + thoroughfare + ", " + locality + " " + administrativeArea
                
                placemark.addressDictionary
                
                return completion(address)
                
            }
            completion(nil)
        }
    }


}

extension mapViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
          if let strcountry = placemark.country, let strname = placemark.name {
            strLocationAddress = "\(strname) \(city) \(state) \(strcountry)"
            }
        }
        currentLat =  (placemark.location?.coordinate.latitude)!
        currentLong =  (placemark.location?.coordinate.longitude)!

        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}

extension mapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
        button.addTarget(self, action: #selector(mapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}
