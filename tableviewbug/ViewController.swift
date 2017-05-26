//
//  ViewController.swift
//  tableviewbug
//
//  Created by Konstantin Novikov on 26/05/2017.
//  Copyright © 2017 Revolut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
//    var dataSource = [2,3,4,11,4,10,4,5,4,8,1,1,3,3,8,4,5,7,5,1,2,1,13,1,1,1,1,2,2,1,2,2,1,2,1,3,2,1,3,2,6,3,1,3,1,2,1,1,1,3,1,2,1,2,1,2,5,4,3,2,1,1,2,1,1,1,3,2,1,5,4,2,10,28,10,3,3,3,2,2,1,2,8,6,18,4,1,11,1,4,1,3,1,5,1,1,1,4,2,1,3,2,1,10,1,1,1,1,2,6,7,1,2,1,1,3,1,1,5,7,4,1,2,1,4,2,1,1,1,1,2,4,1,2,1,2,2,1,1,2,4,3,1,4,4,1,3,1,2,3,4,1,1,3,5,2,1,1,1,1,2,2,4,3,2,3,2,5,1,3,1,2,2,1,1,1,1,1,5,1,4,2,1,1,4,3,4,2,2,3,2,3,21,3,3,2,1,1,3,2,1,1,5,1,2,2,1,2,2,3,3,3,1,1,1,2,1,1,1,1,1,2,1,1,1,1,10,1,1,3,4,4,4,3,1,1,4,1,3,1,1,1,2,1]
    var dataSource = [2,3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(doit))
    }

    func doit() {
//        let c = [8, 23, 1, 2, 8, 1, 6, 1]
        let c = [1, 2]
        tableView.beginUpdates()
        dataSource.insert(contentsOf: c, at: 1)
        tableView.insertSections(IndexSet(integersIn: 1...c.count), with: .fade)
        for (i, n) in c.enumerated() {
            tableView.insertRows(at: (0..<n).map{ IndexPath(row: $0, section: i+1) }, with: .fade)
        }
        tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .none)
        tableView.endUpdates()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.section), \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(section)"
    }
}
