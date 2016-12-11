//
//  ViewController.swift
//  BusStops
//
//  Created by Bearson, Matt D. on 12/3/16.
//  Copyright © 2016 Bearson, Matt D. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

typealias SectionMetadata = (header: String, footer: String)

let zeroState = "\nno results"
var sectionOne = Observable2DArraySection<SectionMetadata,String>(metadata: ("Southbound", ""), items: [zeroState,zeroState])
var sectionTwo = Observable2DArraySection<SectionMetadata,String>(metadata: ("Northbound", ""), items: [zeroState,zeroState,zeroState])
let stopIdsArray : [[String]] = [["40303","40110"],["40036","40024","40069"]]
let namesArray : [[String]] = [["Magnolia Ave & Ward St","Hwy 101 @ Spencer Ave Bus Pad"],["Richardson Ave & Francisco St","San Francisco Civic Ctr-McAllister St & Polk St","Pine St & Battery St"]]
var array = MutableObservable2DArray([sectionOne])

let rowHeight : CGFloat = 120

let tableView = UITableView(frame: CGRect(), style:UITableViewStyle.grouped)
let refreshControl = UIRefreshControl()


struct MyBond: TableViewBond {
    
    func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<SectionMetadata, String>) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let stopId = stopIdsArray[indexPath.section][indexPath.row]
        let str = NSMutableAttributedString()
        let attribute1 = [NSForegroundColorAttributeName: UIColor.green]
        let attrString1 = NSAttributedString(string: stopId, attributes: attribute1)
        
        let attribute2: [String : Any] = [
            NSForegroundColorAttributeName: UIColor.blue,
            NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 14.0)! ]
        let attrString2 = NSAttributedString(string: " "+namesArray[indexPath.section][indexPath.row], attributes: attribute2)
        
        let predictions = array[indexPath]
        let attribute3: [String : Any] = [
            NSForegroundColorAttributeName: UIColor.orange,
            NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 12.0)! ]
        let attrString3 = NSAttributedString(string: " "+predictions, attributes: attribute3)
        
        
        str.append(attrString1)
        str.append(attrString2)
        str.append(attrString3)
        
        let frame = cell.contentView.frame
        let tV = UITextView(frame: frame)
        tV.isEditable = false
        
        tV.attributedText = str
        cell.addSubview(tV)
        return cell
    }
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<SectionMetadata, String>) -> String? {
        return dataSource[section].metadata.header
    }
    
    func titleForFooter(in section: Int, dataSource: Observable2DArray<SectionMetadata, String>) -> String? {
        return dataSource[section].metadata.footer
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        array.appendSection(sectionTwo)
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let frame = self.view.frame
        tableView.frame = frame
        tableView.rowHeight = rowHeight
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        array.bind(to: tableView, using: MyBond())
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .refreshData_notif, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        print("refreshing")
        
        var sectionCounter = 0
        var itemsCounter = 0
        stopIdsArray.map({
            $0.map( {
                let indexPath = IndexPath(item:itemsCounter,section:sectionCounter)
                print("indexPath for stop_id "+String(describing: $0)+" = "+indexPath.description)
                NetworkManager.sharedInstance.getData(stop:$0,indexPath:indexPath)
                itemsCounter += 1
            })
            itemsCounter = 0
            sectionCounter += 1
        })
        //should be in callback?
        refreshControl.endRefreshing()
    }
}

