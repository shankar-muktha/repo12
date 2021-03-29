//
//  GoogleMapViewController.swift
//  GoogleMapsEx
//  Created by M Shankar on 26/03/21.


import UIKit
import GoogleMaps
import GooglePlaces
import SQLite3


class GoogleMapViewController: UIViewController {

    func locateWithLong(lon: String, andLatitude lat: String, andAddress address: String) {
        DispatchQueue.main.async {
            
            let latDouble = Double(lat)
            let lonDouble = Double(lon)
            self.mapView.clear()
            let position = CLLocationCoordinate2D(latitude: latDouble ?? 20.0, longitude: lonDouble ?? 10.0)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: latDouble ?? 20.0, longitude: lonDouble ?? 10.0, zoom: 15)
            self.mapView.camera = camera
            self.searchButton.setTitle(address, for: .normal)
         

           marker.map = self.mapView
        }
    }
    

    //location manager for accessing current location of the device
    private let locationManager = CLLocationManager()
    
    
    
    @IBOutlet weak var searchButton: UIButton!
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //initializing CLLocationManager
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        
        //searchButton ui implementations
        self.searchButton.layer.cornerRadius = 15.0
        print("<<<<<<<<<>>>>>>>>>>>>>")
        print(g_lat)
    
        
        if g_lat != nil {
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            locateWithLong(lon:g_long,andLatitude:g_lat , andAddress: g_address)
        }else{

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if g_lat != nil {
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            locateWithLong(lon:g_long , andLatitude: g_lat, andAddress: g_address)
        }else{
            "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        }
    }
    
    
    
    @IBAction func btnAction(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(identifier: "autocompleteSearchViewController") as! autocompleteSearchViewController
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true, completion: nil)
        
    }
    
}

//implementing extension from CLLocationManagerDelegate
extension GoogleMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
        
    }
    
}
