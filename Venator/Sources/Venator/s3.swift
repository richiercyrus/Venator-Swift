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

func amzn_sig(secret_access_key: String, data: String, aws_region: String) -> String{
    let today: DateFormatter = DateFormatter()
    today.dateFormat = "yyyyMMdd"
    let strTime: String = today.string(from: NSDate() as Date)
    let date_key = hmac(hashName: "SHA256", message: strTime.data(using:.utf8)!, key: "AWS4\(secret_access_key)".data(using:.utf8)!)
    let date_region_key = hmac(hashName: "SHA256", message: aws_region.data(using: .utf8)!, key: date_key!)
    let date_region_svc_key = hmac(hashName: "SHA256", message: "s3".data(using: .utf8)!, key: date_region_key!)
    let sign_key = hmac(hashName: "SHA256", message: "aws4_request".data(using: .utf8)!, key: date_region_svc_key!)
    let final_key = hmac(hashName: "SHA256", message: data.data(using: .utf8)!, key: sign_key!)
    
    var final_key_String = ""
    for byte in final_key! {
        final_key_String += String(format:"%02x", UInt8(byte))
    }
    return final_key_String

}

//https://riptutorial.com/swift/example/25615/hmac-with-md5--sha1--sha224--sha256--sha384--sha512--swift-3-
func hmac(hashName:String, message:Data, key:Data) -> Data? {
    let algos = ["SHA1":   (kCCHmacAlgSHA1,   CC_SHA1_DIGEST_LENGTH),
                 "MD5":    (kCCHmacAlgMD5,    CC_MD5_DIGEST_LENGTH),
                 "SHA224": (kCCHmacAlgSHA224, CC_SHA224_DIGEST_LENGTH),
                 "SHA256": (kCCHmacAlgSHA256, CC_SHA256_DIGEST_LENGTH),
                 "SHA384": (kCCHmacAlgSHA384, CC_SHA384_DIGEST_LENGTH),
                 "SHA512": (kCCHmacAlgSHA512, CC_SHA512_DIGEST_LENGTH)]
    guard let (hashAlgorithm, length) = algos[hashName]  else { return nil }
    var macData = Data(count: Int(length))

    macData.withUnsafeMutableBytes {macBytes in
        message.withUnsafeBytes {messageBytes in
            key.withUnsafeBytes {keyBytes in
                CCHmac(CCHmacAlgorithm(hashAlgorithm),
                       keyBytes,     key.count,
                       messageBytes, message.count,
                       macBytes)
            }
        }
    }
    return macData
}

let AMZN_SIGNED_HEADERS = ["content-md5", "content-type","host", "x-amz-content-sha256","x-amz-date"]
func amzn_canonical_req(filename_path: String, headers_list: Dictionary<String, String>) -> String{
    var headers: Dictionary<String, String> = [:]
    for k in headers_list {
        headers.updateValue((k.value as String).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""), forKey: k.key.lowercased())
    }
    var canonical_hdrs:Array<String> = []
    for amzn_header in AMZN_SIGNED_HEADERS {
        canonical_hdrs.append("\(amzn_header):\(headers[amzn_header]!)")
    }
    
    return ("PUT\n\(filename_path)\n\n\(canonical_hdrs.joined(separator: "\n"))\n\n\(AMZN_SIGNED_HEADERS.joined(separator: ";"))\n\("UNSIGNED-PAYLOAD")")
}

@available(OSX 10.13, *)
//https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
func postS3(venator_data: String) throws -> [String: Any] {
    // Define group to send results through DispathQueue
    let group = DispatchGroup()
    group.enter()
    var file_name = ""
    if config.filename != nil {
        file_name = "\(config.filename!).json"
    }
    else {
        file_name = "\(ProcessInfo.processInfo.hostName).json"
    }
    let filename_path = "/uploads/\(file_name)"
    let s3_host = "\(config.aws_bucket!).s3.\(config.aws_region!).amazonaws.com"
    let s3_upload_url = URL.init(string: "https://\(s3_host)\(filename_path)")
    let results = [String: Any]()
    var getURLComponents = URLComponents()
    getURLComponents.scheme = "https"
    getURLComponents.host = "s3_host"
    if config.filename != nil {
        getURLComponents.path = "/\(config.filename!)"
    }
    else {
        getURLComponents.path = "/\(ProcessInfo.processInfo.hostName))"
    }
    
    getURLComponents.port = 443
    var request = URLRequest(url: s3_upload_url!)
    request.httpMethod = "PUT"
    request.httpBody = venator_data.data(using: String.Encoding.utf8)
    
    
    let objDateformat: DateFormatter = DateFormatter()
    objDateformat.dateFormat = "yyyyMMddHMSSSZZZZZ"
    var amzn_ts: String = "\(objDateformat.string(from: NSDate() as Date))"
    
    let objDateformat2: DateFormatter = DateFormatter()
    objDateformat2.dateFormat = "yyyyMMdd"
    let amzn_date: String = objDateformat2.string(from: NSDate() as Date)
    
    
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime,
                                      .withFullDate,
                                      ]
    let timestamp = isoDateFormatter.string(from: Date())
    amzn_ts = timestamp.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: ".", with: "")
    
    let data_md5 = MD5(string: venator_data)
    request.setValue(s3_host, forHTTPHeaderField: "Host")
    request.setValue(data_md5.base64EncodedString(), forHTTPHeaderField: "Content-MD5")
    request.setValue(amzn_ts, forHTTPHeaderField: "X-Amz-Date")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("UNSIGNED-PAYLOAD", forHTTPHeaderField: "X-Amz-Content-SHA256")
    
    let canonical_req = amzn_canonical_req(filename_path: filename_path, headers_list: request.allHTTPHeaderFields!)
    
    
    let scope = "\(amzn_date)/\(config.aws_region!)/s3/aws4_request"
    let hash_canonical_req = SHA256(string: canonical_req)
    var hash_canonical_req_String = ""
    for byte in hash_canonical_req{
        hash_canonical_req_String += String(format:"%02x", UInt8(byte))
    }
    let to_sign = "AWS4-HMAC-SHA256\n\(amzn_ts)\n\(scope)\n\(hash_canonical_req_String)"
    let req_sig = amzn_sig(secret_access_key: config.aws_secret!, data: to_sign, aws_region: config.aws_region!)

    let signed_headers = AMZN_SIGNED_HEADERS.joined(separator: ";")
    let creds = "\(config.aws_id!)/\(scope)"
    let auth_header = "AWS4-HMAC-SHA256 Credential=\(creds), SignedHeaders=\(signed_headers), Signature=\(req_sig)"
    request.setValue(auth_header, forHTTPHeaderField: "Authorization")
    let task = URLSession(configuration: .ephemeral).dataTask(with: request) {
        data, response, error in
        if error != nil {
            print("error")
        } else if
            let _ = data,
            let response = response as? HTTPURLResponse, response.statusCode == 200 {
    
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

func SHA256(string: String) -> Data {
    let length = Int(CC_SHA256_DIGEST_LENGTH)
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: length)

    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)
                CC_SHA256(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }
            return 0
        }
    }
    return digestData
}
