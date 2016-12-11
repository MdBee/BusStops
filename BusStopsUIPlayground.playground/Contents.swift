//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

//import WebKit

let frame = CGRect(x: 0, y: 0, width: 320, height:550)
//let web = WKWebView(frame: frame)
//let rq = NSURLRequest(url: NSURL(string: "http://api.511.org/transit/StopMonitoring?api_key=8e72a140-c5a0-4bed-a401-7aaa9bb6fa10&agency=Golden%20Gate%20Transit&format=json&stopCode=40110")! as URL)
//web.load(rq as URLRequest)
//PlaygroundPage.current.liveView = web

let tV = UITextView(frame: frame)


let dataDict = ["40069":[("Line24", " 00:04:24"), ("Line24X", " 00:29:24"), ("Line24", " 00:39:24")], "40024":[("Line93", " 00:04:24"), ("Line101", " 00:06:24"), ("Line92", " 00:09:24"), ("Line93", " 00:19:24"), ("Line101", " 00:32:24"), ("Line70", " 00:33:24"), ("Line93", " 00:34:24"), ("Line30", " 00:58:24")]]

//let myString = (dataDict["40024"])?.description
let myString = dataDict["40024"]?[1].0
let myAttribute = [ NSForegroundColorAttributeName: UIColor.blue ]
var myAttrString = NSMutableAttributedString(string: myString!+"\n\n\n\n\n\n", attributes: myAttribute)
let myAttribute2 = [ NSForegroundColorAttributeName: UIColor.green ]
let myAttrString2 = NSMutableAttributedString(string: myString!, attributes: myAttribute2)
//myAttrString.append(myAttrString2)

let attributedData : [NSMutableAttributedString] = [myAttrString, myAttrString2]

// set attributed text on a UILabel
//tV.attributedText = myAttrString

var str = attributedData[0]
var str2 = attributedData[1]
var str3 = NSMutableAttributedString()
str3.append(str)
str3.append(str2)
tV.attributedText = str3

PlaygroundPage.current.liveView = tV