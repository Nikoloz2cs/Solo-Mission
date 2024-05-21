//
//  GameOverScene.swift
//  Solo Mission
//
//  Created by Nikoloz Gvelesiani on 5/16/24.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "Futura-MediumItalic")
    
    override func didMove(to view: SKView) {
            
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameoverLabel = SKLabelNode(fontNamed: "Futura-MediumItalic")
        gameoverLabel.text = "Game Over"
        gameoverLabel.fontSize = 155
        gameoverLabel.fontColor = SKColor.white
        gameoverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameoverLabel.zPosition = 1
        self.addChild(gameoverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "f")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highscoreNumber = defaults.integer(forKey: "highscoreSaved")
        
        if gameScore > highscoreNumber {
            highscoreNumber = gameScore
            defaults.set(highscoreNumber, forKey: "highscoreSaved")
            
            let newHighScoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
            newHighScoreLabel.text = "*NEW*"
            newHighScoreLabel.fontSize = 50
            newHighScoreLabel.fontColor = SKColor.red
            newHighScoreLabel.position = CGPoint(x: self.size.width * 0.27,  y: self.size.height * 0.493)
            newHighScoreLabel.zRotation = CGFloat.pi / 8
            newHighScoreLabel.zPosition = 3
            self.addChild(newHighScoreLabel)
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.7)
            let scaleDown = SKAction.scale(to: 1, duration: 0.7)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let bounceEffect = SKAction.repeatForever(scaleSequence)
            
            newHighScoreLabel.run(bounceEffect)
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "Futura-MediumItalic")
        highScoreLabel.text = "High Score: \(highscoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.width * 0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch) {
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
            
        }
    }
    
}
