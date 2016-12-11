//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


//import WebKit
//
//let frame = CGRect(x: 0, y: 0, width: 320, height:550)
//let web = WKWebView(frame: frame)
//let rq = NSURLRequest(url: NSURL(string: "http://api.511.org/transit/StopMonitoring?api_key=8e72a140-c5a0-4bed-a401-7aaa9bb6fa10&agency=Golden%20Gate%20Transit&format=json&stopCode=40110")! as URL)
//web.load(rq as URLRequest)
//PlaygroundPage.current.liveView = web

//import Alamofire //not supported in playgrounds anymore?


PlaygroundPage.current.needsIndefiniteExecution = true

enum Levels : String {
    case ServiceDelivery
    case StopMonitoringDelivery
    case MonitoredStopVisit
    case MonitoredVehicleJourney
    case MonitoredCall
    case AimedArrivalTime
    case LineRef
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

//let token = "8e72a140-c5a0-4bed-a401-7aaa9bb6fa10"
//let agency = "Golden%20Gate%20Transit"
let stop = "40110"



var token = "8e72a140-c5a0-4bed-a401-7aaa9bb6fa10"
var dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

private func localStopsList() -> Array<[String:Any]> {
    var arr = [[String:Any]]()
    arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40303", "direction":"SB", "lines":["18"], "stop_name":"Magnolia Ave & Ward St", "coordinates":(37.935921,-122.535309)])
    arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40110", "direction":"SB", "lines":["4","18","70"], "stop_name":"Hwy 101 @ Spencer Ave Bus Pad", "coordinates":(37.853199,-122.493103)])
    arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40036", "direction":"NB", "lines":["4","18","70"], "stop_name":"Richardson Ave & Francisco St", "coordinates":(37.800369,-122.446915)])
    arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40024", "direction":"NB", "lines":["4","18","70"], "stop_name":"San Francisco Civic Ctr-McAllister St & Polk St", "coordinates":(37.780289,-122.418831)])
    arr.append(["agency":"Golden%20Gate%20Transit", "stop_id":"40069", "direction":"NB", "lines":["4","18","70"], "stop_name":"Pine St & Battery St", "coordinates":(37.792381,-122.399284)])
    return arr
}

var stopsList = localStopsList()



func waitStringTo(_ date: Date) -> String {
    
    let interval = date.timeIntervalSinceNow
    let roundedSeconds = Int(abs(interval))
    
    let hours = Int(roundedSeconds / 3600)
    let minutes = Int(roundedSeconds / 60) % 60
    let seconds = roundedSeconds % 60
    
    var hourString = String(hours)
    var minuteString = String(minutes)
    var secondString = String(seconds)
    
    //would like to use guards here but compiler enforced 'break' in a way I couldn't satisfy
    if hours > 9 {}
        else { hourString = "0"+hourString}
    if minutes > 9 {}
        else { minuteString = "0"+minuteString}
    if seconds > 9 {}
        else { secondString = "0"+secondString}

    return hourString+":"+minuteString+":"+secondString
}

func getData() {
    
    var outputArr = [Any]()
    var counter = stopsList.count
    
    //print(stopsList)
   // for each in stopsList {
    stopsList.map({

    let connection = URLSession(configuration: .default)
    
    var urlString = "http://api.511.org/transit/StopMonitoring?api_key=" + token
    urlString += "&agency="
    urlString += $0["agency"] as! String
    urlString += "&format=json&stopCode="
    urlString += $0["stop_id"] as! String
   // let stop_id = each["stop_id"]
    //let urlString = "http://api.511.org/transit/StopMonitoring?api_key=" + token + "&agency=" + agency + "&format=json&stopCode=" + stop_id
        let url = URL(string:urlString)
    
    connection.dataTask(with: url!, completionHandler:  {
        (data : Data?, response : URLResponse?, error : Error?) in
        
        guard !(error != nil) else {
            print(error.debugDescription)
            return
        }
        
        do {
            if let predictedTimes = try JSONSerialization.jsonObject(with: data!, options: []) as?
                [String:Any] {
                
                let urlString = url!.description
                let index = urlString.index(urlString.endIndex, offsetBy: -5)
                let stopCode = urlString.substring(from: index)
                outputArr.append("*******" + stopCode + "*********************************")
                
                guard let serviceDelivery = predictedTimes[Levels.ServiceDelivery.rawValue] as? [String:Any]
                    else {return}
                
                guard let stopMonitoringDelivery = serviceDelivery[Levels.StopMonitoringDelivery.rawValue] as? [String:Any]
                    else {return}
                
                guard let monitoredStopVisit = stopMonitoringDelivery[Levels.MonitoredStopVisit.rawValue] as? [Any]
                    else {return}
                
                monitoredStopVisit.map({
                    guard let mVJ = $0 as? [String:Any]
                        else {return}
                    guard let mVJ2 = mVJ[Levels.MonitoredVehicleJourney.rawValue] as? [String:Any]
                        else {return}
                    
                    var tuple = ("","")
                    if let lineRef = mVJ2[Levels.LineRef.rawValue] as? String {
                        //outputArr.append("Line" + lineRef)
                        tuple.0 = "Line" + lineRef
                    }
                    if let mC = mVJ2[Levels.MonitoredCall.rawValue] as? [String:Any] {
                        //  print(mC)
                        if let aAT = mC[Levels.AimedArrivalTime.rawValue] as? String {
                        //  print(aAT)
                            if let date = dateFormatter.date(from: aAT) {
                                
                                let waitString = waitStringTo(date)
                                //outputArr.append(waitString)
                                tuple.1 = waitString
                                outputArr.append(tuple)
                            }
                        }
                    }
                   // outputArr.append("\n")
                })
            }
        }
        catch {  }
        
        counter -= 1
        if counter == 0 {
            print(outputArr) }
    }).resume()
    })
}

getData()
