//
//  ViewController.swift
//  SwiftAPM
//
//  Created by rongheng on 09/18/2020.
//  Copyright (c) 2020 rongheng. All rights reserved.
//

import UIKit
import SwiftAPM
import Darwin

// MARK: - ViewController
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GodEye Feature List"
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(self.tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    
    private lazy var tableView: UITableView = { [unowned self] in
        let new = UITableView(frame: CGRect.zero, style: .grouped)
        new.delegate = self
        new.dataSource = self
        return new
        }()
    
    private var sections:[DemoSection] = [
        DemoModelFactory.aslSection,
        DemoModelFactory.crashSection,
        DemoModelFactory.networkSection,
        DemoModelFactory.anrSection
    ]
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DemoCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.textLabel?.font = UIFont(name: "Courier", size: 12)
        }
        
        cell!.textLabel?.text = self.sections[indexPath.section].model[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 10, y: 15, width: tableView.frame.size.width - 10, height: 20))
        label.backgroundColor = UIColor.clear
        label.font =  UIFont(name: "Courier", size: 14)
        label.text = self.sections[section].header
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.sections[indexPath.section].model[indexPath.row]
        model.action()
    }
}

// MARK: - DemoModel
class DemoModel: NSObject {
    
    private(set) var title: String
    
    private(set) var action: (()->()) = {}
    
    init(title:String,action:@escaping ()->()) {
        self.title = title
        self.action = action
        
        super.init()
    }
}

class DemoSection: NSObject {
    private(set) var header: String!
    private(set) var model:[DemoModel]!
    
    init(header:String,model:[DemoModel]) {
        super.init()
        self.header = header
        self.model = model
    }
}

class DemoModelFactory: NSObject {
    
    static var crashSection: DemoSection {
        var models = [DemoModel]()
        var model = DemoModel(title: "Exception Crash") {
//            let array = NSArray()
//            _ = array[2]
            
//            let window = UIWindow(frame:UIScreen.main.bounds)
//            SwiftAPM.openSandBox(window)
            
            CrashBrowser.share.openCrashList()
        }
        models.append(model)
        
        model = DemoModel(title: "Signal Crash") {
            var a = [String]()
            print(a[2])
//
//            var b: Int? = nil
//            print(b!)
            
//            var array = NSArray(array: [1,2])
//            print(array[2])
            
            // 打开调试lldb: pro hand -p true -s false SIGTRAP
//            kill(getpid(), SIGTRAP)
        }
        models.append(model)
        
        return DemoSection(header: "Crash", model: models)
    }
    
    static var networkSection: DemoSection {
        let url = URL(string: "https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc")
        let request = URLRequest(url: url!)
        
        var new = [DemoModel]()
        
        var title = "Send Sync Connection Network"
        var model = DemoModel(title: title) {
            _ = try! NSURLConnection.sendSynchronousRequest(request, returning: nil)
            alert(t: "Completed", title)
        }
        new.append(model)
        
        title = "Send Async Connection Network"
        model = DemoModel(title: title) {
            NSURLConnection.sendAsynchronousRequest(request,
                                                    queue: OperationQueue.main,
                                                    completionHandler: {(response, data, error) in
                                                        alert(t: "Completed", title)
            })
        }
        new.append(model)
        
        title = "Send Shared Session Network"
        model = DemoModel(title: title) {
            let session = URLSession.shared
            URLSession.shared.dataTask(with: request)
            let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
                alert(t: "Completed", title)
            }
            task.resume()
        }
        new.append(model)
        
        title = "Send Configuration Session Network"
        model = DemoModel(title: title) {
            let configure = URLSessionConfiguration.default
            let session = URLSession(configuration: configure,
                                     delegate: nil,
                                     delegateQueue: OperationQueue.current)
            let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
                alert(t: "Completed", title)
            }
            task.resume()
        }
        new.append(model)
        
        return DemoSection(header: "Network", model: new)
    }
    
    static var aslSection: DemoSection {
        var models = [DemoModel]()
        let model = DemoModel(title: "NSLog") {
            NSLog("test")
        }
        models.append(model)
        
        return DemoSection(header: "ASL", model: models)
    }
    
    static var anrSection: DemoSection {
        var models = [DemoModel]()
        
        let title = "Simulate ANR"
        let model = DemoModel(title: title) {
            sleep(4)
            alert(t: "Completed", title)
        }
        models.append(model)
        
        return DemoSection(header: "ANR", model: models)
    }
    
}

func alert(t:String, _ m:String) {
    let alertView = UIAlertView()
    alertView.title = t
    alertView.message = m
    alertView.addButton(withTitle: "OK")
    alertView.show()
}
