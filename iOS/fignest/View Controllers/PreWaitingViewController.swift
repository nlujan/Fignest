//
//  PreWaitingViewController.swift
//  fignest
//
//  Created by Naim on 3/13/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import SwiftyJSON

class PreWaitingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    var users: JSON = []
    var eventData: Event!
    
    @IBOutlet var waitingTable: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Actions
    
    @IBAction func preWaitingShowOptions(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        //only put in for testing
        
        let gotoGameAction = UIAlertAction(title: "Start Game", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.performSegueWithIdentifier("showGameView", sender: nil)
        })
        
        
        let logoutAction = UIAlertAction(title: "Exit Fig", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("User Exited to Home Page")
            
            NavigationUtil().takeUserToHomePage(self.storyboard)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(gotoGameAction)
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        optionMenu.view.tintColor = StyleUtil().primaryColor
    }
    
    //MARK: Functions
    
    func joinRoom(userId: String, eventId: String) {
        SocketIOManager.sharedInstance.joinRoom(userId, eventId: eventData.id)
    }
    
    func setupStatusListener() {
        SocketIOManager.sharedInstance.setupStatusListener() { userList in
            dispatch_async(dispatch_get_main_queue(), {
                print("Status update received")
                self.users = userList
                self.waitingTable.reloadData()
            })
        }
    }
    
    func setupStartListener() {
        SocketIOManager.sharedInstance.setupStartListener() {
            dispatch_async(dispatch_get_main_queue(), {
                print("done!")
                self.performSegueWithIdentifier("showGameView", sender: nil)
            })
        }
    }
    
    
    //MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PreWaitingCell", forIndexPath: indexPath) as! PreWaitingCell
        
        let userInfo = users[indexPath.row]
        let URL = NSURL(string: ImageUtil().getFBImageURL(userInfo["facebook"]["id"].stringValue))!
        
        cell.playerImage.af_setImageWithURL(URL)
        
        cell.nameLabel.text = userInfo["displayName"].stringValue
        
        if userInfo["status"].stringValue == "ready" {
            cell.statusView.backgroundColor = UIColor.greenColor()
        }
        
        return cell
    }
    
    //MARK: Override View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = eventData.name.uppercaseString
        
        activityIndicator.startAnimating()
        
        let userId = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
        
        setupStatusListener()
        setupStartListener()
        joinRoom(userId, eventId: eventData.id)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if (segue.identifier == "showGameView") {
            let gameController = segue.destinationViewController as! GameViewController
            
            gameController.eventData = self.eventData
        }
        
        
    }


}
