//
//  ComposeCommentViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/21/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class ComposeCommentViewController: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var placeHolderTextLabel: UILabel!
    
    
    
    @IBAction func cancelComposeComment(sender: UIBarButtonItem) {
        dismissComposeCommentViewController()
    }
    
    var post: Post? //the post to which this comment replies
    
    weak var respondingPostCell: PostTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.alwaysBounceVertical = true
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
        self.commentTextView.delegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyBoardWillHide), name: UIKeyboardWillHideNotification, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissComposeCommentViewController(){
        view.endEditing(true)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    func keyboardDidShow(notification: NSNotification){
        if let keyboardFrame = notification.keyboardEndFrame{
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height + 10, right: 0)
        }
    }
    
    func keyBoardWillHide(notification: NSNotification){
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}

extension ComposeCommentViewController: UITextViewDelegate{
    func textViewDidChange(textView: UITextView) {
        placeHolderTextLabel.hidden = !textView.text.isEmpty
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.title = "Posting..."
            textView.resignFirstResponder()
            //add comment to post
            getLoggedInUser()?.commentPost(textView.text, post: post!, completionHandler: {
                (comment) in
                if comment != nil && self.respondingPostCell != nil{
                    let countString = self.post!.postComments!.count == 0 ? "" : String(self.post!.postComments!.count)
                    self.respondingPostCell?.postCommentCountLabel.text = countString
                    self.dismissComposeCommentViewController()
                }
            })
            return false
        }
        return true
    }
}
