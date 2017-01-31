//
//  ViewController.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2016-11-27.
//  Copyright © 2016 Jean-Pierre Digital. All rights reserved.
//

import UIKit
import FileBrowser

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mobile AR"
   }

    @IBAction func didPressShowFilesButton(sender: UIButton) {
        presentViewController(FileBrowser(), animated: true, completion: nil)
    }
}
