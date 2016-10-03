//
//  NearByTableViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/24/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

let reuseIden = "NearByCell"

class NearByTableViewController: UITableViewController {

    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var defaultMessageView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var defaultMessageTextLabel: UILabel!
    
    var currentLoadedNearByUser = [User]()
    var currentLoadedUserIdList = [Int]()
    
    @IBOutlet weak var loadingIndicator: UIRefreshControl!
    
    @IBAction func refresh(sender: UIRefreshControl) {
        currentLoadedNearByUser = [User]()
        currentLoadedUserIdList = [Int]()
        
        
        
        
        let central = (UIApplication.sharedApplication().delegate as? AppDelegate)?.centralManager
        central?.stopScan()
        let serviceUUID = [ CBUUID(NSUUID:  NSUUID(UUIDString: APPUUID)! ) ]
        central?.scanForPeripheralsWithServices(serviceUUID, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        
        print(getCurrentNearByUserIdList())
        
        
        guard let idList = getCurrentNearByUserIdList() where idList.count > 0 else{
            sender.endRefreshing()
            showDefaultViewWithOption(.NoContentMessage)
            return
        }
        
        
        fetchingUserFromIdList(idList)
    }
    
    
    var fetchingUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rangingInitNotification = NSNotification(name: NotificationLocalizedString.RangingInitNotificationName, object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(rangingInitNotification)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.centralManagerStatedUpdated(_:)), name: NotificationLocalizedString.CentralManagerStateUpdatedNotificationName, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.nearbyUserIdUpdated(_:)), name: NotificationLocalizedString.NearByUserIdUpdatedNotificationName, object: nil)
        
        
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        showDefaultViewWithOption(.Loading)
        
        self.performSelector(#selector(self.doneWithLoading), withObject: nil, afterDelay: 10)
        
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentLoadedNearByUser.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIden, forIndexPath: indexPath) as! NearByTableViewCell
        cell.user = currentLoadedNearByUser[indexPath.row]
        let tapGestureForAvator = UITapGestureRecognizer(target: self, action: #selector(self.avatorTapped(_:)))
        cell.userAvatorImageView.addGestureRecognizer(tapGestureForAvator)
        return cell
    }
    
    
    
    func doneWithLoading(){
        if !fetchingUser{
            showDefaultViewWithOption(.NoContentMessage)
        }
    }
    
    
    func avatorTapped(gesture: UITapGestureRecognizer){
        if let nearByCell = gesture.view?.superview?.superview as? NearByTableViewCell{
            self.navigationController?.pushProfileWithUser(nearByCell.user)
        }
    }
    

    func centralManagerStatedUpdated(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(), {
            if let centralState = (UIApplication.sharedApplication().delegate as? AppDelegate)?.centralManager.state{
                switch centralState{
                case .PoweredOn:
                    guard let currentIdList = getCurrentNearByUserIdList() where currentIdList.count > 0 else{
                        self.defaultImageView.image = UIImage(named: "profile-user-shape")
                        self.defaultMessageTextLabel.text = "No near-by profile found"
                        return
                    }
                    self.fetchingUserFromIdList(currentIdList)
                case .PoweredOff:
                    print("power off")
                    //show the bluetooth icon to ask the user to turn on the bluetooth
                    self.defaultImageView.image = UIImage(named: "blue-tooth")
                    self.defaultMessageTextLabel.text = "Turn on the bluetooth to range people near by"
                    
                    self.showDefaultViewWithOption(.NoContentMessage)
                default:
                    print("default")
                    break
                }
            }
            
        })
    }
    
    
    
    func nearbyUserIdUpdated(notification: NSNotification){
        if let currentNearByUserIdList = notification.userInfo!["currentNearByUserIdList"] as? [Int]{
            print("------notification recieved------")
            //update the interface indicating there are new users near by
            if currentNearByUserIdList.count > 0{
                fetchingUserFromIdList(currentNearByUserIdList)
            }
        }
    }
    
    
    func fetchingUserFromIdList(currentNearByUserIdList: [Int]){
        fetchingUser = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let loadingGroup = dispatch_group_create()
            for userId in currentNearByUserIdList{
                if !self.currentLoadedUserIdList.contains(userId){
                    dispatch_group_enter(loadingGroup)
                    self.currentLoadedNearByUser.insert(User(id: userId, completionHandler: {
                        (succeed, error) in
                        self.currentLoadedUserIdList.insert(userId, atIndex: 0)
                        dispatch_group_leave(loadingGroup)
                    })!, atIndex: 0)
                }
            }
            dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                //haven't loaded any user yet
                self.loadingIndicator.endRefreshing()
                self.hideDefaultView()
                self.tableView.reloadData()
                
            })
        })

    }

    
    
    func showDefaultViewWithOption(option: DefaultViewOpenOption){
        self.defaultView.frame.size = self.getVisibleContentRectSize()
        switch option{
        case .Loading:
            //show the loading view
            self.activityIndicator.startAnimating()
            self.defaultMessageView.hidden = true
        case .NoContentMessage:
            self.activityIndicator.stopAnimating()
            self.defaultMessageView.hidden = false
            
        }
    }
    
    func hideDefaultView(){
        self.defaultView.frame.size = CGSizeZero
    }

    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




//extension NearByTableViewController: CBCentralManagerDelegate{
//    
//    func centralManagerDidUpdateState(central: CBCentralManager) {
//    }
//    
//    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
//        print("the advertisment data is")
//        print(advertisementData)
//    }
//    
//    
//}
