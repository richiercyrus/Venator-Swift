//
//  launch_agents.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

func runLaunchAgents(system_info: SystemInfo) {
    // gather launch agents
    print("[+] Gathering Launch Agents data")
    let launch_agents = getLaunchAgents(path: "/Library/LaunchAgents/",
                                        system_info: system_info)
    if launch_agents.count > 0 {
        config.venator_data.launch_agents = launch_agents
    }
}

func getLaunchAgents(path: String, system_info: SystemInfo) -> Array<LaunchItem> {
    
    var parsedAgents = Array<LaunchItem>()
    
    let fileManager = FileManager.default
    
    do {
        let files = try fileManager.contentsOfDirectory(atPath: path)
        if files.count > 0 {
            for f in files {
                parsedAgents.append(parseLaunchItem(plistFile: URL(fileURLWithPath: path + f as String),
                                                module: "launch_agents",
                                                system_info: system_info))
            }
        }
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
    
    return parsedAgents
    
}
