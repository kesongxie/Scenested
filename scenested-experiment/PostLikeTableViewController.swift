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
        showDefaultViewWithOption(.Loading)
        startFetchingLikes({
            self.userFetchingCompleted = true
            let postLikeCount = self.post?.postLikes?.count ?? 0
            if postLikeCount < 1{
                self.showDefaultViewWithOption(.NoContentMessage)
            }else{
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
        return  userFetchingCompleted ? (post!.postLikes?.count ?? 0) : 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postLikeCell", forIndexPath: indexPath) as! PostLikeTableViewCell
        cell.postLike = post!.postLikes![indexPath.row]
        cell.likeUserAvatorImageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navigateToProfile))
        cell.likeUserAvatorImageView.addGestureRecognizer(tapGesture)
        return cell
    }
    
    
    
    func startFetchingLikes(completionHandler: () -> Void){
        self.post!.fetchPostLikeInfo({
            (postLikes, error) in
            completionHandler()
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
