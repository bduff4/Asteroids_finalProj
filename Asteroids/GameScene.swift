//
//  GameScene.swift
//  Asteroids
//
//  Created by Brennan Duff on 5/13/22.
//

import SpriteKit
import GameplayKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


struct PhysicsCategory {
  static let none       : UInt32 = 0
  static let all        : UInt32 = UInt32.max
  static let rockPhys   : UInt32 = 0b1       // 1
  static let shipPhys   : UInt32 = 0b10      // 2
  static let projPhys   : UInt32 = 0b11      // 3
}



class GameScene: SKScene
{
    
   
    var ship:SKSpriteNode = SKSpriteNode()
    
    
    
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    let side = [0, 1, 2, 3]
    var projVect = CGVector()
    
    var theRotation:CGFloat = 0
    var offset:CGFloat = 0
    
    var gameOverBool = false
    
    
    override func didMove(to view: SKView)
    {

        physicsWorld.contactDelegate = self
        if let someShip:SKSpriteNode = self.childNode(withName: "Ship") as? SKSpriteNode
        {
            
            ship = someShip
            someShip.physicsBody?.isDynamic = true
            someShip.physicsBody?.categoryBitMask = PhysicsCategory.shipPhys
            someShip.physicsBody?.contactTestBitMask = PhysicsCategory.rockPhys
            someShip.physicsBody?.collisionBitMask = PhysicsCategory.none
        }
       
        rotateRec.addTarget(self, action: #selector(GameScene.rotatedView(_:) ))
        self.view!.addGestureRecognizer(rotateRec)
        
        
        self.view!.isMultipleTouchEnabled = true
        self.view!.isUserInteractionEnabled = true

        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
        
        
        
        run(SKAction.repeatForever(
              SKAction.sequence([
                SKAction.wait(forDuration: 4.0),
                SKAction.run(addAsteroid)
                ])
            ))

        
        
    }
    
    @objc func rotatedView(_ sender:UIRotationGestureRecognizer)
    {
        
        if (sender.state == .began)
        {
            print("began")
        
        }
        
        if (sender.state == .changed)
        {
            print("rotated")
            
            theRotation = CGFloat(sender.rotation) + self.offset
            theRotation = theRotation * -1
            
            ship.zRotation = theRotation
        }
        
        if (sender.state == .ended)
        {
            print("we ended")
            
            self.offset = ship.zRotation * -1
        }
    }
    
    @objc func tappedView()
    {
        
        print("we tapped")
        
        let xVec:CGFloat = sin(theRotation) * -10
        let yVec:CGFloat = cos(theRotation) * 10
        
        let theVector:CGVector = CGVector(dx: xVec, dy: yVec)
        projVect = theVector
        ship.physicsBody?.applyImpulse(theVector)
        
        shooting()
        
    }
    
    
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    
    func xValue() -> CGFloat
    {
         let randx = CGFloat.random(in: 0...self.frame.width)
        return(randx)
    }
    func yValue() -> CGFloat
    {
        let randy = CGFloat.random(in: 0...self.frame.height)
        return(randy)
    }
    
    
    func shooting()
    {
        if gameOverBool == false
        {
        let projectile = SKSpriteNode(imageNamed: "projectile")
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 8, center: projectile.anchorPoint)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projPhys
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.rockPhys
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        projectile.position = ship.position
        projectile.size = CGSize(width: 16, height: 16)
        addChild(projectile)
        
        projectile.physicsBody?.applyImpulse(projVect)
        
        }
    }
    
    
    
   
    
    func addAsteroid()
    {
        let asteroid = SKSpriteNode(imageNamed: "rock")
        
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: 175, center: asteroid.anchorPoint)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.rockPhys
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.projPhys
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.shipPhys
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        var asteroidx = CGFloat()
        var asteroidy = CGFloat()
       
        
        var randwall = Int.random(in: 1...4)
        if randwall == 1
        {
            asteroidx = xValue()
            asteroidy = self.frame.height
        }
        else if randwall == 2
        {
            asteroidx = self.frame.width
            asteroidy = yValue()
        }
        else if randwall == 3
        {
            asteroidx = xValue()
            asteroidy = 0
        }
        else
        {
            asteroidx = 0
            asteroidy = yValue()
        }
       
        var shipLocation = ship.position
        
        asteroid.position = CGPoint(x: asteroidx, y: asteroidy)
        asteroid.size = CGSize(width: 350, height: 350)
        
        
        let offset = shipLocation - asteroid.position
        
        
        addChild(asteroid)
        
        
        let direction = offset.normalized()
        
        let travelDistance = direction * 5000
        
        let trueDestination = travelDistance + asteroid.position
        
        let actualDuration = random(min: CGFloat(30.0), max: CGFloat(40.0))
        
        let actionMove = SKAction.move(to: trueDestination, duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
          asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func asteroidProjectileCollision(projectile: SKSpriteNode, asteroid: SKSpriteNode)
    {
        print("ship hit")
        projectile.removeFromParent()
        asteroid.removeFromParent()
        if projectile == ship || asteroid == ship
        {
            print("game over")
            gameOverBool = true
            let label = SKLabelNode(fontNamed: "Chalkduster")
                label.text = "Game Over"
                label.fontSize = 120
                label.fontColor = SKColor.white
                label.position = CGPoint(x: size.width/2, y: size.height/2)
                addChild(label)
        }
    }
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    

}


extension GameScene: SKPhysicsContactDelegate
{
    func didBegin(_ contact: SKPhysicsContact) {

      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }


      if ((firstBody.categoryBitMask & PhysicsCategory.rockPhys != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.shipPhys != 0)) {
        if let asteroidphysics = firstBody.node as? SKSpriteNode,
          let projectilephysics = secondBody.node as? SKSpriteNode {
          asteroidProjectileCollision(projectile: projectilephysics, asteroid: asteroidphysics)
        }
      }
    }

}
