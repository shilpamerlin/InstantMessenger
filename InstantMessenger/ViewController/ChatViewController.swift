//
//  ChatVC.swift
//  InstantMessenger
//
//  Created by Shilpa Joy on 2021-07-11.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import SDWebImage

class ChatViewController: MessagesViewController,InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

    var currentUser: User = Auth.auth().currentUser!
    private var docReference: DocumentReference?
    var messages: [Message] = []
    var selectedObject: Chat?
    var user2Name: String?
    var user2ImgUrl: String?
    var user2UID: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        user2Name = selectedObject?.displayName.joined(separator: ", ")
        user2UID = selectedObject?.users.joined(separator: ", ")
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
        imageview.layer.borderWidth = 1
        imageview.layer.masksToBounds = false
        imageview.layer.cornerRadius = imageview.frame.height/2
        imageview.clipsToBounds = true
        containView.addSubview(imageview)
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        // Display profile image in navigationbar
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
        self.title = user2Name ?? "Chat"
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        loadChat()
       
    }
    func loadChat() {
        let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            else {
                    guard let queryCount = chatQuerySnap?.documents.count else {
                        return
                    }
                if queryCount == 0 {
                    self.createNewChat()
                }
                else if queryCount >= 1 {
                    for doc in chatQuerySnap!.documents {
                        let chat = Chat(dictionary: doc.data()) //Get the chat which has user2 id
                        if (chat?.users.contains(self.user2UID ?? "ID Not Found")) == true {
                            self.docReference = doc.reference
                            //fetch it's thread collection
                            doc.reference.collection("thread")
                            .order(by: "created", descending: false)
                            .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                        else {
                            self.messages.removeAll()
                            for message in threadQuery!.documents {
                                let msg = Message(dictionary: message.data())
                                self.messages.append(msg!)
                                print("Data: \(msg?.content ?? "No message found")")
                            }
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                            })
                            return
                        }
                    }
                    self.createNewChat()
                } else {
                        print("Let's hope this error never prints!")
                    }
            }
        }
    }
    
    func createNewChat() {
        let users = [self.currentUser.uid, self.user2UID]
        let data: [String: Any] = [
            "users":users
            ]
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    private func save(_ message: Message) {
        
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName
        ]
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            else {
                print("success")
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        })

    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: currentUser.displayName!)
        insertNewMessage(message)
        save(message)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func currentSender() -> SenderType {
        return ChatUser(senderId: Auth.auth().currentUser!.uid, displayName: (Auth.auth().currentUser?.displayName)!)
    }
   
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }

    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
   
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue: .lightGray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
   
        if message.sender.senderId == currentUser.uid {
        SDWebImageManager.shared.loadImage(with: currentUser.photoURL, options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
            avatarView.image = image
        }
        } else {
            SDWebImageManager.shared.loadImage(with: URL(string: user2ImgUrl!), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                avatarView.image = image
            }
        }
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }

}
