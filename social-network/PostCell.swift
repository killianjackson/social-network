//
//  PostCell.swift
//  social-network
//
//  Created by Killian Jackson on 2/16/16.
//  Copyright © 2016 Killian Jackson. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!

    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        postImage.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        if post.imageURL != nil {
            if img != nil {
                self.postImage.image = img
            } else {
                
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.postImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                    } else {
                        print(err.debugDescription)
                    }
                })
                
                
            }
        } else {
            self.postImage.hidden = true
        }
        
        // checking to see if the like exists for the given post. Used to determine whether to show the filled in heart or not
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no data in .value then you will get an NSNull
            if let _ = snapshot.value as? NSNull {
                // This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no data in .value then you will get an NSNull
            if let _ = snapshot.value as? NSNull {
                // This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                
                // if the post is not attributed to the current user when this is called it will add the post id to the 
                // likes of the user and set it to true.
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue() // deletes the entire key for this post in firebase
            }
        })

    }

}
