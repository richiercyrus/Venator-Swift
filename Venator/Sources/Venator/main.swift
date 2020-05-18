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

printBanner()

// create master struct
var venator_data = VenatorData()

// get system info
print("[+] Gathering system data")
let system_info = getSystemInfo()
venator_data.system_info = system_info

//get user info
print("[+] Gathering user data")
let users = getSystemUsers(system_info: system_info)
// check to see if there is more than one user before assigning to struct
if users.count > 0 {
    venator_data.users = users
}

// gather launch agents
print("[+] Gathering Launch Agents data")
let launch_agents = getLaunchAgents(path: "/Library/LaunchAgents/", system_info: system_info)
if launch_agents.count > 0 {
    venator_data.launch_agents = launch_agents
}

// gather launch daemons
print("[+] Gathering Launch Daemons data")
let launch_daemons = getLaunchDaemons(path: "/Library/LaunchDaemons/", system_info: system_info)
if launch_daemons.count > 0 {
    venator_data.launch_daemons = launch_daemons
}

// gather sip info
print("[+] Gathering SIP data")
let sip = getSIPStatus(system_info: system_info)
venator_data.system_integrity_protection = sip

// get gatekeeper status
print("[+] Gathering GateKeeper data")
let gatekeeper = getGatekeeperStatus(system_info: system_info)
venator_data.gatekeeper = gatekeeper

// get cron jobs
// collect usernames
print("[+] Gathering cron job data")
var usernames = Array<String>()
for i in users {
    usernames.append(i.username)
}
let cron_jobs = getCronJobs(users: usernames, system_info: system_info)
if cron_jobs.count > 0 {
    venator_data.cron_jobs = cron_jobs
}

// get bash history
print("[+] Gathering bash history data")
let bash_history = getBashHistory(users: usernames, system_info: system_info)
if bash_history.count > 0 {
    venator_data.bash_history = bash_history
}

// get network connections
print("[+] Gathering network connection data")
let network_connections = getNetworkConections(system_info: system_info)
if network_connections.count > 0 {
    venator_data.network_connections = network_connections
}

// get environment variables
print("[+] Gathering environment variables data")
let environment_variables = getEnvironmentVariables(system_info: system_info)
if environment_variables.variables.count > 0 {
    venator_data.environment_variables = environment_variables
}

print("[+] Gathering Installed Applications")
let applications = getApps(app_path: "/Applications/", system_info: system_info)
if applications.count > 0 {
    venator_data.applications = applications
}

print("[+] Gathering LoginItems")
let login_items = getLoginItems(users: usernames, system_info: system_info)
if login_items.count > 0 {
    venator_data.login_items = login_items
}

// get install history
print("[+] Gathering install history data")
let install_history = getInstallHistory(withName: "/Library/Receipts/InstallHistory.plist")
if install_history.count > 0 {
    venator_data.install_history = install_history
}

// get periodic scripts
print("[+] Gathering periodic scripts")
let periodic_scripts = getPeriodicScripts(system_info: system_info)
venator_data.periodic_scripts = periodic_scripts

// get shell startup scripts
print("[+] Gathering shell startup scripts data")
let shell_startup_scripts = getShellStartupScripts(users: usernames, system_info: system_info)
if shell_startup_scripts.count > 0 {
    venator_data.shell_startup_scripts = shell_startup_scripts
}

// get firefox extensions
print("[+] Gathering Firefox extensions data")
let firefox_extensions = getFirefoxExtensions(users: usernames, system_info: system_info)
if firefox_extensions.count > 0 {
    venator_data.firefox_extensions = firefox_extensions
}

// test virus total query
//let test = getVTResult(hash: "52d3df0ed60c46f336c131bf2ca454f73bafdc4b04dfa2aea80746f5ba9e6d")
//print(test)

// convert data to json
print("[+] Converting collected data to final JSON")
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

