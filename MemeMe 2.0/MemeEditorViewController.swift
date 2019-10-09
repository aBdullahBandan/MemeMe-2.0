//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Abdullah Bandan on 15/01/1441 AH.
//  Copyright © 1441 AbdullahBandan. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    

    @IBOutlet var imagePickerView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var topToolbar: UINavigationBar!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    var memedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preperTextField(textField: topTextField, text: "TOP")
        preperTextField(textField: bottomTextField, text: "BOTTOM")
        self.shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyBoardNotifications()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = pickedImage
        }
        if let _ = imagePickerView.image {
            self.shareButton.isEnabled = true
        } else {
            self.shareButton.isEnabled = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func pickAnImageFromAlbums(_ sender: Any) {
        albumsorCamera(isAlbums: true)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        albumsorCamera(isAlbums: false)
    }
    
    func albumsorCamera(isAlbums:Bool) {
        imagePicker.delegate = self
        if(isAlbums){
            imagePicker.sourceType = .photoLibrary
        }else{
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func preperTextField(textField: UITextField, text: String) {
        if text == "Cancel" {
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            return
        }
        let TextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -4.0
        ]
        textField.delegate = self
        textField.text = text
        textField.defaultTextAttributes = TextAttributes
        textField.textAlignment = .center
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = 0
        }
    }
    
    fileprivate func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    fileprivate func subscribeToKeyBoardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func unsubscribeToKeyBoardNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        self.dismiss(animated: true, completion: nil)

    }

    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        hideToolbars(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // TODO: Show toolbar and navbar
        hideToolbars(false)
        return memedImage
    }
    
    fileprivate func hideToolbars(_ hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
    }
    
    @IBAction func share() {
        memedImage = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        activity.popoverPresentationController?.sourceView = self.view
        activity.completionWithItemsHandler = {(activity, success, items, error) in
            if (success){
               self.save()
               return
            }
        }
    }
    
    @IBAction func cancel() {
        self.shareButton.isEnabled = false
        imagePickerView.image = nil
        memedImage = nil
        preperTextField(textField: topTextField, text: "Cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
}

