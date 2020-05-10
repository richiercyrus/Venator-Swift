//
//  environment_variables.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

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
