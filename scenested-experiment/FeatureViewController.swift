//
//  featureViewController.swift
//  poststed-experiment
//
//  Created by Xie kesong on 7/19/16.
//  Copyright © 2016 ___poststed___. All rights reserved.
//

import UIKit


let reusedIden = "postCell"

class FeatureViewController: UITableViewController{

    @IBAction func backButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func refresh(sender: UIRefreshControl) {
        self.isFetchingPost = true
        print(self.tableView.contentOffset)
        self.feature?.refreshPost(numberOfPostPerFecthingRequest, completionHandler: {
            lastRowPostId in
            self.feature!.lastLoadedPostId = lastRowPostId
            sender.endRefreshing()
            //self.tableView.scrollIndicatorInsets.top = 0
            self.tableView.reloadData()
            self.isFetchingPost = false
            if lastRowPostId == nil{
                self.showDefaultViewWithOption(.NoPostMessage)
            }else{
                self.hideDefaultView()
            }
        })
        
    }

    //the default view to display when there is no post in this feature
    @IBOutlet weak var defaultView: UIView!

    @IBOutlet weak var defaultMessageView: UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    //  private let slideInPresentationAnimator = HorizontalSlideInPresentationAnimator()
    var feature: Feature?
    
    var isFetchingPost: Bool = false
    
    private let numberOfPostPerFecthingRequest: Int = 10
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var bottomActivityIndicator: UIActivityIndicatorView!
    
    
    
    private let adjustScrollViewOffSetForLoadMorePost: CGFloat = 400 //when the scroll bar is less than 200, load more post

    enum DefaultViewOpenOption{
        case Loading
        case NoPostMessage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.title = feature?.featureName.uppercaseString

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.postTextTextViewMentionedTapped(_:)), name: NotificationLocalizedString.TextViewMentionedTappedNotificationName, object: nil)
        //check whether the posts are available or not

        if feature?.post == nil{
            //reload
            if feature?.postCount > 0{
                showDefaultViewWithOption(.Loading)
                fetchingPostForFeature({
                    lastRowPostId in
                    self.feature!.lastLoadedPostId = lastRowPostId
                    self.hideDefaultView()
                    self.tableView.reloadData()
                    self.isFetchingPost = false
                })
            }else{
                showDefaultViewWithOption(.NoPostMessage)
            }
        }else{
            //already load
            if self.feature!.postCount < 1 {
                //show default message view
                showDefaultViewWithOption(.NoPostMessage)
            }else{
                //hide fault message view
                hideDefaultView()
            }
        }
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if self.feature?.currentLoadedPostCount < self.feature?.postCount{
            if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height - adjustScrollViewOffSetForLoadMorePost{
                if !isFetchingPost{
                    self.bottomActivityIndicator.startAnimating()
                    self.isFetchingPost = true
                    if let lastPostId =  self.feature!.lastLoadedPostId{
                        self.loadMorePost(lastPostId, completionHandler: {
                            self.isFetchingPost = false
                            self.bottomActivityIndicator.stopAnimating()
                        })
                    }
                }
            }
        }

    }
    


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.feature?.post?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.feature?.post?[section].count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusedIden, forIndexPath: indexPath) as! PostTableViewCell
        //add tap gesture for dot icon
        let tapGestureForDotIcon = UITapGestureRecognizer(target: self, action: #selector(self.dotIconTapped(_:)))
        cell.dotIconImageView.addGestureRecognizer(tapGestureForDotIcon)

        //tap for like count label
        let tapGestureForPostLikeCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.postLikeCountLabelTapped(_:)))
        cell.postLikeCountLabel?.userInteractionEnabled = true
        cell.postLikeCountLabel?.addGestureRecognizer(tapGestureForPostLikeCountLabel)

        //tap for comment icon
        let tapGestureForCommentIcon = UITapGestureRecognizer(target: self, action: #selector(self.commentIconTapped(_:)))
        cell.commentIconImageView?.userInteractionEnabled = true
        cell.commentIconImageView?.addGestureRecognizer(tapGestureForCommentIcon)

        //tap for comment count label
        let tapGestureForPostCommentCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.postCommentCountLabelTapped(_:)))
        cell.postCommentCountLabel?.userInteractionEnabled = true
        cell.postCommentCountLabel?.addGestureRecognizer(tapGestureForPostCommentCountLabel)


        //tap for the user imageview
        let tapGestureForUserAvatorImageView = UITapGestureRecognizer(target: self, action: #selector(self.postUserAvatorImageViewTapped(_:)))
        cell.postUserImageView?.userInteractionEnabled = true
        cell.postUserImageView?.addGestureRecognizer(tapGestureForUserAvatorImageView)

        cell.post = feature?.post?[indexPath.section][indexPath.row]
        return cell
    }



    func loadMorePost(lastRowPostId: Int, completionHandler: () -> Void){
        feature!.fetchPostsForFeature(lastRowPostId, numberOfRequestedRow: numberOfPostPerFecthingRequest, completionHandler: {
            lastRowPostId in
             self.feature?.lastLoadedPostId = lastRowPostId
            let indexSet = NSIndexSet(index: self.feature!.currentNumberOfLoadedSection)
            self.tableView.insertSections(indexSet, withRowAnimation: .Fade)
            completionHandler()
        })
    }

    func fetchingPostForFeature(completionHandler: Int? -> Void){
        //start fetching posts in this feature
         if !self.isFetchingPost{
            if feature != nil{
                self.isFetchingPost = true
                //load new posts
                feature!.fetchPostsForFeature( self.feature!.lastLoadedPostId, numberOfRequestedRow: numberOfPostPerFecthingRequest, completionHandler: completionHandler)
            }
        }
    }


    func showDefaultViewWithOption(option: DefaultViewOpenOption){
        self.defaultView.frame.size = self.getVisibleContentRectSize()
        switch option{
        case .Loading:
            //show the loading view
            self.activityIndicator.startAnimating()
            self.defaultMessageView.hidden = true
        case .NoPostMessage:
            self.activityIndicator.stopAnimating()
            self.defaultMessageView.hidden = false
        }
    }

    func hideDefaultView(){
        self.defaultView.frame.size = CGSizeZero
    }




    //action after the dot icon is tapped
    func dotIconTapped(gesture: UITapGestureRecognizer){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete Post", style: .Destructive, handler: {
            alertAction in
            let alert = UIAlertController(title: "Delete Post", message: "Do you want to delete this post?", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                alertAction in
                if let postCell = gesture.view?.superview?.superview as? PostTableViewCell{
                    self.title = "Deleting..."
                    getLoggedInUser()?.deletePostInFeature(postCell.post!, feature: self.feature!, completionHandler: {
                        status in
                        if status{
                            //successfully deleted the post
                            self.title = self.feature?.featureName.uppercaseString
                            if let indexPath = self.tableView.indexPathForCell(postCell){
                                self.feature?.post?[indexPath.section].removeAtIndex(indexPath.row)
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                if let postCount = self.feature?.postCount{
                                    if postCount < 1{
                                        self.showDefaultViewWithOption(.NoPostMessage)
                                    }
                                }
                            }
                        }
                    })
                }

            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)

        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }


    func commentIconTapped(gesture: UIGestureRecognizer){
        if let composeCommentNVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.ComposeCommentNavigationViewControllerIden) as? ComposeCommentNavigationViewController{
            if let composeCommentVC = composeCommentNVC.viewControllers.first as? ComposeCommentViewController{


                if let postCell = gesture.view?.superview?.superview as? PostTableViewCell{
                    composeCommentVC.post = postCell.post
                    composeCommentVC.respondingPostCell = postCell
                }

                self.presentViewController(composeCommentNVC, animated: true, completion: {
                    composeCommentVC.commentTextView.becomeFirstResponder()
                })
            }
        }
    }



    func postLikeCountLabelTapped(gesture: UITapGestureRecognizer){
        if let postCell = gesture.view?.superview?.superview as? PostTableViewCell{
            if let postLikeTableVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.PostLikeTableViewControllerIden) as? PostLikeTableViewController{
                postLikeTableVC.post = postCell.post
                postLikeTableVC.postLikes = postCell.post!.postLikes
                self.navigationController?.pushViewController(postLikeTableVC, animated: true)
            }
        }
    }
    //
    //    func postCommentCountLabelTapped(gesture: UITapGestureRecognizer){
    //        if let postCell = gesture.view?.superview?.superview as? PostTableViewCell{
    //            if let postCommentNVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.PostCommentNavigationControllerIden) as? PostCommentNavigationController{
    //                if let postCommentVC = postCommentNVC.viewControllers.first as? PostCommentViewController{
    //                    postCommentVC.post = postCell.post
    //                    postCommentVC.postComments = postCell.post!.postComments
    //                    postCommentVC.respondingPostCell = postCell
    //
    //    //                postCommentVC.hidesBottomBarWhenPushed = true
    //      //               self.navigationController?.pushViewController(postCommentVC, animated: true)
    ////
    //                    self.modalPresentationStyle = .Custom
    //                   postCommentNVC.transitioningDelegate = self
    //                   self.presentViewController(postCommentNVC, animated: true, completion: nil)
    //                }
    //            }
    //        }
    //    }


    func postCommentCountLabelTapped(gesture: UITapGestureRecognizer){
        if let postCell = gesture.view?.superview?.superview as? PostTableViewCell{
            if let postCommentNVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.PostCommentNavigationControllerIden) as? PostCommentNavigationController{
                if let postCommentVC = postCommentNVC.viewControllers.first as? PostCommentViewController{
                    postCommentVC.post = postCell.post
                    postCommentVC.postComments = postCell.post!.postComments
                    postCommentVC.respondingPostCell = postCell

                    // postCommentVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(postCommentVC, animated: true)
                }
            }
        }
    }



    func postUserAvatorImageViewTapped(gesture: UIGestureRecognizer){
        if let postCell = gesture.view?.superview?.superview as? PostTableViewCell{
            self.navigationController?.pushProfileWithUser(postCell.post!.feature.user)
        }

    }


    private func retriveInteracingPostFromTextView(postTextTextView: UITextView?) -> Post?{
        if let textview = postTextTextView{
            if let postCell = textview.superview?.superview as? PostTableViewCell{
                if let indexPath = self.tableView.indexPathForCell(postCell){
                    return self.feature?.post![indexPath.section][indexPath.row]
                }
            }
        }
        return nil
    }

    func postTextTextViewMentionedTapped(notification: NSNotification){
        //navigate to mentioned user's profile
        if let post = retriveInteracingPostFromTextView(notification.userInfo!["textView"] as? UITextView){
            //find the info for the mentioned user
            var userFound: User?
            if post.mentionedUserList != nil{
                for user in post.mentionedUserList!{
                    if user.username! == notification.userInfo!["mentionedUserName"] as! String{
                        userFound = user
                        break
                    }
                }
            }
            self.navigationController?.pushProfileWithUser(userFound, requestedUsername: notification.userInfo!["mentionedUserName"] as? String)

        }
    }
}

//profile custom transition
//extension FeatureViewController: UIViewControllerTransitioningDelegate{
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
