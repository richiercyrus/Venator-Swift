//
//  applications.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

//get applications - /Contents/Info.plist
func getApps(app_path: String)-> Void {
    let fileManager = FileManager.default
    do {
        let apps = try fileManager.contentsOfDirectory(atPath: app_path)
        for app in apps {
            var appList = [String:Any]()
            var app_full_path = app_path + app
            parseApps(app_path: app_full_path)
        }
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
}

func parseApps(app_path: String) -> Any {
    let fileManager = FileManager.default
    var appInfo = [String:Any]()
    let appPlist = app_path + "/Contents/Info.plist"
    if fileManager.fileExists(atPath: appPlist) {
        let app = NSDictionary(contentsOf: URL(fileURLWithPath: appPlist)) as! [String:Any]
        //print(app)
        //print((dict["ProgramArguments"] as! [String]).count)
        let executable = ""
        let executable_path = ""
        let app_hash = ""
        let app_sig = ""
        if (app["CFBundleExecutable"] != nil) {
            let executable = app["CFBundleExecutable"] as! String
            let executable_path = app_path + "/Contents/MacOS/" + executable
            
            if fileManager.fileExists(atPath: executable_path) {
                var app_sig = getSigningStatus(file: URL(fileURLWithPath: executable_path) as! NSURL)
                var app_hash = getHash(url: URL(fileURLWithPath: executable_path)) as! String
                appInfo.updateValue(app_hash, forKey: "application_hash")
                appInfo.updateValue(app_sig, forKey: "signature")
            }
            appInfo.updateValue(app_path, forKey: "application")
            appInfo.updateValue(executable, forKey: "executable")
            appInfo.updateValue(executable_path, forKey: "executable_path")
        }
    }
    return appInfo
}
