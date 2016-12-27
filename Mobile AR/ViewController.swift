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

    let fileBrowser = FileBrowser()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressShowFilesButton(sender: UIButton) {
        presentViewController(fileBrowser, animated: true, completion: nil)
    }
}