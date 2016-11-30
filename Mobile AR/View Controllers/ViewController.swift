//
//  ViewController.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2016-11-27.
//  Copyright © 2016 Jean-Pierre Digital. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
   }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFilesSegue" {
            let destinationViewController = segue.destinationViewController as! FileListViewController

            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory = paths[0]
            let directoryURL = NSURL(fileURLWithPath: documentsDirectory, isDirectory: true)

            destinationViewController.initialPath = directoryURL
        }
    }

    @IBAction func didPressShowFilesButton(sender: UIButton) {
        performSegueWithIdentifier("showFilesSegue", sender: sender)
    }
}
