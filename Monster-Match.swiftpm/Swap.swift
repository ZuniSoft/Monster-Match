//
//  Swap.swift
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

import Foundation

struct Swap: CustomStringConvertible, Hashable {
    let monsterA: Monster
    let monsterB: Monster
    
    init(monsterA: Monster, monsterB: Monster) {
        self.monsterA = monsterA
        self.monsterB = monsterB
    }
    
    static func ==(lhs: Swap, rhs: Swap) -> Bool {
        return (lhs.monsterA == rhs.monsterA && lhs.monsterB == rhs.monsterB) ||
        (lhs.monsterB == rhs.monsterA && lhs.monsterA == rhs.monsterB)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(monsterA.hashValue ^ monsterB.hashValue)
    }
    
    var description: String {
        return "swap \(monsterA) with \(monsterB)"
    }
}

