//
//  SignupViewController.swift
//  Continue
//
//  Created by Angie Ta on 6/22/18.
//  Copyright © 2018 Angie Ta. All rights reserved.
//

// handle security with database

import UIKit
import Firebase

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPWField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage:StorageReference! // stores user uploads
    var database:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        database = Database.database().reference()
        
        let storage = Storage.storage().reference(forURL: "gs://foodmates-f682c.appspot.com")
        
        userStorage = storage.child("users") // creates a folder in storage firebase
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // establishes UIImagePicker
    @IBAction func selectImagePressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }
    
    // called when profile image is chosen from selectImagePressed
    // image information in info var
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image // show pic
            nextButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil) // dismiss imagePicker
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confirmPWField.text != ""
            else {
                // insert message for user to enter all the fields
                print("Please enter all fields")
                return
            }
        if passwordField.text == confirmPWField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                
                if let error = error {
                    // print error
                    print(error.localizedDescription)
                }
                if let user = user { // successfully created user
                    
                    let changeReq = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeReq.displayName = self.nameField.text!
                    changeReq.commitChanges(completion: nil)
                    
                    // reference to put image in the db
                    let imgRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imgRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imgRef.downloadURL(completion: { (url, er) in
                            
                            if er != nil{
                                print(er!.localizedDescription)
                            }
                            
                            if let url = url {
                                let userInfo: [String:Any] = ["uid": user.uid,
                                                              "full name": self.nameField.text!,
                                                              "urlToImg": url.absoluteString]
                                
                                // puts userInfo into db folder for specific uid
                                self.database.child("users").child(user.uid).setValue(userInfo)
                                
                                //let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabVC")
                                
                                self.present(vc, animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                    })
                    
                    uploadTask.resume()
                    
                }
                
            })
        }
        else{
            print("Password does not match")
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
