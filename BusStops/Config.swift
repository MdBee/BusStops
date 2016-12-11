//
//  Config.swift
//  BusStops
//
//  Created by Bearson, Matt D. on 12/6/16.
//  Copyright © 2016 Bearson, Matt D. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let refreshData_notif = Notification.Name("refreshData_notif")
}

class Config: NSObject {

    static var stopsList = Config.localStopsList()
    static let token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx" //get your own token here: http://511.org/developers/list/tokens/create
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let agency = "Golden%20Gate%20Transit"
    
    private static func localStopsList() -> Array<[String:Any]> {
        var arr = [[String:Any]]()
        arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40303", "direction":"SB", "lines":["18"], "stop_name":"Magnolia Ave & Ward St", "coordinates":(37.935921,-122.535309)])
        arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40110", "direction":"SB", "lines":["4","18","70"], "stop_name":"Hwy 101 @ Spencer Ave Bus Pad", "coordinates":(37.853199,-122.493103)])
        arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40036", "direction":"NB", "lines":["4","18","70"], "stop_name":"Richardson Ave & Francisco St", "coordinates":(37.800369,-122.446915)])
        arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40024", "direction":"NB", "lines":["4","18","70"], "stop_name":"San Francisco Civic Ctr-McAllister St & Polk St", "coordinates":(37.780289,-122.418831)])
        arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40069", "direction":"NB", "lines":["4","18","70"], "stop_name":"Pine St & Battery St", "coordinates":(37.792381,-122.399284)])
        return arr
    }

}
