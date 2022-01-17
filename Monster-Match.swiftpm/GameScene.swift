//
//  GameScene.swift
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
import AVFoundation

// Global scaling values
let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
let scaleFactor = deviceIdiom == .phone ? 0.52 : 1.0
let fontSize = deviceIdiom == .phone ? 24.0 : 32.0
let mapFontSize = deviceIdiom == .phone ? 8.0 : 10.0

class GameScene: SKScene {
    var defaults = UserDefaults.standard
    var level: Level!
    var movesLeft = 0
    var score = 0
    var currentLevelNum = 0
    var tapGestureRecognizer: UITapGestureRecognizer!
    var targetDesc: SKLabelNode!
    var targetLabel: SKLabelNode!
    var movesDesc: SKLabelNode!
    var movesLabel: SKLabelNode!
    var scoreDesc: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var shuffleButton: SKNode!
    var backgroundPanel: SKSpriteNode!
    var levelMap: LevelMap!
    var gameOverPanel:SKSpriteNode!
    var levelCompletePanel:SKSpriteNode!
    var selectionSprite = SKSpriteNode()
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    var swipeHandler: ((Swap) -> ())?
    
    lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    let TileWidth: CGFloat = 60.0 * scaleFactor
    let TileHeight: CGFloat = 60.0 * scaleFactor
    let gameLayer = SKNode()
    let monstersLayer = SKNode()
    let tilesLayer = SKNode()
    let cropLayer = SKCropNode()
    let maskLayer = SKNode()
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingMonsterSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addMonsterSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        currentLevelNum = defaults.object(forKey: "CurrentLevelNum") as? Int ?? 0
        
        self.backgroundColor = UIColor.black
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        backgroundPanel = SKSpriteNode(imageNamed: "Background")
        backgroundPanel.size = size
        addChild(backgroundPanel)
        
        createUIElements()
        
        gameLayer.isHidden = true
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        levelMap = LevelMap(scene: self)
        
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cropLayer)
        
        maskLayer.position = layerPosition
        cropLayer.maskNode = maskLayer
        
        monstersLayer.position = layerPosition
        cropLayer.addChild(monstersLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
        let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupLevel(levelNum: currentLevelNum)
        backgroundMusic?.play()
    }
    
    func createUIElements(){
        targetDesc = SKLabelNode(fontNamed: "GillSans-Bold")
        targetDesc.text = "Target:"
        targetDesc.fontColor = UIColor.purple
        targetDesc.fontSize = fontSize
        targetDesc.horizontalAlignmentMode = .center
        targetDesc.position = CGPoint(
            x: tilesLayer.position.x - 200 * scaleFactor, 
            y: tilesLayer.position.y + 365 * scaleFactor)
        targetDesc.zPosition = 1
        addChild(targetDesc)
        
        targetLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        targetLabel.text = "999999"
        targetLabel.fontColor = UIColor.lightGray
        targetLabel.fontSize = fontSize
        targetLabel.horizontalAlignmentMode = .center
        targetLabel.position = CGPoint(
            x: tilesLayer.position.x - 200 * scaleFactor,
            y: tilesLayer.position.y + 315 * scaleFactor)
        targetLabel.zPosition = 1
        addChild(targetLabel)
        
        movesDesc = SKLabelNode(fontNamed: "GillSans-Bold")
        movesDesc.text = "Moves:"
        movesDesc.fontColor = UIColor.purple
        movesDesc.fontSize = fontSize
        movesDesc.horizontalAlignmentMode = .center
        movesDesc.position = CGPoint(
            x: tilesLayer.position.x * scaleFactor, 
            y: tilesLayer.position.y + 365 * scaleFactor)
        movesDesc.zPosition = 1
        addChild(movesDesc)
        
        movesLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        movesLabel.text = "999999"
        movesLabel.fontColor = UIColor.lightGray
        movesLabel.fontSize = fontSize
        movesLabel.horizontalAlignmentMode = .center
        movesLabel.position = CGPoint(
            x: tilesLayer.position.x * scaleFactor,
            y: tilesLayer.position.y + 315 * scaleFactor)
        movesLabel.zPosition = 1
        addChild(movesLabel)
        
        scoreDesc = SKLabelNode(fontNamed: "GillSans-Bold")
        scoreDesc.text = "Score:"
        scoreDesc.fontColor = UIColor.purple
        scoreDesc.fontSize = fontSize
        scoreDesc.horizontalAlignmentMode = .center
        scoreDesc.position = CGPoint(
            x: tilesLayer.position.x + 200 * scaleFactor, 
            y: tilesLayer.position.y + 365 * scaleFactor)
        scoreDesc.zPosition = 1
        addChild(scoreDesc)
        
        scoreLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        scoreLabel.text = "999999"
        scoreLabel.fontColor = UIColor.lightGray
        scoreLabel.fontSize = fontSize
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(
            x: tilesLayer.position.x + 200 * scaleFactor,
            y: tilesLayer.position.y + 315 * scaleFactor)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        shuffleButton = SKSpriteNode(imageNamed: "Shuffle")
        shuffleButton.position = CGPoint(
            x: tilesLayer.position.x * scaleFactor,
            y: tilesLayer.position.y - 390 * scaleFactor)
        shuffleButton.xScale = scaleFactor
        shuffleButton.yScale = scaleFactor
        self.addChild(shuffleButton)
        
        gameOverPanel = SKSpriteNode(imageNamed: "Game-Over")
        gameOverPanel.xScale = scaleFactor
        gameOverPanel.yScale = scaleFactor
        addChild(gameOverPanel)
        
        levelCompletePanel = SKSpriteNode(imageNamed: "Level-Complete")
        levelCompletePanel.xScale = scaleFactor
        levelCompletePanel.yScale = scaleFactor
        addChild(levelCompletePanel)
    }
    
    func showLabels() {
        targetDesc.isHidden = false
        targetLabel.isHidden = false
        movesDesc.isHidden = false
        movesLabel.isHidden = false
        scoreDesc.isHidden = false
        scoreLabel.isHidden = false
    }
    
    func hideLabels() {
        targetDesc.isHidden = true
        targetLabel.isHidden = true
        movesDesc.isHidden = true
        movesLabel.isHidden = true
        scoreDesc.isHidden = true
        scoreLabel.isHidden = true
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func setupLevel(levelNum: Int) {
        self.view?.isMultipleTouchEnabled = false
        self.level = Level(filename: "Level_\(levelNum)")
        self.addTiles()
        self.swipeHandler = handleSwipe
        
        levelMap.hideMap()
        gameOverPanel.isHidden = true
        levelCompletePanel.isHidden = true
        shuffleButton.isHidden = true
        
        beginGame()
    }
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        self.animateBeginGame() { self.shuffleButton.isHidden = false }
        shuffle()
    }
    
    func showGameOver() {
        gameOverPanel.isHidden = false
        self.isUserInteractionEnabled = false
        shuffleButton.isHidden = true
        
        self.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            super.view?.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @objc func hideGameOver() {
        self.view?.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.isHidden = true
        self.scene?.isUserInteractionEnabled = true
        
        setupLevel(levelNum: currentLevelNum)
    }
    
    func showLevelComplete() {
        levelCompletePanel.isHidden = false
        self.isUserInteractionEnabled = false
        shuffleButton.isHidden = true
        
        self.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideLevelComplete))
            super.view?.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @objc func hideLevelComplete() {
        self.view?.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        defaults.set(currentLevelNum, forKey: "CurrentLevelNum")
        
        levelCompletePanel.isHidden = true
        levelMap.showMap()
        self.scene?.isUserInteractionEnabled = true
        
        showGameMap()
    }
    
    func showGameMap() {
        backgroundPanel.isHidden = true
        levelMap.showMap()
        levelMap.showMarkers()
        levelCompletePanel.isHidden = true
        self.isUserInteractionEnabled = true
        shuffleButton.isHidden = true
        hideLabels()
        
        self.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameMap))
            super.view?.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @objc func hideGameMap() {
        self.view?.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        levelMap.removeMarkers()
        
        levelCompletePanel.isHidden = true
        backgroundPanel.isHidden = false
        showLabels()
        self.scene?.isUserInteractionEnabled = true
        
        setupLevel(levelNum: currentLevelNum)
    }
    
    func shuffle() {
        self.removeAllMonsterSprites()
        let newMonsters = level.shuffle()
        self.addSprites(for: newMonsters)
        // skip Level to debug level map ////////////////////
        //score = 1500
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        self.animateMatchedMonsters(for: chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.animateFallingMonsters(columns: columns) {
                let columns = self.level.topUpMonsters()
                self.animateNewMonsters(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        decrementMoves()
        self.view?.isUserInteractionEnabled = true
    }
    
    func handleSwipe(_ swap: Swap) {
        self.view?.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap: swap)
            self.animate(swap, completion: handleMatches)
        } else {
            self.animateInvalidSwap(swap) {
                self.view?.isUserInteractionEnabled = true
            }
        }
    }
    
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        
        if score >= level.targetScore {
            currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum + 1 : 1
            levelMap.setGamelLevel(currLevel: currentLevelNum) 
            showLevelComplete()
        } else if movesLeft == 0 {
            showGameOver()
        }
    }

    func addSprites(for monsters: Set<Monster>) {
        for monster in monsters {
            let sprite = SKSpriteNode(imageNamed: monster.monsterType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: monster.column, row: monster.row)
            monstersLayer.addChild(sprite)
            monster.sprite = sprite
            
            // Give each cookie sprite a small, random delay. Then fade them in.
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                    ])
                ]))
        }
    }
    
    func addTiles() {
        tilesLayer.removeAllChildren()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointFor(column: column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        for row in 0...NumRows {
            for column in 0...NumColumns {
                let topLeft     = (column > 0) && (row < NumRows)
                && level.tileAt(column: column - 1, row: row) != nil
                let bottomLeft  = (column > 0) && (row > 0)
                && level.tileAt(column: column - 1, row: row - 1) != nil
                let topRight    = (column < NumColumns) && (row < NumRows)
                && level.tileAt(column: column, row: row) != nil
                let bottomRight = (column < NumColumns) && (row > 0)
                && level.tileAt(column: column, row: row - 1) != nil
                
                // The tiles are named from 0 to 15, according to the bitmask that is
                // made by combining these four values.
                let tleft = Int(topLeft ? 1 : 0)
                let tright = Int(topRight ? 1 : 0)
                let bleft = Int(bottomLeft ? 1 : 0)
                let bright = Int(bottomRight ? 1 : 0)
                let value = tleft | tright << 1 | bleft << 2 | bright << 3
                
                // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
                if value != 0 && value != 6 && value != 9 {
                    let name = String(format: "Tile_%ld", value)
                    let tileNode = SKSpriteNode(imageNamed: name)
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    var point = pointFor(column: column, row: row)
                    point.x -= TileWidth/2
                    point.y -= TileHeight/2
                    tileNode.position = point
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func removeAllMonsterSprites() {
        monstersLayer.removeAllChildren()
    }
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func showSelectionIndicatorForMonster(monster: Monster) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = monster.sprite {
            let texture = SKTexture(imageNamed: monster.monsterType.highlightedSpriteName)
            selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
            selectionSprite.run(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: monstersLayer)
        let (success, column, row) = convertPoint(point: location)
        
        if success {
            if let monster = level.monsterAt(column: column, row: row) {
                swipeFromColumn = column
                swipeFromRow = row
                showSelectionIndicatorForMonster(monster: monster)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard swipeFromColumn != nil else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: monstersLayer)
        
        let (success, column, row) = convertPoint(point: location)
        if success {
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            if horzDelta != 0 || vertDelta != 0 {
                trySwap(horizontal: horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Loop over all the touches in this event
        for touch in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            // Check if the location of the touch is within the button's bounds
            if shuffleButton.contains(location) {
                shuffle()
                decrementMoves()
            } else {
                if selectionSprite.parent != nil && swipeFromColumn != nil {
                    hideSelectionIndicator()
                }
                swipeFromColumn = nil
                swipeFromRow = nil
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func trySwap(horizontal horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        
        if let toPokemon = level.monsterAt(column: toColumn, row: toRow),
           let fromPokemon = level.monsterAt(column: swipeFromColumn!, row: swipeFromRow!) {
            
            if let handler = swipeHandler {
                let swap = Swap(monsterA: fromPokemon, monsterB: toPokemon)
                handler(swap)
            }
        }
    }
    
    func animateScore(for chain: Chain) {
        let firstSprite = chain.firstMonster().sprite!
        let lastSprite = chain.lastMonster().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 24
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        monstersLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    func animate(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.monsterA.sprite!
        let spriteB = swap.monsterB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        run(swapSound)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.monsterA.sprite!
        let spriteB = swap.monsterB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        run(invalidSwapSound)
    }
    
    func animateMatchedMonsters(for chains: Set<Chain>, completion: @escaping () -> ()) {
        for chain in chains {
            animateScore(for: chain)
            for monster in chain.monsters {
                if let sprite = monster.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                   withKey:"removing")
                    }
                }
            }
        }
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingMonsters(columns: [[Monster]], completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (idx, windup) in array.enumerated() {
                let newPosition = pointFor(column: windup.column, row: windup.row)
                let delay = 0.05 + 0.15*TimeInterval(idx)
                let sprite = windup.sprite!   // sprite always exists at this point
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction, fallingMonsterSound])]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateNewMonsters(_ columns: [[Monster]], completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        
        for array in columns {
            let startRow = array[0].row + 1
            
            for (idx, monster) in array.enumerated() {
                let sprite = SKSpriteNode(imageNamed: monster.monsterType.spriteName)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                sprite.position = pointFor(column: monster.column, row: startRow)
                monstersLayer.addChild(sprite)
                monster.sprite = sprite
                
                let delay = 0.1 + 0.2 * TimeInterval(array.count - idx - 1)
                let duration = TimeInterval(startRow - monster.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                let newPosition = pointFor(column: monster.column, row: monster.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.05),
                            moveAction,
                            addMonsterSound])
                    ]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateGameOver(_ completion: @escaping () -> ()) {
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: completion)
    }
    
    func animateBeginGame(_ completion: @escaping () -> ()) {
        gameLayer.isHidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: completion)
    }
}
