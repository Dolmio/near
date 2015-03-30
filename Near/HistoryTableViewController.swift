//
//  HistoryTableViewController.swift
//  Near
//
//  Created by Petteri Noponen on 04/03/15.
//  Copyright (c) 2015 aalto. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    let visitedPlaces: [Place] = PlaceController().fetchVisitedPlaces()
    @IBOutlet weak var delimeterLine: UIView!
    @IBOutlet weak var footerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        delimeterLine.hidden = visitedPlaces.isEmpty
        footerView.alpha = visitedPlaces.isEmpty ? 1 : 0.5

    }

    override func viewDidAppear(animated: Bool) {
        if (!NSUserDefaults.standardUserDefaults().boolForKey("userHasSeenIntroduction")) {
            performSegueWithIdentifier("toIntroduction", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return visitedPlaces.count
    }

    private struct Storyboard {
        static let cellReuseIdentifier = "HistoryCell"

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath: indexPath) as HistoryTableViewCell
        let place = visitedPlaces[indexPath.row]
        cell.place = place
        cell.tweakSizeAccordingToTable(tableView)
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toMapSegue") {
            let mapViewController = segue.destinationViewController as MapViewController
            if let indexPath = self.tableView.indexPathForSelectedRow(){
                      mapViewController.currentPlace = visitedPlaces[indexPath.row]
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
