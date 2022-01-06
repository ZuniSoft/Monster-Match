//
//  Chain.swift
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

class Chain: Hashable, CustomStringConvertible {
    var monsters = [Monster]()
    var score = 0
    
    enum ChainType: CustomStringConvertible {
        case horizontal
        case vertical
        
        var description: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func add(monster: Monster) {
        monsters.append(monster)
    }
    
    func firstMonster() -> Monster {
        return monsters[0]
    }
    
    func lastMonster() -> Monster {
        return monsters[monsters.count - 1]
    }
    
    var length: Int {
        return monsters.count
    }
    
    var description: String {
        return "type:\(chainType) monsters:\(monsters)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(monsters.reduce(0) { $0.hashValue ^ $1.hashValue})
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.monsters == rhs.monsters
}

