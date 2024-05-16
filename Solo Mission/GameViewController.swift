//
//  GameViewController.swift
//  Solo Mission
//
//  Created by Nikoloz Gvelesiani on 5/14/24.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation //for audio

class GameViewController: UIViewController {

    var backingAudio = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "the-art-of-synths(space song3)", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL) }
        catch { return print("Cannot Find The Background Audio") }
        
        backingAudio.numberOfLoops = -1
        backingAudio.play()
        
        if let view = self.view as! SKView? {
             // Load the SKScene from 'GameScene.sks'
             let scene = MainMenuScene(size: CGSize(width: 1535, height: 2048))
             // Set the scale mode to scale to fit the window
             scene.scaleMode = .aspectFill
             
             // Present the scene
             view.presentScene(scene)
             
             
             view.ignoresSiblingOrder = true
             
             view.showsFPS = false
             view.showsNodeCount = false
         }
     }


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

