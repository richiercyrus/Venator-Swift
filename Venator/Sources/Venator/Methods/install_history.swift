//
//  install_history.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func getInstallHistory(withName name: String) -> Array<InstallHistory> {
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
