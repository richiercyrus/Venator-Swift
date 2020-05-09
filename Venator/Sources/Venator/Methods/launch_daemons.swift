//
//  launch_daemons.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

func getLaunchDaemons(path: String, system_info: SystemInfo) -> Array<LaunchItem> {
    
    var parsedDaemons = Array<LaunchItem>()
    
    let fileManager = FileManager.default
    
    do {
        let files = try fileManager.contentsOfDirectory(atPath: path)
        for f in files {
            parsedDaemons.append(parseLaunchItem(plistFile: URL(fileURLWithPath: path + f as String),
                                                 module: "launch_daemons",
                                                 system_info: system_info))
        }
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
    
    return parsedDaemons
    
}
