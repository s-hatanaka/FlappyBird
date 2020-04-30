//
//  GameScene.swift
//  FlappyBird
//
//  Created by 畑中 彩里 on 2020/04/27.
//  Copyright © 2020 sari.hatanaka. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    var star1Node: SKNode!
    
    //効果音
    let musicNode = SKAudioNode.init(fileNamed: "coin03.mp3")
    
   // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let star1Category: UInt32 = 1 << 4
   // スコア・ポイント用
    var score = 0
    var point = 0
    var scoreLabelNode: SKLabelNode!
    var pointLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    /// SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
       // 重力を設定
       physicsWorld.gravity = CGVector(dx: 0, dy: -4)
       physicsWorld.contactDelegate = self
        
       backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
       // スクロールするウップライトの親ノード
       scrollNode = SKNode()
       addChild(scrollNode)
       //壁用ノード
       wallNode = SKNode()
       scrollNode.addChild(wallNode)
       //ポイント用ノード
       star1Node = SKNode()
       scrollNode.addChild(star1Node)
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupPointLabel()
        setupStar1()
        setupMusic()
    }
   
    
    /// 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if bird.speed > 0 {
            
        // 鳥の速度をゼロ
        bird.physicsBody?.velocity = CGVector.zero
        // 鳥に縦方向の力を与える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
     } else if bird.speed == 0 {
            restart()
            
        }
    }
    
    /// 地面の設定
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0 , duration: 5)
        // 一瞬で元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width , y: 0 , duration: 0)
        // 左スクロール→元の位置を無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
        
       
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            let groundSprite = SKSpriteNode(texture: groundTexture)
                   groundSprite.position = CGPoint(
                       x: groundTexture.size().width / 2,
                       y: groundTexture.size().height / 2
                   )
            
           //スプライトにアクションを設定
            sprite.run(repeatScrollGround)
            scrollNode.addChild(sprite)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
           // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
        }
    }
    
    /// 雲の設定
    func setupCloud() {
       // 雲の画像を読み込む
       let cloudTexture = SKTexture(imageNamed: "cloud")
           cloudTexture.filteringMode = .nearest
       // 必要な枚数を計算する
       let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
       // 左方向に画像一枚分スクロールさせるアクション
       let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0 , duration: 20)
       // 元の位置に戻すアクション
       let resetCloud = SKAction.moveBy(x: cloudTexture.size().width , y: 0 , duration: 0)
       // 左にスクロール->元の位置を無限に繰り返すアクション
       let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        // スプライトを配置する
        for i in 0..<needCloudNumber {
               let sprite = SKSpriteNode(texture: cloudTexture)
               sprite.zPosition = -100
         // スプライトの表示する位置を指定する
         sprite.position = CGPoint(
               x: cloudTexture.size().width / 2  + cloudTexture.size().width * CGFloat(i),
               y: cloudTexture.size().height / 2
               )
        
         // スプライトにアニメーションを設定する
         sprite.run(repeatScrollCloud)

         // スプライトを追加する
         scrollNode.addChild(sprite)
    }
   
  }
    
    
    /// 壁の設定
    func setupWall() {
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        //二つのアニメーションを順実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall,removeWall])
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3
        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥
            // 0~random_rangeまでのランダム値を生成
             let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
             let under_wall_y = under_wall_lowest_y + random_y
         // 下側の壁を作成
         let under = SKSpriteNode (texture: wallTexture)
             under.position = CGPoint(x: 0, y: under_wall_y)
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
             wall.addChild(under)
        
         // 上側の壁を作成
         let upper = SKSpriteNode (texture: wallTexture)
             upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
             // スプライトに物理演算を設定する
             upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
             upper.physicsBody?.categoryBitMask = self.wallCategory
             // 衝突の時に動かないように設定する
             upper.physicsBody?.isDynamic = false
             wall.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            wall.addChild(scoreNode)
            
             wall.run(wallAnimation)
             self.wallNode.addChild(wall)
            
        })
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation =  SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    
    /// 鳥の設定
    func setupBird() {
        // 鳥の画像２種類を読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let  birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
   
       // 2種類のテクスチャを交互に変更するアニメーションを作成
       let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
       // スプライトを作成
       bird = SKSpriteNode(texture: birdTextureA)
       bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
       // 物理演算しを設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
       // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
       // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | star1Category
       // アニメーションを設定
        bird.run(flap)
       // スプライトを追加する
        addChild(bird)
    }
    
     /// スターの設定
        func setupStar1() {
        // スターの画像を読み込む
        let star1Texture = SKTexture(imageNamed: "star1")
        star1Texture.filteringMode = .linear
        // 移動する距離を計算
        let star1MovingDistance = CGFloat(self.frame.size.width + star1Texture.size().width)
        // 画面外まで移動するアクションを作成
        let moveStar1 = SKAction.moveBy(x: -star1MovingDistance, y: 0, duration:4)
        // 自身を取り除くアクションを作成
        let removeStar1 = SKAction.removeFromParent()
        // 2つのアニメーションを順に実行するアクションを作成
        let star1Animation = SKAction.sequence([moveStar1, removeStar1])
        // スターの画像サイズを取得
        let star1Size = SKTexture(imageNamed: "star1").size()
        let star1Slit_length = star1Size.height * 2
        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let star1Random_y_range = star1Size.height * 2
        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = (self.frame.size.height - groundSize.height)
        let star1_lowest_y = center_y - star1Slit_length  - star1Texture.size().height / 2 - star1Random_y_range / 2
            
        // スターを生成するアクションを作成
        let createStar1Animation = SKAction.run({
            // スター関連のノードを乗せるノードを作成
            let star1 = SKNode()
            star1.position = CGPoint(x: self.frame.size.width + star1Texture.size().width, y: 0)
            star1.zPosition = -50 // 雲より手前、地面より奥
            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<star1Random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let star1_y = star1_lowest_y + random_y
            let random_star1_x = star1Size.width * 2
            let random_x = CGFloat.random(in: 0..<random_star1_x)
            let star1_x = random_star1_x + random_x
            // スターを作成
            let Star1 = SKSpriteNode(texture: star1Texture)
            Star1.position = CGPoint(x: star1_x, y: star1_y)
            // スプライトに物理演算を設定する
            Star1.physicsBody = SKPhysicsBody(rectangleOf: star1Texture.size())
            Star1.physicsBody?.categoryBitMask = self.star1Category
            // 衝突の時に動かないように設定する
            Star1.physicsBody?.isDynamic = false
            
            self.addChild(Star1)
            Star1.run(star1Animation)
            self.star1Node.addChild(star1)
            
        })
           
            // 次の星作成までの時間待ちのアクションを作成
            let star1WaitAnimation = SKAction.wait(forDuration: 5)
            // 星を作成->時間待ち->星を作成を無限に繰り返すアクションを作成
            let star1RepeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createStar1Animation, star1WaitAnimation]))
            star1Node.run(star1RepeatForeverAnimation)

    }
    
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
       if scrollNode.speed <= 0 {
            return
        }
       if(contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
         // スコア用の物体と衝突した
           print("ScoreUp")
           score += 1
           scoreLabelNode.text = "Score:\(score)"
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
               bestScore = score
               bestScoreLabelNode.text = "Best Score:\(bestScore)"
               userDefaults.set(bestScore, forKey: "BEST")
               userDefaults.synchronize()
            }
    } else if(contact.bodyA.categoryBitMask & star1Category) == star1Category || (contact.bodyB.categoryBitMask & star1Category) == star1Category {
        // ポイント用の物体と衝突した
           print("PointUp")
           point += 1
           pointLabelNode.text = "Point:\(point)"
           contact.bodyA.node?.removeFromParent()
           let playAction = SKAction.play()
           musicNode.run(playAction)
    
           
            
        } else {
        // 壁か地面に衝突した
           print("GameOver")
        // スクロールを停止させる
            scrollNode.speed = 0
            bird.physicsBody?.collisionBitMask = groundCategory
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) *  CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
        
    }
        
    /// スコアラベル初期化
    func setupScoreLabel() {
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
    }
    
    /// ポイントラベル
    func setupPointLabel() {
        pointLabelNode = SKLabelNode()
        pointLabelNode.fontColor = UIColor.black
        pointLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        pointLabelNode.zPosition = 100
        pointLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        pointLabelNode.text = "Point:\(point)"
        
           self.addChild(pointLabelNode)
       }
       
    /// リスタート
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        point = 0
        pointLabelNode.text = "Point:\(point)"
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupMusic() {
    musicNode.autoplayLooped = false
    addChild(musicNode)
    }
    
    
}


