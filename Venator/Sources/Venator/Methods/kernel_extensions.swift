//
//  kernel_extensions.swift
//  Venator
//
//  Created by defaultuser on 5/26/20.
//

import Foundation

func runKernelExtensions(system_info: SystemInfo) {
    // get kernel extensions
    print("[+] Gathering kernel extensions data")
    let kernel_extensions = getKernelExtensions(system_info: system_info)
    if kernel_extensions.count > 0 {
        config.venator_data.kernel_extensions = kernel_extensions
    }
}

func getKernelExtensions(system_info: SystemInfo) -> Array<KernelExtension> {
    var kernel_extensions = Array<KernelExtension>()
    do {
        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "/Library/Extensions/"), includingPropertiesForKeys: nil)
        for i in fileURLs {
            if fileManager.fileExists(atPath: "\(i.relativePath)/Contents/Info.plist") {
                let fileUrl = URL(fileURLWithPath: "\(i.relativePath)/Contents/Info.plist")
                let dict = NSDictionary(contentsOf: fileUrl) as! [String: Any]
                var kext = KernelExtension(hostname: system_info.hostname,
                                           uuid: system_info.uuid)
                let executable_path: String
                if dict["CFBundleExecutable"] != nil {
                    executable_path = "\(i.relativePath)/Contents/MacOS/\(dict["CFBundleExecutable"]!)"
                    kext.CFBundleExecutable = executable_path
                }
                if dict["CFBundleName"] != nil {
                    kext.CFBundleName = dict["CFBundleName"]! as? String
                }
                if dict["CFBundleIdentifier"] != nil {
                    kext.CFBundleIdentifier = dict["CFBundleIdentifier"]! as? String
                }
                if dict["OSBundleRequired"] != nil {
                    kext.OSBundleRequired = dict["OSBundleRequired"]! as? String
                }
                if dict["CFBundleGetInfoString"] != nil {
                    kext.CFBundleGetInfoString = dict["CFBundleGetInfoString"]! as? String
                }
                kernel_extensions.append(kext)
            }
        }
    } catch {
        
    }
    return kernel_extensions
}
