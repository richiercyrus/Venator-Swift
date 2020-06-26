//
//  system_info.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation

func runSystemInfo() {
    // get system info
    print("[+] Gathering system data")
    let system_info = getSystemInfo()
    config.venator_data.system_info = system_info
}

// Get the full system info for a given system like version number, hostname, kernel etc.
func getSystemInfo() -> SystemInfo {
    //using process info to get the operating system version as a string
    let macOS_version = ProcessInfo.processInfo.operatingSystemVersionString
    // using process info to get the hostname
    let hostname = ProcessInfo.processInfo.hostName
    // getting the kernel version using sysctlbyname
    var size = 0
    
    sysctlbyname("kern.version", nil, &size, nil, 0)
    var kern = [CChar](repeating: 0,  count: size)
    
    sysctlbyname("kern.version", &kern, &size, nil, 0)
    let kernel_info = String(cString: kern)
    
    // getting the machine architechture using sysctlbyname
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0,  count: size)
    
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    let arch_info = String(cString: machine)

    
    //adding data to the sysInfoData struct
    let system_info = SystemInfo(hostname: hostname,
                                 uuid: getUUID(),
                                 kernel_info: kernel_info,
                                 os_ver: macOS_version,
                                 os_arch: arch_info)
    return system_info
}
