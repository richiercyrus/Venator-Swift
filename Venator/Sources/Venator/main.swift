//
//  main.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

// check if running as admin/root
if !isAdmin() {
    print("[!] This program must be ran as root")
    exit(1)
}

// parse arguments

// create master struct
var venator_data = VenatorData(system_info: nil,
                               launch_agents: nil,
                               launch_daemons: nil,
                               users: nil)

// get system info
let system_info = getSystemInfo()
venator_data.system_info = system_info

//get user info
let users = getSystemUsers(system_info: system_info)
// check to see if there is more than one user before assigning to struct
if users.count > 0 {
    venator_data.users = users
}

// gather launch agents
let launch_agents = getLaunchAgents(path: "/Library/LaunchAgents/", system_info: system_info)
if launch_agents.count > 0 {
    venator_data.launch_agents = launch_agents
}

// gather launch daemons
let launch_daemons = getLaunchDaemons(path: "/Library/LaunchDaemons/", system_info: system_info)
if launch_daemons.count > 0 {
    venator_data.launch_daemons = launch_daemons
}

// gather sip info
let sip = getSIPStatus(system_info: system_info)
venator_data.system_integrity_protection = sip

// get gatekeeper status
let gatekeeper = getGatekeeperStatus(system_info: system_info)
venator_data.gatekeeper = gatekeeper

// get cron jobs
// collect usernames
var usernames = Array<String>()
for i in users {
    usernames.append(i.username)
}
let cron_jobs = getCronJobs(users: usernames, system_info: system_info)
if cron_jobs.count > 0 {
    venator_data.cron_jobs = cron_jobs
}

// get applications
//print(getApps(app_path: "/Applications/"))

// convert data to json
let final_json = venator_data.toJson(data: venator_data)

// write data to file or to the cloud
// if filename not specified then generate for /tmp
let filename = "/tmp/\(ProcessInfo.processInfo.hostName).json"
if (writeFile(filename: filename, data: final_json)) {
    print("[+] Successfully saved file to \(filename)")
}
else {
    print("[!] Error writing file to disk")
}

// *********** To do
/*
 Adding collection stop start times
 //begin_collection: getTimeStamp(),
 //finish_collection: nil,
 //venator_data.finish_collection = getTimeStamp()
 
 Adding additional modules from the defualt playground
 
 Porting modules from Venator python into Venator swift
 */

