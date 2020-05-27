//
//  s3.swift
//  Venator
//
//  Created by defaultuser on 5/24/20.
//

import Foundation
import CommonCrypto

func uploadFile(hash: String) -> String {
    var result = ""
    while result == "" {
        do {
            let data = try get(key: config.vt_key!, hash: hash)
            if data["response_code"] as! Int? == 0 {
                result = "This file has no VirusTotal entry"
            }
            else {
                if data["response_code"] as! Int? == 1 {
                    result = "\(String(describing: data["positives"]))/\(String(describing: data["total"] as! Int?))"
                }
                else {
                    result = "This file is OK"
                }
            }
        }
        catch {

        }
    }
    return result
}

func postS3(venator_data: String) throws -> [String: Any] {
    // Define group to send results through DispathQueue
    let group = DispatchGroup()
    group.enter()
    let s3_host = "\(String(describing: config.aws_bucket)).s3.\(String(describing: config.aws_region)).amazonaws.com"
    var results = [String: Any]()
    var getURLComponents = URLComponents()
    getURLComponents.scheme = "https"
    getURLComponents.host = s3_host
    if config.filename != nil {
        getURLComponents.path = "/\(String(describing: config.filename))"
    }
    else {
        getURLComponents.path = "/\(ProcessInfo.processInfo.hostName))"
    }
    getURLComponents.port = 443
    let getURL = getURLComponents.url!
    var request = URLRequest(url: getURL)
    request.httpMethod = "PUT"
    request.httpBody = venator_data.data(using: String.Encoding.utf8)
    let data_md5 = MD5(string: venator_data)
    let objDateformat: DateFormatter = DateFormatter()
    objDateformat.dateFormat = "yyyyMMddHMS"
    let strTime: String = objDateformat.string(from: NSDate() as Date)
    request.setValue("Venator", forHTTPHeaderField: "User-Agent")
    request.setValue(s3_host, forHTTPHeaderField: "Host")
    request.setValue(data_md5.base64EncodedString(), forHTTPHeaderField: "Content-MD5")
    request.setValue("Venator", forHTTPHeaderField: "X-Amz-Date")
    request.setValue("application/zip", forHTTPHeaderField: "Content-Type")
    request.setValue("UNSIGNED-PAYLOAD", forHTTPHeaderField: "X-Amz-Content-SHA256")
    let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, response, error in
        if error != nil {
            print("error")
        } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
                let raw = String(data: data, encoding: .utf8)!
                results = convertToDictionary(text: raw)!
        }
    group.leave()
    }
    task.resume()
    group.wait()
    return results
}

// https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift
func MD5(string: String) -> Data {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: length)

    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)
                CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }
            return 0
        }
    }
    return digestData
}

// https://gist.github.com/MihaelIsaev/f913d84b918d2b2c067d
extension String {
    var md5: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.MD5)
    }
    
    var sha1: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.SHA1)
    }
    
    var sha224: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.SHA224)
    }
    
    var sha256: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.SHA256)
    }
    
    var sha384: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.SHA384)
    }
    
    var sha512: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.SHA512)
    }
}

public struct HMAC {
    
    static func hash(inp: String, algo: HMACAlgo) -> String {
        if let stringData = inp.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            return hexStringFromData(input: digest(input: stringData as NSData, algo: algo))
        }
        return ""
    }
    
    private static func digest(input : NSData, algo: HMACAlgo) -> NSData {
        let digestLength = algo.digestLength()
        var hash = [UInt8](repeating: 0, count: digestLength)
        switch algo {
        case .MD5:
            CC_MD5(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA1:
            CC_SHA1(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA224:
            CC_SHA224(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA256:
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA384:
            CC_SHA384(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA512:
            CC_SHA512(input.bytes, UInt32(input.length), &hash)
            break
        }
        return NSData(bytes: hash, length: digestLength)
    }
    
    private static func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

enum HMACAlgo {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
