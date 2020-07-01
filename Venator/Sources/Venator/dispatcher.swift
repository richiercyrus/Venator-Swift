//
//  dispatcher.swift
//  Venator
//
//  Created by defaultuser on 5/23/20.
//

import Foundation

@available(OSX 10.11, *)
func dispatchVenator() {
    if config.modules.count < 1 {
        fullCollection()
    }
    else {
        moduleCollection()
    }
}

@available(OSX 10.11, *)
func fullCollection() {
    // collect data
    runSystemInfo()
    runSystemUsers(system_info: config.venator_data.system_info!)
    runLaunchAgents(system_info: config.venator_data.system_info!)
    runLaunchDaemons(system_info: config.venator_data.system_info!)
    runSIPStatus(system_info: config.venator_data.system_info!)
    runGatekeeperStatus(system_info: config.venator_data.system_info!)
    runCronjobs(usernames: config.usernames,
                system_info: config.venator_data.system_info!)
    runApps(system_info: config.venator_data.system_info!)
    runBashHistory(usernames: config.usernames,
                   system_info: config.venator_data.system_info!)
    runZshHistory(usernames: config.usernames,
                  system_info: config.venator_data.system_info!)
    runLoginItems(usernames: config.usernames,
                  system_info: config.venator_data.system_info!)
    runFireFoxExtensions(usernames: config.usernames,
                         system_info: config.venator_data.system_info!)
    runChromeExtensions(usernames: config.usernames, system_info: config.venator_data.system_info!)
    runInstallHistory(system_info: config.venator_data.system_info!)
    runEnvironemntVariables(system_info: config.venator_data.system_info!)
    runPeriodicScfripts(system_info: config.venator_data.system_info!)
    runNetworkConnections(system_info: config.venator_data.system_info!)
    runShellStartupScripts(usernames: config.usernames,
                           system_info: config.venator_data.system_info!)
    runEventTaps(system_info: config.venator_data.system_info!)
    runKernelExtensions(system_info: config.venator_data.system_info!)
    
    let final_json = getFinalJson()
    
    if config.upload {
        do {
            if #available(OSX 10.13, *) {
                try postS3(venator_data: final_json)
            } else {
                // Fallback on earlier versions
            }
        }
        catch {
            print("UnableToUpload")
        }
        
    }
    else {
        if config.filename != nil {
            outFile(final_json: final_json,
                    file_path: config.filename!)
        }
        else {
            outDefaultFile(final_json: final_json)
        }
    }
}

@available(OSX 10.11, *)
func moduleCollection() {
    // collect data
    runSystemInfo()
    runSystemUsers(system_info: config.venator_data.system_info!)
    for module in config.modules {
        switch module.lowercased() {
            case "launchagents":
                runLaunchAgents(system_info: config.venator_data.system_info!)
            case "launchdaemons":
                runLaunchDaemons(system_info: config.venator_data.system_info!)
            case "sip":
                runSIPStatus(system_info: config.venator_data.system_info!)
            case "gatekeeper":
                runGatekeeperStatus(system_info: config.venator_data.system_info!)
            case "cronjobs":
                runCronjobs(usernames: config.usernames,
                            system_info: config.venator_data.system_info!)
            case "apps":
                runApps(system_info: config.venator_data.system_info!)
            case "bashhistory":
                runBashHistory(usernames: config.usernames,
                               system_info: config.venator_data.system_info!)
            case "zshhistory":
            runZshHistory(usernames: config.usernames,
                           system_info: config.venator_data.system_info!)
            case "loginitems":
                runLoginItems(usernames: config.usernames,
                               system_info: config.venator_data.system_info!)
            case "firefoxExtension":
                runFireFoxExtensions(usernames: config.usernames,
                               system_info: config.venator_data.system_info!)
            case "chromeExtension":
                runChromeExtensions(usernames: config.usernames,
                                    system_info: config.venator_data.system_info!)
            case "installhistory":
                runInstallHistory(system_info: config.venator_data.system_info!)
            case "envvariables":
                runEnvironemntVariables(system_info: config.venator_data.system_info!)
            case "periodicscripts":
                runPeriodicScfripts(system_info: config.venator_data.system_info!)
            case "connections":
                runNetworkConnections(system_info: config.venator_data.system_info!)
            case "startupscripts":
                runShellStartupScripts(usernames: config.usernames,
                                       system_info: config.venator_data.system_info!)
            case "eventtap":
                runEventTaps(system_info: config.venator_data.system_info!)
            case "kext":
                runKernelExtensions(system_info: config.venator_data.system_info!)
            default:
                print("[!] Module \(module) does not exist")
        }
    }
    
    let final_json = getFinalJson()
    
    if config.upload {
        
    }
    else {
        if config.filename != nil {
            outFile(final_json: final_json,
                    file_path: config.filename!)
        }
        else {
            outDefaultFile(final_json: final_json)
        }
    }
}

func getFinalJson() -> String {
    // convert data to json
    print("[+] Converting collected data to final JSON")
    let final_json = config.venator_data.toJson(data: config.venator_data)
    return final_json
}

func outFile(final_json: String, file_path: String) {
    if (writeFile(filename: file_path, data: final_json)) {
        print("[+] Successfully saved file to \(file_path)")
    }
    else {
        print("[!] Error writing file to disk")
    }
}

func outDefaultFile(final_json: String) {
    let filename = "/tmp/\(ProcessInfo.processInfo.hostName).json"
    if (writeFile(filename: filename, data: final_json)) {
        print("[+] Successfully saved file to \(filename)")
    }
    else {
        print("[!] Error writing file to disk")
    }
}
