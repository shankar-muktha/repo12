//
//  GoogleMapViewController.swift
//  GoogleMapsEx
//  Created by M Shankar on 26/03/21.

import SQLite3
import UIKit

var Locations = [String]()
class DBHelper
{

    init()
    {
        db = openDatabase()
        createTable()
    }

    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS LocationNames(Location String);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("Location table created.")
            } else {
                print("Location table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    func insert(Location:String)
    {
        let LocationNames = read()
        for l in LocationNames
        {
            if l.Location == Location
            {
                return
            }
        }
        let insertStatementString = "INSERT INTO LocationNames(Location) VALUES (?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 2, (Location as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row\(Location)")
                Locations.append(Location)
                print(Locations.count)
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read() -> [LocStore] {
        let queryStatementString = "SELECT * FROM Location;"
        var queryStatement: OpaquePointer? = nil
        var psns : [LocStore] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let loc = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                psns.append(LocStore(Location:loc))
                print("Query Result:")
                print("\(psns)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
    
   
}
