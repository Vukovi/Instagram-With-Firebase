//
//  FeedVC.swift
//  instagramFirebase
//
//  Created by Vuk on 4/16/17.
//  Copyright © 2017 Vuk. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UIImagePickerControllerDelegate, UINavigationControllerDelegate --- ova dva su mi za dodavanje slika koje su slikane telefonom, prvi da se omoguci ta f-ja a drugi da se taj kontroler skloni po zavrsetku posla
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutBtn: UIImageView!
    @IBOutlet weak var addStoryField: FancyField!
    @IBOutlet weak var imageAddBtn: UIImageView!
    
    var posts = [PostObject]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString,UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate  = self
        
        //postavljam listener na POSTS u bazu podataka koji prati sve promene u ovom ogranku baze
        DataService.dataServiceSingleton.REF_POSTS.observe(FIRDataEventType.value, with: { (snapshot) in
            //print(snapshot.value!)
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = PostObject(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PostCell {
            let post = posts[indexPath.row]
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                //return cell
            } else {
                cell.configureCell(post: post, img: nil)
                //return cell
            }
            return cell
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageAddBtn.image = image
            self.imageSelected = true
        } else {
            print("VUČE: Nije odabrana slika preko imagePicker-a!")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let caption = addStoryField.text, caption != "" else {
            print("Vuče: Post nije upisan!")
            return
        }
        guard let img = imageAddBtn.image, imageSelected == true else {
            print("Vuče: Slika za post mora biti odabrana")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imageUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            DataService.dataServiceSingleton.REF_STORAGE_POST_IMAGES.child(imageUid).put(imgData, metadata: metaData, completion: { (metadata, error) in
                if error != nil {
                    print("VUČE: Ne mogu da uploadujem sliku na Storage")
                } else {
                    print("VUČE: Uspesno uploadovana slika na Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    self.postToFirebase(imageUrl: downloadUrl!)
                }
            })
        }
    }
    
    func postToFirebase(imageUrl: String) {
        let post: Dictionary<String, AnyObject> = ["caption": addStoryField.text as AnyObject,
                                                   "imageUrl": imageUrl as AnyObject,
                                                   "likes": 0 as AnyObject
                                                ]
        
        let firebasePost = DataService.dataServiceSingleton.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        self.addStoryField.text = ""
        self.imageSelected = false
        self.imageAddBtn.image = UIImage(named: "add-image")
        
        self.tableView.reloadData()
    }

    @IBAction func signOutTapped(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        //performSegue(withIdentifier: "goToSignIn", sender: nil)
        dismiss(animated: true, completion: nil)
    }


}
