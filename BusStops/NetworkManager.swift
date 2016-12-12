//
//  NetworkManager.swift
//  BusStops
//
//  Created by Bearson, Matt D. on 12/5/16.
//  Copyright © 2016 Bearson, Matt D. All rights reserved.
//

import Foundation
import UIKit

let stopsArray = Config.stopsList

let dateFormatter = DateFormatter()


enum Levels : String {
    case ServiceDelivery
    case StopMonitoringDelivery
    case MonitoredStopVisit
    case MonitoredVehicleJourney
    case MonitoredCall
    case AimedArrivalTime
    case LineRef
}

class NetworkManager: AnyObject {
    
    static let sharedInstance = NetworkManager()
    
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
    
    
    func getData(stop:String, indexPath:IndexPath) {
        
        dateFormatter.dateFormat = Config.dateFormat
        
        let connection = URLSession(configuration: .default)
        
        var urlString = "http://api.511.org/transit/StopMonitoring?api_key=" + Config.token
        urlString += "&agency="
        urlString += Config.agency
        urlString += "&format=json&stopCode="
        urlString += stop
        let url = URL(string:urlString)
        
        let outputStr0 = "no data"
        
        connection.dataTask(with: url!, completionHandler:  {
            (data : Data?, response : URLResponse?, error : Error?) in
            
            guard !(error != nil) else {
                print(error.debugDescription)
                array[indexPath] = error.debugDescription
                return
            }
            
            do {
                if let predictedTimes = try JSONSerialization.jsonObject(with: data!, options: []) as?
                    [String:Any] {
                    
                    guard let serviceDelivery = predictedTimes[Levels.ServiceDelivery.rawValue] as? [String:Any]
                        else {
                            array[indexPath] = outputStr0
                            return}
                    
                    guard let stopMonitoringDelivery = serviceDelivery[Levels.StopMonitoringDelivery.rawValue] as? [String:Any]
                        else {
                            array[indexPath] = outputStr0
                            return}
                    
                    guard let monitoredStopVisit = stopMonitoringDelivery[Levels.MonitoredStopVisit.rawValue] as? [Any]
                        else {
                            array[indexPath] = outputStr0
                            return}
                    
                    var outputStr = ""
                    monitoredStopVisit.map({
                        guard let mVJ = $0 as? [String:Any]
                            else {
                                array[indexPath] = outputStr0
                                return}
                        guard let mVJ2 = mVJ[Levels.MonitoredVehicleJourney.rawValue] as? [String:Any]
                            else {
                                array[indexPath] = outputStr0
                                return}
                        
                        if let lineRef = mVJ2[Levels.LineRef.rawValue] as? String {
                            outputStr += "\nLine" + lineRef + "--"
                        }
                        if let mC = mVJ2[Levels.MonitoredCall.rawValue] as? [String:Any] {
                            if let aAT = mC[Levels.AimedArrivalTime.rawValue] as? String {
                                if let date = dateFormatter.date(from: aAT) {
                                    let waitString = self.waitStringTo(date)
                                    outputStr += waitString
                                    array[indexPath] = outputStr
                                } else { array[indexPath] = outputStr0 }
                            } else { array[indexPath] = outputStr0 }
                        } else { array[indexPath] = outputStr0 }
                    })
                } else { array[indexPath] = outputStr0 }
            }
            catch { array[indexPath] = outputStr0 }
        }).resume()
    }
}
