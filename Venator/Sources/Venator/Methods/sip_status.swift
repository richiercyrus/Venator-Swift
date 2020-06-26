//
//  sip_status.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

func runSIPStatus(system_info: SystemInfo) {
     // gather sip info
     print("[+] Gathering SIP data")
     let sip = getSIPStatus(system_info: system_info)
    config.venator_data.system_integrity_protection = sip
}

func getSIPStatus(system_info: SystemInfo) -> SIP {
    let task = Process()
    task.launchPath = "/usr/bin/csrutil"
    task.arguments = ["status"]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    // Launch the task
    task.launch()
    task.waitUntilExit()
    
    // Get the data
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8) ?? ""
    var status = output.split(separator: ":")[1].replacingOccurrences(of: ".", with: "")
    // clean up a bit
    status = status.replacingOccurrences(of: "\n", with: "")
    status = status.replacingOccurrences(of: " ", with: "")
    let sip = SIP(hostname: system_info.hostname,
                  uuid: system_info.uuid,
                  status: status)
    return sip
}
