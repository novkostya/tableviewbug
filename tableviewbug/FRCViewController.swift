//
//  FRCViewController.swift
//  tableviewbug
//
//  Created by Konstantin Novikov on 26/05/2017.
//  Copyright © 2017 Revolut. All rights reserved.
//

import UIKit
import CoreData

class FRCViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)

    let moc: NSManagedObjectContext = {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension:"momd")!
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        try! psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        return moc
    }()
    
    var frc: NSFetchedResultsController<Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(doit))
        setup()
    }
    
    func insertItems(_ items: (String, String)...) {
        for (section, row) in items {
            let item = Item(context: moc)
            item.section = section
            item.row = row
        }
    }
    
    func setup() {
        insertItems(("A", "1"), ("A", "2"), ("D", "1"), ("D", "2"), ("D", "3"))
        try! moc.save()
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.sortDescriptors = [NSSortDescriptor(key: "section", ascending: true), NSSortDescriptor(key: "row", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "section", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }

    func doit() {
        insertItems(("B", "1"), ("B", "2"), ("C", "1"))
        
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.predicate = NSPredicate(format: "section = %@ AND row = %@", "D", "2")
        if let item = try! moc.fetch(request).first {
            item.row = "2!!!"
        }
        
        try! moc.save()
    }
}

extension FRCViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections![section].objects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = frc.object(at: indexPath)
        cell.textLabel?.text = "\(item.section!) \(item.row!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return frc.sections![section].name
    }
}

extension FRCViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("~~~ begin updates")
        let l = (0..<tableView.numberOfSections).map { "\(tableView.numberOfRows(inSection: $0))" }.joined(separator: " ")
        print("~~~ \(l)")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("~~~ end updates")
        if let dataSource = tableView.dataSource {
            let l = (0..<dataSource.numberOfSections!(in: tableView)).map { "\(dataSource.tableView(tableView, numberOfRowsInSection: $0))" }.joined(separator: " ")
            print("~~~ \(l)")
        }
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("~~~ insert (\(newIndexPath!.section), \(newIndexPath!.row))")
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            print("~~~ delete (\(indexPath!.section), \(indexPath!.row))")
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            print("~~~ reload (\(indexPath!.section), \(indexPath!.row))")
            tableView.reloadRows(at: [indexPath! as IndexPath], with: .none)
        case .move:
            print("~~~ move (\(indexPath!.section), \(indexPath!.row)) -> (\(newIndexPath!.section), \(newIndexPath!.row))")
            if indexPath! == newIndexPath! {
                tableView.reloadRows(at: [indexPath! as IndexPath], with: .none)
            } else {
                tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("~~~ insert section \(sectionIndex)")
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            print("~~~ delete section \(sectionIndex)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
}
