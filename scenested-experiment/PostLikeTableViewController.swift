//
//  PostLikeTableViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/18/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit



class PostLikeTableViewController: UITableViewController {
    let reuseIden = "postLikeCell"
    
    var post: Post?
    
    var postLikes: [PostLike]?
    
    var backBtn = UIBarButtonItem()
    
    var userFetchingCompleted = false

    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var defaultMessageView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Likes"
        backBtn.image = UIImage(named: "back-icon")
        backBtn.target = self
        backBtn.action = #selector(PostLikeTableViewController.backBtnTapped)
        backBtn.tintColor = StyleSchemeConstant.themeMainTextColor
        self.navigationItem.leftBarButtonItem = backBtn

        
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostLikeTableViewController.navigateToProfile(_:)), name: NotificationLocalizedString.profileNavigatableViewTappedNotificationName, object: nil)
        
        
        
        showDefaultView()
        startFetchingLikeUsers({
            self.userFetchingCompleted = true
            if self.post!.postLikes?.count < 1{
                self.defaultMessageView.hidden = false
            }else{
                self.defaultMessageView.hidden = true
                self.hideDefaultView()
            }
            self.tableView.reloadData()
        })
        
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
        return  userFetchingCompleted ? (postLikes?.count ?? 0) : 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postLikeCell", forIndexPath: indexPath) as! PostLikeTableViewCell
        cell.postLike = postLikes![indexPath.row]
        cell.likeUserAvatorImageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navigateToProfile))
        cell.likeUserAvatorImageView.addGestureRecognizer(tapGesture)
        return cell
    }
    
    
    
    func startFetchingLikeUsers(completionHandler: () -> Void){
        if postLikes != nil{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { //don't block the main thread
                let loadingGroup = dispatch_group_create()
                for postLike in self.postLikes!{
                    dispatch_group_enter(loadingGroup)
                    postLike.likeUser = User(id: postLike.likeUserId!, completionHandler: {
                        (succeed, info) in
                        dispatch_group_leave(loadingGroup)
                    })
                }
                dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            })
        }else{
            activityIndicator.stopAnimating()
            defaultMessageView.hidden = false
        }
    }
    
    
    func showDefaultView(){
        defaultView?.frame.size.width = view.bounds.size.width
        let statusHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        defaultView?.frame.size.height = view.bounds.size.height - statusHeight - navigationBarHeight - tabBarHeight
        
    }
    

    
    func hideDefaultView(){
        defaultView?.frame.size = CGSizeZero
    }
    

    
    func backBtnTapped(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    func navigateToProfile(gesture: UIGestureRecognizer){
        if let postLikeCell = gesture.view?.superview?.superview as? PostLikeTableViewCell{
            if let user = postLikeCell.postLike?.likeUser{
                self.navigationController?.pushProfileWithUser(user)
            }
        }
    }
    
    
    /*
     func navigatableAvatorImageViewTapped(gesture: UIGestureRecognizerState){
     if let postLike = postLike{
     let userInfo: [String: AnyObject] = [
     "user": postLike.likeUser
     ]
     
     let profileNavigatableViewTappedNotification = NSNotification(name: NotificationLocalizedString.profileNavigatableViewTappedNotificationName, object: self, userInfo: userInfo)
     NSNotificationCenter.defaultCenter().postNotification(profileNavigatableViewTappedNotification)
     }
     }
     */
    
    
    
    
    
    
    
}
