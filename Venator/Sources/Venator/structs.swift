//
//  structs.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

struct VenatorConfig {
    var venator_data:VenatorData
    var modules:Array<String>
    var usernames:Array<String>
    var attempts:Int
    let checkVT:Bool
    let upload:Bool
    let vt_key:String?
    let filename:String?
    let aws_bucket:String?
    let aws_id:String?
    let aws_secret:String?
    let aws_region:String?
}

struct VenatorData: Encodable {
    //let begin_collection:String
    //var finish_collection:String?
    var system_info:SystemInfo?
    var launch_agents:Array<LaunchItem>?
    var launch_daemons:Array<LaunchItem>?
    var users:Array<User>?
    var system_integrity_protection:SIP?
    var gatekeeper:GateKeeper?
    var cron_jobs:Array<CronJob>?
    var bash_history:Array<BashHistory>?
    var network_connections:Array<NetworkConnection>?
    var environment_variables:EnvironmentVariables?
    var applications:Array<Application>?
    var login_items:Array<Application>?
    var install_history:Array<InstallHistory>?
    var periodic_scripts:PeriodicScripts?
    var shell_startup_scripts:Array<ShellStartupScript>?
    var firefox_extensions:Array<FireFoxExtension>?
    
    func toJson(data: VenatorData) -> String {
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

struct SystemInfo: Encodable {
    var hostname:String
    var uuid:String
    var kernel_info:String
    var os_ver:String
    var os_arch:String
}

struct SIP: Encodable {
    var hostname:String
    var uuid:String
    var status:String
}

struct GateKeeper: Encodable {
    var hostname:String
    var uuid:String
    var status:String
}

struct CronJob: Encodable {
    var hostname:String
    var uuid:String
    var user:String
    var crontab:String
}

struct EnvironmentVariables: Encodable {
    var hostname:String
    var uuid:String
    var variables:[String: String]
}

struct SigningInfo: Encodable {
    var appleBinary:Bool
    var authority:Array<String>
    var status:String
}

struct NetworkConnection: Encodable {
    var hostname:String
    var uuid:String
    var user:String
    var process_name:String
    var process_id:String
    var TCP_UDP:String
    var connection_flow:String
}

struct BashHistory: Encodable {
    var hostname:String
    var uuid:String
    var user:String
    var bash_commands:String
}

struct LaunchItem: Encodable {
    var hostname:String
    var uuid:String
    var programArguments:String
    var programExecutable:String
    var programExecutableHash:String
    var signingInfo:SigningInfo
    var label:String
    var runAtLoad:Bool
}

struct User: Encodable {
    let hostname:String
    let uuid:String
    let username:String
    let isAdmin:Bool
}

struct Application: Encodable {
    let hostname:String
    let uuid:String
    var appExecutable:String
    var appExecutablePath:String
    var appHash:String
    var appSigningInfo:SigningInfo
}

struct InstallHistory: Encodable {
    var hostname:String
    var uuid:String
    var version:String
    var display_name:String
    var install_date:String
    var package_identifiers:Array<String>
}

struct PeriodicScripts: Encodable {
    var hostname:String
    var uuid:String
    var daily:Array<String>?
    var weekly:Array<String>?
    var monthly:Array<String>?
}

struct ShellStartupScript: Encodable {
    var hostname:String
    var uuid:String
    var user:String
    var shell_startup_filename:String
    var shell_startup_data:String
}

struct FireFoxExtension: Encodable {
    var hostname:String
    var uuid:String
    var user:String
    var extension_id:String?
    var extension_update_url:String?
    var extension_options_url:String?
    var extension_install_date:String?
    var extension_last_updated:String?
    var extension_source_uri:String?
    var extension_name:String?
    var extension_description:String?
    var extension_creator:String?
    var extension_homepage_url:String?
}
