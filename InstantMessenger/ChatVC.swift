//
//  ChatVC.swift
//  InstantMessenger
//
//  Created by Shilpa Joy on 2021-07-11.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class ChatVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        

      // imageview.image = UIImage(named: "sp")
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
                       // imageview.layer.cornerRadius = 20
                        //imageview.layer.masksToBounds = true
        imageview.layer.borderWidth = 1
        imageview.layer.masksToBounds = false
        //imageview.layer.borderColor = UIColor.black.cgColor
        imageview.layer.cornerRadius = imageview.frame.height/2//This will change with corners of image and height/2 will make this circle shape
        imageview.clipsToBounds = true
                        containView.addSubview(imageview)
                        let rightBarButton = UIBarButtonItem(customView: containView)
                        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let currentUser = Auth.auth().currentUser
        let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
        let fullName = user.profile.name
        let email = user.profile.email
        if user.profile.hasImage {
        let userDP = user.profile.imageURL(withDimension: 200)
            print(userDP)
            if let data = try? Data(contentsOf: userDP!) {
                if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    imageview.image = image
                                }
                            }
                        }
            
        } else {
            imageview.image = UIImage(named: "default-user")
        }
       
                        
       
        print(currentUser?.displayName)
        print(currentUser?.email)

        // Do any additional setup after loading the view.
    }
    
    
}
