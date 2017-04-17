//
//  PostCell.swift
//  instagramFirebase
//
//  Created by Vuk on 4/17/17.
//  Copyright © 2017 Vuk. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var post: PostObject! //ovo mi treba uvek

    func configureCell(post: PostObject) {
        
        self.post = post
        
        self.caption.text = post.caption
        self.likesLabel.text = String(post.likes)
        //self.postImage.image = UIImage(data: try! Data(contentsOf: URL(string: post.imageUrl)!))
    
    }

}
