//
//  login_items.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

//get login items - this will be a doozy
func getLoginItems(users: Array<String>, system_info: SystemInfo) -> Array<Application> {
    var loginApps:[String] = []
    var loginItems = Array<Application>()
    
    for i in users {
        let plist_file = "/Users/\(i)/Library/Application Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: plist_file) {
            continue
        }
        let plist = NSDictionary(contentsOf: URL(fileURLWithPath: plist_file))
        
        let objects = plist!["$objects"] as! NSArray?
        if objects == nil {
            return loginItems
        }
        for object in objects! {
            if object is NSData {
                let bookmark = object as! Data
                var properties = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmark)! as NSDictionary
                loginApps.append(((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"]) as! String)
                //print((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"])
            }
            else if object is NSDictionary {
                let item = object as! NSDictionary
                if item["NS.data"] != nil {
                    let bookmark = item["NS.data"] as! Data
                    var properties = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmark)! as NSDictionary
                    loginApps.append(((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"]) as! String)
                }
            }
        }
    }

    loginApps = Array(Set(loginApps))
    for app in loginApps{
        //var loginItems = [String:Any]()
        loginItems.append(parseApp(app_path: app, system_info: system_info))
        //loginItems.updateValue("login_items", forKey: "module")
        //loginItems.updateValue(getSystemInfo()["hostname"]!, forKey: "hostname")
        //loginItems.updateValue(getSystemInfo()["UUID"]!, forKey: "UUID")

    }
    return loginItems
}
