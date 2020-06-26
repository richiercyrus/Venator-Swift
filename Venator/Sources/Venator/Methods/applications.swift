//
//  applications.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

func runApps(system_info: SystemInfo) {
    print("[+] Gathering Installed Applications")
    let applications = getApps(app_path: "/Applications/",
                               system_info: system_info)
    if applications.count > 0 {
        config.venator_data.applications = applications
    }
}

//get applications - /Contents/Info.plist
func getApps(app_path: String, system_info: SystemInfo)-> Array<Application> {
    
    var parsedApps = Array<Application>()
    
    let fileManager = FileManager.default
    do {
        let apps = try fileManager.contentsOfDirectory(atPath: app_path)
        for app in apps {
            let app_full_path = app_path + app
            parsedApps.append(parseApp(app_path: app_full_path, system_info: system_info))
        }
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
    return parsedApps
}
