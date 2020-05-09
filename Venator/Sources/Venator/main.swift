//
//  main.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

// parse arguments

// create master struct
var venator_data = VenatorData(begin_collection: getTimeStamp(),
                               finish_collection: nil,
                               system_info: nil,
                               launch_agents: nil,
                               launch_daemons: nil,
                               users: nil)
// get system info
let system_info = getSystemInfo()
venator_data.system_info = system_info
// run collection methods
//let launch_agents = getLaunchAgents(path: "", system_info: system_info)
//if launch_agents.count > 0 {
//    venator_data.launch_agents = launch_agents
//}
//let launch_daemons = getLaunchDaemons(path: "", system_info: system_info)
//if launch_daemons.count > 0 {
//    venator_data.launch_daemons = launch_daemons
//}
let users = getSystemUsers(system_info: system_info)
if users.count > 0 {
    venator_data.users = users
}
venator_data.finish_collection = getTimeStamp()
// convert data to json
let final_json = venator_data.toJson(data: venator_data)
// write data to file or to the cloud
print(final_json)
