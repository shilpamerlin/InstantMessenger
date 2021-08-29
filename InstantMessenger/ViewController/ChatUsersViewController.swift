//
//  DisplayChatUsers.swift
//  InstantMessenger
//
//  Created by Shilpa Joy on 2021-07-14.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import MessageKit
import FirebaseFirestore

class ChatUsersViewController : UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var currentUserLbl: UILabel!
    @IBOutlet weak var tablUsers: UITableView!
    var userArray: [Chat] = []
    var currentUserName : String?
    var selectedIndex : Chat?
    
    override func viewDidLoad() {
        
        let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
        currentUserName = user.profile.name
        currentUserLbl.text = currentUserName
        tablUsers.delegate = self
        tablUsers.dataSource = self
        super.viewDidLoad()
        self.getChatUsers { data in
            self.userArray = data
            DispatchQueue.main.async {
            self.tablUsers.reloadData()
           }
        }
    }
    func getChatUsers(closures : @escaping ([Chat])->()){
                let db = Firestore.firestore().collection("Chats").whereField("display name", notIn: [self.userArray])
                db.getDocuments { [self] querySnapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        var chat : Chat?
                        for document in querySnapshot!.documents {
                             chat = Chat(dictionary: document.data())
                             userArray.append(chat!)
                        }
                            for (index, element) in userArray.enumerated() {
                                if element.displayName.joined(separator: ", ") == currentUserName {
                                userArray.remove(at: index)
                                }
                            }
                        print("Original chat users list\(userArray)")
                        closures(userArray)
                    }
                }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",for:indexPath)
        let user = userArray[indexPath.row]
        cell.textLabel?.text = user.displayName.joined(separator: ", ")
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "chatUser"
        {
            let controller = segue.destination as! ChatViewController
            controller.selectedObject = selectedIndex
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        selectedIndex = userArray[row]
        self.performSegue(withIdentifier: "chatUser", sender: self)
    }
}
