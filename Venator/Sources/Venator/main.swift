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
var venator_data = VenatorData(system_info: nil,
                               launch_agents: nil,
                               launch_daemons: nil,
                               users: nil)
//begin_collection: getTimeStamp(),
//finish_collection: nil,

// get system info
let system_info = getSystemInfo()
venator_data.system_info = system_info
//get user info
let users = getSystemUsers(system_info: system_info)
// check to see if there is more than one user before assigning to struct
if users.count > 0 {
    venator_data.users = users
}
//venator_data.finish_collection = getTimeStamp()
// convert data to json
let final_json = venator_data.toJson(data: venator_data)
// write data to file or to the cloud
print(final_json)


