//
//  ViewController.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/19/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var mainView: MainView
    var myGame: ConwayGame
    
    required init(coder aDecoder: NSCoder) {
        self.myGame = ConwayGame(rows: 100, cols: 50)
        self.myGame.populateBoard(60)
        
        self.mainView = MainView(coder: aDecoder)
        
        super.init(coder: aDecoder)
    }
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpBoardView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        self.mainView.configureView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setUpBoardView() {
        self.mainView.gameBoard = myGame
        self.mainView.gameBoard.delegate = self.mainView
        
        self.view = self.mainView
    }
}

