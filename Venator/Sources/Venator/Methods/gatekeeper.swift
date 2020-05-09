//
//  gatekeeper.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

// gatekeeper status - have to use spctl --status
func getGatekeeperStatus(system_info: SystemInfo) -> GateKeeper {
    let task = Process()
    task.launchPath = "/usr/sbin/spctl"
    task.arguments = ["--status"]

    let pipe = Pipe()
    task.standardOutput = pipe
    // Launch the task
    task.launch()
    task.waitUntilExit()

    // Get the data
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8) ?? ""
    let gatekeeper = GateKeeper(hostname: system_info.hostname,
                                uuid: system_info.uuid,
                                status: output.replacingOccurrences(of: "\n",
                                                                    with: ""))
    return gatekeeper
}
