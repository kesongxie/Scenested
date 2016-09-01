//
//  PostCommentViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/23/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class PostCommentViewController: UIViewController {
    
    let reuseIden = "postCommentCell"

    
    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var defaultMessageView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var defaultScrollView: UIScrollView!
    
    @IBOutlet weak var heartIconImageView: UIImageView!
    
    @IBOutlet weak var commentTextField: UITextField!{
        didSet{
            commentTextField.layer.borderColor = UIColor(red: 240 / 255.0, green:  240 / 255.0, blue:  240 / 255.0, alpha: 1).CGColor
            commentTextField.layer.borderWidth = 1.0
        }
    }
    
    weak var respondingPostCell: PostTableViewCell?
 
    var post: Post?
    
    var postComments: [PostComment]?
    
    
    var backBtn: UIBarButtonItem?{
        didSet{
            backBtn!.image = UIImage(named: "back-icon")
            backBtn!.target = self
            backBtn!.action = #selector(PostLikeTableViewController.backBtnTapped)
            backBtn!.tintColor = StyleSchemeConstant.themeMainTextColor
            self.navigationItem.leftBarButtonItem = backBtn!
        }
    }
    
    var userFetchingCompleted = false
  
    
    var commentText: String?{
        get{
            return self.commentTextField.text
        }
        set{
            self.commentTextField.text = newValue
        }
    }
    
    private var StatusBarAndNavigatioBarHeightSum: CGFloat = 0
    
    private var isUIAdjustingWhileKeyBoardShows: Bool = false //when the keyboard shows, the offset of the view will be adjusted based upon the frame of the keyboard, set to yes, if the View is on the process of adjusting the UI

   // private let slideInPresentationAnimator = HorizontalSlideInPresentationAnimator()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        defaultScrollView.delegate = self
        commentTextField.delegate = self
        StatusBarAndNavigatioBarHeightSum = self.getHeaderHeight()
        
        self.title = "Comments"
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        loadComment()

        backBtn = UIBarButtonItem()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.navigateToProfile(_:)), name: NotificationLocalizedString.profileNavigatableViewTappedNotificationName, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyBoardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.commentTextViewTapped), name: NotificationLocalizedString.TextViewTappedNotificationName, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.commentTextViewMentionedTapped), name: NotificationLocalizedString.TextViewMentionedTappedNotificationName, object: nil)
        
        
        
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//         self.tabBarController?.tabBar.hidden = false
//    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isUIAdjustingWhileKeyBoardShows{
            view.endEditing(true)
            defaultScrollView.scrollEnabled = false
            commentTextField.textAlignment = .Center
        }
    }

    //if indexPathSetToload is not nil, then insert with animation for only the indexPath provided
    func loadComment(indexPathSetToload: [NSIndexPath]? = nil){
        startFetchingUserInfo(indexPathSetToload, completionHandler:{
            self.userFetchingCompleted = true
            self.activityIndicator.stopAnimating()
            let commentCount = self.post!.postComments?.count ?? 0
            if commentCount < 1{
                self.defaultMessageView.hidden = false
            }else{
                self.defaultMessageView.hidden = true
                self.defaultScrollView.hidden = true
            }
            if indexPathSetToload == nil{
                self.tableView.reloadData()
            }else{
                self.title = "Comments"
                self.tableView.insertRowsAtIndexPaths(indexPathSetToload!, withRowAnimation: .Automatic)
            }
        })
    }
    
    
    func startFetchingUserInfo(indexPathSetToload: [NSIndexPath]?,completionHandler: () -> Void){
        if postComments != nil{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { //don't block the main thread
                let loadingGroup = dispatch_group_create()
                //load the comment user
                for postComment in self.postComments!{
                    dispatch_group_enter(loadingGroup)
                    postComment.commentUser = User(id: postComment.commentUserId!, completionHandler: {
                        (succeed, info) in
                        //load tagged user
                        if postComment.mentionedUserIdList != nil{
                                postComment.mentionedUserList = [User]()
                            for mentionedUserId in postComment.mentionedUserIdList!{
                                dispatch_group_enter(loadingGroup)
                                postComment.mentionedUserList!.append(User(id: mentionedUserId, completionHandler: {
                                    (succeed, info) in
                                    dispatch_group_leave(loadingGroup)
                                })!)
                            }
                        }
                        dispatch_group_leave(loadingGroup)
                    })
                }
                dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            })
        }else{
            completionHandler()
        }
    }
    
    func keyboardDidShow(notification: NSNotification){
        isUIAdjustingWhileKeyBoardShows = true
        if let keyboardFrame = notification.keyboardEndFrame{
            let defaultViewShouldScroll = -(self.view.frame.size.height - heartIconImageView.frame.origin.y)
            UIView.animateWithDuration(0.3, animations: {
                self.defaultScrollView.contentOffset.y = defaultViewShouldScroll
                self.view.frame.origin.y = (-keyboardFrame.height + 49)
                }, completion: {
                    finished in
                    if finished{
                        self.isUIAdjustingWhileKeyBoardShows = false
                    }
            })
        }
    }
    
    func keyBoardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
        let contentOffset = (StatusBarAndNavigatioBarHeightSum != 0) ? StatusBarAndNavigatioBarHeightSum : 0
        self.tableView.contentOffset.y = -contentOffset
        self.defaultScrollView.contentOffset.y = -contentOffset
    }
    
    func backBtnTapped(){
        self.navigationController?.popViewControllerAnimated(true)
       // self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func navigateToProfile(gesture: UIGestureRecognizer){
        if let postCommentCell = gesture.view?.superview?.superview as? PostCommentTableViewCell{
            if let user = postCommentCell.comment?.commentUser{
                
                
               self.navigationController?.pushProfileWithUser(user)
//                
//                if let tabbarVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.GlobalTabBarControllerIden) as? TabBarController{
//                    tabbarVC.selectedIndex = 0
//                    if let profileNVC = tabbarVC.selectedViewController as? ProfileNavigationController{
//                        if let profileVC = profileNVC.viewControllers.first as? ProfileViewController{
//                                profileVC.profileUser = user
////                                profileVC.title = user.username
//                                profileVC.navigationItem.leftBarButtonItem = getBackBtnAsUIBarBtnItem()
//                                  profileVC.navigationItem.leftBarButtonItem?.target = self
//                                 profileVC.navigationItem.leftBarButtonItem?.action = #selector(self.popProfile)
//                            
//                                tabbarVC.transitioningDelegate = self
//                                self.presentViewController(tabbarVC, animated: true, completion: nil)
//                        }
//                    }
//                
//                }
//            
//                
                
                
                
                
                
                
            }
        }
    }
    

    
    
    //when the textview(other than the hash tag or mention part) is tapped, receive a notification
    func commentTextViewTapped(notification: NSNotification){
        if let commentTextView = notification.userInfo!["textView"] as? UITextView{
            if let commentCell = commentTextView.superview?.superview as? PostCommentTableViewCell{
                if let indexPath = self.tableView.indexPathForCell(commentCell){
                    let interactingComment = self.postComments![indexPath.row]
                    if interactingComment.commentUserId != getLoggedInUser()?.id{
                        reactWhenCommentTapped(indexPath)
                    }
                }
            }
        }
    }
    
    func commentTextViewMentionedTapped(notification: NSNotification){
        //navigate to mentioned user's profile
        if let postComment = retriveInteracingCommentFromTextView(notification.userInfo!["textView"] as? UITextView){
            //find the info for the mentioned user
            var userFound: User?
            if postComment.mentionedUserList != nil{
                for user in postComment.mentionedUserList!{
                    if user.username! == notification.userInfo!["mentionedUserName"] as! String{
                        userFound = user
                        break
                    }
                }
            }
            self.navigationController?.pushProfileWithUser(userFound, requestedUsername: notification.userInfo!["mentionedUserName"] as? String)

        }
    }
    
    private func retriveInteracingCommentFromTextView(commentTextView: UITextView?) -> PostComment?{
        if let textview = commentTextView{
            if let commentCell = textview.superview?.superview as? PostCommentTableViewCell{
                if let indexPath = self.tableView.indexPathForCell(commentCell){
                    return self.postComments![indexPath.row]
                }
            }
        }
        return nil
    }
    
    
    
    func commentCellTapped(gesture: UITapGestureRecognizer){
        if let commentCell = gesture.view as? PostCommentTableViewCell{
            if let indexPath = self.tableView.indexPathForCell(commentCell){
                reactWhenCommentTapped(indexPath)
            }
        }
        
    }
    
    
    func commentCellLongPressed(gesture: UILongPressGestureRecognizer){
        if self.presentedViewController == nil{
            if let commentCell = gesture.view as? PostCommentTableViewCell{
                if let indexPath = self.tableView.indexPathForCell(commentCell){
                    let interactingComment = self.postComments![indexPath.row]
                    guard let loggedInUserId = getLoggedInUser()?.id else{
                        return
                    }
                    if interactingComment.commentUserId == loggedInUserId || post!.feature.user.id == loggedInUserId{
                        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                            alertAction in
                            
                            self.title = "Deleting..."
                            self.post!.deleteComment(interactingComment.postCommentId!, completionHandler: {
                                deletedSucceed in
                                if deletedSucceed{
                                    self.title = "Comments"
                                    self.post?.postComments?.removeAtIndex(indexPath.row)
                                    self.postComments = self.post?.postComments
                                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                    let commentCount = self.post!.postComments?.count ?? 0
                                    
                                    var countString: String?
                                    if commentCount > 0{
                                        countString = String(commentCount)
                                    }else{
                                        countString = ""
                                        self.defaultScrollView.contentOffset.y = 0
                                        self.defaultMessageView.hidden = false
                                        self.defaultScrollView.hidden = false
                                    }
                                    self.respondingPostCell?.postCommentCountLabel.text = countString
                                }
                            })
                        })
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                        alert.addAction(deleteAction)
                        alert.addAction(cancelAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    func reactWhenCommentTapped(indexPath: NSIndexPath){
        self.commentTextField.becomeFirstResponder()
        let interactingComment = self.postComments![indexPath.row]
        self.commentText = "@" + interactingComment.commentUser.username! + " "
        
    }
}

extension PostCommentViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  userFetchingCompleted ? (postComments?.count ?? 0) : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIden) as! PostCommentTableViewCell
        cell.comment = postComments![indexPath.row]
        cell.commentUserImageView.userInteractionEnabled = true
        //tap gesture for avator
        let tapGestureForAvator = UITapGestureRecognizer(target: self, action: #selector(self.navigateToProfile))
        cell.commentUserImageView.addGestureRecognizer(tapGestureForAvator)
        cell.selectionStyle = .None
        
        //long press gesture for cell
        let longPressedGestureForCell = UILongPressGestureRecognizer(target: self, action: #selector(self.commentCellLongPressed))
        cell.addGestureRecognizer(longPressedGestureForCell)
        
        //tap gesture for cell and it's only for other user's comment
        let interactingComment = self.postComments![indexPath.row]
        if interactingComment.commentUserId != getLoggedInUser()?.id{
            let tapGestureForCell = UITapGestureRecognizer(target: self, action: #selector(self.commentCellTapped))
            cell.addGestureRecognizer(tapGestureForCell)
        }
        return cell
    }
}

extension PostCommentViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.textAlignment = .Left
        defaultScrollView.scrollEnabled = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.title = "Posting..."
        let text = self.commentText!
        self.commentText = ""
        
        self.defaultScrollView.hidden = true
        commentTextField.resignFirstResponder()
        //add comment to post
        getLoggedInUser()?.commentPost(text, post: post!, completionHandler: {
            (comment) in
            if comment != nil && self.respondingPostCell != nil{
                self.postComments = self.post?.postComments
                let commentIndexPath = NSIndexPath(forItem: 0, inSection: 0)
                let indexPathSetToLoad = [commentIndexPath]
                self.loadComment(indexPathSetToLoad)
                self.commentTextField.textAlignment = .Center
                let countString = self.post!.postComments!.count == 0 ? "" : String(self.post!.postComments!.count)
                self.respondingPostCell?.postCommentCountLabel.text = countString
              }
        })
        return true
    }
}



//extension PostCommentViewController: UIViewControllerTransitioningDelegate{
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        slideInPresentationAnimator.presenting = true
//        return slideInPresentationAnimator
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        print("ehllo")
//        slideInPresentationAnimator.presenting = false
//        return slideInPresentationAnimator
//    }
//    
//    
//    
//    
//}




