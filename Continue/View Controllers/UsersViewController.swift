//
//  UsersViewController.swift
//  Continue
//
//  Created by Angie Ta on 6/26/18.
//  Copyright © 2018 Angie Ta. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()

        // Do any additional setup after loading the view.
        
        // connects UITableViewDelegate and UITableViewDataSource to this class
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func getUsers() {
        print("GET USERS")
        
        let db = Database.database().reference()
        let currUid = Auth.auth().currentUser!.uid
    
        
        db.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            let users = snapshot.value as! [String: AnyObject]
            self.user.removeAll() // remove preexisiting
            
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != currUid { // if user in db not current user
                        let userShow = User()                // check if all fields exist -> no crash
                        if let fullName = value["full name"] as? String,
                            let imgURL = value["urlToImg"] as? String{
                                userShow.fullName = fullName
                                userShow.userID = uid
                                userShow.imgURL = imgURL
                                self.user.append(userShow)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
        db.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        // show image, name etc
        cell.nameLabel.text = self.user[indexPath.row].fullName
        cell.userID = self.user[indexPath.row].userID
        cell.userImg.downloadImage(from: self.user[indexPath.row].imgURL)
        checkIfFollowing(indexPath: indexPath)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database().reference()
        let key = db.child("users").childByAutoId().key
        
        var isFollower = false
        
        db.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            if let following = snapshot.value as? [String:AnyObject] { // unfollow selected user
                for(k, val) in following { // val is user we are following
                    if val as! String == self.user[indexPath.row].userID {
                        isFollower = true               // current user following selected user
                        
                        db.child("users").child(uid).child("following/\(k)").removeValue()
                        db.child("users").child(self.user[indexPath.row].userID).child("followers/\(k)").removeValue()
                    
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                        
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)": self.user[indexPath.row].userID ]
                let followers = ["followers/\(key)": uid]
                
                db.child("users").child(uid).updateChildValues(following)
                db.child("users").child(self.user[indexPath.row].userID).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                
            }
        }
        db.removeAllObservers()
    }
    
    func checkIfFollowing(indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database().reference()
     
        db.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            if let following = snapshot.value as? [String:AnyObject] { // unfollow selected user
                for(k, val) in following {
                    if val as! String == self.user[indexPath.row].userID {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                    
                }
            }
        }
        db.removeAllObservers()
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
    }
    

}

extension UIImageView{
    
    func downloadImage(from imgURL: String!){
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("error with download image")
                print(error!)
                return
            }
            
            DispatchQueue.main.async { // image will go into the UIImageView that called the function
                self.image = UIImage(data: data!)
            }
            
        }
        task.resume()
    }
    
}



