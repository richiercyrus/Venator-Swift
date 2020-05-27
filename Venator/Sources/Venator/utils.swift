//
//  utils.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation
import CommonCrypto

//let apikey = "5fdc8b8e20a5ba7427e86e1699c784927e2d5a9b1146a9cbf201c2b7d71df127"

func isAdmin() -> Bool {
    if #available(OSX 10.12, *) {
        if ProcessInfo.processInfo.fullUserName == "System Administrator" || ProcessInfo.processInfo.fullUserName == "root" {
            return true;
        }
        else {
            return false
        }
    } else {
        return false
    }
}

func writeFile(filename: String, data: String) -> Bool {
    let url = NSURL.fileURL(withPath: filename)
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filename) {
        print("[!] File already exists")
        return false
    }
    else {
        do {
            try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch {
            return false
        }
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getTimeStamp() -> String {
    let timestamp = NSDate().timeIntervalSince1970
    let myTimeInterval = TimeInterval(timestamp)
    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
    return time.description
}

func getUUID() -> String{
    var _: NSObject = Bundle.init(identifier: "com.apple.framework.IOKit")!
    //getting UUID as CFString
    let uuidAsCFString = (IORegistryEntryCreateCFProperty((IOServiceGetMatchingService(0, (IOServiceMatching("IOPlatformExpertDevice")))), kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0))
    //UUID Type Casted to String
    let uuid = uuidAsCFString?.takeRetainedValue() as! String
    return uuid
}

func parseLaunchItem(plistFile: URL, module:String, system_info:SystemInfo) -> LaunchItem
{
    let fileManager = FileManager.default
    var launchItem = LaunchItem(hostname: system_info.hostname, uuid: system_info.uuid, programArguments: "", programExecutable: "", programExecutableHash: "", signingInfo: SigningInfo(appleBinary: false, authority: [], status: ""), label: "", runAtLoad: false)
    if fileManager.fileExists(atPath: plistFile.absoluteString.components(separatedBy: "file://")[1]) {
        let dict = NSDictionary(contentsOf: plistFile) as! [String: Any]
        if (dict["ProgramArguments"] != nil && (dict["ProgramArguments"] as! [String]).count > 0) {
            launchItem.programExecutable = (dict["ProgramArguments"] as! [String])[0]
        }
        else if (dict["Program"] != nil){
            launchItem.programExecutable = (dict["Program"] as! String)
        }
        if (dict["RunAtLoad"] != nil) {
            launchItem.runAtLoad = dict["RunAtLoad"] as! Bool
        }
        //grab the label
        launchItem.label = dict["Label"] as! String
    
        //for loop to get the program hash and signing information
        if fileManager.fileExists(atPath: launchItem.programExecutable) {
            launchItem.programExecutableHash = getHash(url: URL(fileURLWithPath: launchItem.programExecutable))!
            launchItem.signingInfo = getSigningStatus(file: URL(fileURLWithPath: launchItem.programExecutable) as NSURL)
        }
    }
        
    return launchItem
}

//get the hash of any file on the system
//"stackoverflow.com/questions/42934154/how-can-i-hash-a-file-on-ios-using-swift-3/49878022#49878022"
func getHash(url: URL) -> String? {
    do {
        let bufferSize = 1024 * 1024
        let file = try FileHandle(forReadingFrom: url)
        defer {
            file.closeFile()
        }
        
        var context = CC_SHA256_CTX()
        CC_SHA256_Init(&context)
        
        while autoreleasepool(invoking: {
            let data = file.readData(ofLength: bufferSize)
            if data.count > 0 {
                data.withUnsafeBytes { bytesFromBuffer in let rawBytes = bytesFromBuffer.bindMemory(to: UInt8.self).baseAddress
                    _ = CC_SHA256_Update(&context, rawBytes, numericCast(data.count))}
                return true
            }
            else
            {
                return false
            }
        })
        { }
        
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes { bytesFromDigest in let rawBytes = bytesFromDigest.bindMemory(to: UInt8.self).baseAddress
            _ = CC_SHA256_Final(rawBytes, &context)
        }
        
        var hashString = ""
        for byte in digest{
            hashString += String(format:"%02x", UInt8(byte))
        }
    
        return hashString
    } catch {
        print(error)
        return nil
    }
}

//get the signature information for given file
func getSigningStatus(file: NSURL) -> SigningInfo {
    let kSecCSDefaultFlags = 0x0
    let kSecCSStrictValidate_kSecCSCheckAllArchitectures_kSecCSCheckNestedCode = 0x1f
    let errSecSuccess: OSStatus = 0
    let kSecCSSigningInformation = 0x2
    let kSecCodeInfoCertificates = "certificates"
    //let signingInfo: NSMutableDictionary = [:]
    var signingInfo = SigningInfo(appleBinary: false, authority: [], status: "")
    let sigCheckFlags = kSecCSStrictValidate_kSecCSCheckAllArchitectures_kSecCSCheckNestedCode
    var signedStatus = 0
    var isApple = false
    var authorities = [String]()
    
    let path = file
    var staticCode: SecStaticCode? = nil
    
    //Creating a static code object stored in staticCode variable
    SecStaticCodeCreateWithPath(path, SecCSFlags(rawValue: SecCSFlags.RawValue(kSecCSDefaultFlags)), &staticCode)
    
    // static validation of static signed code with result stored in signedStatus variable
    signedStatus = Int(SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: SecCSFlags.RawValue(sigCheckFlags)), nil, nil))
    
    // if the validation occurred successfully continue
    if errSecSuccess == signedStatus {
        let requirementReference = "anchor apple"
        var requirement: SecRequirement? = nil
        if  errSecSuccess == SecRequirementCreateWithString(requirementReference as CFString, SecCSFlags(rawValue: SecCSFlags.RawValue(kSecCSDefaultFlags)), &requirement) {
            if errSecSuccess == SecStaticCodeCheckValidity(staticCode!, SecCSFlags(rawValue: SecCSFlags.RawValue(sigCheckFlags)), requirement) {
                isApple = true
            }
        }
        var information: CFDictionary? = nil
        
        //Retrieves various pieces of information from a code signature stored in the information variable
        SecCodeCopySigningInformation(staticCode!, SecCSFlags(rawValue: SecCSFlags.RawValue(kSecCSSigningInformation)), &information)
        
        let key = kSecCodeInfoCertificates
        let information_dict = information! as NSDictionary
        let certChain = information_dict[key]
        let certChain_array = certChain as! Array<Any>
        let certChain_count = certChain_array.count
        var certName: CFString? = nil
        
        for index in 0..<certChain_count {
            let cert = certChain_array[index]
            let result = SecCertificateCopyCommonName(cert as! SecCertificate, &certName)
            if errSecSuccess != result {
                continue
            }
            authorities.append(certName! as String)
        }
    }
    if signedStatus == 0 {
        signingInfo.status = "signed"
    }
    else {
        signingInfo.status = "unsigned"
    }
    signingInfo.appleBinary = isApple
    signingInfo.authority = authorities
    return signingInfo
}

func parseApp(app_path: String, system_info:SystemInfo) -> Application {
    let fileManager = FileManager.default
    var appInfo = Application(hostname: system_info.hostname, uuid: system_info.uuid, appExecutable: "", appExecutablePath: "", appHash: "", appSigningInfo: SigningInfo(appleBinary: false, authority: [], status: ""))
    let appPlist = app_path + "/Contents/Info.plist"
    if fileManager.fileExists(atPath: appPlist) {
        
        
        let app = NSDictionary(contentsOf: URL(fileURLWithPath: appPlist)) as! [String:Any]
        
        if (app["CFBundleExecutable"] != nil) {
            appInfo.appExecutable = app["CFBundleExecutable"] as! String
            appInfo.appExecutablePath = app_path + "/Contents/MacOS/" + appInfo.appExecutable
            
            if fileManager.fileExists(atPath: appInfo.appExecutablePath) {
                appInfo.appSigningInfo = getSigningStatus(file: URL(fileURLWithPath: appInfo.appExecutablePath) as NSURL)
                appInfo.appHash = getHash(url: URL(fileURLWithPath: appInfo.appExecutablePath))!
            }
        }
    }
    return appInfo
}

func printBanner() {
    let banner = """
    __     __               _
    \\ \\   / /__ _ __   __ _| |_ ___  _ __
     \\ \\ / / _ \\ '_ \\ / _` | __/ _ \\| '__|
      \\ V /  __/ | | | (_| | || (_) | |
       \\_/ \\___|_| |_|\\__,_|\\__\\___/|_|

"""
    print(banner)
}

func checkRoot() {
    // check if running as admin/root
    if !isAdmin() {
        print("[!] This program must be ran as root")
        exit(1)
    }
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
