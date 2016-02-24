//
//  FeedVC.swift
//  social-network
//
//  Created by Killian Jackson on 2/16/16.
//  Copyright © 2016 Killian Jackson. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var imageSelected = false
    static var imageCache = NSCache()
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImg: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 354
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // .Value represents the event that any data changed in Firebase with respect to REF_POSTS path
    
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            self.posts = [] // clear out posts each time there is a change because we are going to completely update the data
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageURL == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImg.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let text = postField.text where text != "" {
            if let image = imageSelectorImg.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(image, 0.2)!
                let keyData = "KO5VHDLZb7c1e1a8d979e3a1f0bc3c46f23b6029".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                Alamofire.upload(.POST, url, multipartFormData: { MultipartFormData in
                    MultipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    MultipartFormData.appendBodyPart(data: keyData, name: "key")
                    MultipartFormData.appendBodyPart(data: keyJSON, name: "format")

                    }) { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON { response in
                                
                                if let info = response.result.value as? Dictionary<String,AnyObject> {
                                    
                                    if let links = info["links"] as? Dictionary<String,AnyObject> {
                                        
                                        if let imgLink = links["image_link"] as? String {
                                            
                                            print("LINK: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        case .Failure(let error):
                            print(error)
                        }
                }
            } else {
                // just a description, no image attached to post
                self.postToFirebase(nil)
            }

        }
    }
    
    func postToFirebase(imgURL: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0
        ]
        if imgURL != nil {
            post["imageURL"] = imgURL
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImg.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
}


















