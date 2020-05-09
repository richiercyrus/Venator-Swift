//
//  utils.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation
import CommonCrypto


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
    var launchItem = LaunchItem(hostname: system_info.hostname, uuid: system_info.uuid, programArguments: "", programExecutable: "", programExecutableHash: "", signingInfo: SigningInfo(appleBinary: false, authority: [], status: ""), label: "", runAtLoad: false, module: module)
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
