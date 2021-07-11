//
//  ViewController.swift
//  InstantMessenger
//
//  Created by Shilpa Joy on 2021-07-09.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController,GIDSignInDelegate {
    
    @IBOutlet weak var googleSignIn: UIButton!
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    var loadingView: UIView = UIView()
    @IBOutlet weak var userNameTxt: UITextField!{
        didSet {
            userNameTxt.setIcon(UIImage(imageLiteralResourceName: "emailicon"))
        }
    }
    @IBOutlet weak var passwordTxtField: UITextField!{
        didSet{
            passwordTxtField.setIcon(UIImage(imageLiteralResourceName: "passwordicon"))
        }
    }
    
    @IBAction func signInBtnTapped(_ sender: Any) {
    }
    @IBAction func googleSignInTapped(_ sender: Any) {
       
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidLoad() {
    
        navigationController?.navigationBar.barTintColor = UIColor.systemIndigo
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        super.viewDidLoad()
       
    }
 
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
        print(error.localizedDescription)
        return
        }
        guard let auth = user.authentication else { return }
        showActivityIndicator()
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { [self] (authResult, error) in
        if let error = error {
        print(error.localizedDescription)
        } else {
            self.hideActivityIndicator()
            self.performSegue(withIdentifier: "chat", sender: self)            
            
        }
    }
    
    }
    func showActivityIndicator() {
        
        DispatchQueue.main.async {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
        self.loadingView.backgroundColor = UIColor.systemIndigo
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10

        self.spinner = UIActivityIndicatorView(style: .whiteLarge)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)

            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
   
}
extension UITextField {
func setIcon(_ image: UIImage) {
   let iconView = UIImageView(frame:
                  CGRect(x: 10, y: 5, width: 20, height: 20))
   iconView.image = image
   let iconContainerView: UIView = UIView(frame:
                  CGRect(x: 20, y: 0, width: 30, height: 30))
   iconContainerView.addSubview(iconView)
   leftView = iconContainerView
   leftViewMode = .always
}
}



