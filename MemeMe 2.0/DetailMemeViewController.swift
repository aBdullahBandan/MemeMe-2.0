//
//  DetailMemeViewController.swift
//  MemeMe 2.0
//
//  Created by Abdullah Bandan on 21/01/1441 AH.
//  Copyright © 1441 AbdullahBandan. All rights reserved.
// 

import UIKit 

class DetailMemeViewController: UIViewController {
    
    var meme: Meme!
    @IBOutlet var memedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memedImageView.image = meme.memedImage
        memedImageView.contentMode = .scaleAspectFit
        
    }
}
