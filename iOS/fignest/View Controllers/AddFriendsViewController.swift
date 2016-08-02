//
//  NWSTokenViewExampleViewController.swift
//  NWSTokenView
//
//  Created by James Hickman on 8/11/15.
//  Copyright (c) 2015 NitWit Studios. All rights reserved.
//

import UIKit
import NWSTokenView
import DZNEmptyDataSet

class AddFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NWSTokenDataSource, NWSTokenDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var tokenView: NWSTokenView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tokenViewHeightConstraint: NSLayoutConstraint!
    
    let tokenViewMinHeight: CGFloat = 40.0
    let tokenViewMaxHeight: CGFloat = 150.0
    let tokenBackgroundColor = UIColor(red: 98.0/255.0, green: 203.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    var names = []
    var isSearching = false
    var contacts = [NWSTokenContact]()
    var selectedContacts = [NWSTokenContact]()
    var filteredContacts = [NWSTokenContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjust tableView offset for keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFriendsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFriendsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        if contacts.count == 0 {
            // Create list of contacts to test
            var unsortedContacts: [NWSTokenContact] = [
            ]
            
            for name in names {
                unsortedContacts.append(NWSTokenContact(name: name as! String, andImage: UIImage(named: "person")!))
            }
            
            contacts = NWSTokenContact.sortedContacts(unsortedContacts)
        }
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        // TableView
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = .SingleLine
        
        // TokenView
        tokenView.dataSource = self
        tokenView.delegate = self
        tokenView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        if let view = touch.view
        {
            if view.isDescendantOfView(tableView)
            {
                return false
            }
        }
        return true
    }
    
    // MARK: Keyboard
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets

        }        
    }
    
    func keyboardWillHide(notification: NSNotificationCenter)
    {
        tableView.contentInset = UIEdgeInsetsZero
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    @IBAction func didTapView(sender: UITapGestureRecognizer)
    {
        dismissKeyboard()
    }
    
    func dismissKeyboard()
    {
        tokenView.resignFirstResponder()
        tokenView.endEditing(true)
    }
    
    // MARK: Search Contacts
    func searchContacts(text: String)
    {
        // Reset filtered contacts
        filteredContacts = []
        
        // Filter contacts
        if contacts.count > 0
        {
            filteredContacts = contacts.filter({ (contact: NWSTokenContact) -> Bool in
                return contact.name.rangeOfString(text, options: .CaseInsensitiveSearch) != nil
            })
            
            self.isSearching = true
            self.tableView.reloadData()
        }
    }
    
    func didTypeEmailInTokenView()
    {
        let email = self.tokenView.textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let contact = NWSTokenContact(name: email, andImage: UIImage(named: "TokenPlaceholder")!)
        self.selectedContacts.append(contact)
        
        self.tokenView.textView.text = ""
        self.isSearching = false
        self.tokenView.reloadData()
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isSearching
        {
            return filteredContacts.count
        }
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("NWSTokenViewExampleCellIdentifier", forIndexPath: indexPath) as! NWSTokenViewExampleCell
        
        let currentContacts: [NWSTokenContact]!
        
        // Check if searching
        if isSearching {
            currentContacts = filteredContacts
        } else {
            currentContacts = contacts
        }
        
        // Load contact data
        let contact = currentContacts[indexPath.row]
        cell.loadWithContact(contact)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NWSTokenViewExampleCell
        cell.selected = false
        
        // Check if already selected
        if !selectedContacts.contains(cell.contact) {
            cell.contact.isSelected = true
            selectedContacts.append(cell.contact)
            isSearching = false
            tokenView.textView.text = ""
            tokenView.reloadData()
            tableView.reloadData()
        }
    }
    
    // MARK: DZNEmptyDataSetSource
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        
        if let view = UINib(nibName: "EmptyDataSet", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? UIView {
            view.frame = scrollView.bounds
            view.translatesAutoresizingMaskIntoConstraints = false
            view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            return view
        }
        return nil
    }
    
    
    // MARK: NWSTokenDataSource
    func numberOfTokensForTokenView(tokenView: NWSTokenView) -> Int {
        return selectedContacts.count
    }
    
    func insetsForTokenView(tokenView: NWSTokenView) -> UIEdgeInsets? {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func titleForTokenViewLabel(tokenView: NWSTokenView) -> String? {
        return ""
    }
    
    func titleForTokenViewPlaceholder(tokenView: NWSTokenView) -> String? {
        return "Search friends..."
    }
    
    func tokenView(tokenView: NWSTokenView, viewForTokenAtIndex index: Int) -> UIView? {
        let contact = selectedContacts[Int(index)]
        if let token = NWSImageToken.initWithTitle(contact.name, image: contact.image) {
            return token
        }
        return nil
    }
    
    // MARK: NWSTokenDelegate
    func tokenView(tokenView: NWSTokenView, didSelectTokenAtIndex index: Int) {
        let token = tokenView.tokenForIndex(index) as! NWSImageToken
        token.backgroundColor = UIColor.blueColor()
    }
    
    func tokenView(tokenView: NWSTokenView, didDeselectTokenAtIndex index: Int) {
        let token = tokenView.tokenForIndex(index) as! NWSImageToken
        token.backgroundColor = tokenBackgroundColor
    }
    
    func tokenView(tokenView: NWSTokenView, didDeleteTokenAtIndex index: Int) {
        // Ensure index is within bounds
        if index < self.selectedContacts.count {
            let contact = self.selectedContacts[Int(index)] as NWSTokenContact
            contact.isSelected = false
            self.selectedContacts.removeAtIndex(Int(index))
            
            tokenView.reloadData()
            tableView.reloadData()
            tokenView.layoutIfNeeded()
            tokenView.textView.becomeFirstResponder()
            
            // Check if search text exists, if so, reload table (i.e. user deleted a selected token by pressing an alphanumeric key)
            if tokenView.textView.text != "" {
                self.searchContacts(tokenView.textView.text)
            }
        }
    }
    
    func tokenView(tokenViewDidBeginEditing: NWSTokenView) {
        // Check if entering search field and it already contains text (ignore token selections)
        if tokenView.textView.isFirstResponder() && tokenView.textView.text != "" {
            //self.searchContacts(tokenView.textView.text)
            print("editing and not empty")
        }
    }
    
    func tokenViewDidEndEditing(tokenView: NWSTokenView) {
        if tokenView.textView.text.isEmail() {
            didTypeEmailInTokenView()
        }
        
        isSearching = false
        tableView.reloadData()
    }
    
    func tokenView(tokenView: NWSTokenView, didChangeText text: String) {
        // Check if empty (deleting text)
        if text == "" {
            isSearching = false
            tableView.reloadData()
            return
        }
        
        // Check if typed an email and hit space
        let lastChar = text[text.endIndex.predecessor()]
        if lastChar == " " && text.substringWithRange(text.startIndex..<text.endIndex.predecessor()).isEmail() {
            self.didTypeEmailInTokenView()
            return
        }
        
        self.searchContacts(text)
    }
    
    func tokenView(tokenView: NWSTokenView, didEnterText text: String) {
        if text == "" {
            return
        }
        
        if text.isEmail() {
            self.didTypeEmailInTokenView()
        } else {
        }
    }
    
    func tokenView(tokenView: NWSTokenView, contentSizeChanged size: CGSize) {
        self.tokenViewHeightConstraint.constant = max(tokenViewMinHeight,min(size.height, self.tokenViewMaxHeight))
        self.view.layoutIfNeeded()
    }
    
    func tokenView(tokenView: NWSTokenView, didFinishLoadingTokens tokenCount: Int) {
    }

}

class NWSTokenContact: NSObject {
    var image: UIImage!
    var name: String!
    var isSelected = false
    
    init(name: String, andImage image: UIImage) {
        self.name = name
        self.image = image
    }
    
    class func sortedContacts(contacts: [NWSTokenContact]) -> [NWSTokenContact] {
        return contacts.sort({ (first, second) -> Bool in
            return first.name < second.name
        })
    }
}

class NWSTokenViewExampleCell: UITableViewCell {
    @IBOutlet weak var userTitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
   
    var contact: NWSTokenContact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round corners
        userImageView.layer.cornerRadius = 5.0
        userImageView.clipsToBounds = true
        
        checkmarkImageView.image = UIImage(named: "ic_done_black")
    }
    
    func loadWithContact(contact: NWSTokenContact) {
        self.contact = contact
        userTitleLabel.text = contact.name
        userImageView.image = contact.image
        
        // Show/Hide Checkmark
        if contact.isSelected {
            checkmarkImageView.hidden = false
        } else {
            checkmarkImageView.hidden = true
        }
    }
}

extension String {
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

