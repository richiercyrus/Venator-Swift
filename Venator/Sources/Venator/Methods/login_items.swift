//
//  login_items.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

//get login items - this will be a doozy
func getLoginItems(path: String, system_info: SystemInfo) -> Void {
    let plist_file = path
    let plist = NSDictionary(contentsOf: URL(fileURLWithPath: plist_file))
    var loginApps:[String] = []
    let objects = plist!["$objects"] as! NSArray
    for object in objects {
        if object is NSData {
            let bookmark = object as! Data
            var properties = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmark) as! NSDictionary
            loginApps.append(((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"]) as! String)
            //print((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"])
        }
        else if object is NSDictionary {
            let item = object as! NSDictionary
            if item["NS.data"] != nil {
                let bookmark = item["NS.data"] as! Data
                var properties = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmark) as! NSDictionary
                loginApps.append(((properties["NSURLBookmarkAllPropertiesKey"] as! NSDictionary)["_NSURLPathKey"]) as! String)
            }
        }
    }
    loginApps = Array(Set(loginApps))
    for app in loginApps{
        var loginItems = [String:Any]()
        loginItems = parseApp(app_path: app, system_info: system_info) as! [String : Any]
        loginItems.updateValue("login_items", forKey: "module")
        //loginItems.updateValue(getSystemInfo()["hostname"]!, forKey: "hostname")
        //loginItems.updateValue(getSystemInfo()["UUID"]!, forKey: "UUID")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: loginItems, options:[])
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let file: FileHandle? = FileHandle(forWritingAtPath: "/Users/richiecyrus/Desktop/ventator.json")
            
            file?.write(decoded as! Data)

                // Close the file
                file?.closeFile()
    
        } catch { print(error.localizedDescription)}
        
    }
}
