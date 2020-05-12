//
//  periodic_scripts.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func getPeriodicScripts(system_info: SystemInfo) -> PeriodicScripts {
    let dirs = ["/etc/periodic/daily", "/etc/periodic/weekly", "/etc/periodic/monthly"]
    let fileManager = FileManager.default
    var periodic_scripts = PeriodicScripts(hostname: system_info.hostname,
                                           uuid: system_info.uuid,
                                           daily: nil,
                                           weekly: nil,
                                           monthly: nil)
    var data = Array<Array<String>>()
    do {
        for i in dirs {
            let path = NSURL.fileURL(withPath: i)
            let fileURLs = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            var temp = Array<String>()
            for i in fileURLs {
                let fileName = i.lastPathComponent
                temp.append(fileName)
            }
            data.append(temp)
        }
        periodic_scripts.daily = data[0]
        periodic_scripts.weekly = data[1]
        periodic_scripts.monthly = data[2]
    }
    catch {
        
    }
    return periodic_scripts
}
