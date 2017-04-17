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
    @IBOutlet weak var imageAddBtn: UIImageView!
    
    var posts = [PostObject]()
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posts = []

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate  = self
        
        //postavljam listener na POSTS u bazu podataka koji prati sve promene u ovom ogranku baze
        DataService.dataServiceSingleton.REF_POSTS.observe(FIRDataEventType.value, with: { (snapshot) in
            //print(snapshot.value!)
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
            cell.configureCell(post: post)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageAddBtn.image = image
        } else {
            print("VUČE: Nije odabrana slika preko imagePicker-a!")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func signOutTapped(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        //performSegue(withIdentifier: "goToSignIn", sender: nil)
        dismiss(animated: true, completion: nil)
    }


}
