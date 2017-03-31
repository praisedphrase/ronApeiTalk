//
//  ViewController.swift
//  ronapei talk
//
//  Created by  theronapei on 2017. 3. 30..
//  Copyright © 2017년  theronapei. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    
    var ref: FIRDatabaseReference!
    var messages: [FIRDataSnapshot]! = []
    var _refHandle: FIRDatabaseHandle?

    @IBAction func sendButtonPressed(_ sender: Any) {
        var mdata = [String: String]()
        mdata["text"] = chatTextView.text
        
        // Push data to Firebase Database
        self.ref.child("messages").childByAutoId().setValue(mdata)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        configureDatabase()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.chatTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Unpack message from Firebase DataSnapshot
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        guard let message = messageSnapshot.value as? [String:String] else { return cell }
        let text = message["text"] ?? "[text]"
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    deinit {
        if let refHandle = _refHandle {
            self.ref.child("messages").removeObserver(withHandle: refHandle)
        }
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("messages").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.messages.append(snapshot)
            strongSelf.chatTableView.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
        })
    }
}

