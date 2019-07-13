//
//  GameScene.swift
//  FlappyBird
//
//  Created by アプリ開発 on 2019/06/20.
//  Copyright © 2019 Masato.achiwa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate /* 追加 */ { //★★★
        

        var scrollNode:SKNode!
        var wallNode:SKNode!    // 追加
        var ringoNode:SKNode!    //課題

        var bird:SKSpriteNode!    // 追加
        
        var ringoImage:SKSpriteNode! //課題
      
     

        
        // 衝突判定カテゴリー ↓追加
        let birdCategory: UInt32 = 1 << 0       // 0...00001
        let groundCategory: UInt32 = 1 << 1     // 0...00010
        let wallCategory: UInt32 = 1 << 2       // 0...00100
        let scoreCategory: UInt32 = 1 << 3      // 0...01000
        let ringoCategory: UInt32 = 1 << 4      // 0...01000
       
        

        
        
        
        
        
        
        
        
        // スコア用
        var score = 0  // ←追加
        var itemScore = 0 //課題
        var scoreLabelNode:SKLabelNode!    // ←追加
        var itembestScoreLabelNode:SKLabelNode! //課題
        var bestScoreLabelNode:SKLabelNode!    // ←追加
        let userDefaults:UserDefaults = UserDefaults.standard    // 追加


        // 画面をタップした時に呼ばれる
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
               
                 if scrollNode.speed > 0 { // 追加
                
                
                // 鳥の速度をゼロにする
             bird.physicsBody?.velocity = CGVector.zero
                
                // 鳥に縦方向の力を与える
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
                 }else if bird.speed == 0 { // --- ここから ---
                        restart()
                 }
        } // --- ここまで追加 ---
        
  
        
        
        func didBegin(_ contact: SKPhysicsContact) {
                // ゲームオーバーのときは何もしない
                if scrollNode.speed <= 0 {
                        return
                }
                
                if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                        // スコア用の物体と衝突した
                        print("ScoreUp")
                        score += 1
                        scoreLabelNode.text = "Score:\(score)"    // ←追加

                        
                        
                        
                        // ベストスコア更新か確認する --- ここから ---
                        var bestScore = userDefaults.integer(forKey: "BEST")
                        if score > bestScore {
                                bestScore = score
                                bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
                                userDefaults.set(bestScore, forKey: "BEST")
                                userDefaults.synchronize()
                        } // --- ここまで追加---
                        
      
                        
                        
                }  else if ((contact.bodyA.categoryBitMask & ringoCategory) == ringoCategory || (contact.bodyB.categoryBitMask & ringoCategory) == ringoCategory) {
                        
                       contact.bodyA.node?.removeFromParent()
                        
                                        // スコア用の物体と衝突した
                        print("ScoreUp")
                        itemScore += 1
                        itembestScoreLabelNode.text = "Item Score:\(itemScore)"    // ←追加
                        
                     
                        
                        
                        
                        
                        
                
                
                        
                
                } else {
                        // 壁か地面と衝突した
                        print("GameOver")
                        
                        // スクロールを停止させる
                        scrollNode.speed = 0
                        
                        bird.physicsBody?.collisionBitMask = groundCategory
                        
                        let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
                        bird.run(roll, completion:{
                                self.bird.speed = 0
                        })
                }
                }
        
        
        func restart() {
                score = 0
                itemScore = 0
                scoreLabelNode.text = String("Score:\(score)")    // ←追加
                itembestScoreLabelNode.text = String("Item Score:\(itemScore)")    // ←追加
                
                bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
                bird.physicsBody?.velocity = CGVector.zero
                bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
                bird.zRotation = 0
                
                wallNode.removeAllChildren()
                
                bird.speed = 1
                scrollNode.speed = 1
        }

        
        
        override func didMove(to view: SKView) {//この画面が呼び出された時に実行される処理　//★★★
                
                
                // 重力を設定
                physicsWorld.gravity = CGVector(dx: 0, dy: -4)    // ←追加
                
                physicsWorld.contactDelegate = self // ←追加
                
                
                
                // 背景色を設定
                backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1) //★★★
                
                // スクロールするスプライトの親ノード  //追加１
                scrollNode = SKNode() //★★★scrollNodeのインスタンス化
                addChild(scrollNode) //★★追加で必要
                // 壁用のノード
                wallNode = SKNode()   // 追加　★★★(Nodeのボス）
                scrollNode.addChild(wallNode)   // 追加　★★使いますよという意味（
                ringoNode = SKNode()  //課題りんご用のノード
                scrollNode.addChild(ringoNode)
                
                
                
                
                // 各種スプライトを生成する処理をメソッドに分割
                setupGround()
                setupCloud()
                setupWall()   // 追加
                setupBird()   // 追加
                
                setupScoreLabel()   // 追加
                
                setupRing() //課題
        }
                
                func setupGround() { //★★★ 地面の画像
                        
                        
                        // 地面の画像を読み込む
                        let groundTexture = SKTexture(imageNamed: "ground") //★★★
                        groundTexture.filteringMode = .nearest //★★★
                        
                        // 必要な枚数を計算
                        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2  //追加１　//★★★
                        
                        // スクロールするアクションを作成
                        // 左方向に画像一枚分スクロールさせるアクション
                        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5) //★★★
                        
                        // 元の位置に戻すアクション
                        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)  //★★★
                        
                        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
                        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround])) //★★★
                        
                        // groundのスプライトを配置する
                        for i in 0..<needNumber {
                                let sprite = SKSpriteNode(texture: groundTexture) //★★★
                                sprite.zPosition = -400
                                
                                // テクスチャを指定してスプライトを作成する　　//消すの？
                                //    let groundSprite = SKSpriteNode(texture: groundTexture) //★★★（なぜ、消す必要があるのか？下のコードで使っているのに、なぜと疑問に思ったが、後にspriteに変更していることが判明
                                
                                
                                // スプライトの表示する位置を指定する
                                sprite.position = CGPoint(  //★★★ （sprite変数で宣言していないのになぜ使えるのか？→後に宣言する
                                   //変更前    x: groundTexture.size().width / 2,  //★★★
                                        x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),  //★★★
                                        y: groundTexture.size().height / 2 //★★★
                                )
                                // スプライトにアクションを設定する
                                sprite.run(repeatScrollGround)  //★★★
                                
                                // スプライトに物理演算を設定する
                                sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
                                
                                // 衝突のカテゴリー設定
                                sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加
                                
                                
                                // 衝突の時に動かないように設定する
                                sprite.physicsBody?.isDynamic = false   // ←追加
                                // シーンにスプライトを追加する
                                //変更   addChild(groundSprite)
                                scrollNode.addChild(sprite) //★★★
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                        }
                        
                }
        
        func setupCloud() { //★★★
                // 雲の画像を読み込む
                let cloudTexture = SKTexture(imageNamed: "cloud")
                cloudTexture.filteringMode = .nearest
                
                // 必要な枚数を計算
                let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
                
                // スクロールするアクションを作成
                // 左方向に画像一枚分スクロールさせるアクション
                let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)
                
                // 元の位置に戻すアクション
                let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
                
                // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
                let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
                
                // スプライトを配置する
                for i in 0..<needCloudNumber {
                        let sprite = SKSpriteNode(texture: cloudTexture)
                        sprite.zPosition = -300 // 一番後ろになるようにする　//★★★
                        
                        // スプライトの表示する位置を指定する
                        sprite.position = CGPoint(
                                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                                y: self.size.height - cloudTexture.size().height / 2
                        )
                        
                        // スプライトにアニメーションを設定する
                        sprite.run(repeatScrollCloud)
                        
                        // スプライトを追加する
                        scrollNode.addChild(sprite)
                }
        }
        
        func setupWall() { //壁の画像
                // 壁の画像を読み込む
                let wallTexture = SKTexture(imageNamed: "wall")
                wallTexture.filteringMode = .linear //★★★
                
                // 移動する距離を計算
                let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width) //★★★
                
                // 画面外まで移動するアクションを作成
                let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4) //★★★
                
                // 自身を取り除くアクションを作成
                let removeWall = SKAction.removeFromParent() //★★★
                
                // 2つのアニメーションを順に実行するアクションを作成
                let wallAnimation = SKAction.sequence([moveWall, removeWall]) //★★★
                
                // 鳥の画像サイズを取得
                let birdSize = SKTexture(imageNamed: "bird_a").size()  //★★（size()とは？なぜ壁とかにはなかったのか？）
                
                // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
                let slit_length = birdSize.height * 3 //★★★
                
                // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
                let random_y_range = birdSize.height * 3  //★（隙間位置とは？）
                
                // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
                let groundSize = SKTexture(imageNamed: "ground").size() //★★★地面のサイズを代入　groundSizeに地面の画像を代入
                let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2 //★★★ 画面から地面のサイズを引いた画面の中央値を代入
                let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
                //画面の中央値から-鳥が通り抜けられる３倍のサイズと、隙間位位置を引いた数
                
                // 壁を生成するアクションを作成
                let createWallAnimation = SKAction.run({  //★★★ アクション機能を追加
                        // 壁関連のノードを乗せるノードを作成
                        let wall = SKNode()
                        wall.position = CGPoint(x: self.frame.size.width  + wallTexture.size().width / 2, y: 0)  //壁のポジションは
                        wall.zPosition = -50 // 雲より手前、地面より奥
                        
                        // 0〜random_y_rangeまでのランダム値を生成　//★★★ただの位置決定の話
                        let random_y = CGFloat.random(in: 0..<random_y_range)
                        // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
                        let under_wall_y = under_wall_lowest_y + random_y
                        
                        // 下側の壁を作成　//★（xって何？と思って200にしたらずれた）
                        let under = SKSpriteNode(texture: wallTexture)
                                    under.position = CGPoint(x: 0, y: under_wall_y)
                        
                        
                        //  上のコードwall.position = CGPoint(x: self.frame.size.width  + wallTexture.size().width / 2, y: 0) からみたunderの位置
                        
                        // スプライトに物理演算を設定する
                        under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
                       under.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
                        
                        // 衝突の時に動かないように設定する
                        under.physicsBody?.isDynamic = false    // ←追加

                        wall.addChild(under) //★★
                        

                        
                        // 上側の壁を作成
                        let upper = SKSpriteNode(texture: wallTexture)
                        upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
                        
                        // スプライトに物理演算を設定する
                        upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
                        upper.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
                        
                        // 衝突の時に動かないように設定する
                        upper.physicsBody?.isDynamic = false    // ←追加
                        

                        
                        wall.addChild(upper)
                        
                        // スコアアップ用のノード --- ここから ---
                        let scoreNode = SKNode()
                        scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
                        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
                        scoreNode.physicsBody?.isDynamic = false
                        scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                        scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
                        
                        wall.addChild(scoreNode)
                        // --- ここまで追加 ---
                        
                        
                        
                        
                        wall.run(wallAnimation)
                        
                        self.wallNode.addChild(wall)
                })
                
                
                
                
                // 次の壁作成までの時間待ちのアクションを作成
                let waitAnimation = SKAction.wait(forDuration: 2)
                
                // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
                let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
                
                wallNode.run(repeatForeverAnimation)
        }
        

        
func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)    // ←追加
      
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory | ringoCategory   // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | ringoCategory   // ←追加
        
        
        

        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
}
        
        func setupScoreLabel() {
                score = 0
                scoreLabelNode = SKLabelNode()
                scoreLabelNode.fontColor = UIColor.black
                scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
                scoreLabelNode.zPosition = 100 // 一番手前に表示する
                scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                scoreLabelNode.text = "Score:\(score)"
                self.addChild(scoreLabelNode)
                
                bestScoreLabelNode = SKLabelNode()
                bestScoreLabelNode.fontColor = UIColor.black
                bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
                bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
                bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                
                let bestScore = userDefaults.integer(forKey: "BEST")
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                self.addChild(bestScoreLabelNode)
    
               itemScore = 0
               itembestScoreLabelNode = SKLabelNode()
               itembestScoreLabelNode.fontColor = UIColor.black
               itembestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
               itembestScoreLabelNode.zPosition = 100 // 一番手前に表示する
               itembestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
               itembestScoreLabelNode.text = "Item Score:\(itemScore)"
                self.addChild(itembestScoreLabelNode)

        
         

        
        
        
        
        
        
        
        
        
        
        
        }
        
        func setupRing(){
              
                
                let ringoA = SKTexture(imageNamed: "ringo-a")  //りんごの画像を読み込む
                ringoA.filteringMode = .linear //テクスチャ作成
               
                //りんごの画像サイズを取得
                let ringoSize = SKTexture(imageNamed: "ringo-a").size()
                let random_r_range = ringoSize.height * 3   //りんごの３倍の画像代入
                
                let random_r = CGFloat.random(in: -3..<random_r_range)
        
           
                
                let wallTexture = SKTexture(imageNamed: "wall")
                wallTexture.filteringMode = .linear //★★★
                
                // 移動する距離を計算
                let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
                
            
                
                //--------------りんごをスクロールさせるアクションを記述する-----
                
                // 画面外まで移動するアクションを作成
                let moveRingo = SKAction.moveBy(x: -movingDistance*2, y: 0, duration:8)   //元々は壁と同じように右のコードだった (x: -movingDistance, y: 0, duration:４)
                
                // 自身を取り除くアクションを作成
                let removeWall = SKAction.removeFromParent()
                
                // 2つのアニメーションを順に実行するアクションを作成
                let ringoAnimation = SKAction.sequence([moveRingo,  removeWall])
//----------------------ここまで------------------------------
                
                //---------りんごを生成するアクションを作成----------
                
                let  createRingoAnimation = SKAction.run({
                        let ringo = SKNode()
                        let iValue = CGFloat.random(in: 150 ... 800)
                       
                        ringo.position = CGPoint(x: self.frame.size.width*1.4 + ringoA.size().width / 2 , y:iValue )
                      print(iValue)
                       
                      
                        let up = SKSpriteNode(texture: ringoA)
                    //    up.position = CGPoint(x: self.frame.size.width * 0.5, y:self.frame.size.height * 0.6)
                     up.position = CGPoint(x: self.frame.size.width * 0.5, y:0)
                        
                        up.physicsBody = SKPhysicsBody(rectangleOf: ringoA.size())    // ←追加
                        // 衝突のカテゴリー設定
                        up.physicsBody?.categoryBitMask = self.ringoCategory    // ←追加
                        // 衝突の時に動かないように設定する
                        up.physicsBody?.isDynamic = false
                        
                        
                        
                     
                        
                        
                        
                
                        
                        
                        
                        ringo.addChild(up) //ノードは作っただけでは表示されないので、addChild() を使ってシーンに追加する必要があると覚えておきまし
                        ringo.run(ringoAnimation)
                        
                        self.ringoNode.addChild(ringo)
                        
       
        
                })
               
                // 次の壁作成までの時間待ちのアクションを作成
                let waitringoAnimation = SKAction.wait(forDuration: 2)
                
                //Ringo 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
                let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createRingoAnimation, waitringoAnimation]))
                
                ringoNode.run(repeatForeverAnimation)
                
        }
}
        


