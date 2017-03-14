//
//  URLTableViewController.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class URLTableViewController: UITableViewController {

    let kCellWithIdentifier = "reuseIdentifier"
    
    
    var getURLs: ((_ scannedURLs: [URL]) -> Void)?
    var stringURLs: [String]?
    
    
    init() {
        super.init(style: .plain)
    }
    
    convenience init(urls: [URL]?) {
        self.init()
        
        if let urlArray = urls {
            for url in urlArray {
                stringURLs?.append(url.absoluteString)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.rightBarButtonItem = editButtonItem
        
        let scanButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(scanQR))
 
        navigationItem.rightBarButtonItems = [editButtonItem, scanButtonItem]
        
        let cancelButtonItem = UIBarButtonItem.init(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        let confirmButtonItem = UIBarButtonItem.init(title: "Confirm", style: .done, target: self, action: #selector(confirm))
        
        navigationItem.leftBarButtonItems = [cancelButtonItem, confirmButtonItem]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellWithIdentifier)
    }

    func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func confirm() {
        var URLs: [URL] = Array()
        guard let _ = stringURLs else{
            return
        }
        for urlStr: String in stringURLs! {
            URLs.append(URL.init(string: urlStr)!)
        }
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            if let _ = self?.getURLs {
                self?.getURLs!(URLs)
            }
        })
    }
    
    func scanQR() {
        let qrVC = QRViewController()
        qrVC.getQrCode = { [weak self] (stringQR) -> Void in
            self?.stringURLs?.append(stringQR)
            // TODO: strong self
            self?.dismiss(animated: true, completion: nil)
            self?.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stringURLs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellWithIdentifier, for: indexPath)

        cell.textLabel?.text = (stringURLs! as NSArray).object(at: indexPath.row) as? String

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
}
