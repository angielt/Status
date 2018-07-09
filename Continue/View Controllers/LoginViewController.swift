//
//  LoginViewController.swift
//  Continue
//
//  Created by Angie Ta on 6/25/18.
//  Copyright © 2018 Angie Ta. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        guard emailField.text! != "", pwField.text! != ""
            else {
                    print("Please fill out both email and password fields")
                    return
                
            }
        Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let user = user {
                //let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabVC")
                
                self.present(vc, animated: true, completion: nil)
            }
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
