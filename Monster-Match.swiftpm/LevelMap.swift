//
//  LevelMap.swift
//  Monster Match
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
//  Created by Keith Davis on 01/02/22.
//  Copyright © 2022 ZuniSoft. All rights reserved.
//

import SpriteKit

class LevelMap {
    var scene: SKScene!
    var gameMapPanel: SKSpriteNode!
    var levelLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var position: CGPoint!
    var levelMarkerX: [CGFloat]!
    var levelMarkerY: [CGFloat]!
    var currLevel: Int!
    var score: Int!
    
    init(scene: SKScene) {
        self.scene = scene
        self.currLevel = 0
        self.score = 0
        
        gameMapPanel = SKSpriteNode(imageNamed: "Game-Map")
        gameMapPanel.position = CGPoint(
            x: self.scene.position.x,
            y: self.scene.position.y)
        gameMapPanel.size = CGSize(width: 600 * scaleFactor,
                                   height: 900 * scaleFactor)
        self.scene.addChild(gameMapPanel)
        
        let posX = self.scene.position.x
        let posY = self.scene.position.y
        
        levelMarkerX = [
            posX + 145 * scaleFactor, 
            posX + 105 * scaleFactor,
            posX * scaleFactor,
            posX + 25 * scaleFactor, 
            posX - 90 * scaleFactor,
            posX - 90 * scaleFactor,
            posX + 20 * scaleFactor,
            posX + 105 * scaleFactor,
            posX + 185 * scaleFactor,
            posX + 15 * scaleFactor
        ]
        levelMarkerY = [
            posY - 330 * scaleFactor, 
            posY - 250 * scaleFactor,
            posY * scaleFactor,
            posY + 80 * scaleFactor,
            posY + 75 * scaleFactor,
            posY + 155 * scaleFactor,
            posY + 195 * scaleFactor,
            posY + 255 * scaleFactor,
            posY + 350 * scaleFactor,
            posY + 400 * scaleFactor
        ]
    }
    
    func showMap() {
        gameMapPanel.isHidden = false
    }
    
    func hideMap() {
        gameMapPanel.isHidden = true
    }
    
    func showMarkers() {
        var marker: SKSpriteNode!
        var levelLower = 1
        var levelUpper = 2
        
        for (index, value) in levelMarkerX.enumerated() {
            print(index % self.currLevel)
            if index < self.currLevel - (index + 1) {
                marker = SKSpriteNode(imageNamed: "Level-Complete-Marker")
            } else {
                marker = SKSpriteNode(imageNamed: "Level-Open-Marker")
            }
            marker.name = "marker"
            marker.position = CGPoint(x: value, y: levelMarkerY[index])
            marker.zPosition = 1
            marker.size = CGSize(width: 48 * scaleFactor, height: 48 * scaleFactor)
            self.scene.addChild(marker)
            
            let level = SKLabelNode(fontNamed: "GillSans-Bold")
            level.name = "level"
            level.text = String(format: "%ld-%ld", levelLower, levelUpper)
            level.fontSize = mapFontSize
            level.fontColor = UIColor.black
            level.horizontalAlignmentMode = .center
            level.position = CGPoint(x: value, y: levelMarkerY[index])
            level.zPosition = 2
            self.scene.addChild(level)
            
            levelLower += 2
            levelUpper += 2
        }
    }
    
    func removeMarkers() {
        for obj in self.scene.children {
            if obj.name == "marker" || obj.name == "level" || obj.name == "label" {
                obj.removeFromParent()
            }
        }
    }
    
    func showLabels() {
        levelLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        levelLabel.name = "label"
        levelLabel.text = String(format: "Level: %ld", currLevel)
        levelLabel.fontColor = UIColor.white
        levelLabel.fontSize = fontSize
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(
            x: self.scene.position.x - 285 * scaleFactor,
            y: self.scene.position.y + 385 * scaleFactor)
        levelLabel.zPosition = 1
        self.scene.addChild(levelLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        scoreLabel.name = "label"
        scoreLabel.text = String(format: "Score: %ld", score)
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontSize = fontSize
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(
            x: self.scene.position.x + 285 * scaleFactor,
            y: self.scene.position.y + 385 * scaleFactor)
        scoreLabel.zPosition = 1
        self.scene.addChild(scoreLabel)
    }
    
    func setGamelLevel(currLevel: Int) {
        self.currLevel = currLevel
    }
    
    func setScore(score: Int) {
        self.score = score
    }
}
