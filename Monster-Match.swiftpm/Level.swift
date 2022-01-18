
//
//  Level.swift
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

let NumColumns = 9
let NumRows = 9
let NumLevels = 19

class Level {
    
    fileprivate var monsters = Array2D<Monster>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = Set<Swap>()
    private var comboMultiplier = 0
    var targetScore = 0
    var maximumMoves = 0
    
    init(filename: String) {
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
        
        targetScore = dictionary["targetScore"] as! Int
        maximumMoves = dictionary["moves"] as! Int
    }
    
    func monsterAt(column: Int, row: Int) -> Monster? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return monsters[column, row]
    }
    
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    private func calculateScores(for chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
    func shuffle() -> Set<Monster> {
        var set: Set<Monster>
        repeat {
            set = createInitialMonsters()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }
    
    private func createInitialMonsters() -> Set<Monster> {
        var set = Set<Monster>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                    var monsterType: MonsterType
                    repeat {
                        monsterType = MonsterType.random()
                    } while (column >= 2 &&
                             monsters[column - 1, row]?.monsterType == monsterType &&
                             monsters[column - 2, row]?.monsterType == monsterType)
                    || (row >= 2 &&
                        monsters[column, row - 1]?.monsterType == monsterType &&
                        monsters[column, row - 2]?.monsterType == monsterType)
                    
                    let monster = Monster(column: column, row: row, monsterType: monsterType)
                    monsters[column, row] = monster
                    
                    set.insert(monster)
                }
            }
        }
        return set
    }
    
    private func hasChainAt(column: Int, row: Int) -> Bool {
        let monsterType = monsters[column, row]!.monsterType
        
        // Horizontal chain check
        var horzLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && monsters[i, row]?.monsterType == monsterType {
            i -= 1
            horzLength += 1
        }
        
        // Right
        i = column + 1
        while i < NumColumns && monsters[i, row]?.monsterType == monsterType {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 { return true }
        
        // Vertical chain check
        var vertLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && monsters[column, i]?.monsterType == monsterType {
            i -= 1
            vertLength += 1
        }
        
        // Up
        i = row + 1
        while i < NumRows && monsters[column, i]?.monsterType == monsterType {
            i += 1
            vertLength += 1
        }
        return vertLength >= 3
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for row in 0..<NumRows {
            var column = 0
            while column < NumColumns-2 {
                if let monster = monsters[column, row] {
                    let matchType = monster.monsterType
                    
                    if monsters[column + 1, row]?.monsterType == matchType &&
                        monsters[column + 2, row]?.monsterType == matchType {
                        
                        let chain = Chain(chainType: .horizontal)
                        repeat {
                            chain.add(monster: monsters[column, row]!)
                            column += 1
                        } while column < NumColumns && monsters[column, row]?.monsterType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                
                column += 1
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            var row = 0
            while row < NumRows-2 {
                if let monster = monsters[column, row] {
                    let matchType = monster.monsterType
                    
                    if monsters[column, row + 1]?.monsterType == matchType &&
                        monsters[column, row + 2]?.monsterType == matchType {
                        let chain = Chain(chainType: .vertical)
                        repeat {
                            chain.add(monster: monsters[column, row]!)
                            row += 1
                        } while row < NumRows && monsters[column, row]?.monsterType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeMonsters(chains: horizontalChains)
        removeMonsters(chains: verticalChains)
        
        calculateScores(for: horizontalChains)
        calculateScores(for: verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    private func removeMonsters(chains: Set<Chain>) {
        for chain in chains {
            for monster in chain.monsters {
                monsters[monster.column, monster.row] = nil
            }
        }
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let monster = monsters[column, row] {
                    // Is it possible to swap this monster with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a monster in this spot? If there is no tile, there is no monster.
                        if let other = monsters[column + 1, row] {
                            // Swap them
                            monsters[column, row] = other
                            monsters[column + 1, row] = monster
                            
                            // Is either monster now part of a chain?
                            if hasChainAt(column: column + 1, row: row) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(monsterA: monster, monsterB: other))
                            }
                            
                            // Swap them back
                            monsters[column, row] = monster
                            monsters[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = monsters[column, row + 1] {
                            monsters[column, row] = other
                            monsters[column, row + 1] = monster
                            
                            // Is either monster now part of a chain?
                            if hasChainAt(column: column, row: row + 1) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(monsterA: monster, monsterB: other))
                            }
                            
                            // Swap them back
                            monsters[column, row] = monster
                            monsters[column, row + 1] = other
                        }
                    }
                }
            }
        }
        possibleSwaps = set
    }
    
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func performSwap(swap: Swap) {
        let columnA = swap.monsterA.column
        let rowA = swap.monsterA.row
        let columnB = swap.monsterB.column
        let rowB = swap.monsterB.row
        monsters[columnA, rowA] = swap.monsterB
        swap.monsterB.column = columnA
        swap.monsterB.row = rowA
        
        monsters[columnB, rowB] = swap.monsterA
        swap.monsterA.column = columnB
        swap.monsterA.row = rowB
    }
    
    func fillHoles() -> [[Monster]] {
        var columns = [[Monster]]()
        
        for column in 0..<NumColumns {
            var array = [Monster]()
            for row in 0..<NumRows {
                if tiles[column, row] != nil && monsters[column, row] == nil {
                    for lookup in (row + 1)..<NumRows {
                        if let monster = monsters[column, lookup] {
                            monsters[column, lookup] = nil
                            monsters[column, row] = monster
                            monster.row = row
                            array.append(monster)
                            break
                        }
                    }
                }
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpMonsters() -> [[Monster]] {
        var columns = [[Monster]]()
        var monsterType: MonsterType = .unknown
        
        for column in 0..<NumColumns {
            var array = [Monster]()
            var row = NumRows - 1
            
            while row >= 0 && monsters[column, row] == nil {
                if tiles[column, row] != nil {
                    var newMonsterType: MonsterType
                    repeat {
                        newMonsterType = MonsterType.random()
                    } while newMonsterType == monsterType
                    monsterType = newMonsterType
                    
                    let monster = Monster(column: column, row: row, monsterType: monsterType)
                    monsters[column, row] = monster
                    array.append(monster)
                }
                
                row -= 1
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
}
