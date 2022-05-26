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





class GameScene: SKScene, SKPhysicsContactDelegate
{
    
    
    var ship:SKSpriteNode = SKSpriteNode()
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    let side = [0, 1, 2, 3]
    
    var theRotation:CGFloat = 0
    var offset:CGFloat = 0
    
    
    
    
    override func didMove(to view: SKView)
    {
        
        if let someShip:SKSpriteNode = self.childNode(withName: "Ship") as? SKSpriteNode
        {
            
            ship = someShip
        
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
                SKAction.run(addAsteroid),
                SKAction.wait(forDuration: 4.0)
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
        
        ship.physicsBody?.applyImpulse(theVector)
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
    
    func addAsteroid()
    {
        let asteroid = SKSpriteNode(imageNamed: "rock")
        
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
       
        asteroid.position = CGPoint(x: asteroidx, y: asteroidy)
        asteroid.size = CGSize(width: 350, height: 350)
        
        addChild(asteroid)
        
        let actualDuration = random(min: CGFloat(9.0), max: CGFloat(20.0))
        
        
        
        
        let actionMove = SKAction.move(to: CGPoint(x: ship.position.x, y: ship.position.y), duration: TimeInterval(actualDuration))
          let actionMoveDone = SKAction.removeFromParent()
          asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
      
        
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
