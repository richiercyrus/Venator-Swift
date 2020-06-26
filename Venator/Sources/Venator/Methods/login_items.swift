//
//  login_items.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

func runLoginItems(usernames: Array<String>, system_info: SystemInfo) {
    print("[+] Gathering LoginItems")
    let login_items = getLoginItems(users: usernames, system_info: system_info)
    if login_items.count > 0 {
        config.venator_data.login_items = login_items
    }
}

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
                let properties = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmark)! as NSDictionary
                loginApps.append(((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"]) as! String)
            }
            else if object is NSDictionary {
                let item = object as! NSDictionary
                if item["NS.data"] != nil {
                    let bookmark = item["NS.data"] as! Data
                    let properties = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmark)! as NSDictionary
                    loginApps.append(((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"]) as! String)
                }
            }
        }
    }

    loginApps = Array(Set(loginApps))
    for app in loginApps{
        loginItems.append(parseApp(app_path: app, system_info: system_info))

    }
    return loginItems
}
