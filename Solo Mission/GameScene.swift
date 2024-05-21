//
//  GameScene.swift
//  Solo Mission
//
//  Created by Nikoloz Gvelesiani on 5/14/24.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    var livesNumber = 3
    var heartNodes: [SKSpriteNode] = []
    //let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound = SKAction.playSoundFileNamed("laserBulletSoundEffect", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosionSoundEffect", waitForCompletion: false)
    var bulletSparkSound = SKAction.playSoundFileNamed("bulletSparkSoundEffect", waitForCompletion: false)
        
    let tapToStartLabel = SKLabelNode(fontNamed: "the Bold Font")

    
    enum gameState {
        case preGame //game state before the game starts
        case inGame //game state during the game
        case postGame //game state after the game ends
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories {
        static let None : UInt32 = 0       //0
        static let Player : UInt32 = 0b1   //1
        static let Bullet : UInt32 = 0b10  //2
        static let Enemy : UInt32 = 0b100  //4
        static let Asteroid: UInt32 = 0b1000 // 8
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
    
    func createHearts() {
        // Remove any existing heart nodes
        for heart in heartNodes {
            heart.removeFromParent()
        }
        heartNodes.removeAll()
        
        // Create new heart nodes
        for i in 0..<livesNumber {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.setScale(0.7)
            heart.position = CGPoint(x: self.size.width * 0.7 + CGFloat(i * 40), y: self.size.height * 1.1)
            heart.zPosition = 99
            heartNodes.append(heart)
            self.addChild(heart)
        }
    }
    
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        //Aspect Ratio differs from devices to devices
        let maxAspectRatio: CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0

        self.physicsWorld.contactDelegate = self
        
        for i in 0...1 {
            
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width / 2,
                                          y: self.size.height * CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
            
        }
        

        player.setScale(1) //Size of the player ship
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.systemYellow
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.22, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 99
        self.addChild(scoreLabel)
    
        createHearts()
        
        let moveOntoScreen = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOntoScreen)
        
        for heart in heartNodes {
            heart.run(moveOntoScreen)
        }
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSec: CGFloat = 600.0 //Changing this value lets you speed up/slow down the background movement
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSec * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background") { (background, stop) in
            if self.currentGameState == gameState.inGame {
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
    
    
    func startGame() {
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    
    func loseALife() {
        // Ensure there are lives to lose
        if livesNumber > 0 {
            livesNumber -= 1
            
            // Animate the first heart before removing it
            let firstHeart = heartNodes[0]
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            firstHeart.run(scaleSequence, completion: {
                firstHeart.removeFromParent()
            })
            
            // Remove the heart from the array after the animation
            heartNodes.remove(at: 0)
        }
        
        // Check for game over
        if livesNumber < 1 {
            runGameOver()
        }
    }
    
    func loseAllLives() {
        
        for heart in heartNodes {
            // Animate the first heart before removing it
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            heart.run(scaleSequence, completion: {
                heart.removeFromParent()
            })
        }
        
        runGameOver()
    }
    
    
    func addScore() {
        
        gameScore += 1
        scoreLabel.position = CGPoint(x: self.size.width * 0.255, y: self.size.height * 0.9)
        scoreLabel.text = "\(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            startNewLevel()
        }
        
    }
    
    
    func runGameOver() {
        
        currentGameState = gameState.postGame
        //freeze all items on screen
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") { (bullet, stop) in bullet.removeAllActions() }
        self.enumerateChildNodes(withName: "Enemy") { (enemy, stop) in enemy.removeAllActions() }
        self.enumerateChildNodes(withName: "Asteroid") { (asteroid, stop) in asteroid.removeAllActions() }

        
        //change to game over scene
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    
    func changeScene() {
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // If spawning something(explosion, bulletSpark,..) where something else previously was, check for its existence incase it was deleted(check for the body != nil).
        
        //if the player has hit the enemy
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            
            if body1.node != nil && body2.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            loseAllLives()
        }
        
        //if the bullet has hit the enemy
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            
            addScore()
            
            if body2.node != nil {
                if body2.node!.position.y > self.size.height {
                    return //if the enemy is off the top of the screen, 'return'. This will stop running this code here, therefore doing nothing unless we hit the enemy when it's on the screen. As we are already checking that body2.node isn't nothing, we can safely unwrap (with '!)' this here.
                } else {
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        
        //if the enemy hit the asteroid
        if body1.categoryBitMask == PhysicsCategories.Enemy && body2.categoryBitMask == PhysicsCategories.Asteroid {
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            body1.node?.removeFromParent()
        }
        
        //if the player hit the asteroid
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Asteroid {
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            body1.node?.removeFromParent()
            
            loseAllLives()
        }
        
        //if the byullet hit the asteroid
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Asteroid {
            
            if body1.node != nil {
                spawnBulletSpark(spawnPosition: body1.node!.position)
            }
            body1.node?.removeFromParent()
        }
        
        
    }
    
    
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func spawnBulletSpark(spawnPosition: CGPoint) {
        
        let bulletSpark = SKSpriteNode(imageNamed: "bulletSpark")
        bulletSpark.position = spawnPosition
        bulletSpark.zPosition = 4
        bulletSpark.setScale(0)
        self.addChild(bulletSpark)
        
        let scaleIn = SKAction.scale(to: 0.15, duration: 0.05)
        let fadeOut = SKAction.fadeOut(withDuration: 0.05)
        let delete = SKAction.removeFromParent()
        
        
        let bulletSparkSequence = SKAction.sequence([bulletSparkSound, scaleIn, fadeOut, delete])
        bulletSpark.run(bulletSparkSequence)
    }
    
    func startNewLevel() {
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.6
        default:
            levelDuration = 0.6
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn, SKAction.run(spawnAsteroid)])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    // Declare enemy spawning coordinates globally to make sure asteroids don't spawn into enemies
    var randomEnemyXStart = CGFloat(-1)
    var randomEnemyXEnd = CGFloat(-1)

    func spawnEnemy() {
        
        randomEnemyXStart = random(min: gameArea.minX, max: gameArea.maxX)
        randomEnemyXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomEnemyXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomEnemyXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame { enemy.run(enemySequence) }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRot = atan2(dy, dx)
        enemy.zRotation = amountToRot
        
    }

    func spawnAsteroid() {
        
        var randomAstXStart = CGFloat(-1)
        var randomAstXEnd = CGFloat(-1)

        //Generate random starting and ending coordinates for the asteroid, making sure it doesn't spawn in an enemy
        while true {
            let randStart = random(min: gameArea.minX, max: gameArea.maxX)
            if randStart != randomEnemyXStart - 65 || randStart != randomEnemyXStart + 65 {
                randomAstXStart = randStart
                break
            }
        }
        
        while true {
            let randEnd = random(min: gameArea.minX, max: gameArea.maxX)
            if randEnd != randomEnemyXEnd - 65 || randEnd != randomEnemyXEnd + 65 {
                randomAstXEnd = randEnd
                break
            }
        }
        
        let randAstSize = random(min: 0.4, max: 1.1)
    
        let startPoint = CGPoint(x: randomAstXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomAstXEnd, y: -self.size.height * 0.2)
        
        let asteroidTexture = SKTexture(imageNamed: "smallAsteroid")
        let asteroid = SKSpriteNode(texture: asteroidTexture)
        asteroid.name = "Asteroid"
        asteroid.setScale(randAstSize)
        asteroid.position = startPoint
        asteroid.zPosition = 3

        // Create the physics body using the texture for accurate hitbox
        asteroid.physicsBody = SKPhysicsBody(texture: asteroidTexture, size: asteroid.size)
        asteroid.physicsBody!.affectedByGravity = false
        asteroid.physicsBody!.categoryBitMask = PhysicsCategories.Asteroid
        asteroid.physicsBody!.collisionBitMask = PhysicsCategories.None
        asteroid.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet | PhysicsCategories.Enemy
        self.addChild(asteroid)
        
        
        let moveAsteroid = SKAction.move(to: endPoint, duration: 2.1)
        
        // Define rotation range in radians (120 degrees to 480 degrees)
        let minRotationAngle = 2 * CGFloat.pi / 3
        let maxRotationAngle = 8 * CGFloat.pi / 3
        // Rotate the asteroid by 120-480 degrees (2pi/3-8pi/3 radians) over the duration of its movement
        let randRotationAngle = random(min: minRotationAngle, max: maxRotationAngle)
        let rotateAsteroid = SKAction.rotate(byAngle: randRotationAngle, duration: 2.1)

        // Group the movement and rotation actions so they run simultaneously
        let asteroidGroup = SKAction.group([moveAsteroid, rotateAsteroid])
        let deleteAsteroid = SKAction.removeFromParent()

        let asteroidSequence = SKAction.sequence([asteroidGroup, deleteAsteroid])
        
        
        if currentGameState == gameState.inGame { asteroid.run(asteroidSequence) }
        
//        let dx = endPoint.x - startPoint.x
//        let dy = endPoint.y - startPoint.y
//        let amountToRot = atan2(dy, dx)
//        asteroid.zRotation = amountToRot
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame { startGame() }
        else if currentGameState == gameState.inGame { fireBullet() }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame {
                player.position.x += amountDragged
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
    
    
    
    
}
