//
//  autocompleteSearchViewController.swift
//  GoogleMapsEx
//  Created by M Shankar on 26/03/21.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import SQLite3


var g_lat: String!
var g_long: String!
var g_address: String!

var mapAddress = [LocStore]()


protocol LocateOnTheMap {
    func locateWithLong(lon: String, andLatitude lat: String, andAddress address: String)
}


class autocompleteSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate {
    
    
    var db:DBHelper = DBHelper()

    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var placeIDArray = [String]()
    var resultsArray = [String]()
    var primaryAddressArray = [String]()
    var searchResults = [String]()
    var searhPlacesName = [String]()
    let googleAPIKey = "AIzaSyDsIG8XXKNR2B1pklpLlbx1cXh0GI7k76E"
    var delegate: LocateOnTheMap?
  
    
    
    //search Controller implementations
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewSetup()
        setSearchController()
     
    }

    func tableViewSetup(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.backgroundColor = UIColor.white
    }
    func setSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.title = "Autocomplete"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.delegate = self
        searchController.searchBar.showsScopeBar = true
    }
  
    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
   
  
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForTextSearch(searchText: String){
        placeAutocomplete(text_input: searchText)
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchController.searchBar.showsCancelButton = true
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    func isFiltering() -> Bool{
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBarIsEmpty()){
            searchBar.text = ""
        }else{
            placeAutocomplete(text_input: searchText)
            
        }
    }
    
    
    //Table view methods to be implemented
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive == true{
            return searchResults.count
        }else{
            return Locations.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        
        if searchController.isActive == true{
            cell.textLabel?.text = searchResults[indexPath.row]
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
        }else{
            cell.textLabel?.text = Locations[indexPath.row]
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
        }
        
        

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive == true{
        guard let correctedAddress = self.resultsArray[indexPath.row].addingPercentEncoding(withAllowedCharacters: .symbols) else {
            print("Error. cannot cast name into String")
            return
        }
        
        //print(correctedAddress)
        let urlString =  "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false&key=\(self.googleAPIKey)"
        
        let url = URL(string: urlString)
        
        Alamofire.request(url!, method: .get, headers: nil)
        .validate()
            .responseJSON { [self] (response) in
                switch response.result {
                case.success(let value):
                    let json = JSON(value)
                    print(json)
                    
                    let lat = json["results"][0]["geometry"]["location"]["lat"].rawString()
                    let lng = json["results"][0]["geometry"]["location"]["lng"].rawString()
                    let formattedAddress = json["results"][0]["formatted_address"].rawString()
                    
                    g_lat = lat
                    g_long = lng
                    g_address = formattedAddress
                    
                    if searchController.isActive{
                        mapAddress.append(LocStore(Location: g_address))
                    db.insert(Location:"\(mapAddress)")
                    }else{
                        print("no data")
                    }
                    //mapAddress.append(LocStore(Location: g_address))
                         
                          mapAddress = db.read()
                    
                    
                   
                 //  print(g_lat,g_long,g_address)
                    
                    //print(mapAddress)
                    self.dismiss(animated: true, completion: nil)
                
                    
                case.failure(let error):
                    print("\(error.localizedDescription)")
                }
            
                
        }
        }else{
            guard let savedAddress = Locations[indexPath.row].addingPercentEncoding(withAllowedCharacters: .symbols) else {
                print("Error. cannot cast name into String")
                return
            }
            
            //print(correctedAddress)
            let urlString =  "https://maps.googleapis.com/maps/api/geocode/json?address=\(savedAddress)&sensor=false&key=\(self.googleAPIKey)"
            
            let url = URL(string: urlString)
            
            Alamofire.request(url!, method: .get, headers: nil)
            .validate()
                .responseJSON { [self] (response) in
                    switch response.result {
                    case.success(let value):
                        let json = JSON(value)
                        print(json)
                        
                        let lat = json["results"][0]["geometry"]["location"]["lat"].rawString()
                        let lng = json["results"][0]["geometry"]["location"]["lng"].rawString()
                        let formattedAddress = json["results"][0]["formatted_address"].rawString()
                        
                        g_lat = lat
                        g_long = lng
                        g_address = formattedAddress
                        
                        self.dismiss(animated: true, completion: nil)
                    
                        
                    case.failure(let error):
                        print("\(error.localizedDescription)")
                    }
                
                    
            }
        }
        
    }
    //function for autocomplete
    func placeAutocomplete(text_input: String) {
        let filter = GMSAutocompleteFilter()
        let placesClient = GMSPlacesClient()
        filter.type = .establishment
        
        
        //geo bounds set for bengaluru region
        let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 13.001356, longitude: 75.174399), coordinate: CLLocationCoordinate2D(latitude: 13.343668, longitude: 80.272055))
        placesClient.autocompleteQuery(text_input, bounds: bounds, filter: nil) { (results, error) -> Void in
            self.placeIDArray.removeAll() //array that stores the place ID
            self.resultsArray.removeAll() // array that stores the results obtained
            self.primaryAddressArray.removeAll() //array storing the primary address of the place.
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                for result in results {
                    self.primaryAddressArray.append(result.attributedPrimaryText.string)
                    //print("primary text: \(result.attributedPrimaryText.string)")
                    //print("Result \(result.attributedFullText) with placeID \(String(describing: result.placeID!))")
                    self.resultsArray.append(result.attributedFullText.string)
                    self.primaryAddressArray.append(result.attributedPrimaryText.string)
                    self.placeIDArray.append(result.placeID)
                }
            }
            self.searchResults = self.resultsArray
            self.searhPlacesName = self.primaryAddressArray
            self.tableView.reloadData()
        }
    }
    
   
}
extension autocompleteSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForTextSearch(searchText: searchController.searchBar.text!)
    }
    
}
