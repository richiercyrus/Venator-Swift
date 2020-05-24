//
//  install_history.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func runInstallHistory(system_info: SystemInfo) {
    // get install history
    print("[+] Gathering install history data")
    let install_history = getInstallHistory(withName: "/Library/Receipts/InstallHistory.plist",
                                            system_info: system_info)
    if install_history.count > 0 {
        config.venator_data.install_history = install_history
    }
}

func getInstallHistory(withName name: String, system_info: SystemInfo) -> Array<InstallHistory> {
    var install_history = Array<InstallHistory>()
    let xml = FileManager.default.contents(atPath: name)
    let data = try! PropertyListSerialization.propertyList(from: xml!, options: [], format: nil) as! Array<[String: Any]>
    for i in data {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let install_date = df.string(from: i["date"]! as! Date)
        let history = InstallHistory(hostname: system_info.hostname,
                                     uuid: system_info.uuid,
                                     version: i["displayVersion"]! as! String,
                                     display_name: i["displayName"]! as! String,
                                     install_date: install_date,
                                     package_identifiers: i["packageIdentifiers"]! as! Array<String>)
        install_history.append(history)
    }
    return install_history
}
