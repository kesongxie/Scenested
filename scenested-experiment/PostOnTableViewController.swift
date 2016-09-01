//
//  PostOnTableViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/15/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit


class PostOnTableViewController: UITableViewController {

    private let reuseIden = "PostOnTableViewCellIden"

    @IBAction func cancelBtnTapped(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBOutlet weak var defaultView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        defaultViewShouldDisplay()
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
        return getLoggedInUser()?.features?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIden, forIndexPath: indexPath) as! PostOnTableViewCell
        cell.feature = getLoggedInUser()?.features?[indexPath.row]
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let editPostNVC =  self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.EditPostNavigationViewControllerIden) as? EditPostNavigationViewController{
            if let editPostVC = editPostNVC.viewControllers.first as? EditPostViewController{
                editPostVC.feature = getLoggedInUser()?.features?[indexPath.row]
                self.navigationController?.pushViewController(editPostVC, animated: true)
            }
        }
    }
    
    
    
    func defaultViewShouldDisplay(){
        let count =  getLoggedInUser()?.features?.count ?? 0
        if count > 0{
            defaultView?.frame.size = CGSizeZero
            self.tableView.separatorStyle = .SingleLine
        }else{
            defaultView?.frame.size.width = view.bounds.size.width
            let statusHeight = UIApplication.sharedApplication().statusBarFrame.height
            let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
            defaultView?.frame.size.height = view.bounds.size.height - statusHeight - navigationBarHeight
            self.tableView.separatorStyle = .None
        }
    }

    
    
  
}
