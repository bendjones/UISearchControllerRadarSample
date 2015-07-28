//
//  MasterViewController.swift
//  UISearchControllerRadarSample
//
//  Created by Ben D. Jones on 7/9/15.
//  Copyright (c) 2015 Ben D. Jones. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var filteredObjects = [AnyObject]()

    var searchController: UISearchController?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // NOTE: Setup iOS 8 UISearchController
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.barTintColor = view.tintColor
        searchController?.searchBar.tintColor = UIColor.blackColor()
        searchController?.searchBar.translucent = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // NOTE: Add the search bar to the tableView
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.searchBar.sizeToFit()
        
        definesPresentationContext = true
        
        tableView.reloadData()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers

            self.detailViewController = (controllers.last as? UINavigationController)?.topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for _ in 0..<2 {
            insertNewObject(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}

private typealias TableViewDataSource = MasterViewController
extension TableViewDataSource {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchController = searchController where searchController.active {
            return filteredObjects.count
        }
        
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        if let searchController = searchController where searchController.active {
            let object = filteredObjects[indexPath.row] as! NSDate
            cell.textLabel!.text = object.description
        } else {
            let object = objects[indexPath.row] as! NSDate
            cell.textLabel!.text = object.description
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if let searchController = searchController where searchController.active {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

private typealias TableViewDelegate = MasterViewController
extension TableViewDelegate {
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let exampleView = UIView()
        exampleView.backgroundColor = UIColor.purpleColor()
        
        return exampleView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 317
    }
}

extension MasterViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        filteredObjects = objects.filter { $0.description == searchText }
        
        tableView.reloadData()
    }
}
