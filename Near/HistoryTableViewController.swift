import UIKit
import CoreData

class HistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var visitedPlaces = [Place]()
    @IBOutlet weak var delimeterLine: UIView!
    @IBOutlet weak var footerView: UIView!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        var error: NSError? = nil
        if (fetchedResultsController.performFetch(&error) == false) {
            println("An error occurred: \(error?.localizedDescription)")
        }

        updateVisitedPlaces()
    }

    private func updateVisitedPlaces() {
        visitedPlaces = fetchedResultsController.fetchedObjects as! [Place]

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

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let frc = NSFetchedResultsController(
            fetchRequest: PlaceController.visitedPlacesRequest(),
            managedObjectContext: self.appDelegate.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)

        frc.delegate = self

        return frc
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visitedPlaces.count
    }

    private struct Storyboard {
        static let cellReuseIdentifier = "HistoryCell"

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath: indexPath) as! HistoryTableViewCell
        let place = visitedPlaces[indexPath.row]
        cell.place = place
        cell.tweakSizeAccordingToTable(tableView)
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toMapSegue") {
            let mapViewController = segue.destinationViewController as! MapViewController
            if let indexPath = self.tableView.indexPathForSelectedRow(){
                      mapViewController.currentPlace = visitedPlaces[indexPath.row]
            }
        }
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        updateVisitedPlaces()
        tableView.reloadData()
    }

}
