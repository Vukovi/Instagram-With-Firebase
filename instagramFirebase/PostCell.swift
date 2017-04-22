//
//  PostCell.swift
//  instagramFirebase
//
//  Created by Vuk on 4/17/17.
//  Copyright © 2017 Vuk. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImg: UIImageView!
    
    var post: PostObject! //ovo mi treba uvek
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        self.likesImg.addGestureRecognizer(tap)
        self.likesImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: PostObject, img: UIImage?) {
        
        self.post = post
        self.likesRef = DataService.dataServiceSingleton.REF_USER_CURRENT.child("likes").child(post.postKey) //da bi se like odnosio samo na jedan posta a ne da bude prosledjen na sve postove
        
        self.caption.text = post.caption
        self.likesLabel.text = String(post.likes)
        
        //self.postImage.image = UIImage(data: try! Data(contentsOf: URL(string: post.imageUrl)!))
        if img != nil {
            self.postImage.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("VUČE: Ne moze da se povuce slika iz Firebase Storega")
                } else {
                    print("VUČE: Slika je povucena iz Firebase Storega")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.postImage.image = image
                            FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    func likeTapped() {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }

}
