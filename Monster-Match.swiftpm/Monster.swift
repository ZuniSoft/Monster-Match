//
//  Monster.swift
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
//  Created by Keith Davis on 01/01/22.
//  Copyright © 2022 ZuniSoft. All rights reserved.
//

import SpriteKit

enum MonsterType: Int, CustomStringConvertible {
    case unknown = 0, aqua, berry, blue, green, orange, yellow
    
    var spriteName: String {
        let spriteNames = [
            "Aqua",
            "Berry",
            "Blue",
            "Green",
            "Orange",
            "Yellow"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> MonsterType {
        return MonsterType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}

class Monster: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let monsterType: MonsterType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, monsterType: MonsterType) {
        self.column = column
        self.row = row
        self.monsterType = monsterType
    }
    
    var description: String {
        return "type:\(monsterType) square:(\(column),\(row))"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(row*10 + column)
    }
    
    static func == (lhs: Monster, rhs: Monster) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
}

