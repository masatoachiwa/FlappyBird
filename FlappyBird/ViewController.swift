//
//  ViewController.swift
//  FlappyBird
//
//  Created by アプリ開発 on 2019/06/16.
//  Copyright © 2019 Masato.achiwa. All rights reserved.
//

import UIKit
import SpriteKit //インポートする　　★★★

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
  
        // SKViewに型を変換する SpriteKitのこと。ゲームを作るためのフレームワーク。
        let skView = self.view as! SKView //★★★
        //SKViewとはSKSceneを表示するためのもの
        //UIViewに対してキャストして使用する
        
        
        // FPSを表示する。画面が一秒間に何回更新されるかを示す。
        skView.showsFPS = true   //★★★
        
        // ノードの数を表示する。テキストやキャラクター。画像などの物体を表示します。
        skView.showsNodeCount = true  //★★★
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size)  //GameSceneクラスに変更　//★★★
        
        // ビューにシーンを表示する
        skView.presentScene(scene)  //★★★
    
    //１SKViewをキャストする（tableView)的な物
    //2 SKSceneの設定。SKSceとは表示する画面の１ユニット

    }

}

