//
//  shell_startup.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func runShellStartupScripts(usernames: Array<String>, system_info: SystemInfo) {
    // get shell startup scripts
    print("[+] Gathering shell startup scripts data")
    let shell_startup_scripts = getShellStartupScripts(users: usernames,
                                                       system_info: system_info)
    if shell_startup_scripts.count > 0 {
        config.venator_data.shell_startup_scripts = shell_startup_scripts
    }
}

func getShellStartupScripts(users: Array<String>, system_info: SystemInfo) -> Array<ShellStartupScript>{
    let files = [".bash_profile", ".bashrc", ".profile"]
    var shell_startup_scripts = Array<ShellStartupScript>()
    let fileManager = FileManager.default
    for i in users {
        for f in files {
            if fileManager.fileExists(atPath: "/Users/\(i)/\(f)") {
                do {
                    let contents = try NSString(contentsOfFile: "/Users/\(i)/\(f)",
                    encoding: String.Encoding.utf8.rawValue)
                    let script = ShellStartupScript(hostname: system_info.hostname,
                                                    uuid: system_info.uuid,
                                                    user: i,
                                                    shell_startup_filename: f,
                                                    shell_startup_data: contents as String)
                    shell_startup_scripts.append(script)
                }
                catch {
                    
                }
            }
        }
    }
    return shell_startup_scripts
}
