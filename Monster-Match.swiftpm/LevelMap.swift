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
    var position: CGPoint!
    var levelMarkerX: [CGFloat]!
    var levelMarkerY: [CGFloat]!
    var currLevel: Int!
    
    init(scene: SKScene) {
        self.scene = scene
        self.currLevel = 0
        
        gameMapPanel = SKSpriteNode(imageNamed: "Game-Map")
        gameMapPanel.position = CGPoint(
            x: self.scene.position.x,
            y: self.scene.position.y)
        gameMapPanel.size = CGSize(width: 600, height: 900)
        self.scene.addChild(gameMapPanel)
        
        let posX = self.scene.position.x
        let posY = self.scene.position.y
        
        levelMarkerX = [
            posX + 145, 
            posX + 105,
            posX,
            posX + 25, 
            posX - 90,
            posX - 90,
            posX + 20,
            posX + 105,
            posX + 185,
            posX + 15
        ]
        levelMarkerY = [
            posY - 330, 
            posY - 250,
            posY,
            posY + 80,
            posY + 75,
            posY + 155,
            posY + 195,
            posY + 255,
            posY + 350,
            posY + 400
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
        
        for (index, value) in levelMarkerX.enumerated() {
            if index < self.currLevel {
                marker = SKSpriteNode(imageNamed: "Level-Complete-Marker")
            } else {
                marker = SKSpriteNode(imageNamed: "Level-Open-Marker")
            }
            marker.name = "marker"
            marker.position = CGPoint(x: value, y: levelMarkerY[index])
            marker.zPosition = 1
            marker.size = CGSize(width: 48, height: 48)
            self.scene.addChild(marker)
            
            let level = SKLabelNode(fontNamed: "GillSans-Bold")
            level.name = "level"
            level.text = String(index + 1)
            level.fontSize = 18
            level.fontColor = UIColor.black
            level.horizontalAlignmentMode = .center
            level.position = CGPoint(x: value, y: levelMarkerY[index])
            level.zPosition = 2
            self.scene.addChild(level)
        }
    }
    
    func removeMarkers() {
        for obj in self.scene.children {
            if obj.name == "marker" || obj.name == "level" {
                obj.removeFromParent()
            }
        }
    }
    
    func setGamelLevel(currLevel: Int) {
        self.currLevel = currLevel
    }
}
