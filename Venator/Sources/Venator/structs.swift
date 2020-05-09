//
//  structs.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

struct VenatorData: Encodable {
    let begin_collection:String
    var finish_collection:String?
    var system_info:SystemInfo?
    var launch_agents:Array<LaunchItem>?
    var launch_daemons:Array<LaunchItem>?
    var users:Array<User>?
    
    func toJson(data: VenatorData) -> String {
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

struct SystemInfo: Codable {
    var hostname:String
    var uuid:String
    var kernel_info:String
    var os_ver:String
    var os_arch:String
    let module = "system_info"
}

struct SigningInfo: Codable {
    var appleBinary:Bool
    var authority:Array<String>
    var status:String
}

struct LaunchItem: Codable {
    var hostname:String
    var uuid:String
    var programArguments:String
    var programExecutable:String
    var programExecutableHash:String
    var signingInfo:SigningInfo
    var label:String
    var runAtLoad:Bool
    let module:String
}

struct User: Codable {
    let module = "users"
    let hostname:String
    let uuid:String
    let username:String
    let isAdmin:Bool
}
