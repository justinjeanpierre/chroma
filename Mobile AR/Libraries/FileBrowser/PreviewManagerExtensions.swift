//
//  PreviewManagerExtensions.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2016-11-30.
//  Copyright © 2016 Jean-Pierre Digital. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension PreviewManager {
    func previewViewControllerForVideoFile(file: FBFile, fromNavigation: Bool) -> UIViewController {
        // (maybe guard file type?)
        let playerItem = AVPlayerItem(URL: file.filePath)
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()

        playerViewController.player = player

        return playerViewController
    }
}
