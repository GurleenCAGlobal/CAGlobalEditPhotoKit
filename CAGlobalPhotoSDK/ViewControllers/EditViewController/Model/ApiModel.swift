//
//  ApiModel.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 16/08/23.
//

import UIKit
import SystemConfiguration

// new dev url for stickers
let newDevUrl = "http://qazip.smilecdn.site/api"
//Production
let liveURL = "http://zip.smilecdn.site/api"

let devUrl = "http://polaroidapps.testurapp.com/dev/"
let newDevUrl2 = "http://devfirmware.us-east-2.elasticbeanstalk.com/"
let liveAwsUrl = "http://polaroidzip.us-east-2.elasticbeanstalk.com/"
let baseUrl = newDevUrl
let stickerApi = "/stickers"
let frameApi = "/frames"

enum EventsUrl {

    static let productionUrl = "http://smile.smilecdn.site/api/"

    static let devUrl = "http://qa.smilecdn.site/api/"
    //"http://ec2-52-15-189-116.us-east-2.compute.amazonaws.com/api/"
    //set url below for stickers

    static let main = productionUrl

    static let stickers = main + "stickers"

    static let frames = main + "frames"

    static let message = main + "event-message"

}
class ApiModel: NSObject {
    var responseDict = [String:Any]()
    
    // MARK: - - Check Internet connection
    func isInternetAvailable() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needConnections = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needConnections)
    }
}
