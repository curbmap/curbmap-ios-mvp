//
//  ViewController.swift
//  curbmap
//
//  Created by Eli Selkin on 3/23/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var activeTextField: UITextField?
    
    let defaultCenter = NotificationCenter.default
    let UIKeyboardFrameEndUserInfoKey = "UIKeyboardFrameEndUserInfoKey"

    
    // MARK: - View Configs
    override func viewDidLoad() {
        // Add observer for keyboard notification
        registerForKeyboardNotifications()
        
        AuthServices.authServicesBroker.login { [weak self] result in
            switch result {
            case AuthServices.Constants.success:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "login"), object: nil)
                self?.performSegue(withIdentifier: "show_camera", sender: nil)
            case AuthServices.Constants.failedFind:
                self?.showAlert(result: AuthServices.Constants.failedFind)
            case AuthServices.Constants.failedAuthorized :
                self?.showAlert(result: AuthServices.Constants.failedAuthorized)
            default:
                break
            }
        }
        
        // TODO: Fix autolayout so textfield is properly shown.  Currently it's hiding 
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // disable scrolling
        scrollView.isScrollEnabled = false
    }
    
    private func showAlert(result: Int) {
        // TODO:  Create alert view controller displaying login error
    }
    
    // MARK: - Keyboards
    func registerForKeyboardNotifications() {
        // Listens for when keyboard shows itself and when hiding
        defaultCenter.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.addObserver(self, selector: #selector(keyboardWasHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        // Enable scrolling
        scrollView.isScrollEnabled = true
        
        // obtain size of keyboard
        if let info = notification.userInfo, let keyboardInfo = info[UIKeyboardFrameEndUserInfoKey] {
            var keyboardFrame: CGRect = (keyboardInfo as! NSValue).cgRectValue
           let keyboardHeight = keyboardFrame.size.height
            // move contentView frame up by keyboard size
            contentView.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWasHidden(notification: NSNotification) {
        // move contentView frame to its origin
        contentView.frame.origin.y = 0.0
    }
    
    // MARK: - TextField Delegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // track textfield and resign first resopnder status
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when user hit return button
        textField.resignFirstResponder()
        return true
        // TODO: To implement logic so keyboard can be dismissed just by tapping on the view, instead of hitting "done" button.
    }
    
    
    // MARK: - User Action
    @IBAction func loginButtonDidPressed(_ sender: UIButton) {
        // TODO: call login service and login user
        
    }
    
    
    
    
    

}

