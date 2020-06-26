//
//  environment_variables.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func runEnvironemntVariables(system_info: SystemInfo) {
    // get environment variables
    print("[+] Gathering environment variables data")
    let environment_variables = getEnvironmentVariables(system_info: system_info)
    if environment_variables.variables.count > 0 {
        config.venator_data.environment_variables = environment_variables
    }
}

func getEnvironmentVariables(system_info: SystemInfo) -> EnvironmentVariables {
    var list: [String: String] = [:]
    for i in ProcessInfo.processInfo.environment {
        list[i.key] = i.value
    }
    let vars = EnvironmentVariables(hostname: system_info.hostname,
                                    uuid: system_info.uuid,
                                    variables: list)
    return vars
}
